#INCLUDE "Acda090.ch" 
#INCLUDE "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณACDA090   บ Autor ณ Anderson Rodrigues บ Data ณ  11/07/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณManutencao do Cadastro de ProdutoxEndereco (Modelo2)        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAACD                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Function ACDA090

Private aRotina
Private cCadastro

cCadastro := STR0001 //"Amarracao Produto x Endereco"
aRotina := Menudef()

CBJ->(DbSetOrder(2))
mBrowse(6,1,22,75,"CBJ")
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAnalisa   บ Autor ณ Anderson Rodrigues บ Data ณ  11/07/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAnalisa a Opcao escolhida no ARotina e executa a rotina de  บฑฑ
ฑฑบ          ณacordo com a Opcao(Visualizar/Incluir/Alterar/Excluir)      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAACD                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Analisa(nOpcx)
Local lRetorno
Local aSX3Area
Local aTela
Local aCGD
Local nRecno := CBJ->(Recno())
Local nI	 := 0

Local aSize     := {}
Local aInfo     := {}
Local aObjects  := {}
Local aObj      := {}
Local aHeadAUX	:= {}


Private nUsado,nPosItem,nPosArm,nPosEnd,nPosDesc,PosDel,nQtdAcols,nLaco
Private cProduto,cDescProd,cArmazem,cEndereco,cDescEnd,cItem,cTitulo,cLinhaOk,cTudoOk
Private aHeader,Acols,aDeletados,aCabec,aRodape,aAreaDados
Private lInclui := .f.
Private lAltera := .f.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta aHeader para a Tabela ProdutoxEndereco (CBJ)     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeadAUX	:= aClone(APBuildHeader("CBJ"))
nUsado := 0
aHeader:= {}
For nI := 1 to Len(aHeadAUX)
	If !AllTrim(aHeadAUX[nI,2]) $ "CBJ_FILIAL/CBJ_CODPRO"  
		nUsado := nUsado + 1
		Aadd (aHeader,aHeadAUX[nI])
	EndIf
Next nI 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Guarda as posicoes dos campos no aHeader                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPosItem := aScan(aHeader,{|x| Alltrim(x[2]) == "CBJ_ITEM"})
nPosArm  := aScan(aHeader,{|x| Alltrim(x[2]) == "CBJ_ARMAZ"})
nPosEnd  := aScan(aHeader,{|x| Alltrim(x[2]) == "CBJ_ENDERE"})
nPosDesc := aScan(aHeader,{|x| Alltrim(x[2]) == "CBJ_DESCEN"})
nPosDel  := Len(aHeader)+1


If nOpcx == 3
	aHeadAUX	:= aClone(APBuildHeader("CBJ"))
	aCols := Array(1,nUsado+1)
	nUsado := 0
	For nI := 1 to Len(aHeadAUX)
		If !AllTrim(aHeadAUX[nI,2]) $ "CBJ_FILIAL/CBJ_CODPRO"  
			nUsado := nUsado + 1
			If AllTrim(aHeadAUX[nI,2]) $ "CBJ_ITEM" .AND. aHeadAUX[nI,8] == "C"
				aCols[1,nUsado] := "01"
			ElseIf aHeadAUX[nI,8] == "C"
				aCols[1,nUsado] := SPACE(aHeadAUX[nI,4])
			ElseIf aHeadAUX[nI,8] == "N"
				aCols[1,nUsado] := 0
			ElseIf aHeadAUX[nI,8] == "D"
				aCols[1,nUsado] := CtoD("  /  /  ")
			ElseIf aHeadAUX[nI,8] == "M"
				aCols[1,nUsado] := ""
			Else
				aCols[1,nUsado] := .F.
			EndIf
		EndIf
	Next nI
	aCols[1,nUsado+1] := .F.
