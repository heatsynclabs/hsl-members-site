import React from 'react';

import { CardDescription } from '../../../elements/card';
import { Link } from 'react-router';
import Image from '@elements/images/Image';

export default function CardTwo() {
  return (
    <div className="rounded-xl border border-gray-200 bg-white p-4 dark:border-gray-800 dark:bg-white/[0.03]">
      <div className="mb-5 overflow-hidden rounded-lg">
        <Image
          width={303}
          height={190}
          src="/images/cards/card-02.png"
          alt="card"
          className="w-full overflow-hidden rounded-lg"
        />
      </div>
      <div>
        <CardDescription>
          Lorem ipsum dolor sit amet, consectetur adipisicing elit. Animi
          architecto aspernatur cum et ipsum
        </CardDescription>
        <Link
          to="/"
          className="inline-flex items-center gap-2 px-4 py-3 mt-4 text-sm font-medium text-white rounded-lg bg-brand-500 shadow-theme-xs hover:bg-brand-600"
        >
          Read more
        </Link>
      </div>
    </div>
  );
}
