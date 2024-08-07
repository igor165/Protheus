#INCLUDE "TMKA280D.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk280TLC04�Autor  �Armando M. Tessaroli� Data �  16/05/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Painel que demonstra os titulo que venceram apos a ultima ne���
���          �gociacao.                                                   ���
�������������������������������������������������������������������������͹��
���Parametros�oExplorer - Objeto que contem os paineis com os dados do    ���
���          �            pre-atendimento.                                ���
���          �nPanel    - Nupero do painel corrente.                      ���
���          �aPanels   - Todos objetos de todos paineis.                 ���
�������������������������������������������������������������������������͹��
���Uso       � TMKA280                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Tk280TLC04(oExplorer, nPanel, aPanels)

// Definicao de variaveis de manipulacao
Local nRow		:= Int((oExplorer:aPanel[nPanel]:nHeight * .97) / 2)
Local nCol		:= Int((oExplorer:aPanel[nPanel]:nWidth * .985) / 2)
Local aHeadNew	:= {}
Local aColsNew	:= {}
Local aRodape	:= Array(12,2)

// Definicao de variaveis para objetos
Local oFonte
Local oSay1
Local oSay2
Local oPanel

DEFINE FONT oFonte NAME "Arial" SIZE 0,14 BOLD

//������������������
//�Parte 01 da tela�
//������������������
@ (nRow*.010), (nCol*.010) TO (nRow*.60), nCol OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.015), (nCol*.020) SAY oSay1 PROMPT STR0001 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// " T�tulos Vencidos Ap�s a �ltima Negocia��o"
oSay1:lTransparent := .F.
oSay1:nHeight := 14
oSay1:nWidth  := (Len(STR0001) * 6.2) //" T�tulos Vencidos Ap�s a �ltima Negocia��o"

// Atualiza os itens do atendimento - .T. monta a getdados em branco
Tk280SK1(@aHeadNew,@aColsNew,aRodape,,,.T.)

// Cria o objeto que contara os atendimentos agendados.
Aadd( aPanels, { MsNewGetDados():New((nRow*.05),(nCol*.02),(nRow*.58), (nCol*.98),0,,,,,,4096,,,,oExplorer:GetPanel(nPanel),aHeadNew,aColsNew), "DOBJ01", .F.} )


//������������������
//�Parte 02 da tela�
//������������������
@ (nRow*.620), (nCol*.010) TO nRow, nCol OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.625), (nCol*.020) SAY oSay2 PROMPT STR0002 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// " Totais da Negocia��o"
oSay2:lTransparent := .F.
oSay2:nHeight := 14
oSay2:nWidth  := (Len(STR0002) * 6.2) //" Totais da Negocia��o"


@ (nRow*.67), (nCol*.02) MSPanel oPanel Size (nCol*.96), (nRow*.3) Of oExplorer:GetPanel(nPanel) Centered Lowered
oPanel:oFont := oExplorer:GetPanel(nPanel):oFont

nRow := oPanel:nHeight/2
nCol := oPanel:nWidth/2

@ (nRow*.08),(nCol*.02) SAY STR0003 OF oPanel PIXEL //"Abatimentos"
@ (nRow*.08),(nCol*.14) MSGET aRodape[1][1] VAR aRodape[1][2] Picture "@E 999,999,999.99" OF oPanel PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.30),(nCol*.02) SAY STR0004 OF oPanel PIXEL //"Corr. Monet."
@ (nRow*.30),(nCol*.14) MSGET aRodape[2][1] VAR aRodape[2][2] Picture "@E 999,999,999.99" OF oPanel PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.52),(nCol*.02) SAY STR0005 OF oPanel PIXEL //"Juros"
@ (nRow*.52),(nCol*.14) MSGET aRodape[3][1] VAR aRodape[3][2] Picture "@E 999,999,999.99" OF oPanel PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.74),(nCol*.02) SAY STR0006 OF oPanel PIXEL //"Descontos"
@ (nRow*.74),(nCol*.14) MSGET aRodape[6][1] VAR aRodape[6][2] Picture "@E 999,999,999.99" OF oPanel PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)


@ (nRow*.08),(nCol*.36) SAY STR0007 OF oPanel PIXEL //"Acr�scimos"
@ (nRow*.08),(nCol*.48) MSGET aRodape[4][1] VAR aRodape[4][2] Picture "@E 999,999,999.99" OF oPanel PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.30),(nCol*.36) SAY STR0008 OF oPanel PIXEL //"Decr�scimos"
@ (nRow*.30),(nCol*.48) MSGET aRodape[5][1] VAR aRodape[5][2] Picture "@E 999,999,999.99" OF oPanel PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.52),(nCol*.36) SAY STR0009 OF oPanel PIXEL //"Sld Mda Tit."
@ (nRow*.52),(nCol*.48) MSGET aRodape[8][1] VAR aRodape[8][2] Picture "@E 999,999,999.99" OF oPanel PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.74),(nCol*.36) SAY STR0010 OF oPanel PIXEL //"Sld Mda Corr."
@ (nRow*.74),(nCol*.48) MSGET aRodape[9][1] VAR aRodape[9][2] Picture "@E 999,999,999.99" OF oPanel PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)


@ (nRow*.08),(nCol*.70) SAY STR0011 OF oPanel PIXEL //"Valor Original"
@ (nRow*.08),(nCol*.82) MSGET aRodape[7][1] VAR aRodape[7][2] Picture "@E 999,999,999.99" OF oPanel PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.30),(nCol*.70) SAY STR0012 OF oPanel PIXEL //"Pagto Parcial"
@ (nRow*.30),(nCol*.82) MSGET aRodape[10][1] VAR aRodape[10][2] Picture "@E 999,999,999.99" OF oPanel PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.52),(nCol*.70) SAY STR0013 OF oPanel PIXEL COLOR CLR_RED //"D�v Mda T�t"
@ (nRow*.52),(nCol*.82) MSGET aRodape[11][1] VAR aRodape[11][2] Picture "@E 999,999,999.99" OF oPanel PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12) COLOR CLR_RED

@ (nRow*.74),(nCol*.70) SAY STR0014 OF oPanel PIXEL COLOR CLR_RED //"D�v Mda Corr"
@ (nRow*.74),(nCol*.82) MSGET aRodape[12][1] VAR aRodape[12][2] Picture "@E 999,999,999.99" OF oPanel PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12) COLOR CLR_RED

Aadd( aPanels, { aRodape, "DOBJ02" } )

Return(.T.)
