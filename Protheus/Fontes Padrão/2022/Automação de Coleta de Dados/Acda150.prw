#INCLUDE "Acda150.ch" 
#include "Protheus.ch"
#Include "Folder.ch"

/*
��������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������������Ŀ��
���Fun��o    � ACDA150  � Autor � Henrique Gomes Oikawa  								 � Data � 30/03/04 ���
���������������������������������������������������������������������������������������������������Ĵ��
���Descri��o � Monitor de Embarque Simples              						 								    ���
���������������������������������������������������������������������������������������������������Ĵ��
���Uso       � Rotina de monitoramento de embarque simples sobre os itens da Nota Fiscal de Saida   ���
���       	 � OBS.: Nao utiliza controle de enderecamento/rastreabilidade/palletizacao 				 ���
����������������������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������������������
*/
Function ACDA150
PRIVATE aRotina := Menudef()

PRIVATE cCadastro := OemtoAnsi( STR0004 ) //"Monitor de Embarque Simples"

aCores := {{ "ACDA150Anl(1)", "ENABLE"      },;
				{ "ACDA150Anl(2)", "BR_AMARELO"  },;
				{ "ACDA150Anl(3)", "DISABLE"     }}
CBK->(DbSetOrder(1))
mBrowse( 6, 1, 22, 75, "SF2", , , , , , aCores, , , ,{|x|TimerBrw(x)})

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ACDA150Cs � Autor � Henrique Gomes Oikawa � Data � 30/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta dos itens embarcados             					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void ACDA150Cs()                          					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ACDA150Cs()
Local oDlgEmb
Local oFolder, aTitulos:={}, aPaginas:={}
Local lUsaCB0 := UsaCB0("01")
Local oTimer

Local aListBoxSD2 := {}
Local oListBoxSD2
Local cVarSD2

Local aListBoxDet := {}
Local oListDet
Local cVarDet

Local cStatus := RetStatusEmb()
Local cTitulo := STR0005+SF2->F2_DOC+STR0006+SF2->&(SerieNfId ('SF2',3,'F2_SERIE'))+" - ("+cStatus+")" //"Embarque - Nota Fiscal: "###" - Serie: "

// Incrementa titulos do Folder:
aadd(aTitulos,OemtoAnsi(STR0007)) //"Itens"
aadd(aPaginas,OemtoAnsi(STR0007)) //"Itens"
If lUsaCB0
	aadd(aTitulos,OemtoAnsi(STR0008)) //"Etiquetas"
	aadd(aPaginas,OemtoAnsi(STR0008)) //"Etiquetas"
Endif

DEFINE MSDIALOG oDlgEmb TITLE OemToAnsi(cTitulo) FROM 0,0 TO 530,1010 PIXEL

// Monta Folder:
oFolder:=TFolder():New(29,10,aTitulos,aPaginas,oDlgEmb,,,,.T.,.F.,492,790,)
oFolder:bSetOption := {|nAtu| AtuDetEti(aListBoxDet,oListDet,aListBoxSD2[oListBoxSD2:nAt,1],oTimer)}

@ 0,0 LISTBOX oListBoxSD2 VAR cVarSD2 FIELDS HEADER STR0009,STR0010,STR0024,STR0025,STR0026,STR0011,STR0012 SIZE 490,200 PIXEL OF oFolder:aDialogs[1] //"Produto"###"Descricao"#,"Lote"#"Sub-Lote"#"Num.Serie"#"Qtde Nota"###"Qtde Embarcada"
AtuSD2(aListBoxSD2,oListBoxSD2)

If lUsaCB0
	@  0,0  LISTBOX oListDet VAR cVarDet FIELDS HEADER STR0013,STR0014,STR0024,STR0025,STR0026,STR0015,"" SIZE 490,200 PIXEL OF oFolder:aDialogs[2] //"Etiqueta            "###"Produto  ""###Lote""### Sub-Lote"#" Num.Serie"#      "###"Quantidade"
	AtuDetEti(aListBoxDet,oListDet,aListBoxSD2[oListBoxSD2:nAt,1])
