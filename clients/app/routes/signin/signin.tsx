import React from 'react';

const signinUrl = '/users/sign_in';

export default function Signin() {
  const formElement = React.useRef(null);

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const form = formElement?.current;
    if (!form) {
      return;
    }
    const formData = new FormData(form);
    const data = Object.fromEntries(formData);
    console.log('signin', { formData, data });
    debugger;
  };
  return (
    <>
      <h2>Sign in</h2>

      <form
        id="new_user"
        className="new_user"
        accept-charset="UTF-8"
        method="post"
        action={signinUrl}
        onSubmit={handleSubmit}
        ref={formElement}
      >
        <div style={{ margin: 0, padding: 0, display: 'inline' }}>
          <input name="utf8" type="hidden" value="✓" />
          <input
            name="authenticity_token"
            type="hidden"
            value="yzOAGJFFREYHIUcMFA7v3WHTduXRgLuukozrSndO9Ks="
          />
        </div>
        <div className="field">
          <label htmlFor="user_email">Email</label>
          <input
            id="user_email"
            name="user[email]"
            size={30}
            type="email"
            value=""
          />
        </div>

        <div className="field">
          <label htmlFor="user_password">Password</label>
          <input
            id="user_password"
            name="user[password]"
            size={30}
            type="password"
          />
        </div>

        <div className="field">
          <input name="user[remember_me]" type="hidden" value="0" />
          <input
            id="user_remember_me"
            name="user[remember_me]"
            type="checkbox"
            value="1"
          />
          <label htmlFor="user_remember_me">Remember me</label>
        </div>

        <div className="field">
          <input name="commit" type="submit" value="Sign in" />
        </div>
      </form>

      <div className="flex gap-3 m-3">
        <a href="/users/sign_up" className="button">
          Sign up
        </a>

        <a href="/users/password/new" className="button">
          Forgot your password?
        </a>
      </div>
    </>
  );
}
