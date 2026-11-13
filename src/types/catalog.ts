export interface Produto {
	id: string;
	nome: string;
	codigo: string;
	preco_peca_branca: number | string;
	fotos: string[];
	tags: string[];
	destaque: boolean;
}
