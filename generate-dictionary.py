max_block_size = 4096


def print_section(block):
    if block > 0:
        print("")
        print("")

    print("SECTION \"Words [{0}]\", ROMX".format(block))
    print("words_{0}:".format(block))


with open("/usr/share/dict/words") as f:
    block = 0
    block_size = 1

    print_section(block)

    for word in f:
        word = word.strip().lower()
        block_size += len(word)

        if block_size > max_block_size:
            block += 1
            block_size = 1 + len(word)

            print("    db 0")
            print_section(block)

        print("    db \"{0}\", 0".format(word))

    print("    db 0")

    print("")
    print("")

    print("SECTION \"Words Index\", ROM0")
    print("words_index::")

    for i in range(0, block):
        label = "words_{0}".format(i)
        print("    db BANK({0}), HIGH({0}), LOW({0})".format(label))

    print("    db 0")
