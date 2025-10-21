import ComponentCard from '@components/common/ComponentCard';
import React from 'react';
import CustomLink from './Link';

export default function DefaultLinkExample() {
  return (
    <ComponentCard title="Colored Links">
      <div className="flex flex-col space-y-3">
        <CustomLink to="/" variant="colored" color="primary">
          Primary link
        </CustomLink>
        <CustomLink to="/" variant="colored" color="secondary">
          Secondary link
        </CustomLink>
        <CustomLink to="/" variant="colored" color="success">
          Success link
        </CustomLink>
        <CustomLink to="/" variant="colored" color="danger">
          Danger link
        </CustomLink>
        <CustomLink to="/" variant="colored" color="warning">
          Warning link
        </CustomLink>
        <CustomLink to="/" variant="colored" color="info">
          Info link
        </CustomLink>
        <CustomLink to="/" variant="colored" color="light">
          Light link
        </CustomLink>
        <CustomLink to="/" variant="colored" color="dark">
          Dark link
        </CustomLink>
      </div>
    </ComponentCard>
  );
}