Endif

DEFINE TIMER oTimer INTERVAL 1000 ACTION If(oFolder:nOption == 1,AtuSD2(aListBoxSD2,oListBoxSD2,oTimer),AtuDetEti(aListBoxDet,oListDet,aListBoxSD2[oListBoxSD2:nAt,1],oTimer)) OF oDlgEmb
oTimer:Activate()

ACTIVATE MSDIALOG oDlgEmb CENTERED ON INIT EnchoiceBar(oDlgEmb,{||oDlgEmb:End()},{||oDlgEmb:End()})

Return


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �RetStatusEmb� Autor � Henrique Gomes Oikawa � Data � 30/03/04 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a descricao do status do embarque                	 ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Caracter                                                   	 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function RetStatusEmb()
CBK->(DbSeek(xFilial('CBK')+SF2->(F2_DOC+F2_SERIE)))
If CBK->CBK_STATUS $ " 0"
	Return(STR0016) //"Nao iniciado embarque"
ElseIf CBK->CBK_STATUS == "1"
	Return(STR0017) //"Embarque em andamento"
ElseIf CBK->CBK_STATUS == "2"
	Return(STR0018+DTOC(CBK->CBK_DTEMBQ)) //"Embarque Finalizado em "
EndIf

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AtuSD2   � Autor � Henrique Gomes Oikawa � Data � 31/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que atualiza informacoes do listbox principal (SD2) ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aListBoxSD2 -> array do listbox principal                  ���
���          � oListBoxSD2 -> objeto do listbox principal                 ���
���          � oTimer      -> objeto timer do listbox principal           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � NULO                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AtuSD2(aListBoxSD2,oListBoxSD2,oTimer)
Local  nPos

If oTimer # NIL
	oTimer:DeActivate()
EndIf

