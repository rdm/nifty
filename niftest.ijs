require 'dir ~user/readnif.ijs ~user/writenif.ijs'

3 :0 ''
  for_file. {."1 dirtree jpath '~user/furniture/unpack/*.nif' do.
    orig=: fread file
    if. _1 -: orig do.
      smoutput file
      assert. -. _1 -: orig
    end.
    data=: parse_nif_readnif_ orig
    regen=: put_nif_writenif_ data
    if. -. regen -: orig do.
      smoutput file
      assert. regen-:orig
    end.
  end.
  i.0 0
)