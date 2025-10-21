import React from 'react';

type ImageProps = {
  width: number;
  height: number;
  src: string;
  className?: string;
  alt: string;
};

export default function Image({
  width,
  height,
  src,
  className,
  alt,
}: ImageProps) {
  return (
    <img
      width={width}
      height={height}
      src={src}
      className={className}
      alt={alt}
    />
  );
}