aListBoxSD2 := {}
SD2->(DbSetOrder(3))
SD2->(DbSeek(xFilial('SD2')+SF2->(F2_DOC+F2_SERIE)))
While SD2->(!Eof() .and. D2_FILIAL+D2_DOC+D2_SERIE == xFilial('SF2')+SF2->(F2_DOC+F2_SERIE))
	nPos := Ascan(aListBoxSD2,{|x| x[1]+x[3]+x[4]+x[5] == SD2->(D2_COD+D2_LOTECTL+D2_NUMLOTE+D2_NUMSERI)})
	If nPos == 0
 		aadd(aListBoxSD2,{SD2->D2_COD,Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC"),SD2->D2_LOTECTL,SD2->D2_NUMLOTE,SD2->D2_NUMSERI,SD2->D2_QUANT,0,SD2->D2_ITEM})
	Else
		aListBoxSD2[nPos,06] += SD2->D2_QUANT
	EndIf
	SD2->(DbSkip())
EndDo

CBL->(dbSetOrder(1))
CBL->(DbSeek(xFilial('CBL')+SF2->(F2_DOC+F2_SERIE)))
While CBL->(!Eof() .and. CBL_FILIAL+CBL_DOC+CBL_SERIE == xFilial('SF2')+SF2->(F2_DOC+F2_SERIE))
	nPos := Ascan(aListBoxSD2,{|x| x[1]+x[3]+x[4]+x[5] == CBL->(CBL_PROD+CBL_LOTECT+CBL_SLOTE+CBL_NUMSER)})
	If nPos > 0
		aListBoxSD2[nPos,07] += CBL->CBL_QTDEMB
	Endif
	CBL->(DbSkip())
EndDo

If Empty( aListBoxSD2 )
	AAdd( aListBoxSD2, {CriaVar("CBL_PROD"),CriaVar("B1_DESC"),CriaVar("CBL_LOTECT"),CriaVar("CBL_SLOTE"),CriaVar("CBL_NUMSER"),CriaVar("CBL_QTDEMB"),CriaVar("CBL_QTDEMB"),CriaVar("D2_ITEM") } )
EndIf

aSort( aListBoxSD2, , , { |x,y| x[8]+x[1]+x[3]+x[4]+x[5] < y[8]+y[1]+y[3]+y[4]+y[5] } )

oListBoxSD2:SetArray(aListBoxSD2)
oListBoxSD2:bLine := { || { aListBoxSD2[oListBoxSD2:nAT,1], aListBoxSD2[oListBoxSD2:nAT,2], aListBoxSD2[oListBoxSD2:nAT,3], aListBoxSD2[oListBoxSD2:nAT,4], aListBoxSD2[oListBoxSD2:nAT,5], Transform(aListBoxSD2[oListBoxSD2:nAT,6],"@E 999,999,999.99"), Transform(aListBoxSD2[oListBoxSD2:nAT,7],"@E 999,999,999.99") } }
oListBoxSD2:Refresh()

If oTimer # NIL
	oTimer:Activate()
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AtuDetEti� Autor � Henrique Gomes Oikawa � Data � 31/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza informacoes do listbox das etiquetas lidas (CBL)  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aListBoxDet -> array do listbox das etiquetas              ���
���          � oListDet -> objeto do listbox das etiquetas                ���
���          � cProduto -> codigo do produto selecionado                  ���
���          � oTimer   -> objeto timer do listbox das etiquetas       	  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � NULO                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AtuDetEti(aListBoxDet,oListDet,cProduto,oTimer)

If oTimer # NIL
	oTimer:DeActivate()
EndIf

aListBoxDet := {}
CBL->(dbSetOrder(1))
CBL->(DbSeek(xFilial('CBL')+CBK->(CBK_DOC+CBK_SERIE)))
While CBL->(!Eof() .and. CBL_FILIAL+CBL_DOC+CBL_SERIE == xFilial('CBK')+CBK->(CBK_DOC+CBK_SERIE))
	If CBL->CBL_PROD == cProduto
		aadd(aListBoxDet,{CBL->CBL_CODETI,CBL->CBL_PROD,CBL->CBL_LOTECT,CBL->CBL_SLOTE,CBL->CBL_NUMSER,CBL->CBL_QTDEMB,""})
	Endif
	CBL->(DbSkip())
EndDo

If Empty( aListBoxDet )
	aadd(aListBoxDet,{CriaVar("CBL_CODETI"),CriaVar("CBL_PROD"),CriaVar("CBL_LOTECT"),CriaVar("CBL_SLOTE"),CriaVar("CBL_NUMSER"),0,""})
EndIf

aSort( aListBoxDet, , , { |x,y| y[1] > x[1] } )

oListDet:SetArray( aListBoxDet )
oListDet:bLine := { || { aListBoxDet[oListDet:nAT,1], aListBoxDet[oListDet:nAT,2], aListBoxDet[oListDet:nAT,3], aListBoxDet[oListDet:nAT,4],aListBoxDet[oListDet:nAT,5], Transform(aListBoxDet[oListDet:nAT,6],"@E 999,999,999.99"), aListBoxDet[oListDet:nAT,7] } }
oListDet:Refresh()

If oTimer # NIL
	oTimer:Activate()
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ACDA150Anl� Autor � Henrique Gomes Oikawa � Data � 30/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Analisa a cor a ser retornada para o browse                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 1 - Nao iniciado embarque                                  ���
���			 | 2 - Embarque em andamento                                  ���
���			 | 3 - Embarque Finalizado                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ACDA150Anl(nTipo)
Local lRet := .f. 
CBK->(DbSeek(xFilial('CBK')+SF2->(F2_DOC+F2_SERIE)))
If nTipo == 1 .and. (CBK->CBK_STATUS == "0" .or. CBK->(Eof())) 	// ENABLE = "- Nao iniciado embarque"
	lRet := .t.
ElseIf nTipo == 2	 .and. CBK->CBK_STATUS == "1"	// BR_AMARELO = "- Embarque em andamento"
	lRet := .t.
ElseIf nTipo == 3 .and. CBK->CBK_STATUS == "2"	// DISABLE = "- Embarque Finalizado"
	lRet := .t.
Endif
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ACDA150Lg � Autor � Henrique Gomes Oikawa � Data � 30/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Legenda para as cores da mbrowse                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ACDA150Lg()
Local aCorDesc
aCorDesc := {	{ "ENABLE",			STR0019 	},; //"- Nao iniciado embarque"
					{ "BR_AMARELO",	STR0020 	},; //"- Embarque em andamento"
					{ "DISABLE",		STR0021  	}} //"- Embarque Finalizado"
BrwLegenda( STR0022, STR0023, aCorDesc ) //"Legenda - Embarque" //"Status"

Return( .T. )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TimerBrw  � Autor � Henrique Gomes Oikawa � Data � 30/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que cria timer no mbrowse                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cMBrowse -> form em que sera criado o timer                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TimerBrw(oMBrowse)
Local oTimer
DEFINE TIMER oTimer INTERVAL 1000 ACTION TmBrowse(GetObjBrow(),oTimer) OF oMBrowse
oTimer:Activate()
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TmBrowse � Autor � Henrique Gomes Oikawa � Data � 30/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de timer do mbrowse                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cMBrowse -> objeto mbrowse a dar refresh                   ���
���          � oTimer   -> objeto timer                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TmBrowse(oObjBrow,oTimer)
oTimer:Deactivate()
oObjBrow:Refresh()
oTimer:Activate()
Return .T.

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ACDA150Sts � Autor � Henrique Gomes Oikawa � Data � 30/03/04 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a descricao do status do embarque                	 ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Caracter                                                   	 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function ACDA150Sts(lAtuCaption)
Local cStatus := ""
Default lAtuCaption := .f.
CBK->(DbSetOrder(1))
If CBK->(DbSeek(xFilial('CBK')+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))) .AND. (CBK->(CBK_CLIENT+CBK_LOJA+DTOS(CBK_EMISSA))<>SF2->(F2_CLIENTE+F2_LOJA+DTOS(F2_EMISSAO)))
	//Se a nota gravada na tabela de Conferencia Embarque 'CBK' diferente da Nota fiscal, exclui CBK/CBL
	CBV250Del(SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
Endif
If !CBK->(DbSeek(xFilial('CBK')+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
	CBV250Grv(SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
Endif

If CBK->CBK_STATUS $ " 0"
	cStatus := STR0016   //"Nao iniciado embarque"
ElseIf CBK->CBK_STATUS == "1"
	cStatus := STR0017  //"Embarque em andamento"
ElseIf CBK->CBK_STATUS == "2"
	cStatus := STR0018+DTOC(CBK->CBK_DTEMBQ) //"Embarque Finalizado em "
EndIf

If lAtuCaption
	oDlgEmb:cCaption := STR0005+SF2->F2_DOC+STR0006+SF2->F2_SERIE+" - ("+cStatus+")" //"Embarque - Nota Fiscal: "###" - Serie: "
Endif

Return cStatus



/*/{Protheus.doc} Menudef
	(long_description)
	@type  Static Function
	@author TOTVS
	@since 24/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function MenuDef()

Local aRotMenu := { }


aRotMenu :=  {	{ STR0001  ,"AxPesqui"   	, 0, 1 },; //"Pesquisar"
				{ STR0002  ,"ACDA150Cs"	, 0, 2 },; //"Consultar"
				{ STR0003  	,"ACDA150Lg" , 0, 3 }} //"Legenda"

 
 RETURN aRotMenu



