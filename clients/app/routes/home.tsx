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
        <p className="mb-1">
          You must be new here! What do you want to make? We have a workshop
          full of tools waiting to help you make awesome stuff.
        </p>
        Most popular tools (in no particular order) CNC 3D Printer, Laser
        Cutter, CNC Mill Electronics Arduino, Soldering/Rework, Scopes/Meters,
        PCB Etching Textiles Sewing Machines incl. Industrial & Regular,
        Knitting, Vinyl Cutter Wood Bandsaw, Table Saw, Miter Saw, Planer, Disc
        Sander Metal Bandsaw, Metal Lathes & Mills, MIG & TIG Welders,
        Brake/Shear/Roller Classes Taught on-demand by volunteers! Check the
        discussion list, calendar, or request a class for something you're
        interested in. Taught by people like you! Do you know how to do anything
        cool? Share it with others, just say what & when! Visiting the Lab Yes
        we're serious that you can just come down for free during open hours!
        Come with an idea of something you might like to do (or willingness to
        try something new) and, if you can, a laptop (we don't have too many
        spares.) If you need materials for your project, consider bringing them
        too; we don't have too many materials here, mostly tools. If you're
        still scared or just curious, feel free to come in during open hours for
        a tour. Best conversation starter? "Whatcha working on?" We don't bite
        :) Got kids? All ages are welcome, but there are dangerous tools in the
        back and we don't babysit so we're relying on your supervision and
        judgment. Plus, what a great experience to learn and make alongside each
        other! Volunteering We wouldn't exist without volunteer support! You
        don't need to ask permission to be a volunteer; we follow the
        "do-ocracy" approach, but if you're super excited to contribute you can
        ask "how can I help? I've got experience with ___ and ___, is that
        useful?" Our tools need love! Without someone taking charge and ensuring
        a tool stays working, it'd probably fall into disrepair and we'd
        probably end up selling it. HeatSync is "for the people, by the people"
        and if a tool doesn't get love we won't keep it around forever. If you
        want to help keep a tool maintained OR teach others how to use it,
        express interest in it or just start using it yourself! If money is a
        concern, remember you don't have to be a paying member in order to
        volunteer! Membership Start by reading the FAQ, Rules, and Policies on
        our Wiki! We have a twice-monthly "inservice day" where we quickly vote
        and then improve the lab -- we call it Hack Your Hackerspace. Tiers If
        you're not a member, you're a Non-Member or Volunteer. Associate
        ($25/mo) - mostly a monthly donation and community member (you can vote
        at HYH meetings) Basic ($50/mo) - also gets you a storage box and
        ability to vote for the Board Plus ($100/mo) - gets you a locker instead
        of a box -- thank you for your support! Ready? Just stop by during open
        hours and work on something! If you really want to give us money, you
        can also Become a Member however it is not necessary to be a member to
        come and work.
      </main>
    </>
  );
}
