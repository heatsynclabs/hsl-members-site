import ComponentCard from '~/lib/components/common/ComponentCard';
import React from 'react';
import CustomLink from './Link';

export default function ColoredCustomLinkWithUnderline() {
  return (
    <ComponentCard title="Colored CustomLinks with Underline">
      <div className="flex flex-col space-y-3">
        <CustomLink to="/" variant="underline" color="primary">
          Primary CustomLink
        </CustomLink>
        <CustomLink to="/" variant="underline" color="secondary">
          Secondary CustomLink
        </CustomLink>
        <CustomLink to="/" variant="underline" color="success">
          Success CustomLink
        </CustomLink>
        <CustomLink to="/" variant="underline" color="danger">
          Danger CustomLink
        </CustomLink>
        <CustomLink to="/" variant="underline" color="warning">
          Warning CustomLink
        </CustomLink>
        <CustomLink to="/" variant="underline" color="info">
          Info CustomLink
        </CustomLink>
        <CustomLink to="/" variant="underline" color="light">
          Light CustomLink
        </CustomLink>
        <CustomLink to="/" variant="underline" color="dark">
          Dark CustomLink
        </CustomLink>
      </div>
    </ComponentCard>
  );
}