Else
	aCols := {}
	aALT  := {}
	CBJ->(DbSetOrder(2))
	cCodProd := CBJ->CBJ_CODPRO
	cDescProd:= Posicione('SB1',1,xFilial("SB1")+cCodProd,"B1_DESC")
	If	CBJ->(DbSeek(xFilial("CBJ")+cCodProd))
		cCodProd  := CBJ->CBJ_CODPRO
		cDescProd := Posicione('SB1',1,xFilial("SB1")+cCodProd,"B1_DESC")
		cItem     := CBJ->CBJ_ITEM
		cArmazem  := CBJ->CBJ_ARMAZ
		cEndereco := CBJ->CBJ_ENDERE
		cDescEnd  := Posicione('SBE',1,xFilial("SBE")+CBJ->CBJ_ARMAZ+CBJ->CBJ_ENDERE,"BE_DESCRIC")
		While CBJ->(!Eof() .And. CBJ_FILIAL == xFilial() .And. CBJ_CODPRO == cCodProd)
			aAdd(aCols,Array(Len(aHeader) + 1))
			nQtdeAcols := Len(aCols)
			
			For nI := 1 To Len(aHeader)
				If aHeader[nI,2] != "CBJ_DESCEN"
					aCols[nQtdeAcols,nI] := &(CBJ->(aHeader[nI,2]))
				Else
					aCols[nQtdeAcols,nI] := Posicione('SBE',1,xFilial("SBE")+CBJ->CBJ_ARMAZ+CBJ->CBJ_ENDERE,"BE_DESCRIC")
				EndIf
			Next
			
			aCols[nQtdeAcols,nPosDel ]:= .F.
			aAdd(aAlt,{CBJ->CBJ_ARMAZ})
			
			CBJ->(DbSetOrder(2))
			CBJ->(DbSkip())
		EndDo
	EndIf
	If	Len(aCols) == 0
		MsgBox(STR0007,STR0008) //"Nao ha nenhum dado selecionado"###"Cadastro ProdutoxEndereco"
		Return
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis do Cabecalho do Modelo 2                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If	nOpcx == 3
	cCodProd  := SPACE(Tamsx3("B1_COD")[1])
	cDescProd := SPACE(40)
	CBJ->(Dbsetorder(1))
	CBJ->(Dbseek(xFilial("CBJ")+cCodProd,.T.))
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Titulo da Janela              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTitulo := STR0008 //"Cadastro ProdutoxEndereco"

Do Case
	Case nOpcx == 2
		cTitulo += " - " + Upper(STR0003) // "Cadastro ProdutoxEndereco - Visualizar"
	Case nOpcx == 3
		cTitulo += " - " + Upper(STR0004) // "Cadastro ProdutoxEndereco - Incluir"	
	Case nOpcx == 4
		cTitulo += " - " + Upper(STR0005) // "Cadastro ProdutoxEndereco - Alterar"
	Case nOpcx == 5
		cTitulo += " - " + Upper(STR0006) // "Cadastro ProdutoxEndereco - Excluir"		
End Case

aCabec  := {}
lInclui := nOpcx==3
lAltera := nOpcx==4

AAdd(aCabec,{"cCodProd", {20,20},STR0009,"@!" ,"NaoVazio() .AND. EXISTCPO('SB1') .AND. DescProd(cCodProd)","SB1",lInclui}) //"Codigo do Produto"
AAdd(aCabec,{"cDescProd",{40,20},STR0010,"@!" ,"NaoVazio()",,.F.}) //"Descricao do Prod"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Array com coordenadas da GetDados no modelo2       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSize   := MsAdvSize()
aAdd(aObjects, {100,  80, .T., .F.})
aAdd(aObjects, {100, 360, .T., .T.})
aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
aPosObj := MsObjSize(aInfo, aObjects)
aRodape := {}
aCGD    := {aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]}
aTela   := {aSize[7],0,aSize[6],aSize[5]}

cTudoOk := "AllwaysTrue()"
cLinhaOk:= "CB090LOK()"

lRetorno := Modelo2(cTitulo,aCabec,aRodaPe,aCGD,nOpcx,cLinhaOk,cTudoOk,,,"+CBJ_ITEM",999,aTela)
If	lRetorno .And. nOpcx == 3
	IncArq()
ElseIf lRetorno .And. nOpcx == 4
	AltArq()
ElseIf lRetorno .And. nOpcx == 5
	ExcArq()
EndIf

SysRefresh()
CBJ->(DbSetOrder(2))
CBJ->(DbGoto(nRecno))
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDescProd  บ Autor ณ Anderson Rodrigues บ Data ณ  11/07/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValida o Produto informado e Preenche a Descricao do mesmo  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAACD                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function DescProd(cCodProd)
Local lRet := .T.
CBJ->(DbSetOrder(1))
If	CBJ->(DbSeek(xFilial("CBJ")+cCodProd))
	HELP(" ",1,"JAGRAVADO")
	lRet := .F.
