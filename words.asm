SECTION "Words", ROMX, BANK[1]

words::
    db "blog", 0 ; match
    db "blow", 0 ; match
    db "blonde", 0 ; not a match
    db "blows", 0 ; match
    db "blob", 0 ; match
    db "blobby", 0 ; not a match
    db "got", 0 ; match
    db "now", 0 ; match
    db "snow", 0 ; match
    db "stole", 0 ; not a match
    db "swole", 0 ; match
    db "wont", 0 ; match
    db "yolo", 0 ; match
    db 0 ; end of input
