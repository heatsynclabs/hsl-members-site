import * as z from "zod"; 

const AUTH_TOKEN = 'OnAUJH9N2iO4veDtKQLnkUTaCPb1cUJ9BVVNisSR5ZA';

export const User = z.object({
  utf8: z.literal('✓'),
  authenticity_token: z.literal(AUTH_TOKEN),
  user: z.object({
    member_level: z.enum(['0','1','10','25','50','100']),
    payment_method: z.enum(['PayPal', 'Dwolla', 'BillPay', 'Check', 'Cash', 'Other']),
    name: z.string().max(1024),
    email: z.email(),
    email_visible: z.enum(['0', '1']),
    phone: z.string().length(10),
    phone_visible: z.enum(['0', '1']),
    postal_code: z.string(),
    twitter_url: z.url(),
    facebook_url: z.url(),
    github_url: z.url(),
    website_url: z.url(),
    emergency_name: z.string(),
    emergency_phone: z.string(),
    emergency_email: z.email(),
    current_skills: z.string(),
    desired_skills: z.string(),
    marketing_source: z.string(),
    password: z.string(),
    password_confirmation: z.string(),
    commit: z.string(),
  })
});