Else
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+cCodProd))
	cDescProd := SB1->B1_DESC
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CB090DEnd บ Autor ณ Flavio Luiz Vicco บ Data ณ  24/08/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValida o Endereco informado e Preenche a Descricao do mesmo บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAACD                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function CB090DEnd()
Local lRet := .T.
SBE->(DbSetOrder(1))
If	SBE->(DbSeek(xFilial("SBE")+aCols[n,nPosArm]+M->CBJ_ENDERE))
	aCols[n,nPosDesc] := SBE->BE_DESCRIC
Else
	HELP(" ",1,"REGNOIS")
	lRet := .F.
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCB090LOK  บ Autor ณ Anderson Rodrigues บ Data ณ  11/07/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValida a Linha do Acols                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAACD                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function CB090LOK()
Local lRet := .T.
Local nPos := 0
nPos := aScan(acols,{|x| x[2] == aCols[n,nPosArm] .and. x[3] == aCols[n,nPosEnd]})
If	nPos # 0 .And. nPos # n
	If !aCols[n,nPosDel]
		MSGBOX(STR0011,STR0012,"OK") //"Armazem + Endereco ja informados"###"Aviso"
		lRet := .f.
	EndIf
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIncArq    บ Autor ณ Anderson Rodrigues บ Data ณ  11/07/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณInclusao do aCols no Arquivo CBJ                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAACD                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function IncArq()
Local nLaco := 0
Local nItem := 0
For nLaco := 1 to Len(aCols)
	If aCols[nLaco,nPosDel] == .T.
		Loop
	EndIf

	RecLock("CBJ",.T.)
	CBJ->CBJ_FILIAL := xFilial("CBJ")
	CBJ->CBJ_CODPRO := cCodProd
	For nItem := 1 To Len(aHeader)
		&(CBJ->(aHeader[nItem,2])) := aCols[nLaco,nItem]
	Next
	CBJ->(MsUnLock())
Next
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAltArq    บ Autor ณ Anderson Rodrigues บ Data ณ  11/07/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAlteracao do aCols no Arquivo CBJ                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAACD                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function AltArq()
ExcArq()
IncArq()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExcArq    บ Autor ณ Anderson Rodrigues บ Data ณ  11/07/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณExclusao do aCols no Arquivo CBJ                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAACD                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ExcArq()
Local nLaco := 0
CBJ->(DbSetOrder(1))
For nLaco := 1 to Len(aCols)
	If CBJ->(DbSeek(xFilial("CBJ")+cCodProd))
		RecLock("CBJ",.F.)
		CBJ->(DbDelete())
		CBJ->(MsUnLock())
	EndIf
Next
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMTA010PXE บ Autor ณ Aecio Ferreira Gomes บ Data ณ  23/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณVerifica se existe o produto na tabela CBJ                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA010(Cadastro de produtos)                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function MTA010PXE(cProduto)

Local lRet := .F.

DbSelectArea("CBJ")
DbSetOrder(1)
If DbSeek(xFilial("CBJ")+cProduto)
			PutHelp ("PM010ACDPXE",{"Produto nใo poderแ ser excluํdo. "},;
								   {"Producto no puede ser borrado.   "},;
								   {"Product cannot be deleted.       "},;
								   .F.)
									
			PutHelp ("SM010ACDPXE",{"Verificar o cadastro de "," ProdutoxEndere็o do ACD.     "},;
								   {"Verificar el registro de "," ProductoxDirecci๓n del ACD. "},;
						     	   {"Check the registration of ProductxAddress the ACD.       "},;
						     	   .F.)
								
			Help(" ",1,"M010ACDPXE")
	lRet := .T.
EndIf
Return lRet




 /*/{Protheus.doc} Menudef
	(long_description)
	@type  Static Function
	@author TOTVS
	@since 21/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function MenuDef()

Local aRotMenu := { }


aRotMenu :=  {	{STR0002,"AxPesqui",     0, 1 },; //"Pesquisar"
				{STR0003,"Analisa(2)", 0, 2 },; //"Visualizar"
				{STR0004,"Analisa(3)", 0, 3 },; //"Incluir"
				{STR0005,"Analisa(4)", 0, 4 },; //"Alterar"
				{STR0006,"Analisa(5)", 0, 5 } } //"Excluir"

 
 RETURN aRotMenu
