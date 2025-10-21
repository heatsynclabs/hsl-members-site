import React from 'react';
import type { Route } from './+types/resources';

export function meta({}: Route.MetaArgs) {
  return [
    { title: "Resources - HSL portal" },
    { name: "description", content: "Tools and Resources of HeatSync Labs Member Portal" },
  ];
}

export default function resources() {
  return (
    <div>
      poop on these resources
    </div>
  );
}