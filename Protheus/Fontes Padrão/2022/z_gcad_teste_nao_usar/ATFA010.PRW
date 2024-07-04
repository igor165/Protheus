#INCLUDE "Protheus.ch"
#INCLUDE "ATFA010.CH" 
#Include "ApWizard.ch"   

#DEFINE OPC_CONVERSAO 5 

Static lA010Brow
Static lA010Brwt
Static aParamAuto := {}
// ******************************
// Controle de multiplas moedas  *
// ******************************
Static lMultMoed := FindFunction("AtfMoedas")
                                           
//Controle de AVP de Ativo
STATIC lAvpAtf := .F.
STATIC lAvpAtf2 := NIL

//Variaveis para importa玢o da Classifica玢o Cont醔il
Static __aEtapa   := {}     
Static __lExcImp  := .F.
Static __cProcPrinc := "ATFA010"

STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.)// CAZARINI - Flag to indicate if is Russia location

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噭o    ?ATFA010    ?Autor ?Claudinei M. Benzi    ?Data ?01/08/93 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噭o ?Programa de atualiza噭o de Ativos Imobilizados               潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?Gen俽ico                                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?

苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪穆哪哪哪履哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪勘?
北? DATA  ?BOPS 砅rogram.?              ALTERACAO                      潮?
北媚哪哪哪呐哪哪哪拍哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?3.06.98?     矱duardo ?Desenvolvimento do CIAP                      潮?
北?2.06.98?     矨lice   ?Incluir os STRs                              潮?
北?0.08.98?     矨lice   ?Nao gravar se os campos obrigatorios nao esti潮?
北?       ?     ?       ?res preenchidos.BOPS 17237 A                 潮?
北?2.09.98?     矨lice   ?Tratar o tipo N5_TIPO="O"                    潮?
北?9.09.98?2479A矨lice   砃ao gerar lacto na Alteracao                  潮?
北?2.12.98?     矨lice   砊ratar as opcoes de repetir ou nao a chapa    潮?
北?9.12.98?8099a矨lice   矱mitir help ("AF010CTVAZ") qdo as contas nao  潮?
北?       ?     ?       砮stiverem cadastradas e confirmar a aquisicao.潮?
北?7.04.99?     矨lice   矨lteracao na funcao af010Comp.                潮?
北?2.04.99?     矨lice   矨lteracao de macro para PROTHEUS.             潮?
北?8.10.99?     矨lice   砊ratar GetSX8Num                              潮?
北?3.11.99?     矨lice   砊ratar GetSX8Num na copia                     潮?
北?7.01.00?     矨lice   砎erificar se fim de arquivo                   潮?
北?1.09.09?     砏illiam 矨lteracao da Funcao ATFMOD3() para permitir a 潮?
北?       ?     ?       砮dicao dos campos das abas 'Saude' e 'Imoveis'潮?
北?       ?     ?       砤o alterar um bem.							  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北滥哪哪哪牧哪哪哪聊哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/

Function ATFA010(xAutoCab,xAutoItens,nOpcAuto,xParamAuto)
//Fonte descontinuado na vers鉶 12
HELP(" ",1,"CTRDES12")
Return