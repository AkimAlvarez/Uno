# Gera o uno_deck.mif (baralho completo de UNO, 108 cartas) para a RAM do dealer.
# Replica exatamente a codificacao usada na antiga 'module uno_full_deck_lut.v'.
#
# Codificacao de cada carta (10 bits): {categoria[1:0], valor[3:0], cor[3:0]}
#   categoria: 00=numero, 01=acao colorida (skip/reverse/+2), 10=coringa
#   valor    : 0..9 -> 0000..1001 ; bloqueio=1010 ; inversao=1011 ;
#              +2=1100 ; coringa muda cor=1101 ; coringa +4=1110
#   cor      : one-hot 1000=vermelho 0100=verde 0010=azul 0001=amarelo 0000=preto/coringa

DEPTH = 128
WIDTH = 10

CORES = [
    ("vermelho", 0b1000),
    ("verde",    0b0100),
    ("azul",     0b0010),
    ("amarelo",  0b0001),
]

def carta(categoria, valor, cor):
    return (categoria << 8) | (valor << 4) | cor

deck = []

# 4 blocos de cor: 25 cartas cada (red, green, blue, yellow) -> 100 cartas
for _nome, cor in CORES:
    deck.append(carta(0b00, 0, cor))            # um unico zero
    for v in range(1, 10):                       # numeros 1..9, duas vias
        deck.append(carta(0b00, v, cor))
        deck.append(carta(0b00, v, cor))
    for acao in (0b1010, 0b1011, 0b1100):        # bloqueio, inversao, +2 (duas vias)
        deck.append(carta(0b01, acao, cor))
        deck.append(carta(0b01, acao, cor))

# Coringas (8 cartas): 4x muda-cor (1101) + 4x +4 (1110), cor 0000
for _ in range(4):
    deck.append(carta(0b10, 0b1101, 0b0000))
for _ in range(4):
    deck.append(carta(0b10, 0b1110, 0b0000))

assert len(deck) == 108, f"esperava 108 cartas, gerou {len(deck)}"

with open("uno_deck.mif", "w") as f:
    f.write(f"WIDTH={WIDTH};\n")
    f.write(f"DEPTH={DEPTH};\n\n")
    f.write("ADDRESS_RADIX=UNS;\n")
    f.write("DATA_RADIX=BIN;\n\n")
    f.write("CONTENT BEGIN\n")
    for i in range(DEPTH):
        valor = deck[i] if i < len(deck) else 0   # posicoes 108..127 = vazio (0)
        f.write(f"    {i} : {valor:0{WIDTH}b};\n")
    f.write("END;\n")

print(f"uno_deck.mif gerado: {len(deck)} cartas em {DEPTH} posicoes ({WIDTH} bits).")
