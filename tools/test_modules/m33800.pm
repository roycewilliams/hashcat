#!/usr/bin/env perl

##
## Author......: See docs/credits.txt
## License.....: MIT
##

use strict;
use warnings;

use Crypt::Eksblowfish::Bcrypt qw (bcrypt en_base64);
use MIME::Base64               qw (decode_base64);

sub module_constraints { [[0, 72], [16, 16], [-1, -1], [-1, -1], [-1, -1]] }

sub module_generate_hash
{
  my $word = shift;
  my $salt = shift;
  my $iter = shift;

  my $cost = "05";

  if (length ($iter))
  {
    $cost = $iter;
  }

  my $hash = bcrypt ($word, sprintf ('$2a$%s$%s$', $cost, en_base64 ($salt)));

  my $hash2 = bcrypt ($hash, sprintf ('$2a$%s$%s$', $cost, en_base64 ($salt)));

  return $hash2;
}

sub module_verify_hash
{
  my $line = shift;

  my $index1 = index ($line, ":", 33);

  return if $index1 < 1;

  my $hash = substr ($line, 0, $index1);
  my $word = substr ($line, $index1 + 1);

  my $index2 = index ($hash, "\$", 4);

  my $iter = substr ($hash, 4, $index2 - 4);

  my $plain_base64 = substr ($hash, $index2 + 1, 22);

  # base64 mapping

  my $base64   = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  my $itoa64_2 = "./ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

  my $encoded = "";

  for (my $i = 0; $i < length ($plain_base64); $i++)
  {
    my $char = substr ($plain_base64, $i, 1);

    $encoded .= substr ($base64, index ($itoa64_2, $char), 1);
  }

  my $salt = decode_base64 ($encoded);

  my $word_packed = pack_if_HEX_notation ($word);

  my $new_hash = module_generate_hash ($word_packed, $salt, $iter);

  return ($new_hash, $word);
}

1;
