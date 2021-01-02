SECTION "Words", ROMX, BANK[1]

words::
    db "blog", 0 ; matches
    db "blow", 0 ; matches
    db "blonde", 0 ; not a match
    db "blows", 0 ; matches
    db "blob", 0 ; matches
    db "blobby", 0 ; not a match
    db "got", 0 ; matches
    db "now", 0 ; matches
    db "snow", 0 ; matches
    db "stole", 0 ; not a match
    db "swole", 0 ; matches
    db 0 ; end of input
