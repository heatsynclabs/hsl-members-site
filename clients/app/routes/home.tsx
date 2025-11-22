import type { Route } from './+types/home';
import Button from '@elements/button/Button';
import { ChevronDownIcon } from '@icons';

export function meta({}: Route.MetaArgs) {
  return [
    { title: 'HSL portal' },
    { name: 'description', content: 'HeatSync Labs Member Portal' },
  ];
}

export default function Home() {
  return (
    <>
      <main className="h-screen">
        <h1 className="text-3xl">Welcome to the HeatSync Labs Members App</h1>
        <Button className="bg-green-100 to-green-700 fill-green-800">
          Click me
          <ChevronDownIcon className="h-10 w-10 stroke-white"></ChevronDownIcon>
        </Button>

        <div className="container-fluid" id="content">
          <div className="row">
            <h1>Welcome to the HeatSync Labs Members App.</h1>

            <p>
              <strong>You must be new here!</strong>&nbsp;What do you want to
              make? We have a workshop full of tools waiting to help you make
              awesome stuff.
            </p>
            <ul>
              <li>
                Most popular tools (in no particular order)
                <ul>
                  <li>
                    CNC
                    <ul>
                      <li>
                        3D Printer, Laser Cutter,&nbsp;<span>CNC Mill</span>
                      </li>
                    </ul>
                  </li>
                  <li>
                    <span>Electronics</span>
                    <ul>
                      <li>
                        <span>
                          Arduino, Soldering/Rework, Scopes/Meters, PCB Etching
                        </span>
                      </li>
                    </ul>
                  </li>
                  <li>
                    Textiles
                    <ul>
                      <li>
                        Sewing Machines incl.&nbsp;
                        <span>Industrial &amp; Regular</span>, Knitting, Vinyl
                        Cutter
                      </li>
                    </ul>
                  </li>
                  <li>
                    Wood&nbsp;
                    <ul>
                      <li>
                        Bandsaw, Table Saw, Miter Saw, Planer, Disc Sander
                      </li>
                    </ul>
                  </li>
                  <li>
                    Metal&nbsp;
                    <ul>
                      <li>
                        Bandsaw, Metal Lathes &amp; Mills, MIG &amp; TIG
                        Welders, Brake/Shear/Roller
                      </li>
                    </ul>
                  </li>
                </ul>
              </li>
              <li>
                Classes
                <ul>
                  <li>
                    Taught on-demand by volunteers! Check the discussion list,
                    calendar, or request a class for something you're interested
                    in.
                  </li>
                  <li>
                    Taught by people like you! Do you know how to do anything
                    cool? Share it with others, just say what &amp; when!
                  </li>
                </ul>
              </li>
              <li>
                Visiting the Lab
                <ul>
                  <li>
                    <strong>
                      Yes we're serious that you can just come down for free
                      during open hours!
                    </strong>{' '}
                    Come with an idea of something you might like to do (or
                    willingness to try something new) and, if you can, a laptop
                    (we don't have too many spares.) If you need materials for
                    your project, consider bringing them too; we don't have too
                    many materials here, mostly tools.
                  </li>
                  <li>
                    If you're still scared or just curious, feel free to come in
                    during open hours for a tour. Best conversation starter?
                    "Whatcha working on?" We don't bite :)
                  </li>
                  <li>
                    Got kids? All ages are welcome, but there are dangerous
                    tools in the back and we don't babysit so we're relying on
                    your supervision and judgment. Plus, what a great experience
                    to learn and make alongside each other!
                  </li>
                </ul>
              </li>
              <li>
                Volunteering
                <ul>
                  <li>
                    We wouldn't exist without volunteer support!{' '}
                    <strong>
                      You don't need to ask permission to be a volunteer;
                    </strong>{' '}
                    we follow the "
                    <a href="http://www.communitywiki.org/DoOcracy">
                      do-ocracy
                    </a>
                    " approach, but if you're super excited to contribute you
                    can ask "how can I help? I've got experience with ___ and
                    ___, is that useful?"
                  </li>
                  <li>
                    Our tools need love! Without someone taking charge and
                    ensuring a tool stays working, it'd probably fall into
                    disrepair and we'd probably end up selling it. HeatSync is
                    "for the people, by the people" and if a tool doesn't get
                    love we won't keep it around forever. If you want to help
                    keep a tool maintained OR teach others how to use it,
                    express interest in it or just start using it yourself!
                  </li>
                  <li>
                    If money is a concern, remember you don't have to be a
                    paying member in order to volunteer!
                  </li>
                </ul>
              </li>
              <li>
                Membership
                <ul>
                  <li>
                    <a href="http://wiki.heatsynclabs.org/">
                      Start by reading the FAQ, Rules, and Policies on our Wiki!
                    </a>
                  </li>
                  <li>
                    We have a twice-monthly "inservice day" where we quickly
                    vote and then improve the lab -- we call it Hack Your
                    Hackerspace.
                  </li>
                  <li>
                    Tiers
                    <ul>
                      <li>
                        If you're not a member, you're a Non-Member or
                        Volunteer.
                      </li>
                      <li>
                        Associate ($25/mo) - mostly a monthly donation and
                        community member (you can vote at HYH meetings)
                      </li>
                      <li>
                        Basic ($50/mo) - also gets you a storage box and ability
                        to vote for the Board
                      </li>
                      <li>
                        Plus ($100/mo) - gets you a locker instead of a box --
                        thank you for your support!
                      </li>
                    </ul>
                  </li>
                  <li>
                    Ready? Just stop by during open hours and work on something!
                    If you really want to give us money, you can also&nbsp;
                    <a href="/users/sign_up">Become a Member</a>&nbsp;
                    <strong>
                      however it is not necessary to be a member to come and
                      work.
                    </strong>
                  </li>
                </ul>
              </li>
            </ul>

            <div className="col-sm-4"></div>

            <div className="col-sm-4">
              <h2>Member Resources</h2>
              <p> </p>
              <ul>
                <br />{' '}
                <li>
                  <a href="http://wiki.heatsynclabs.org" target="_blank">
                    Check our Wiki for answers to your questions
                  </a>
                  !
                </li>{' '}
                <li>
                  Our{' '}
                  <a href="http://groups.google.com/group/heatsynclabs" target="_blank">
                    Discussion Group
                  </a>{' '}
                  is the main way to interact with the community outside of the
                  lab.
                </li>
                <li>
                  Also find us on: Facebook, Twitter, and IRC (#heatsynclabs on
                  irc.freenode.net)
                </li>
                <li>
                  We need volunteers! If you can spend a few hours a week
                  helping out, please ask "how can I help?"
                </li>{' '}
              </ul>
            </div>

            <span className="col-sm-4">
              <h3>Featured tool:</h3>
              <div className="resource">
                <div className="thumbnail">
                  <a href="/resources/168">
                    <img
                      alt="Thumb"
                      src="https://s3.amazonaws.com/Toolshare/pictures/168/thumb.jpg?1310526779"
                    />
                    <h4>Oscilloscope module</h4>
                  </a>{' '}
                </div>
              </div>
            </span>
          </div>
        </div>
      </main>
    </>
  );
}
