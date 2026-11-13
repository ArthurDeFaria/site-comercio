export interface Produto {
	id: string;
	nome: string;
	codigo: string;
	preco_peca_branca: number | string;
	quantidade_minima: number;
	fotos: string[];
	tags: string[];
	destaque: boolean;
}
