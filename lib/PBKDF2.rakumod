#!/usr/bin/env raku
unit module PBKDF2;

proto pbkdf2(
  $,
  :$salt,
  :&prf,
  UInt :$c,
  UInt :$dkLen
) returns blob8 is export {*}

multi pbkdf2(Str $password, :&prf, :$salt, :$c, :$dkLen) {
  samewith $password.encode, :&prf, :$salt, :$c, :$dkLen
}
multi pbkdf2(blob8 $password, :&prf, Str :$salt, :$c, :$dkLen) {
  samewith $password, :&prf, :salt($salt.encode), :$c, :$dkLen
}

multi pbkdf2(blob8 $key, :&prf, blob8 :$salt, :$c, :$dkLen) {
  LEAVE $*ERR.printf("\n");
  my $dgst-length = &prf("foo".encode, "bar".encode).elems;
  my $l = ($dkLen + $dgst-length - 1) div $dgst-length;
  ([~] do for 1..$l -> $i {
    reduce { blob8.new: $^a.list »+^« $^b.list }, (
      $salt ~ blob8.new((24, 16, 8, 0).map($i +> * +& 0xff)),
      {
	$*ERR.printf("\rPBKFD2: bloc %d/%d, iteration %d/%d", $i, $l, ++$, $c);
	prf($_, $key)
      } ... *
    )[1..$c];
  }).subbuf(0,$dkLen) 
}
  
