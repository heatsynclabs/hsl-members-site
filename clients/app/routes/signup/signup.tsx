import React from 'react';

const signupUrl = '/users';
const billingAddress = '140 W Main St, Mesa AZ 85201';
const paymentInstructionsContent = {
  PayPal:
    'Set up a monthly recurring payment to hslfinances@gmail.com or via the button on the next page.',
  Dwolla:
    'Set up a monthly recurring payment to hslfinances@gmail.com or via the button on the next page.',
  BillPay:
    'Have your bank send a monthly check to HeatSync Labs Treasurer, {billingAddress}'.replace(
      '{billingAddress}',
      billingAddress
    ),
  Check:
    'Mail to HeatSync Labs Treasurer, {billingAddress} OR put in the drop safe at the Lab with a deposit slip firmly attached each month.'.replace(
      '{billingAddress}',
      billingAddress
    ),
  Cash: 'Put in the drop safe at the Lab with a deposit slip firmly attached each month.',
  Other: 'Hmm... talk to a Treasurer!',
};
const getInstructionContent = (paymentInstructions: string) => {
  // @ts-ignore
  return paymentInstructionsContent[paymentInstructions] || '';
};

export default function Signup() {
  const [paymentInstructions, setPaymentInstructions] = React.useState('');

  const formElement = React.useRef(null);

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const form = formElement?.current;
    if (!form) {
      return;
    }
    const formData = new FormData(form);
    const data = Object.fromEntries(formData);
    console.log('signup', { formData, data });
  };

  return (
    <>
      <h2>Membership Application</h2>

      <form
        id="new_user"
        className="new_user"
        accept-charset="UTF-8"
        method="post"
        action={signupUrl}
        onSubmit={handleSubmit}
        ref={formElement}
      >
        <div style={{ margin: 0, padding: 0, display: 'inline' }}>
          <input name="utf8" type="hidden" value="✓" />
          <input
            name="authenticity_token"
            type="hidden"
            value="OnAUJH9N2iO4veDtKQLnkUTaCPb1cUJ9BVVNisSR5ZA="
          />
        </div>
        <i>
          <label htmlFor="user_public_notice">
            * denoted fields will be published to our public mailing list
          </label>
        </i>

        <div className="field">
          <label htmlFor="user_member_level">Membership Level</label>

          <select id="user_member_level" name="user[member_level]">
            <option value=""></option>
            <option value="0">None</option>
            <option value="1">Unable</option>
            <option value="10">Volunteer</option>
            <option value="25">Associate ($25)</option>
            <option value="50">Basic ($50)</option>
            <option value="100">Plus ($100)</option>
          </select>
        </div>

        <div className="field">
          <label htmlFor="user_payment_method">Payment method</label>

          <select
            id="user_payment_method"
            name="user[payment_method]"
            onChange={(event) =>
              setPaymentInstructions(event.target.value || '')
            }
          >
            <option value=""></option>
            <option value="PayPal">PayPal</option>
            <option value="Dwolla">Dwolla</option>
            <option value="BillPay">Bill Pay</option>
            <option value="Check">Check</option>
            <option value="Cash">Cash</option>
            <option value="Other">Other</option>
          </select>

          <span className="payment_instructions">
            {getInstructionContent(paymentInstructions)}
          </span>
        </div>

        <div className="field">
          <label htmlFor="user_name">Full Name *</label>

          <input
            id="user_name"
            name="user[name]"
            size={30}
            type="text"
            required
          />
        </div>

        <div className="field">
          <label htmlFor="user_email">Email</label>

          <input id="user_email" name="user[email]" size={30} type="email" />
          <input name="user[email_visible]" type="hidden" value="0" />
          <input
            id="user_email_visible"
            name="user[email_visible]"
            type="checkbox"
            value="1"
          />
          <label htmlFor="user_email_visible">Show Email to All Members?</label>
        </div>

        <div className="field">
          <label htmlFor="user_phone">Phone</label>

          <input id="user_phone" name="user[phone]" size={30} type="text" />
          <input name="user[phone_visible]" type="hidden" value="0" />
          <input
            id="user_phone_visible"
            name="user[phone_visible]"
            type="checkbox"
            value="1"
          />
          <label htmlFor="user_phone_visible">Show Phone to All Members?</label>
        </div>

        <div className="field">
          <label htmlFor="user_postal_code">Residential Postal Code</label>
          <input
            id="user_postal_code"
            name="user[postal_code]"
            size={30}
            type="text"
          />
          (we'd like to know where you're commuting from!)
        </div>

        <div className="field">
          <label htmlFor="user_twitter_url">Twitter url</label>
          <input
            id="user_twitter_url"
            name="user[twitter_url]"
            placeholder="https://twitter.com/heatsynclabs"
            size={30}
            type="text"
          />

          <label htmlFor="user_facebook_url">Facebook url</label>
          <input
            id="user_facebook_url"
            name="user[facebook_url]"
            placeholder="https://www.facebook.com/HeatSyncLabs"
            size={30}
            type="text"
          />

          <label htmlFor="user_github_url">Github url</label>
          <input
            id="user_github_url"
            name="user[github_url]"
            placeholder="https://github.com/heatsynclabs"
            size={30}
            type="text"
          />

          <label htmlFor="user_website_url">Website url</label>
          <input
            id="user_website_url"
            name="user[website_url]"
            placeholder="http://www.heatsynclabs.org"
            size={30}
            type="text"
          />
        </div>

        <div className="field">
          <label htmlFor="user_emergency_name">Emergency Contact Name</label>

          <input
            id="user_emergency_name"
            name="user[emergency_name]"
            size={30}
            type="text"
          />
        </div>
        <div className="field">
          <label htmlFor="user_emergency_phone">Emergency phone</label>

          <input
            id="user_emergency_phone"
            name="user[emergency_phone]"
            size={30}
            type="text"
          />
        </div>
        <div className="field">
          <label htmlFor="user_emergency_email">Emergency email</label>

          <input
            id="user_emergency_email"
            name="user[emergency_email]"
            size={30}
            type="text"
          />
        </div>
        <div className="field">
          <label htmlFor="user_current_skills">
            What skills, knowledge and experience do you bring to the community?
            *
          </label>

          <textarea
            required
            cols={40}
            id="user_current_skills"
            name="user[current_skills]"
            rows={20}
          ></textarea>
        </div>
        <div className="field">
          <label htmlFor="user_desired_skills">
            What skills, knowledge and experiences are you looking for in
            HeatSync? *
          </label>

          <textarea
            required
            cols={40}
            id="user_desired_skills"
            name="user[desired_skills]"
            rows={20}
          ></textarea>
        </div>

        <div className="field">
          <label htmlFor="user_marketing_source">
            How'd you find out about HeatSync? *
          </label>

          <textarea
            required
            cols={40}
            id="user_marketing_source"
            name="user[marketing_source]"
            rows={20}
          ></textarea>
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
          <label htmlFor="user_password_confirmation">
            Password confirmation
          </label>

          <input
            id="user_password_confirmation"
            name="user[password_confirmation]"
            size={30}
            type="password"
          />
        </div>

        <div className="field">
          <input name="commit" type="submit" value="Sign Up" />
        </div>
      </form>

      <div className="flex gap-3 m-3">
        <a href="/users/sign_in" className="button">
          Sign in
        </a>

        <a href="/users/password/new" className="button">
          Forgot your password?
        </a>
      </div>
    </>
  );
}
