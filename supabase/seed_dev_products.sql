-- Development-only catalog seed. Replace these fictional prices before production migration.
insert into public.produtos (
    nome,
    codigo,
    preco_peca_branca,
    fotos,
    tags,
    ativo,
    destaque
)
values
    (
        'Caneca 24 Branca 260ml',
        'caneca-260ml-branca',
        18.90,
        array['24-caneca-260ml/24-caneca-260ml-branca.png', '24-caneca-260ml/caneca-260ml-personalizada-5cores.jpeg'],
        array['Canecas', 'Personalização sob consulta', 'Caixas de 24'],
        true,
        false
    ),
    (
        'Caneca 31 Branca 120ml',
        'caneca-120ml-branca',
        12.90,
        array['31-caneca-120ml/31-caneca-120ml-branca.jpeg', 'caneca-120ml-branca/caneca-120ml-2cores-branca.jpeg'],
        array['Canecas', 'Personalização sob consulta', 'Caixas de 12 ou 24 brancas'],
        true,
        false
    ),
    (
        'Prato Raso G Coup Branco 28,5cm',
        'prato-coup-g-raso-285cm-branco',
        24.90,
        array['coup-g-prato-raso-28,5cm/coup-g-prato-raso-285cm.png'],
        array['Pratos', 'Personalização sob consulta', 'Caixas de 4, 8 ou 12'],
        true,
        false
    ),
    (
        'Prato Raso Capri 26cm Branco',
        'prato-capri-raso-26cm-branco',
        22.90,
        array['capri-prato-raso-26cm/capri-prato-raso-26cm.png'],
        array['Pratos', 'Personalização sob consulta', 'Caixas de 4, 8 ou 12'],
        true,
        false
    ),
    (
        'Caneca Branca 120ml 2 Cores',
        'caneca-120ml-2cores-branca',
        13.90,
        array['caneca-120ml-branca/caneca-120ml-2cores-branca.jpeg'],
        array['Canecas', 'Personalização sob consulta', 'A partir de 300 peças'],
        true,
        true
    ),
    (
        'Caneca Branca 200ml 1 e 2 Cores',
        'caneca-branca-200ml-1e2cores',
        15.90,
        array['caneca-branca-200ml/caneca-branca-200ml-1e2cores.jpeg'],
        array['Canecas', 'Personalização sob consulta', 'A partir de 200 peças'],
        true,
        true
    ),
    (
        'Caneca Colorida 2 Cores 200ml',
        'caneca-colorida-200ml-2cores',
        19.90,
        array['caneca-colorida-200ml/caneca-colorida-200ml-2cores.jpeg'],
        array['Canecas', 'Personalização sob consulta', 'A partir de 200 peças'],
        true,
        true
    ),
    (
        'Caneca Branca 220ml até 7 Cores',
        'caneca-branca-220ml-ate7cores',
        16.90,
        array['caneca-220ml-branca/caneca-220ml-branca-personalizada-ate7cores.jpeg'],
        array['Canecas', 'Personalização sob consulta', 'Caixas de 24'],
        true,
        true
    ),
    (
        'Xícara de Café Colorida 80ml',
        'xicara-cafe-colorida-80ml',
        14.90,
        array['xicara-cafe-colorida-80ml/xicara-cafe-80ml-colorida.jpeg'],
        array['Xícaras', 'Personalização sob consulta', 'Caixas de 24 peças'],
        true,
        false
    ),
    (
        'Xícara de Café com Pires 70ml',
        'xicara-cafe-com-pires-70ml',
        21.90,
        array['xicara-cafe-com-pires-70ml/xicara-cafe-com-pires-70ml-personalizada-e-filete-em-ouro.jpeg'],
        array['Xícaras', 'Personalização sob consulta', 'Caixas de 24 peças'],
        true,
        false
    )
on conflict (codigo) do update
set
    nome = excluded.nome,
    preco_peca_branca = excluded.preco_peca_branca,
    fotos = excluded.fotos,
    tags = excluded.tags,
    ativo = excluded.ativo,
    destaque = excluded.destaque;
