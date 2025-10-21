import React from 'react';
import { Link } from 'react-router';

type LinkProps = {
  to: string;
  children: React.ReactNode;
  variant?: 'default' | 'colored' | 'underline' | 'opacity' | 'opacityHover';
  color?:
    | 'primary'
    | 'secondary'
    | 'success'
    | 'danger'
    | 'warning'
    | 'info'
    | 'light'
    | 'dark';
  opacity?: 10 | 25 | 50 | 75 | 100;
  className?: string;
};

const CustomLink: React.FC<LinkProps> = ({
  to,
  children,
  variant = 'default',
  color = 'primary',
  opacity = 100,
  className = '',
  ...props
}) => {
  const baseClasses = 'text-sm font-normal transition-colors';

  const colorClasses = {
    primary: 'text-gray-500 dark:text-gray-400',
    secondary: 'text-brand-500 dark:text-brand-500',
    success: 'text-success-500',
    danger: 'text-error-500',
    warning: 'text-warning-500',
    info: 'text-blue-light-500',
    light: 'text-gray-400',
    dark: 'text-gray-800 dark:text-white/90',
  };

  const variantClasses = {
    default: '',
    colored: colorClasses[color],
    underline: `${colorClasses[color]} underline`,
    opacity: `text-gray-500/${opacity} dark:text-gray-400/${opacity}`,
    opacityHover: `text-gray-500 hover:text-gray-500/${opacity} dark:hover:text-gray-400/${opacity}`,
  };

  const classes = `${baseClasses} ${variantClasses[variant]} ${className}`;

  return (
    <Link to={to} className={classes} {...props}>
      {children}
    </Link>
  );
};

export default CustomLink;
