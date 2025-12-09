import React from 'react';
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import {
  AuthError,
  createClient,
  type AuthChangeEvent,
  type Session,
  type SignInWithPasswordCredentials,
  type SignUpWithPasswordCredentials,
} from '@supabase/supabase-js';

/** undefined for initial value of loading state */
const UNDEFINED = undefined;

export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY,
  { global: { fetch: fetch.bind(globalThis) } }
);

type SessionStoreState = {
  isLoading?: boolean;
  isLoggedIn: boolean;
  session: Session | null;
  setLoading: (isLoading: boolean) => void;
  signupSession: (credentials: SignUpWithPasswordCredentials) => void;
  loginSession: (credentials: SignInWithPasswordCredentials) => void;
  logoutSession: () => void;
  clearSession: () => void;
  setSessionResponse: (sessionResponse: SessionResponse) => void;
  setAuthStateChange: (event: AuthChangeEvent, session: Session | null) => void;
};

type SessionResponse = {
  data: { session: Session | null };
  error: AuthError | null;
};

export const useSessionStore = create<SessionStoreState>()(
  devtools(
    // https://github.com/reduxjs/redux-devtools/tree/main/extension#installation
    (set, get) => ({
      isLoading: UNDEFINED,
      isLoggedIn: false,
      event: null,
      session: null,
      sessionResponseError: null,
      signupSession: async (credentials: SignUpWithPasswordCredentials) => {
        get().setLoading(true);
        const {
          data: { session },
          error,
        } = await supabase.auth.signUp(credentials);
        set(
          () => ({
            event: null,
            session,
            sessionResponseError: error,
            isLoading: false,
            isLoggedIn: Boolean(session?.user?.id),
          }),
          undefined,
          'supabase/signupSession'
        );
      },
      loginSession: (credentials: SignInWithPasswordCredentials) => {
        get().setLoading(true);
        supabase.auth.signInWithPassword(credentials);
      },
      logoutSession: async () => {
        get().setLoading(true);
        await supabase.auth.signOut();
        await get().clearSession();
      },
      setLoading: (isLoading: boolean) => {
        set(() => ({ isLoading }));
      },
      setAuthStateChange: (event: AuthChangeEvent, session: Session | null) => {
        set(
          () => ({
            event,
            session,
            sessionResponseError: null,
            isLoading: false,
            isLoggedIn: Boolean(session?.user?.id),
          }),
          undefined,
          'supabase/onAuthStateChange'
        );
      },
      clearSession: () => {
        set(() => ({
          isLoading: false,
          isLoggedIn: false,
          event: null,
          session: null,
          sessionResponseError: null,
        }));
      },
      setSessionResponse: ({ data: { session }, error }: SessionResponse) => {
        set(
          () => ({
            event: null,
            session,
            sessionResponseError: error,
            isLoading: false,
            isLoggedIn: Boolean(session?.user?.id),
          }),
          undefined,
          'supabase/getSession'
        );
      },
    })
  )
);

export const useAuth = () => {
  const { setLoading, setSessionResponse, setAuthStateChange } =
    useSessionStore();

  React.useEffect(() => {
    setLoading(true);

    supabase.auth.getSession().then(setSessionResponse);

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(setAuthStateChange);

    return () => subscription.unsubscribe();
  }, []);
};
