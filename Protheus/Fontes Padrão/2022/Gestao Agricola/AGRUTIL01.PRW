#INCLUDE "AGRUTIL01.CH"
#INCLUDE "protheus.CH"
#INCLUDE "fwmvcdef.CH"
#include "fwbrowse.ch" 
#INCLUDE "DBINFO.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE "FWADAPTEREAI.CH"

#DEFINE _CRLF CHR(13)+CHR(10)
#DEFINE CRLF2 CHR(13)+CHR(10)+CHR(13)+CHR(10)

Static aTrbIndex 	:= {}  
Static __oArqTemp 	:= Nil
Static __cAliasH 	:= Nil
Static __cRet 		:= ''

/*                                                                                                 
+=================================================================================================+
| Programa  : AGRUTIL01                                                                           |
| Descrição : Programa que contém as funções de uso genérico                                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/06/2014                                                                          | 
+=================================================================================================+                                                                           |  
| OBSERVAÇÃO: As funções que serão incluídas esse fonte deverão serem funcionais e conter todas as|  
|             informações para a sua funcionalidade                                               |  
+=================================================================================================+  
*/
// INÍCIO DA DEFINIÇÃO DAS FUNÇÕES
// TRATAMENTO CHAMADA DE FUNÇÃO GENÉRICA
/*                                                                                                 
+=================================================================================================+
| Função    : AGRFUNGE                                                                            |
| Descrição : Programa que Chamada uma função Genérica                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 19/05/2015                                                                          | 
+=================================================================================================+ 
*/
Function AGRFUNGE()
	Local cNomeF := Space(50),cParams := Space(200),nOpc := 0

	DEFINE MSDIALOG oDlg FROM 50,40 To 285,541 TITLE OemToAnsi(STR0028) Of oMainWnd Pixel
	@5,4   Say OemToAnsi(STR0203) SIZE 45 ,9 Of oDlg Pixel  							  										 	
	@5,50  MSGET cNomeF  			 SIZE 55 ,9 Of oDlg Pixel Valid NAOVAZIO(cNomeF).And. AGRFUNCRPO(cNomeF)	Picture "@!" 	 

	@20,4  Say OemToAnsi(STR0204) SIZE 45 ,9 Of oDlg Pixel  
	@20,50 MSGET cParams				 SIZE 200,9 Of oDlg Pixel			  														  	 	Picture "@S150!"	

	DEFINE SBUTTON FROM 105,125 TYPE 1 ENABLE OF oDlg ACTION (nOpc := 1,oDlg:End())
	DEFINE SBUTTON FROM 105,160 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTERED				

	If nOpc == 1
		cFunc := &(Alltrim(cNomeF)+'('+Alltrim(cParams)+')')
	Endif
Return

// TRATAMENTO VALIDAÇÕES GENÉRICAS
/*
+=================================================================================================+
| Função    : AGRVLSTRNUME                                                                        |
| Descrição : Consistência de um valor em caracter para numérico ( 99.999,99.. 9999,99.. 999)     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 22/05/2016                                                                          |
+=================================================================================================+                                                                           |  
|Referências:                                                                                     |
+=================================================================================================+ 
*/
Function AGRVLSTRNUME(cStrVal,ndeci,lMens)
	Local cMens 	 := "",lMostra := If(lMens = Nil,.f.,lMens),nx
	Local nPosP   := At(".",cStrVal),nPosV := At(",",cStrVal)
	Local cString	 := StrTran(cStrVal,".","")
	cString := StrTran(cString,",","")

	For nx := 1 To Len(cString) 
		If !IsDigit(SubStr(cString,nx,1)) 
			cMens := STR0205+" "+SubStr(cString,nx,1) 
			Exit	
		EndIf 		
	Next nx

	If ndeci = Nil
		If nPosP > 0 .Or. nPosV > 0
			cMens := STR0206
		EndIf
	EndIf

	If Empty(cMens) .And. ndeci <> Nil
		aQTDVir := Separa(cStrVal,',')
		If SubStr(right(cStrVal,ndeci+1),1,1) <> "," .Or. Len(aQTDVir) <> 2 .Or. Len(aQTDVir[Len(aQTDVir)]) <> ndeci
			cMens :=STR0207
		EndIf
	EndIf

	If Empty(cMens) .And. nPosP > 0
		cString := StrTran(cStrVal,right(cStrVal,ndeci+1),"")
		aPontos := Separa(cString,'.')
		If !Empty(aPontos)
			For nx := Len(aPontos) To 1 Step -1
				If nx = 1 .And. Len(aPontos[nx]) > 3
					cMens := STR0206
					nx := 0
				ElseIf Len(aPontos[nx]) <> 3
					cMens := STR0206
					nx := 0
				EndIf
			Next nx	
		EndIf
	EndIf

	If lMostra
		Help(,,"HELP",,cMens+" -> "+Alltrim(cStrVal),1,0)
	EndIf
Return If(Empty(cMens),.t.,.f.)


/*
+=================================================================================================+
| Programa  : AGRVLDESP                                                                           |
| Descrição : Consistência ESPECIAL PARA QUALQUER TABELA                                          |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 21/06/2016                                                                          |
+=================================================================================================+ 
| Parâmetros: cAliasA  - Alias da tabela( Sem filial)                                  Obrigatório|
|             cCodigo  - Código de acesso                                              Obrigatório|
|             nIndice  - índice                                                        Não Obrigat|              
|             cCondic  - Condição especial  ( If )                                     Não Obrigat|
|             lMostra  - Indica se mostra, caso não satisfaz a condição  (Nil = .t.)   Não Obrigat| 
|             cFiliaT  - Código da filial                                              Não Obrigat|
|             lRestuA  - Indica se restaura a área ou permace na área em questão       Não Obrigat|
+=================================================================================================+     
| Retorna   : .t.,.f.                                                                             |
|=================================================================================================+
|Referências: OGA261A                                                                             |
+=================================================================================================+
*/
Function AGRVLDESP(cAliasA,cCodigo,nIndice,cCondic,lMostra,cFiliaT,lRestuA)
	Local aArea 	:= GetArea()
	Local lHelp 	:= If (lMostra = Nil,.t.,lMostra),cMens := "",lNExi := .f.
	Local nIndi 	:= If(nIndice = Nil,1,nIndice)
	Local cFili 	:= If(cFiliaT = Nil,xFilial(cAliasA),cFiliaT)
	Local lRest 	:= If(lRestuA = Nil,.t.,lRestuA)
	Local nIndS 	:= Alltrim(Str(nIndi))
	Local nPosTr := 0
	Local nPosMa := 0
	Local cCampo  
	Local cIndi

	If nIndi > 9
		nIndS := Ntoc((nIndi - 9)+64)
	EndIf	

	cIndi  := AGRSEEKDIC("SIX",cAliasA+nIndS,1,"CHAVE")
	nPosTr := At("_",cIndi)
	nPosMa := At("+",cIndi)
	If nPosTr > 0 .And. nPosMa > 0
		cIndi := Alltrim(Substr(cIndi,nPosMa+1,Len(cIndi)))
		nPosMa := At("+",cIndi)
		cCampo := If(nPosMa > 0,Substr(cIndi,1,nPosMa-1),cIndi)
	Else
		nPosMa := At("+",cIndi)
		cCampo := If(nPosMa > 0,Substr(cIndi,1,nPosMa-1),cIndi)
	Endif

	If Empty(Posicione(cAliasA,nIndi,cFili+cCodigo,cCampo))
		cMens := "REGNOIS"
		lNExi := .t.
	ElseIf !&(cCondic)
		cMens := STR0250
	EndIf

	If !Empty(cMens) .And. lHelp 
		Help(,,If(lNExi,cMens,"HELP"),,If(!lNExi,cMens,""),1,0)
	EndIf
	If lRest
		RestArea(aArea)
	EndIf	 
Return If(!Empty(cMens),.f.,.t.)

/*                                                                                                 
+=================================================================================================+
| Programa  : AGRPICTNMAIS                                                                        |
| Descrição : Busca a picture de um campo numerico no dicionório e/ou soma mais algumas posições  |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/06/2016                                                                          | 
+=================================================================================================+                                                                           |  
| Parâmetros: cCampo - Nome do campo do dicionário de dados                            Obrigatório|
|             nMaisP - Incluir mais posições                                           Não Obrigat|
+=================================================================================================+
|Referência :                                                                                     |
+=================================================================================================+                                                                           |  
| Retorna   : cPict - Picture formatada (vazio não achou no dicionário de dados ou não é numerico)|
+=================================================================================================+  
*/

// TRATAMENTO DE ARQUIVO TEMPORÁRIOS
/*
+=================================================================================================+
| Função    : AGRCRIATRB                                                                          |
| Descrição : Cria um arquivo temporário com índice(s)                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/06/2014                                                                          |
+=================================================================================================+                                                                     
| Parâmetros: cAliaE - Alias da tabela para copiar a estrutura                     Não obrigatório|
|             aField - Matriz com os campos(dicionário e/ou especiais)             Não obrigatório|  
|             vVetIn - Vetor com o(s) índice(s)                                    Obrigatório    | 
|             cFunc  - Nome da função que chamou                                   Obrigatório    |  
|             lSaiTe - Indica se ter erro mostrar mensagem de alerta               Não obrigatório|  
+=================================================================================================+  
|OBSERVAÇÕES: cStrut ou aField  deverá ser passado com parâmetros                                 |
+=================================================================================================+   
| Retorna   : Vetor de cinco posições:                                                            |
|             [1] - Ocorreu erro na montagem da estrutura  (.t.,.f.)                              |  
|             [2] - Mensagem do erro,  Se ocorreu um erro                                         |  
|             [3] - Nome do arquivo temporário e prefixo do(s) índice(s)                          |  
|             [4] - Nome do alias do arquivo temporário                                           |  
|             [5] - Matriz  Onde:  [n,1] - Nome do campo,       [n,2] - Tipo do campo             |  
|                                  [n,3] - Tamanho do campo,    [n,4] - Decimal campo             |  
|                                  [n,5] - Título do campo,     [n,6] - Picture do campo          |  
+=================================================================================================+ 
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRCRIATRB(cAliaE,aField,vVetIn,cFunc,lSaiTe)  
	Local lMenTel := If(lSaiTe = Nil,.t.,lSaiTe)
	Local nv,cNomeCa
	Local cMensa   := Space(1) 
	Local aArea    := GetArea()
	Local aStructA := {}
	Local aStructL := {}
	Local aIdx     := {}

	If cAliaE <> Nil
		DbSelectArea(cAliaE)
		aStructA := DbStruct()
		For nv := 1 To Len(aStructA) 
			cCampSX3 := aStructA[nv,1]
			cPicture := PesqPict(cAliaE,aStructA[nv,1])
			cPicture := If(Empty(cPicture),If(aStructA[nv,2] = "C","@!",If(aStructA[nv,2] = "D","99/99/9999","99999")),cPicture)
			Aadd(aStructL,{aStructA[nv,1],aStructA[nv,2],aStructA[nv,3],aStructA[nv,4],RetTitle(aStructA[nv,1]),Alltrim(cPicture)})
		Next nv
	EndIf

	If aField <> Nil .And. !Empty(aField)
		For nv := 1 To Len(aField)
			If Len(aField[nv]) = 1 
				cNomeCa  := Alltrim(aField[nv,1])+Space(10-Len(Alltrim(aField[nv,1])))
				cCampSX3 := aField[nv,1]
				If Empty(cCampSX3)
					cMensa := aField[nv,1]+STR0001+cFunc  
					Exit
				Else 
					If Ascan(aStructA,{|x| x[1] = cNomeCa}) = 0
						Aadd(aStructA,{aField[nv,1],TamSx3(aField[nv,1])[3],TamSx3(aField[nv,1])[1],TamSx3(aField[nv,1])[2]})

						Aadd(aStructL,{aField[nv,1],TamSx3(aField[nv,1])[3],TamSx3(aField[nv,1])[1],TamSx3(aField[nv,1])[2],RetTitle(aField[nv,1]),Alltrim(x3Picture(aField[nv,1]))})  
					EndIf   
				EndIf
			Else 
				If Len(aField[nv]) <> 6
					cMensa := STR0022+chr(143)+STR0003+cfunc  
					Exit
				EndIf 
				If Ascan(aStructA,{|x| x[1] = aField[nv,1]}) = 0
					Aadd(aStructA,{aField[nv,1],aField[nv,2],aField[nv,3],aField[nv,4]}) 
					Aadd(aStructL,aField[nv]) 
				EndIf   
			EndIf  
		Next nv
	EndIf

	For nv := 1 To Len(vVetIn)
		aAdd(aIdx,{"",vVetIn[nv]} )

		If nv > 15
			cMensa := STR0093
			exit
		EndIf
	Next

	If Empty(cMensa) 
		cTrbAli := GetNextAlias()
		cArqTrb := AGRCRTPTB( cTrbAli, {aStructL, aIdx} )
	EndIf   

	RestArea(aArea) 

	If lMenTel .And. !Empty(cMensa)
		MsgInfo(cMensa,STR0005)
	EndIf   
Return {If(Empty(cMensa),.t.,.f.),cMensa,cArqTrb,cTrbAli,aStructL} 

/* 
+=================================================================================================+
| Função    : AGRDELETRB                                                                          |
| Descrição : Deleta um arquivo temporário com índice(s)                                          |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/06/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliaTrb - Nome do alias do arquivo temporário                                      |  
|             cNomeTrb - Nome do arquivo temporário                                               |  
+=================================================================================================+  
| Retorna   : Nil                                                                                 |
+=================================================================================================+ 
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRDELETRB(cAliaTrb,cNomeTrb)
	Local nY, nX
	DbSelectArea(cAliaTrb)
	Use

	If ValType(cNomeTrb) == "C"
		FErase(cNomeTrb  + GetDbExtension())
		If File(cNomeTrb+".fpt")
			FErase(cNomeTrb+".fpt")
		Endif
	EndIf

	For nY := Len(aTrbIndex) To 1 Step -1
		For nX := Len(aTrbIndex[nY]) To 1 Step -1
			If aTrbIndex[nY][nX][1] == cAliaTrb
				FErase(aTrbIndex[nY,nX,2] + OrdBagExt())
				aDel(aTrbIndex[nY], nX)
				aSize(aTrbIndex[nY], nX-1)
			EndIf
		Next nX

		If Len(aTrbIndex[nY]) == 0
			aDel(aTrbIndex,nY)
			aSize(aTrbIndex, Len(aTrbIndex)-1)
		EndIf
	Next nY
Return  

/*
+=================================================================================================+
| Função    : AGRIFSEETRB                                                                         |
| Descrição : Verifica se o registro existe no arquivo temporário                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 21/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliasT  - Alias do arquivo                                              Obrigatório|
|             cChaveT  - Chave de acesso                                               Obrigatório|
|             nIndicT  - Índice de acesso                                              Não Obrigat|
|             lMostrT  - Indica se mostra mensagem                                     Nao Obrigat|
+=================================================================================================+          
| Retorna   : .T.,.F. - .T. Achou,  .F. Não achou o registro                                      |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRIFSEETRB(cAliasT,cChaveT,nIndicT,lMostrT)
	Local lRetLo := .f.,lMostT := If(lMostrT = Nil,.f.,lMostrT) 
	Local nIndiT := If(nIndicT = Nil,1,nIndicT)
	DbSelectArea(cAliasT)
	DbsetOrder(nIndiT)
	lRetLo := If(Dbseek(cChaveT),.T.,.F.)
	If !lRetLo .And. lMostT
		Help(" ",1,"NAOREGISTRO",,CHR(13) + STR0024+Chr(13)+STR0025+"....: "+cAliasT+Chr(13);
		+STR0026+"...: "+cChaveT+Chr(13)+STR0027+"...: "+Str(nIndiT,2),3,0) 
	Endif
Return lRetLo

/*
+=================================================================================================+
| Função    : AGRALTRBCAMP                                                                        |
| Descrição : Altera o conteúdo de um campo do arquivo temporário                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliasT - Alias do arquivo/tabela                                        Obrigatorio|
|             cChaveT - Chave de acesso                                                Obrigatorio|
|             nIndicT - Índice de acesso                                               Nã0 Obrigat|
|             cCampoT - Nome do campo                                                  Obrigatorio|
|             cConteT - Conteúdo                                                       Obrigatorio|
+=================================================================================================+          
| Retorna   : lRet    - (.t.,.f.)                                                                 |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRALTRBCAMP(cAliasT,cChaveT,nIndicT,cCampoT,cConteT)
	Local aAreaAt := GetArea(),lRet := .f.  
	If AGRIFSEETRB(cAliasT,cChaveT,nIndicT)
		aEstrD := DbStruct()
		If Ascan(aEstrD,{|x| x[1] == cCampoT}) > 0
			cCa1 := cAliasT+"->"+cCampoT 
			If type(cCa1) = Valtype(cConteT)
				lTipI := .t.
			ElseIf type(cCa1) = 'M' .And. Valtype(cConteT) = 'C'
				lTipI := .t.
			Endif
			If lTipI   
				If &(cCa1) <> cConteT
					RecLock(cAliasT,.f.)
					&(cCa1) := cConteT
					(cAliasT)->(MSUNLOCK())
					lRet := .t.
				Endif   
			Endif
		Endif
	Endif
	RestArea(aAreaAt)
Return lRet

/*
+=================================================================================================+
| Função    : AGRDELEREG                                                                          |
| Descrição : Deleta um determinado registro do arquivo temporário                                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 17/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliasT - Alias da Tabela                                                Não Obrigat|
|             cChaveT - Chave de acesso sem a filial                                   Não Obrigat|
|             nIndicT - Número do índice de acesso                                     Não Obrigat|
|             lPosicT - Indica se posiciona no registro antes de deletar               Não Obrigat|
+=================================================================================================+
| OBSERVAÇÃO: Se lPosicT For informado os demais parâmetro são OBRIGATÓRIOS                       |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRDELEREG(cAliasT,cChaveT,nIndicT,lPosicT)
	Local nIndiAc := If(nIndicT = Nil,1,nIndicT),lRet := .f.
	Local cAliaAT := If(cAliasT = Nil,alias(),cAliasT),lDeleta := .f.
	If cAliasT = Nil .And. cChaveT = Nil .And. nIndicT = Nil .And. lPosict = Nil
		lDeleta := .t. 
	Else
		lDeleta := AGRIFDBSEETRB(cAliaAT,cChaveT,nIndiAc,.f.)
	EndIf
	If lDeleta     
		DbselectArea(cAliaAT)
		RecLock(cAliaAT,.F.)
		DbDelete()
		(cAliaAT)->(MsUnLock())
		lRet := .t.
	EndIf   
Return lRet

/* 
+=================================================================================================+
| Função    : AGRCOPIAREG                                                                         |
| Descrição : Gera um arquivo temporário e grava dados de um registro                             |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 28/08/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlia  - Alias da tabela com os dados                                    Obrigatório|  
|             cChave - Chave de acesso (sem filial)                                    Não Obrigat|  
|             nInd   - Número do índice de acesso                                      Não Obrigat| 
+=================================================================================================+  
| Retorna   : Vetor com nome do arquivo e alias do arquivo temporário                             |
+=================================================================================================+ 
|Referências: AGRA890                                                                             |
+=================================================================================================+ 
*/
Function AGRCOPIAREG(cAlia,cChave,nInd)
	Local nIndA := If(nInd = Nil,1,nInd),lCerto := .t.
	LocaL cNomeTRI := '',cAliaTRI := '' 
	If cChave <> Nil
		If !AGRIFDBSEEK(cAlia,cChave,nIndA,.f.)
			lCerto := .f.
		EndIf	
	EndIf
	If lCerto
		DbSelectArea(cAlia)
		aEstr := Dbstruct()

		// Cria o arquivo temporário
		aRet := AGRCRIATRB(cAlia,,{aEstr[1,1]},FunName(),.t.)

		If !aRet[1] // Problema na criação dos arquivos Temporário e indicou para mostrar na função
			Return
		EndIf  

		cNomeTRI := aRet[3] //Nome do arquivo temporário 
		cAliaTRI := aRet[4] //Nome do alias do arquivo temporario
		aArqTemI := aRet[5] //Matriz com a estrutura do arquivo temporario + label e picutre

		AGRGRAVA2T(cAliaTRI,cAlia,.T.)
	EndIf	
Return {cNomeTRI,cAliaTRI}

/* 
+=================================================================================================+
| Função    : AGRCOPINREG                                                                         |
| Descrição : Cria um arquivo temporário com os dados para comparar                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 10/09/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlia   - Alias da tabela                                                Obrigatório|  
|             cChave  - Chave de acesso ao registro                                    Obrigatório|  
|             nInd    - Número do índice de acesso                                     Obrigatório| 
|             cWhile  - Dados a comparar para arquivo temporário                       Obrigatório| 
|             vVetI   - Vetor com os campos para indices para arquivo temporário       Obrigatório| 
+=================================================================================================+  
|Referências: AGRA900                                                                             |
+=================================================================================================+ 
*/
Function AGRCOPINREG(cAlia,cChave,nInd,cWhile,vVetI)
	vVetRet := AGRBUSREGIS(cAlia,cChave,nInd,.t.,.f.,cWhile,,,"A",vVetI)
Return vVetRet[2]

// TRATAMENTO DE F3
/*
+=================================================================================================+
| Função    : AGRAF3TEMP                                                                          |
| Descrição : Consulta tipo F3 em arquivo temporário                                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 05/05/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cTitulo - Titulo da consulta                                             Obrigatório|
|             cAliTRB - Alias do arquivo temporário                                    Obrigatório|
|             aArqT   - Matriz com a estrutura do arquivo temporário                   Obrigatório|
|             vVetIn  - Vetor com o(s) campo(s) para indice(s)                         Obrigatório|
|             vRetC   - Vetor com o(s) campo(s) de retorno                             Obrigatório|
+=================================================================================================+          
| Retorna   : Se o Tamanho do vetor vRetC = 1 Retorna cTemF3R - conteúdo do campo  Senão retorna  |
|                                                     vRetF3 - Vetor com os conteúdos             |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRAF3TEMP(cTitulo,cAliTRB,aArqT,vVetIn,vRetC)
	Local oSize	:= Nil,oBrowF3T := Nil,nx,nTamLi,nTamCi
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local aSeek  := AGRINDICONS(vVetIn,aArqT)
	Local aAreaA := GetArea()
	Private cRetF3,vRetF3 := {}

	If Len(vRetC) = 1
		nPosC := Ascan(aArqT,{|x| x[1] = vRetC[1]})
		If nPosC > 0
			cRetF3 := If(aArqT[nPosC,2] = "C",Space(aArqT[nPosC,3]),If(aArqT[nPosC,2] = "N",0,Ctod("  /  /    ")))
		EndIf
	EndIf

	ARGSETIFARQUI(cAliTRB)
	oSize := FWDefSize():New(.T.)
	oSize:AddObject('DLG',100,100,.T.,.T.)    
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.      
	oSize:Process()

	nTamLi := Int(oSize:aWindSize[3]/2)
	nTamCi := Int(oSize:aWindSize[4]/2)
	nTamLi -= Int(nTamLi * .20)
	nTamCi -= Int(nTamCi * .20)

	DEFINE MSDIALOG oDlgF3T FROM nTamLi,nTamCi TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL
	DEFINE FWFORMBROWSE oBrowF3T DATA TABLE ALIAS cAliTRB DESCRIPTION cTitulo OF oDlgF3T
	oBrowF3T:SetTemporary(.T.)
	oBrowF3T:SetFieldFilter(AGRITEMCBRW(aArqT))
	oBrowF3T:SetdbFFilter(.F.)
	oBrowF3T:SetUseFilter(.F.)
	oBrowF3T:DisableDetails()
	oBrowF3T:SetSeek(,aSeek)
	oBrowF3T:AddButton("Ok",{||AGRRF3TEMP(cAliTRB,vRetC)},,,,,,'10')
	oBrowF3T:SetDoubleClick({||AGRRF3TEMP(cAliTRB,vRetC)},,,,,,'10')
	For nx := 1 To Len(aArqT)
		ADD COLUMN oColumn DATA &('{||'+aArqT[nx,1]+'}') Title aArqT[nx,5] SIZE aArqT[nx,3] PICTURE aArqT[nx,6];
		Type aArqT[nx,6] Of oBrowF3T
	Next nx 
	ACTIVATE FWFORMBROWSE oBrowF3T
	ACTIVATE MSDIALOG oDlgF3T CENTER
	RestArea(aAreaA)
Return If(Len(vRetC) = 1,cRetF3,vRetF3)

/*
+=================================================================================================+
| Função    : AGRRF3TEMP                                                                          |
| Descrição : Confirmação da consulta F3 com arquivo temporário                                   |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 05/05/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlTRB - Alias do arquivo temporário                                     Obrigatório|
|             vRetR  - Vetor com o(s) campo(s) de retorno                              Obrigatório|
+=================================================================================================+          
|Referências : AGRAF3TEMP                                                                         |
+=================================================================================================+ 
*/
Function AGRRF3TEMP(cAlTRB,vVetR)
	Local ny
	If Len(vVetR) = 1
		cRetF3 := &(cAlTRB+"->"+vVetR[1])
	Else 
		For ny := 1 To Len(vVetR)
			Aadd(vRetF3,&(cAlTRB+"->"+vVetR[ny]))
		Next ny
	EndIf
	oDlgF3T:End()
Return

/*                                                                                                 
+=================================================================================================+
| Função    : AGRLISTAC                                                                           |
| Descrição : Consulta tipo lista de itens por intervalo para opção tipo perguntas                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 28/08/2015                                                                          | 
+=================================================================================================+ 
|Parâmetros : cAliasC - Alias da tabela de pesquisa                                    Obrigatório|
|             vVetCam - Vetor com os campos para a consulta                            Obrigatório|
|             cCondIf - Expressão de consistência na leitura da tabela                 Não Obrigat|
|=================================================================================================+ 
|Referências: Dicionário de dados (SX1)                                                           |
+=================================================================================================+    
*/
Function AGRLISTAC(cAliasC,vVetCam,cCondIf)
	Local nTamH 		:= (GetScreenRes()[1]-700)
	Local nTamV 		:= (GetScreenRes()[2]-500)
	Local nOpc := 0,nx,ny,cCampRet	
	Local aCamTRB		:= {{"OK","C",2,0,"Ok","@!"}}
	Local cPrefixo	:= AGRPREFIXOCAMP(cAliasC)
	Local aSelecio	:= Separa(&(readvar()),';')
	Local MvPar		:= &(Alltrim(ReadVar())) // Carrega Nome da Variavel do Get em Questao
	Local mvRet		:= Alltrim(ReadVar())    // Iguala Nome da Variavel ao Nome variavel de Retorno
	Local cMarca		:= GetMark()
	Local oDlgLis		:= Nil
	Local cRet			:= MvPar 
	Local vVetAux		:= {}
	Local aRet			:= {}
	Local aIndMat		:= {}
	Local aColumns	:= {}
	Local vVetInd 	:= {}
	Local aOrder		:= {}
	Local aButtons  := {}

	Private oMARKCE := Nil	
	Private nSelMax,nJaSel

	Store 0 To nSelMax,nJaSel

	// Busca os índices e monta os índices p/TRB e browse
	aBusInd := AGRBUSREGIS("SIX",cAliasC,1,.t.,.f.,"SIX->INDICE = '"+cAliasC+"'",{{'CHAVE'},{'DESCRICAO'}},,"M")
	aMatInd := aBusInd[2]

	For nx := 1 To Len(aMatInd)
		Aadd(aIndMat,{Alltrim(StrTran(aMatInd[nx,1],cPrefixo+"_FILIAL+","")),Alltrim(aMatInd[nx,2])}) 
	Next nx

	For nx := 1 To Len(aIndMat)
		aMatInd := Separa(aIndMat[nx,1],'+')
		lIndOk := .t.
		For ny := 1 To Len(aMatInd)
			If aScan(vVetCam,{|x| AllTrim(x) == aMatInd[ny]}) = 0
				lIndOk := .f.
				Exit
			EndIf	
		Next ny
		If lIndOk
			Aadd(vVetInd,aIndMat[nx,1])
			Aadd(aOrder,aIndMat[nx]) 
		EndIf
	Next nx

	For nx := 1 To Len(vVetCam)
		vVetAux := {}
		Aadd(vVetAux,vVetCam[nx])	
		Aadd(aCamTRB,vVetAux)
	Next nx

	// Cria o arquivo temporário
	aRet := AGRCRIATRB(,aCamTRB,vVetInd,FunName(),.t.)

	If !aRet[1] // Problema na criação dos arquivos Temporário e indicou para mostrar na função
		Return
	EndIf  

	cNomeTRB := aRet[3] //Nome do arquivo temporário 
	cAliaTRB := aRet[4] //Nome do alias do arquivo temporario
	aArqTemp := aRet[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	cCampRet := cAliaTRB+"->"+vVetCam[1]
	cFilWhil := cAliasC+"->"+cPrefixo+"_FILIAL"
	nSelMax	 := Int(60 / (AGRSEEKDIC("SX3",vVetCam[1],2,"X3_TAMANHO")+1))

	AGRAREAORDE(cAliasc)
	DbSeek(Xfilial(cAliasC))
	While !Eof() .And. &cFilWhil = Xfilial(cAliasC)
		If cCondIf <> Nil
			If !&(cCondIf)
				AGRDBSELSKIP(cAliasC)
			EndIf
		EndIf
		AGRGRAVA2T(cAliaTRB,cAliasC)
		If aScan(aSelecio,{|x| AllTrim(x) == AllTrim(&cCampRet)}) > 0
			(cAliaTRB)->OK := cMarca 
			nJaSel ++	
		EndIf
		AGRDESTRAREG()
		AGRDBSELSKIP(cAliasC)
	End
	ARGSETIFARQUI(cAliaTRB)

	oDlgLis := TDialog():New(0,0,nTamV,nTamH,STR0166,,,,,CLR_BLACK,CLR_WHITE,,,.t.)
	oDlgLis:lEscClose := .f.

	For nX := 2 To Len(aArqTemp)
		Aadd( aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData(&("{||"+aArqTemp[nx,1]+"}"))
		aColumns[Len(aColumns)]:SetType(aArqTemp[nx,2])
		aColumns[Len(aColumns)]:SetTitle(aArqTemp[nx,5])
		aColumns[Len(aColumns)]:SetSize(aArqTemp[nx,3])
		aColumns[Len(aColumns)]:SetDecimal(aArqTemp[nx,4])
		aColumns[Len(aColumns)]:SetPicture(aArqTemp[nx,6])
		aColumns[Len(aColumns)]:SetAlign(If(aArqTemp[nx,2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT))
	nExt nX

	If oMARKCE == nil
		oMARKCE := FwMarkBrowse():New()
		oMARKCE:SetDescription(AGRSX2NOME(cAliasC))
		oMARKCE:SetFieldMark("OK")
		oMARKCE:SetOwner(oDlgLis)
		oMARKCE:SetDataQuery(.F.)
		oMARKCE:SetDataTable(.T.)
		oMARKCE:SetAlias(cAliaTRB)
		oMARKCE:cMark := cMarca
		oMARKCE:SetCustomMarkRec({||AGRMAKCE()})
		oMARKCE:bAllMark := {||}
		oMARKCE:SetColumns(aColumns)
		oMARKCE:DisableConfig(.t.)
		oMARKCE:DisableReport(.t.)

		If !Empty(aOrder)
			bseek := {|oSeek| MySeek(oSeek,oMARKCE:oBrowse)}  
			oMARKCE:oBrowse:SetIniWindow({||oMARKCE:oBrowse:oData:SetSeekAction(bseek)})
			//			oMARKCE:oBrowse:SetSeek(.T.,aOrder)
		EndIf	 
		oMARKCE:Activate()
	Else
		oMARKCE:SetAlias(cTrbSTUS)//cAliasMrk)
		oMARKCE:Refresh()
	EndIF
	oLegend := FWLegend():New()
	oMARKCE:oBrowse:Setfocus()
	ARGSETIFARQUI(oMARKCE:Alias())

	oDlgLis:Activate(,,,.t.,{ ||.t.},,{|| EnchoiceBar(oDlgLis,{|| nOpc := 1,oDlgLis:End()},{|| nOpc := 0,oDlgLis:End()},,@aButtons)})

	If nOpc > 0 .And. nJaSel > 0
		cRet	:= ''
		ARGSETIFARQUI(cAliaTRB)
		While !Eof()
			If !Empty((cAliaTRB)->OK)
				cRet += If(!Empty(cRet),";","")+&(cCampRet) 
			EndIf
			DbSkip()
		End	
	EndIf
	AGRDELETRB(cAliaTRB,cNomeTRB) 	

	&MvRet := cRet   
Return .t.

/*                                                                                                 
+=================================================================================================+
| Função    : AGRMAKCE                                                                            |
| Descrição : Marca/Desmarca/Consiste itens da lista                                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 28/08/2015                                                                          | 
+=================================================================================================+ 
|Referências: AGRLISTAC                                                                           |
+=================================================================================================+    
*/
Static Function AGRMAKCE() 
	AGRTRAVAREG(cAliaTRB,.f.)
	If (!oMARKCE:IsMark())
		nJaSel ++
		If nJaSel > nSelMax
			Alert(STR0167+" "+Alltrim(Str(nSelMax,2)))
			nJaSel --
			AGRDESTRAREG()
			Return .t. 
		EndIf
		(cAliaTRB)->OK := oMARKCE:Mark()
	Else
		(cAliaTRB)->OK := ""
		nJaSel --
	EndIf
	AGRDESTRAREG()
Return .T.

/*                                                                                                 
+=================================================================================================+
| Função    : AGRLISTAOK                                                                          |
| Descrição : Verifica se os itens da lista estão cadastrados                                     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 28/08/2015                                                                          | 
+=================================================================================================+ 
|Referências:                                                                                     |
+=================================================================================================+    
*/
Function AGRLISTAOK(cAliasC,cPerg)
	Local lRet		:= .T.,nx
	Local aParS	:= Alltrim(Separa(cPerg,';'))

	If !Empty(cPerg)
		For nx := 1 to Len(aParS)
			If !AGRIFDBSEEK(cAliasC,aParS[nx],1,.F.)
				AGRHELPNC(Alltrim(aParS[nx])+" "+STR0168+" "+AGRSX2NOME(cAliasC),STR0169)
				lRet := .F.
				Exit
			EndIF	
		Next nx
	EndIF
Return lRet

/*
+=================================================================================================+
| Função    : AGRF3SXBOX                                                                          |
| Descrição : Verifica e /ou cria a consulta padrão para multiplos itens do X3_BOX                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 17/03/2016                                                                          |
+=================================================================================================+
| Referência:                                                                                     |
+=================================================================================================+  
*/ 
/*
DESCONTINUADO - Referente debito SONARQUBE
Function AGRF3SXBOX() 
	If !AGRIFDICIONA("SXB","AGRBOX",1,.f.)
		AGRCRIASXB("AGRBOX",{{"1","01","RE","Consulta Pad. X3_BOX","Consulta Pad. X3_BOX","Consulta Pad. X3_BOX","SX5"},;
		{"2","01","01","","","","AGRF3X3BOX()"},{"5","01","","","","","AGRF3X3BRET()"}})
	Endif
Return 
*/

/*
+=================================================================================================+
| Função    : AGRF3OPBOX                                                                          |
| Descrição : Validação das opções para seleção de X3_BOX                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 17/03/2016                                                                          |
+=================================================================================================+ 
| Parâmetros: cCampo - Nome do campo do list box                                       Obrigatório|
|             nQtdOp - Quantidade possíveis item selecionados                          Não Obrigat|
+=================================================================================================+ 
| Referência: Dicionário de dados SX1                                                             |
+=================================================================================================+ 
*/ 
Function AGRF3OPBOX(cCampo,nQtdOp)
	Local nI,cOpLista := "",cMens := Space(1)
	Local aListaOp := {},aAux2 := {},aAuxB := {},aAux := {},cMVPar := &(ReadVar())

	If !Empty(cMVPar)
		aAuxB := Separa(AGRRETSX3BOX(cCampo),';')
		aAux 	 := Separa(cMVPar,';')
		For nI := 1 to Len(aAuxB)
			aAux2 := separa(aAuxB[nI],'=')
			aAdd(aListaOp,{alltrim(aAux2[1]),alltrim(aAux2[2])})
		Next
		For nI := 1 to Len(aAux) 
			If aScan(aListaOp,{|x| AllTrim(x[1]) == Alltrim(aAux[nI])}) = 0
				cMens := STR0175
				Exit
			EndIF
		Next nI
	EndIF
	If !Empty(cMens) 
		For ni := 1 To Len(aListaOp)
			cOpLista += aListaOp[ni,1]+If(ni < Len(aListaOp),";","")
		Next ni
		cMens += " (;) Ex. "+cOpLista
	ElseIf nQtdOp <> Nil .And. Len(aAux) > nQtdOp
		cMens := STR0183+".  "+STR0184+"..: "+Alltrim(Str(Len(aAux)))+"  "+STR0185+"..: "+Alltrim(Str(nQtdOp))
	EndIf
	If !Empty(cMens) 
		Help(,,"HELP",,cMens,1,0)
	EndIf	
Return If(!Empty(cMens),.f.,.t.)

/*
+=================================================================================================+
| Progama   : AGRF3X3BOX                                                                          |
| Descrição : Consulta especial de F3 para campos com X3 box                                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 17/03/2016                                                                          |
+=================================================================================================+ 
| Referência: Dicionário de dados                                                                 |
+=================================================================================================+ 
| OBSERVAÇÃO: Declarar cPerg e atribuir o x1_grupo                                                |
+=================================================================================================+ 
*/ 
Function AGRF3X3BOX()
	Static cRet 			:= ''
	Local cMens			:= Space(1),nx,nOpc := 0,cOrdemL 
	Local nTamH 			:= (GetScreenRes()[1]-700),nTamV := (GetScreenRes()[2]-500)
	Local aButtons		:= {},aAuxMrkdos,aLstStus := {},aAux,aAux2 := {} 
	Local aCamTRB			:= {{"CODOP","C",1,0,STR0176,"@!"},{"DESCR","C",20,0,STR0159,"@!"},{"MARCA","C",2,0," ","@!"}} 

	Private aColumns	:= {},nQtdSI := 0
	Private oMrkBOX  	:= Nil
	Private aMarcados	:= separa(&(readvar()),';')
	Private cMarca		:= GetMark()
	aAuxMrkdos				:= aMarcados
	cOrdemL					:= Alltrim(StrTran(Readvar(),"MV_PAR",""))

	If Type('cPerg') = 'U'
		cMens := STR0177+" cPerg "+STR0173
	ElseIf !AGRIFDICIONA("SXB","AGRBOX",1,.f.)
		cMens := STR0178+" AGRF3SXBOX "+STR0179
	Else
		cChavX1   := AGRGRUPSX1(cPerg)+cOrdemL
		cValidSX1 := Alltrim(AGRSEEKDIC("SX1",cChavX1,1,"X1_VALID"))
		If !'AGRF3OPBOX(' $ cValidSX1
			cMens := STR0180+" "+Readvar()+" "+STR0181+"AGRF3OPBOX(....)"  
		EndIf
	EndIf

	If !Empty(cMens)		
		Help(,,"HELP",,cMens,1,0)
		Return 
	EndIf 

	cCampoBx	:= Alltrim(StrTran(cValidSX1,"AGRF3OPBOX(",""))
	nPosTVir 	:= At(',',cCampoBx)
	If nPosTVir > 0
		nPosPVir := At(')',cCampoBx)
		If nPosPVir > 0
			nQtdSI := Val(SubStr(cCampoBx,nPosTVir+1,nPosPVir-1))
		EndIf
	EndIf
	nPosFPar	:= At(')',cCampoBx)
	cCampoBV	:= SubStr(cCampoBx,2,If(nPosTVir > 0,nPosTVir-1,nPosFPar-3))
	aAux			:= Separa(AGRRETSX3BOX(cCampoBV),';')
	cTitCons	:= STR0182+" "+AGRTITULO(cCampoBV)
	aMarcados	:= {} 
	CursorWait()

	vVetD := AGRCRIATRB(,aCamTRB,{"CODOP"},"AGRF3X3BOX",.T.)
	cNoBX := vVetD[3]	//NOME ARQUIVO
	cAlBX := vVetD[4]	//ALIAS
	aAlBX := vVetD[5]	//ARRAY

	For nx := 1 to Len(aAux)
		aAux2 = separa(aAux[nx],'=')
		aAdd(aLstStus,{alltrim(aAux2[1]),alltrim(aAux2[2])})
	Next nx

	For nx := 1 to Len(aLstStus)
		Reclock(cAlBX,.t.)
		(cAlBX)->CODOP = aLstStus[nx][1] 
		(cAlBX)->DESCR = aLstStus[nx][2] 
		(cAlBX)->MARCA = ''
		//verifica se já é para vir marcado
		If aScan(aAuxMrkdos,aLstStus[nX][1]) > 0 	
			(cAlBX)->MARCA  := cMarca
			Aadd(aMarcados,alltrim(aLstStus[nx][1]))
		EndIf
	Next nx

	CursorArrow()
	oDlgBox := TDialog():New(0,0,nTamV,nTamH,cTitCons,,,,,CLR_BLACK,CLR_WHITE,,,.t.)
	oDlgBox:lEscClose := .f.
	Aadd(aColumns,FWBrwColumn():New())				
	aColumns[Len(aColumns)]:SetData(&("{||CODOP}")	)
	aColumns[Len(aColumns)]:SetType("C")
	aColumns[Len(aColumns)]:SetTitle(STR0176)
	aColumns[Len(aColumns)]:SetSize(2)
	aColumns[Len(aColumns)]:SetPicture("@!")

	Aadd(aColumns,FWBrwColumn():New())				
	aColumns[Len(aColumns)]:SetData(&("{||DESCR}")	)
	aColumns[Len(aColumns)]:SetType("C")
	aColumns[Len(aColumns)]:SetTitle(STR0159)
	aColumns[Len(aColumns)]:SetSize(20)
	aColumns[Len(aColumns)]:SetPicture("@!"	)

	IF oMrkBOX == nil
		oMrkBOX := FwMarkBrowse():New()
		oMrkBOX:SetDescription(cTitCons)  
		oMrkBOX:SetFieldMark("MARCA")
		oMrkBOX:SetOwner(oDlgBox)
		oMrkBOX:SetDataQuery(.F.)
		oMrkBOX:SetDataTable(.T.)
		oMrkBOX:SetAlias(cAlBX)
		oMrkBOX:cMark := cMarca
		oMrkBOX:SetCustomMarkRec({||AGRF3X3BMAR(oMrkBOX)})
		oMrkBOX:bAllMark := { ||  }
		oMrkBOX:SetMenuDef("AGRF3X3BRET")
		oMrkBOX:SetColumns(aColumns)
		oMrkBOX:DisableConfig(.t.)
		oMrkBOX:DisableReport(.t.)
		oMrkBOX:Activate()
	Else
		oMrkBOX:SetAlias(cAlBX)
		oMrkBOX:Refresh()
	EndIF
	oLegend := FWLegend():New()
	oMrkBOX:oBrowse:Setfocus()
	(oMrkBOX:Alias())->(dBGotop())
	oDlgBox:Activate(,,,.t.,{ || .t. },,{ || EnchoiceBar(oDlgBox,{|| nOpc := 1,oDlgBox:End()},{|| nOpc := 0,oDlgBox:End()},,@aButtons)})

	cRet := ''

	If nOpc > 0 .And. Len(aMarcados) > 0
		For nx := 1 to Len(aMarcados)
			cRet += alltrim(aMarcados[nx])
			If !nx = Len(aMarcados)
				cRet += ';'
			EndIf
		NExt nx
	Else
		cRet := &(readvar())
	EndIf

	AGRDELETRB(cAlBX,cNoBX)
Return .t.

/*
+=================================================================================================+
| Função    : AGRF3X3BMAR                                                                         |
| Descrição : Marca e/ou desmarca opções para X3_BOX                                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 17/03/2016                                                                          |
+=================================================================================================+ 
| Referência: Dicionário de dados                                                                 |
+=================================================================================================+ 
*/ 
Static Function AGRF3X3BMAR(oMrkBrowse)
	Local lMarca := .t.
	DbSelectArea(cAlBX)
	If (!oMrkBrowse:IsMark())
		If !Empty(nQtdSI) .And. Len(aMarcados) >= nQtdSI
			Help(,,"HELP",,STR0183+".  "+STR0185+"..: "+Alltrim(Str(nQtdSI)),1,0)
			lMarca := .f.
		EndIf
		If lMarca		
			RecLock(oMrkBrowse:Alias(),.F.)
			(oMrkBrowse:Alias())->MARCA := oMrkBrowse:Mark()
			(oMrkBrowse:Alias())->(MsUnLock())
			Aadd(aMarcados,alltrim((oMrkBrowse:Alias())->CODOP))
		EndIf	
	Else
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->MARCA  := ""
		(oMrkBrowse:Alias())->(MsUnLock())
		nPosItMrk := aScan(aMarcados,alltrim((oMrkBrowse:Alias())->CODOP))
		If nPosItMrk > 0
			aDel(aMarcados,nPosItMrk)
			aSize(aMarcados,len(aMarcados)-1)
		EndIf
	EndIf
Return .T. 

/*
+=================================================================================================+
| Função    : AGRF3X3BRET                                                                         |
| Descrição : Retorna as opções selecionadas da consulta padrão X3_BOX                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 17/03/2016                                                                          |
+=================================================================================================+ 
| Referência: Dicionário de dados                                                                 |
+=================================================================================================+ 
*/ 
Function AGRF3X3BRET()
Return(cRet)


/*                                                                                                 
+=================================================================================================+
| Função    : AGRDBMULCRE                                                                         |
| Descrição : Retorno da seleção dos código da consulta                                           |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 21/03/2016                                                                          | 
+=================================================================================================+ 
*/
Function AGRDBMULCRE()
Return(cRet)

/*                                                                                                 
+=================================================================================================+
| Função    : AGRVALBP                                                                            |
| Descrição : Verifica se os itens da lista estão cadastrados                                     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 21/03/2016                                                                          | 
+=================================================================================================+ 
|Parâmetors: cAliasC - Alias da tabela para pesquisa                                   Obrigatório|
|            cCampo  - Nome do campo chave da consulta                                 Obrigatório|
|            nQperm  - Número de seleções permitidas                                   Não Obrigat|
+=================================================================================================+    
*/
Function AGRVALBP(cAliasC,cCampo,nQperm)
	Local nx,cOrdemL	:= Alltrim(StrTran(Readvar(),"MV_PAR",""))
	Local aParS  := Separa(&(ReadVar()),';'),nSelLo,cMensL := Space(1) 

	If !Empty(&(ReadVar()))
		If nQperm = Nil
			cChavX1 := AGRGRUPSX1(cPerg)+cOrdemL
			nTamSX1 := Alltrim(AGRSEEKDIC("SX1",cChavX1,1,"X1_TAMANHO"))
			nSelLo 	:= Int(nTamSX1/(AGRSEEKDIC("SX3",cCampo,2,"X3_TAMANHO")+1))
		Else
			nSelLo := nQperm
		EndIf
		If Len(aParS) > nSelLo
			cMensL := STR0167+" "+Alltrim(Str(nSelLo,2))
		Else
			For nx := 1 to Len(aParS)
				If !AGRIFDBSEEK(cAliasC,aParS[nx],1,.F.)
					cMensL := Alltrim(aParS[nx])+" "+STR0168+" "+AGRSX2NOME(cAliasC)
					Exit
				EndIf	
			Next nx
		EndIf
		If !Empty(cMensL)
			AGRHELPNC(cMensL,STR0169)
		EndIf	
	EndIF
Return If(!Empty(cMensL),.f.,.t.)

/*                                                                                                 
+=================================================================================================+
| Função    : AGRDBMULCRE                                                                         |
| Descrição : Returno da seleção dos código da consulta                                           |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 29/03/2016                                                                          | 
+=================================================================================================+ 
*/
Function AGRDBMUCTRB()
Return(cRet)

/*                                                                                                 
+=================================================================================================+
| Função    : AGRVALBP                                                                            |
| Descrição : Verifica se os itens da lista estão cadastrados                                     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 29/03/2016                                                                          | 
+=================================================================================================+ 
|Parâmetors: cAliasC - Alias da tabela para pesquisa                                   Obrigatório|
|            cCampo  - Nome do campo chave da consulta                                 Obrigatório|
|            aEstru  - Nome da matriz da estrutura do arquivo                          Obrigatório|
|            nQperm  - Número de seleções permitidas                                   Não Obrigat|
+=================================================================================================+    
*/
Function AGRVALTRB(cAliasC,cCampo,aEstru,nQperm)
	Local nx,cOrdemL	:= Alltrim(StrTran(Readvar(),"MV_PAR","")), nTamC := 0
	Local aParS  := Separa(&(ReadVar()),';'),nSelLo,cMensL := Space(1)

	If !Empty(&(ReadVar()))
		If nQperm = Nil
			cChavX1 := AGRGRUPSX1(cPerg)+cOrdemL
			nTamSX1 := Alltrim(AGRSEEKDIC("SX1",cChavX1,1,"X1_TAMANHO"))
			nPosC   := Ascan(aEstru,{|x| Alltrim(x[1]) = cCodRet})
			If nPosC = 0
				nTamC := aEstru[nPosC,4]
			EndIf
			nSelLo 	:= Int(nTamSX1/nTamC)+1
		Else
			nSelLo := nQperm
		EndIf
		If Len(aParS) > nSelLo
			cMensL := STR0167+" "+Alltrim(Str(nSelLo,2))
		Else
			For nx := 1 to Len(aParS)
				If !AGRIFSEETRB(cAliasC,aParS[nx],1,.F.)
					cMensL := Alltrim(aParS[nx])+" "+STR0168+" "+STR0050
					Exit
				EndIf	
			Next nx
		EndIf
		If !Empty(cMensL)
			AGRHELPNC(cMensL,STR0169)
		EndIf	
	EndIF
Return If(!Empty(cMensL),.f.,.t.)

/*
+=================================================================================================+
| Função    : AGRCONSXBE                                                                          |
| Descrição : Verifica e /ou cria a consulta padrão de código de tabelas                          |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/04/2016                                                                          |
+=================================================================================================+
| Referência:                                                                                     |
+=================================================================================================+  
*/ 
/*
DESCONTINUADO - Referente debito SONARQUBE
Function AGRCONSXBE()
	If !AGRIFDICIONA("SXB","AGRCES",1,.f.)
		AGRCRIASXB("AGRCES",{{"1","01","RE","Consulta Padrão Especifica","Consulta Padrão Especifica","Consulta Padrão Especifica","SX5"},;
		{"2","01","01","","","","AGRCONSPES()"},{"5","01","","","","","AGRCONSRES()"}})
	Endif
Return
*/

/*
+=================================================================================================+
| Função    : AGRCONSPES                                                                          |
| Descrição : Consulta Específica padrão códigos de tabelas                                       |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/04/2016                                                                          |
+=================================================================================================+
| OBSERVAÇÃO: Usar em conjunto com a função de validação  SX3 e/ou SX1  Onde:                     |
|             (cAlias,Código,variável de filtro) (marcro vindo do programa chamador)              |  
+=================================================================================================+
*/ 

Function AGRCONSPES()
	Static cRet		:= ''
	Local aAreaA := GetArea(),nx,ny,nPosX3 := 0
	Local aRet		:= {},vVetInd := {},aCamTRB := {},aSeek := {},aIndMat := {},aOrder := {}
	Local cMens	:= Space(1),cCondIf := cMens,cOrdemL
	Local cPrefixo
	Local oSize	:= Nil,oBrowF3T := Nil,nTamLi,nTamCi
	Local aCoors := FWGetDialogSize(oMainWnd)
	Private cVarA := Readvar()
	// Verifica se é uma pergunta
	nPosX1 := At("MV_PAR",Readvar())
	If nPosX1 > 0
		cOrdemL	:= Alltrim(StrTran(Readvar(),"MV_PAR",""))

		If Type('cPerg') = 'U'
			cMens := STR0177+" cPerg "+STR0173
		ElseIf !AGRIFDICIONA("SXB","AGRCES",1,.f.)
			cMens := STR0178+" AGRCES "+STR0179
		Else
			cChavX1 := AGRGRUPSX1(cPerg)+cOrdemL
			cValidC := Alltrim(AGRSEEKDIC("SX1",cChavX1,1,"X1_VALID"))
			If !'AGRVALCES(' $ cValidC
				cMens := STR0180+" "+Readvar()+" "+STR0181+"AGRVALCES(....)"  
			EndIf
		EndIf
	Else
		nPosX3 := At(">",Readvar())
		If nPosX3 > 0
			cChavX3 := SubStr(Readvar(),nPosX3+1,Len(Readvar()))
			cValidC := Alltrim(AGRSEEKDIC("SX3",cChavX3,2,"X3_VALID"))
			If !'AGRVALCES(' $ cValidC
				cMens := STR0180+" "+Readvar()+" "+STR0181+"AGRVALCES(....)"  
			EndIf
		EndIf 
	EndIf

	If Empty(nPosX1) .And. Empty(nPosX3)
		cMens := STR0196	
	ElseIf Empty(cMens)
		nPosVld		:= At('AGRVALCES(',cValidC) 
		cCampoVld	:= Alltrim(SubStr(cValidC,nPosVld+10,Len(cValidC))) 

		nPosAli := At(',',cCampoVld)
		If nPosAli = 0
			cMens := If(nPosX1 > 0,STR0186+" "+cOrdemL,+" "+STR0197+" "+cChavX3) 	
		Else
			cAliasC := SubStr(cCampoVld,2,nPosAli-3)
		Endif

		If Empty(cMens)	 
			cCampoVld := Alltrim(SubStr(cCampoVld,nPosAli+2,Len(cCampoVld)))
			nPostRet  := At('"',cCampoVld)
			If nPostRet = 0
				cMens := If(nPosX1 > 0,STR0187+" "+cOrdemL,+" "+STR0198+" "+cChavX3)
			Else
				cCodRet := SubStr(cCampoVld,1,nPostRet-1)
			EndIf		
		EndIf

		If Empty(cMens)
			cCampoVld := Alltrim(SubStr(cCampoVld,nPostRet+1,Len(cCampoVld)))
			nPosPVir := At(',',cCampoVld)
			If nPosPVir > 0
				nPosPFim := At(')',cCampoVld)
				cCondPar := '"'+SubStr(cCampoVld,1,nPosPFim-1)+'"'
				If Type(&cCondPar) = "U"
					cMens := STR0177+" "+cCondPar+" "+STR0179
				Else
					cCondIf := &(&(cCondPar))	
				EndIf
			EndIf
		EndIf
	EndIf

	If !Empty(cMens)		
		Help(,,"HELP",,cMens,1,0)
		Return 
	EndIf 

	cPrefixo := AGRPREFIXOCAMP(cAliasC)

	//Busca os campos para montar o browse
	vVetCTSI := AGRBUSREGIS("SX3",cAliasC,1,.T.,.F.,"SX3->X3_ARQUIVO = cAliasC",;
	{{"X3_CAMPO"}},"SX3->X3_BROWSE = 'S' .AND. SX3->X3_CONTEXT <> 'V'","M")
	vVetCamp := AClone(vVetCTSI[2])

	// Busca os índices 
	aBusInd := AGRBUSREGIS("SIX",cAliasC,1,.t.,.f.,"SIX->INDICE = '"+cAliasC+"'",{{'CHAVE'},{'DESCRICAO'}},,"M")
	aMatInd := aBusInd[2]

	For nx := 1 To Len(aMatInd)
		Aadd(aIndMat,{Alltrim(StrTran(aMatInd[nx,1],cPrefixo+"_FILIAL+","")),Alltrim(aMatInd[nx,2])}) 
	Next nx

	For nx := 1 To Len(aIndMat)
		aMatInd := Separa(aIndMat[nx,1],'+')
		lIndOk := .t.
		For ny := 1 To Len(aMatInd)
			If aScan(vVetCamp,{|x| AllTrim(x[1]) == aMatInd[ny]}) = 0
				lIndOk := .f.
				Exit
			EndIf	
		Next ny
		If lIndOk
			Aadd(vVetInd,aIndMat[nx,1])
			Aadd(aOrder,aIndMat[nx]) 
		EndIf
	Next nx

	If Empty(vVetInd)
		vVetInd  := {cCodRet}
	EndIf	

	For nx := 1 To Len(vVetCamp)
		Aadd(aCamTRB,vVetCamp[nx])
	Next nx

	// Cria o arquivo temporário
	aRet := AGRCRIATRB(,aCamTRB,vVetInd,"AGRDBMULCO",.t.)

	If !aRet[1] // Problema na criação dos arquivos Temporário e indicou para mostrar na função
		Return
	EndIf  

	cNomeTRB := aRet[3] //Nome do arquivo temporário 
	cAliaTRB := aRet[4] //Nome do alias do arquivo temporario
	aArqTemp := aRet[5] //Matriz com a estrutura do arquivo temporario + label e picutre
	aSeek    := AGRINDICONS(vVetInd,aArqTemp)

	If aScan(aArqTemp,{|x| AllTrim(x[1]) == AllTrim(cCodRet)}) = 0
		Help(,,"HELP",,STR0199+" "+cCodRet+" "+STR0200,1,0)
		Return .f.
	EndIf

	cFilWhil := cAliasC+"->"+cPrefixo+"_FILIAL"
	AGRAREAORDE(cAliasc)
	DbSeek(Xfilial(cAliasC))
	While !Eof() .And. &cFilWhil = Xfilial(cAliasC)
		If !Empty(cCondIf)
			If !&(cCondIf)
				AGRDBSELSKIP(cAliasC)
			EndIf
		EndIf
		AGRGRAVA2T(cAliaTRB,cAliasC)
		AGRDESTRAREG()
		AGRDBSELSKIP(cAliasC)
	End
	ARGSETIFARQUI(cAliaTRB)

	oSize := FWDefSize():New(.T.)
	oSize:AddObject('DLG',100,100,.T.,.T.)    
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.      
	oSize:Process()

	nTamLi := Int(oSize:aWindSize[3]/2)
	nTamCi := Int(oSize:aWindSize[4]/2)
	nTamLi -= Int(nTamLi * .20)
	nTamCi -= Int(nTamCi * .20)

	DEFINE MSDIALOG oDlgF3T FROM nTamLi,nTamCi TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL
	DEFINE FWFORMBROWSE oBrowF3T DATA TABLE ALIAS cAliaTRB DESCRIPTION ARGSX2NOME(cAliasC) OF oDlgF3T
	oBrowF3T:SetTemporary(.T.)
	oBrowF3T:SetFieldFilter(AGRITEMCBRW(aArqTemp))
	oBrowF3T:SetdbFFilter(.F.)
	oBrowF3T:SetUseFilter(.F.)
	oBrowF3T:DisableDetails()
	oBrowF3T:SetSeek(,aSeek)
	oBrowF3T:AddButton("Ok",{||AGRPESRET(cAliaTRB,cCodRet)},,,,,,'10')
	oBrowF3T:SetDoubleClick({||AGRPESRET(cAliaTRB,cCodRet)},,,,,,'10')
	For nx := 1 To Len(aArqTemp)
		ADD COLUMN oColumn DATA &('{||'+aArqTemp[nx,1]+'}') Title aArqTemp[nx,5] SIZE aArqTemp[nx,3] PICTURE aArqTemp[nx,6];
		Type aArqTemp[nx,6] Of oBrowF3T
	Next nx 
	ACTIVATE FWFORMBROWSE oBrowF3T
	ACTIVATE MSDIALOG oDlgF3T CENTER
	AGRDELETRB(cAliaTRB,cNomeTRB) 	
	RestArea(aAreaA)
Return .t.

/*                                                                                                 
+=================================================================================================+
| Função    : AGRPESRET                                                                           |
| Descrição : Retorno o conteúdo da consulta específica padrão                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/04/2016                                                                          | 
+=================================================================================================+ 
|Parâmetors: cAlTRB - Alias do arquivo temporário da pesquisa                          Obrigatório|
|					cCodR  - Campo de retorno                                                 Obrigatório|
+=================================================================================================+ 
*/
Function AGRPESRET(cAlTRB,cCodR)
	&(cVarA) := &(cAlTRB+"->"+cCodR)
	cRet     := &(cAlTRB+"->"+cCodR)
	oDlgF3T:End()
Return .t.

/*                                                                                                 
+=================================================================================================+
| Função    : AGRCONSRES                                                                          |
| Descrição : Retorno da consulta específica padrão                                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/04/2016                                                                          | 
+=================================================================================================+ 
*/
Function AGRCONSRES()
Return(cRet)

/*                                                                                                 
+=================================================================================================+
| Função    : AGRVALCES                                                                           |
| Descrição : Verifica se o item selecionads está cadastrado                                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/04/2016                                                                          | 
+=================================================================================================+ 
|Parâmetors: cAliasC - Alias da tabela para pesquisa                                   Obrigatório|
+=================================================================================================+    
*/
Function AGRVALCES(cAliasC)
	Local cVarA := Readvar()
	Local cChaA := &(cVarA) 
	If !Empty(cChaA) .And. !AGRIFDBSEEK(cAliasC,cChaA,1,.f.)
		Help(,,"HELP",,STR0201,1,0)
		Return .f.
	EndIF
Return .t.

/*
+=================================================================================================+
| Função    : AGRCONTRBE                                                                          |
| Descrição : Verifica e /ou cria a consulta padrão de código de um arquivo temporário            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/04/2016                                                                          |
+=================================================================================================+
| Referência:                                                                                     |
+=================================================================================================+  
*/ 
/*
DESCONTINUADO - Referente debito SONARQUBE
Function AGRCONTRBE()
	If !AGRIFDICIONA("SXB","AGRCTR",1,.f.)
		AGRCRIASXB("AGRCTR",{{"1","01","RE","Cons. Padrão Esp. 	Temp.","Cons. Padrão Esp. 	Temp.","Cons. Padrão Esp. 	Temp.","SX5"},;
		{"2","01","01","","","","AGRCONTRPE()"},{"5","01","","","","","AGRCONTRTE()"}})
	Endif
Return*/

/*
+=================================================================================================+
| Função    : AGRCONTRPE                                                                          |
| Descrição : Consulta Específica padrão código de um arquivo temporário                          |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/04/2016                                                                          |
+=================================================================================================+
| OBSERVAÇÃO: Usar em conjunto com a função de validação (SX3 e/ou SX1)  Onde:                    |
|             (cAlias,Código                                                                      |  
+=================================================================================================+
*/ 
Function AGRCONTRPE()
	Static cRet		:= ''
	Local aSeek := {},aAreaA := GetArea(),nx 
	Local cMens		:= Space(1),cOrdemL
	Local oSize	 	:= Nil,oBrowF3T := Nil,nTamLi,nTamCi
	Local aCoors  	:= FWGetDialogSize(oMainWnd)
	Private cVarA	 	:= Readvar()

	If !AGRIFDICIONA("SXB","AGRCTR",1,.f.)
		cMens := STR0178+" AGRCTR "+STR0179
	EndIf

	If Empty(cMens)
		nPosX1 := At("MV_PAR",Readvar())
		If nPosX1 > 0
			cOrdemL	:= Alltrim(StrTran(Readvar(),"MV_PAR",""))
			If Type('cPerg') = 'U'
				cMens := STR0177+" cPerg "+STR0173
			EndIf
			cChavX1 := AGRGRUPSX1(cPerg)+cOrdemL
			cValidC := Alltrim(AGRSEEKDIC("SX1",cChavX1,1,"X1_VALID"))
		Else
			nPosX3 := At(">",Readvar())
			If nPosX3 > 0
				cChavX3 := SubStr(Readvar(),nPosX3+1,Len(Readvar()))
				cValidC := Alltrim(AGRSEEKDIC("SX3",cChavX3,2,"X3_VALID"))
			EndIf 	
		EndIf

		If !'AGRVALBTRB(' $ cValidC
			cMens := STR0180+" "+Readvar()+" "+STR0181+"AGRVALBTRB(....)"  
		EndIf

		If Empty(cMens)
			cCampoVld	:= Alltrim(StrTran(cValidC,"AGRVALBTRB(",""))
			nPosAli := At(',',cCampoVld)
			If nPosAli = 0
				cMens := If(nPosX1 > 0,STR0186+" "+cOrdemL,STR0198+" "+Alltrim(StrTran(cVarA,"M->","")))	
			Else
				cAliasC := SubStr(cCampoVld,1,nPosAli-1)
			Endif
		EndIf

		If Empty(cMens)	 
			cCampoVld := Alltrim(SubStr(cCampoVld,nPosAli+2,Len(cCampoVld)))
			nPostRet   := At('"',cCampoVld)
			If nPostRet = 0
				cMens := STR0187+" "+cOrdemL
			Else
				cCodRet := SubStr(cCampoVld,1,nPostRet-1)
			EndIf		
		EndIf

		If Empty(cMens)
			cCampoVld := Alltrim(SubStr(cCampoVld,nPostRet+2,Len(cCampoVld)))
			nPosPVir := At(',',cCampoVld)
			nPosPare := 0
			If nPosPVir = 0
				nPosPare := At(')',cCampoVld)
			EndIf	
			nPosTPV := Max(nPosPVir,nPosPare)
			cEstru := '"'+SubStr(cCampoVld,1,nPosTPV-1)+'"'
			If Type(&cEstru) = "U"
				cMens := STR0177+" "+cEstru+" "+STR0179
			Else
				aEstru := &(&(cEstru))	
			EndIf
		EndIf

		If Empty(cMens)
			nPosC := Ascan(aEstru,{|x| Alltrim(x[1]) = cCodRet})
			If nPosC = 0
				cMens := STR0193
			Else
				nTamC := aEstru[nPosC,4]
			EndIf		
		EndIf
	EndIf

	If !Empty(cMens)		
		Help(,,"HELP",,cMens,1,0)
		Return 
	EndIf 

	cAliTRB := &(cAliasc)
	ARGSETIFARQUI(cAliTRB)

	oSize := FWDefSize():New(.T.)
	oSize:AddObject('DLG',100,100,.T.,.T.)    
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.      
	oSize:Process()

	nTamLi := Int(oSize:aWindSize[3]/2)
	nTamCi := Int(oSize:aWindSize[4]/2)
	nTamLi -= Int(nTamLi * .20)
	nTamCi -= Int(nTamCi * .20)

	DEFINE MSDIALOG oDlgF3T FROM nTamLi,nTamCi TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL
	DEFINE FWFORMBROWSE oBrowF3T DATA TABLE ALIAS cAliTRB DESCRIPTION STR0194 OF oDlgF3T
	oBrowF3T:SetTemporary(.T.)
	oBrowF3T:SetFieldFilter(AGRITEMCBRW(aEstru))
	oBrowF3T:SetdbFFilter(.F.)
	oBrowF3T:SetUseFilter(.F.)
	oBrowF3T:DisableDetails()
	oBrowF3T:SetSeek(,aSeek)
	oBrowF3T:AddButton("Ok",{||AGRTRPRET(cAliTRB,cCodRet)},,,,,,'10')
	oBrowF3T:SetDoubleClick({||AGRTRPRET(cAliTRB,cCodRet)},,,,,,'10')
	For nx := 1 To Len(aEstru)
		ADD COLUMN oColumn DATA &('{||'+aEstru[nx,1]+'}') Title aEstru[nx,5] SIZE aEstru[nx,3] PICTURE aEstru[nx,6];
		Type aEstru[nx,6] Of oBrowF3T
	Next nx 
	ACTIVATE FWFORMBROWSE oBrowF3T
	ACTIVATE MSDIALOG oDlgF3T CENTER
	RestArea(aAreaA)
Return .t.

/*                                                                                                 
+=================================================================================================+
| Função    : AGRTRPRET                                                                           |
| Descrição : Retorno o conteúdo da consulta específica padrão de um arquivo temporário           |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/04/2016                                                                          | 
+=================================================================================================+ 
|Parâmetors: cAlTRB - Alias do arquivo temporário da pesquisa                          Obrigatório|
|					cCodR  - Campo de retorno                                                 Obrigatório|
+=================================================================================================+ 
*/
Function AGRTRPRET(cAlTRB,cCodR)
	&(cVarA) := &(cAlTRB+"->"+cCodR)
	cRet     := &(cAlTRB+"->"+cCodR)
	oDlgF3T:End()
Return .t.

/*                                                                                                 
+=================================================================================================+
| Função    : AGRCONTRTE                                                                          |
| Descrição : Retorno da consulta específica padrão de um arquivo temporário                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/04/2016                                                                          | 
+=================================================================================================+ 
*/
Function AGRCONTRTE()
Return(cRet)

/*                                                                                                 
+=================================================================================================+
| Função    : AGRVALBTRB                                                                          |
| Descrição : Verifica se o item selecionads está cadastrado                                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/04/2016                                                                          | 
+=================================================================================================+ 
|Parâmetors: cAliasC - Alias da tabela para pesquisa                                   Obrigatório|
+=================================================================================================+    
*/
Function AGRVALBTRB(cAliasC)
	Local cVarA := Readvar()
	Local cChaA := &(cVarA) 
	If !Empty(cChaA) .And. !AGRIFSEETRB(cAliasC,cChaA,1,.f.)
		Help(,,"HELP",,STR0201,1,0)
		Return .f.
	EndIF
Return .t.

/*
+=================================================================================================+
| Função    : AGRSEQUEPV                                                                          |
| Descrição : Consistência das sequências de códigos separados por ponto e virgula                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 22/03/2016                                                                          |
+=================================================================================================+
|Parâmetro  : cMVPar - Variável da pergunta                                            Obrigatório|
|             nTamSe - Tamanho da sequência                                            Obrigatório|
+=================================================================================================+ 
| Referência: Dicionário de dados SX1 (OGR295 )                                                   |
+=================================================================================================+ 
*/     
Function AGRSEQUEPV(cMVPar,nTamSe)
	Local nx,ny,cMens := Space(1),cCodigo := "",cParMV := Alltrim(cMVPar)
	If !Empty(cParMV)
		For nx := 1 To Len(cParMV)
			cCodigo := ""
			nPosPV := At(';',cParMV)
			If nPosPV > 0
				cCodigo := SubStr(cParMV,1,nPosPV-1)
			Else
				cCodigo := cParMV
			EndIf			
			If Len(cCodigo) <> nTamSe
				cMens := STR0188+" "+cCodigo+" "+STR0189+" "+Str(nTamSe,2)
				Exit
			Else
				For ny := 1 To Len(cCodigo)
					cCaract := SubStr(cCodigo,ny,1)
					If ISDIGIT(cCaract) .Or. ISALPHA(cCaract)
					Else
						cMens := STR0190+" "+cCaract+" "+STR0191+" "+cCodigo
					EndIf
				Next ny		
			EndIf
			If !Empty(cMens)
				Exit
			EndIf	
			If nPosPV <> 0
				cParMV := SubStr(cParMV,nPosPV+1)
			EndIf	
		Next nx
		If !Empty(cMens)
			Help(,,"HELP",,cMens,1,0)
		EndIf	
	EndIf
Return If(!Empty(cMens),.f.,.t.)

/*
+=================================================================================================+
| Função    : AGRMULTOPQRY                                                                        |
| Descrição : Retorna uma lista de códigos da multiplas escolhas para anexar na query             |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 17/03/2016                                                                          |
+=================================================================================================+
|Parâmetros : cMVPAR - Conteúdo da pergunta                                            Obrigotório|
|             cTipoC - Tipo do codigo                                                  Não Obrigot|  
+=================================================================================================+
| Referência:                                                                                     |
+=================================================================================================+  
*/ 
Function AGRMULTOPQRY(cMVPAR,cTipoC)
	Local aListop := separa(cMVPAR,';'),cCodigo := "",nx,cTiQy := If(cTipoC = Nil,"C",cTipoC)
	For nx := 1 to Len(aListop)
		If cTiQy = "N"
			cCodigo += If(Empty(cCodigo),""," , ")+Alltrim(aListop[nx])
		Else
			cCodigo += "'"+Alltrim(aListop[nx])+"'"+If(nx < Len(aListop)," , ","")
		EndIf	
	Next nx
Return cCodigo

// TRATAMENTO COM ARQUIVO DO TIPO TXT
/*
+=================================================================================================+
| Função    : AGRCRIATXT                                                                          |
| Descrição : Cria um arquivo do tipo TXT                                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 01/06/2015                                                                          |
+=================================================================================================+ 
|Parâmetro  : cNome - Nome do arquivo sem extensão                                                |
+=================================================================================================+ 
|Referências: AGRFIMUPD                                                                           |
+=================================================================================================+ 
*/
Function AGRCRIATXT(cNome)
	Local _nHdl := 0,vSinal := {"\","/",":","?","<",">","|"}
	Local nFr := 0 ,vRetTXT := {.t.,0,"",""},cMensa := ""

	For nFr := 1 To Len(vSinal)
		If vSinal[nFr] $ cNome
			vRetTXT[1] := .f.
			Exit
		Endif
	Next nFr

	If !vRetTXT[1]
		cMensa := STR0162+" "+vSinal[nFr]
	Else
		cArqTXT := Alltrim(cNome)+".TXT"
		If File(cArqTXT)
			Ferase(cArqTXT)
		Endif

		_nHdl := Fcreate(cArqTXT)

		If _nHdl < 0
			vRetTXT := {.f.,_nHdl,cArqTXT,STR0164+" "+cArqTXT}
		Else
			vRetTXT := {.t.,_nHdl,cArqTXT,cMensa}
		Endif
	Endif
Return vRetTXT

/*
+=================================================================================================+
| Função    : AGRPREPAPP                                                                          |
| Descrição : Prepara vetor com os alias para refazer a base de dados na execução de UPDs         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 20/05/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlia - Alias da tabela                                                  Obrigatório|
+=================================================================================================+
|Referências:AGRCRIASX3,AGRCRISIX                                                                 |
+=================================================================================================+ 
*/ 
Function AGRPREPAPP(cAlia)
	If Ascan(vVetApp,{|x| x = cAlia}) = 0
		Aadd(vVetApp,cAlia)
	EndIf	
Return


/* 
+=================================================================================================+
| Função    : AGRF3MATRIZ                                                                         |
| Descrição : Monta uma consulta (F3) a partir de uma matriz                                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/06/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: aMatrDa - Matriz com os dados para montar a consulta                     Obrigatório|  
|             vVetCab - Vetor com o(s) nome(s) da(s) coluna(s)                         Obrigatório|  
|             vVetRca - Vetor com o(s) da(s) coluna(s) para retorno                    Obrigatório| 
|             cTitulo - Título da consulta                                             Obrigatório|  
|             lOrde1C - Indica se ordem pela primeira coluna                           Não Obrigat| 
+=================================================================================================+  
| Retorna   : .f.     - Mensagem de erro na montagem da consulta                                  |
|             cRetor  - Retorno da consulta quando for uma única coluna passada por parâmetro     |
|             vVetRe  - Vetor com os valores das colunas passado por parâmetros                   |
+=================================================================================================+ 
|Referências : AGRA980                                                                            |
+=================================================================================================+ 
*/
Function AGRF3MATRIZ(aMatrDa,vVetCab,vVetRca,cTitulo,lOrde1C) 
	Local cMensa   := Space(1),nOpc := 0,nx,ni
	Local aListPad := {}, aHeaCam := {}, aCampos := {}, vVetRe := {}
	Local lOrd1Co  := If(lOrde1C = NIL,.T.,lOrde1C)
	Local aMatDad  := If(lOrd1Co,aSort(aMatrDa,,,{|x,y| x[1] < y[1]}),Aclone(aMatrDa)) 

	If Empty(aMatDad)
		cMensa := STR0006
	ElseIf Empty(vVetCab)
		cMensa := STR0007
	ElseIf Empty(vVetRca)  
		cMensa := STR0008
	ElseIf Len(vVetCab) <> Len(aMatDad[1])
		cMensa :=STR0009 
	ElseIf Len(vVetRca) > Len(aMatDad[1])
		cMensa := STR0010
	Else
		For nx := 1 To Len(vVetRca)
			If vVetRca[nx] > Len(aMatDad[1])
				cMensa := STR0011 
				Exit
			EndIf
		Next nx   
	EndIf
	If !Empty(cMensa)
		Alert(cMensa)
		Return .f.
	EndIf

	For nx := 1 To Len(vVetCab)  
		Aadd(aCampos,{vVetCab[nx],aMatDad[1,nx]})
	Next nx  

	Aeval(aCampos,{|aElem|Aadd(aHeaCam,aElem[1])})

	For nx := 1 To Len(aMatDad)
		Aadd(aListPad,aMatDad[nx])
	Next nx   

	DEFINE DIALOG oDlgF TITLE cTitulo From 12,60 To 36,122 OF oMainWnd
	oLBrowse := TWBrowse():New(0,1,230,160,,aHeaCam,,oDlgF,,,,,,,,,,,,.T.)
	oLBrowse:SetArray(aListPad)
	cBloco := "{|| { "
	For nI := 1 To Len(aListPad[1])
		If nI > 1
			cBloco += ","
		EndIf
		cBloco += "aListPad[oLBrowse:nAt,"+StrZero(nI,2)+"]"
	Next

	cBloco += " }}"
	oLBrowse:bLine := &(cBloco)
	oLBrowse:bLDblClick := {||(nOpc := 1,nReg := oLbrowse:nAt,oDlgF:End())}

	DEFINE SBUTTON oBtn1 FROM 165,10 TYPE 1 ACTION (nOpc := 1,nReg := oLbrowse:nAt,oDlgF:End()) ENABLE OF oDlgF
	DEFINE SBUTTON oBtn2 FROM 165,40 TYPE 2 ACTION (nOpc := 0,oDlgF:End()) ENABLE OF oDlgF
	ACTIVATE MSDIALOG oDlgF

	If nOpc = 1  
		If Len(vVetRca) = 1
			cRetor := aListPad[nReg,vVetRca[1]]
		Else
			For nx := 1 To Len(vVetRca)
				Aadd(vVetRe,aListPad[nReg,vVetRca[nx]])
			Next nx   
		EndIf 
	Else
		Return cMensa 
	EndIf
Return If(Len(vVetRca) = 1,cRetor,vVetRe)

/* 
+=================================================================================================+
| Função    : AGRORVETMATR                                                                        |
| Descrição : Ordena um vetor ou uma matriz                                                       |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 06/03/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: vaDad   - Vetor ou Matriz com os dados para ordenar                      Obrigatório|  
|             vVetCol - Vetor com a(s) coluna(s) para ordenar quando é matriz          Não Obrigat|  
|             cTipoOr - Tipo da ordenação ( C - Cresente  D - Decresente )             Não Obrigat| 
+=================================================================================================+  
| Retorna   : aMatOrd - Vetor ou Matriz ordenada                                                  |
+=================================================================================================+ 
|Referências :                                                                                    |
+=================================================================================================+ 
*/
Function AGRORVETMATR(vaDad,vVetCol,cTipoOr) 
	Local cOrdTipo := If(cTipoOr = Nil,"C",cTipoOr),nx
	Local cSinalOr := If(cOrdTipo = "C","<",">"),cComparX := "",cComparY := ""

	If vVetCol <> Nil .And. !Empty(vVetCol) .And. Len(vVetCol) > 1
		For nx := 1 To Len(vVetCol)
			cComparX += If(Valtype(vaDad[1,vVetCol[nx]]) = "N","Alltrim(Str(x["+Alltrim(Str(vVetCol[nx]))+"]))",;
			If(Valtype(vaDad[1,vVetCol[nx]]) = "D","Dtoc(x["+Alltrim(Str(vVetCol[nx]))+"])",;
			"x["+Alltrim(Str(vVetCol[nx]))+"]"))

			cComparY += If(Valtype(vaDad[1,vVetCol[nx]]) = "N","Alltrim(Str(y["+Alltrim(Str(vVetCol[nx]))+"]))",;
			If(Valtype(vaDad[1,vVetCol[nx]]) = "D","Dtoc(y["+Alltrim(Str(vVetCol[nx]))+"])",;
			"y["+Alltrim(Str(vVetCol[nx]))+"]"))
			If Len(vVetCol) > nx
				cComparX += " + "
				cComparY += " + "
			EndIf	
		Next nx
		cCompar := cComparX+" "+cSinalOr+" "+cComparY
	ElseIf vVetCol <> Nil .And. !Empty(vVetCol) .And. Len(vVetCol) = 1
		cCompar := "x ["+Alltrim(Str(vVetCol[1]))+"] "+cSinalOr+" y["+Alltrim(Str(vVetCol[1]))+"]"
	Else
		cCompar := "x "+cSinalOr+" y"
	EndIf

	cCompM := "{|x,y| "+cCompar+"}"
	vaRet := aSort(vaDad,,,&cCompM)
Return vaRet

/* 
+=================================================================================================+
| Função    : AGRF3PERDAC                                                                         |
| Descrição : Monta consulta da NNK                                                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 07/11/2014                                                                          |
+=================================================================================================+                                                                           |  
| Retorna   : .t., .f.                                                                            |
+=================================================================================================+
|Referências : OGA250, OGA180                                                                     |
+=================================================================================================+ 
*/
Function AGRF3PERDA()
	If FUNNAME() $ "OGA250|OGA251"
		OGA250NNKF3(FwFldGet('NJJ_TABELA'),FwFldGet('NJK_CODDES'))
	Else   
		OGA250NNKF3(FwFldGet('NJF_TABELA'),FwFldGet('NJG_CODDES'))
	EndIf
Return .t.

// TRATAMENTO DE INCOMPATIBILIDADES 
/* 
+=================================================================================================+
| Função    : AGRINCOMDIC                                                                         |
| Descrição : Mensagem de incompatibilidade do dicionário de dados                                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/06/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cFuncao - Nome da função a ser executada                            Não Obrigatório |
|             cNumBol - Número do boletim técnico                                 Não Obrigatório |
|             lTerm   - Indica se o sistema será encerrado                        Não Obrigatório | 
+=================================================================================================+  
| Retorna   : .t., .f.                                                                            |
+=================================================================================================+
|Referências : AGRA840                                                                                    |
+=================================================================================================+ 
*/
Function AGRINCOMDIC(cFuncao,cNumBol,lTerm)
	Local cMenF := If(cFuncao <> Nil,STR0012+" "+cFuncao+"."+CRLF," ")+CRLF;
	+STR0013+" "+If(cNumBol <> Nil,STR0014+" "+cNumBol,STR0015)
	Local lTermi := If(lTerm = Nil,.f.,lTerm)
	Alert(STR0016+" "+OAPP:CMODDESC+" "+STR0017+CRLF+CRLF+cMenF)
	If lTermi
		Final(STR0018)
	Else
		Return .f.
	Endif
Return .t.

/* 
+=================================================================================================+
| Função    : AGRFUNCRPO                                                                          |
| Descrição : Verifica se uma função existe no RPO                                                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/06/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cFUNCRPO -> Nome da função                                          Não Obrigatório |
|             lTela    -> Indica se mostra mensagem                               Não Obrigatório |
|             cProgram -> Nome do fonte para atualizar                            Não Obrigatório | 
+=================================================================================================+  
| Retorna   : lRet (.t., .f.)                                                                     |
+=================================================================================================+ 
|Referências :                                                                                    |
+=================================================================================================+ 
*/
Function AGRFUNCRPO(cFUNCRPO,lTela,cProgram)
	Local lMostT   := If(lTela = Nil,.t.,lTela),lRetF := .t.
	Local cPESFRPO := If(cFUNCRPO = Nil,cFUNCAO,cFUNCRPO)
	If !FINDFUNCTION(cPESFRPO)
		If lMostT
			If cProgram <> Nil
				AGRHELPNC(STR0019+CRLF+"( "+Alltrim(cPESFRPO)+" )",STR0020+" "+cProgram)
			Else
				Alert(STR0019+CRLF+"( "+Alltrim(cPESFRPO)+" )") //"Funcao Nao Encontrada No RPO Em Uso"
			EndIf
		Endif
		lRetF := .f.
	Endif
Return lRetF

// TRATAMENTO DE HELPS
/* 
+=================================================================================================+
| Função    : AGRHELPNC                                                                           |
| Descrição : Monta tela de help padrão da TOTVS                                                  |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/06/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cProbP   - Descrição do problema                                        Obrigatório |
|             cSoluP   - Descrição da solução                                         Obrigatório |
|             cNomHelp - Nome da tela para padrão TOTVS                           Não Obrigatório |
+=================================================================================================+ 
|Referências :                                                                                    |
+=================================================================================================+  
*/
Function AGRHELPNC(cProbP,cSoluP,cNomHelp)
	Local cProp := CriaVar("NP9_OBS"),cSolu := CriaVar("NP9_OBS")
	cProp := cProbP;cSolu := cSoluP

	If cNomHelp <> Nil
		PutHelp("P"+Alltrim(cNomHelp),{cProp},{cProp},{cProp},.F.)
		PutHelp("S"+Alltrim(cNomHelp),{cSolu},{cSolu},{cSolu},.F.)
		Help(" ",1,cNomHelp)
	Else
		DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
		DEFINE MSDIALOG oDlgTeste TITLE STR0021 From 4,20 To 25,59 OF oMainWnd COLOR CLR_BLACK,CLR_WHITE
		@ 5,11 GROUP oGroup TO 070,144 LABEL OemtoAnsi(STR0022) OF oDlgTeste PIXEL COLOR CLR_BLUE
		oGroup:oFont := oFont
		@ 13,12 GET oProb VAR cProp MEMO SIZE 130,56 PIXEL OF oGroup NO MODIFY NO BORDER
		oProb:oFont     := oFont
		oProb:bRClicked := {||AllwaysTrue()}

		@ 80,11 GROUP oGroup TO 145,144 LABEL OemtoAnsi(STR0023) OF oDlgTeste PIXEL COLOR CLR_BLUE
		oGroup:oFont := oFont
		@ 88,12  GET oSolu VAR cSolu MEMO SIZE 130,56 PIXEL OF oGroup NO MODIFY NO BORDER
		oSolu:oFont     := oFont
		oSolu:bRClicked := {||AllwaysTrue()}
		ACTIVATE MSDIALOG oDlgTeste  CENTERED
	EndIf
Return

// TRATAMENTO DO DICIONÁRIO DE DADOS
/*
+=================================================================================================+
| Função    : AGRIFDICIONA                                                                        |
| Descrição : Verifica se o registro existe no dicionário de dados                                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 14/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliaa  - Alias do arquivo                                               Obrigatório|
|             cChave  - Chave de acesso  (Sem a filial)                                Obrigatório|
|             nIndic  - Índice de acesso                                               Obrigatório|
|             lMostr  - Indica se mostra mensagem                                      Não obrigat|
+=================================================================================================+          
| Retorna   : lRet    - (.t.,.f.)                                                                 |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRIFDICIONA(cAliaa,cChave,nIndic,lMostr)
	Local lMostT := If(lMostr = Nil,.f.,lMostr)
	AGRAREAORDE(cAliaa,nIndic)
	lRet := If(Dbseek(cChave),.t.,.f.)
	If !lRet .And. lMostT
		Alert(STR0024+Chr(13)+STR0025+"....: "+cAliaa+Chr(13);
		+STR0026+"...: "+cChave+Chr(13)+STR0027+"...: "+Str(nIndic,2))
	Endif
Return lRet

/*
+=================================================================================================+
| Função    : AGRUSADORESER                                                                       |
| Descrição : Retorna o tipo de obrigotoriedade e reserva padrão                                  |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 03/11/2014                                                                          |
+=================================================================================================+                                                                           |  
| Retorna   : Matriz Onde : [Não usado,Não reservado],[Usado chave,Reservado chave],[Obrigatório, |
|                           Obrigatório resevado],[Usado Opcional,Reservado opcional]             |
+=================================================================================================+
|Referências : OGA180                                                                             |
+=================================================================================================+ 
*/
Function AGRUSADORESER()
	Local cUsadoNao := AGRSEEKDIC("SX3","A1_FILIAL",2,"X3_USADO")
	Local cReserNao := AGRSEEKDIC("SX3","A1_FILIAL",2,"X3_RESERV")
	Local cUsadoChv := AGRSEEKDIC("SX3","A1_COD   ",2,"X3_USADO")
	Local cReserChv := AGRSEEKDIC("SX3","A1_COD   ",2,"X3_RESERV")
	Local cUsadoObr := AGRSEEKDIC("SX3","A1_TIPO  ",2,"X3_USADO")
	Local cReserObr := AGRSEEKDIC("SX3","A1_TIPO  ",2,"X3_RESERV")
	Local cUsadoOpc := AGRSEEKDIC("SX3","A1_DDD   ",2,"X3_USADO")
	Local cReserOpc := AGRSEEKDIC("SX3","A1_DDD   ",2,"X3_RESERV")
Return {{cUsadoNao,cReserNao},{cUsadoChv,cReserChv},{cUsadoObr,cReserObr},{cUsadoOpc,cReserOpc}}

/*
+=================================================================================================+
| Função    : AGRSEEKDIC                                                                          |
| Descrição : Posiciona em um determinado registro do dicionário e retorna a informação solicitada|
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlias - Alias do arquivo                                                Obrigatório|
|             cChave - Chave de acesso                                                 Obrigatório|
|             nOrdem - Ordem de acesso                                                 Obrigatório|
|             cFielR - Campo de retorno (Conteúdo)                                     Obrigatório|
+=================================================================================================+          
| Retorna   : cRet   - Conteúdo do campo do dicionário                                            |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRSEEKDIC(cAlias,cChave,nOrdem,cFielR)
	Local aAreaTemF := GetArea(),cRet := " "

	DbSelectArea(cAlias)
	DbSetOrder(nOrdem)
	If DbSeek(cChave)
		cRet := &cFielR.
	Endif
	RestArea(aAreaTemF)
Return cRet

/* 
+=================================================================================================+
| Função    : ARGSX2NOME                                                                          |
| Descrição : Busca a descrição do arquivo/tabela                                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 14/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cVARQUIV - Alias do arquivo/tabela                                      Obrigatório |
+=================================================================================================+  
| Retorna   : cNOMEATA - Descrição do arquivo/tabela                                              |
+=================================================================================================+
*/
Function ARGSX2NOME(cVARQUIV)
Return FWX2Nome(cVARQUIV)


Function AGRSX2NOME(cVARQUIV)
Return ARGSX2NOME(cVARQUIV)

/*
+=================================================================================================+
| Função    : AGRLoadSX1                                                                          |
| Descrição : Carrega configuração de perguntas do perfil do usuário.                             |
| Autor     : Marlon Richard Trettin                                                              |
| Data      : 08/06/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cGrPerg  - Título do Grupo de Perguntas                                  Obrigatório|
|             aMatPerg - Matriz bidimensional contendo os seguintes dados [n,y]        Obrigatório|
|                        Onde y 1 Pergunta, 2 Tipo, 3 Tamanho, 4 Decimal, 5 Validação, 6 F3, 7 GSC|       
|                               8 GRPSXG, 9 HELP, 10 IDFIL, 11 DEF.01, 12 DEF.02, 13 DEF.03       |
|                               14 DEF.04, 15 DEF.05, 16 PICTURE                                  |
+=================================================================================================+                                                                           |  
| Retorno: aRetMVPAR  - Array com as configurações de perguntas do profile do usuário             |
|                       no formato { "MV_PAR99", xConteudo }                                      |
|                       Obs.: pode-se usar este array para salva a situação anterior das perguntas|
|                             do profile do usuário                                               |
+=================================================================================================+
|Referências: OGC003                                                                              |
+=================================================================================================+ 
*/
Function AGRLoadSX1( cGrPerg, aMatPerg )
	Local nX, nTam := 0
	Local cMVPAR, xConteudo, xContProf
	Local aRetMVPAR := {}

	// Le configuracao de parametros do usuario
	For nX := 1 to Len( aMatPerg )
		cMVPAR := "MV_PAR" + StrZero( nX, 2 )
		nTam	:= aMatPerg[ nX, 3 ]

		If FindProfDef( cUserName, cGrPerg, cGrPerg, cMVPAR )

			xContProf := RetProfDef ( cUserName, cGrPerg, cGrPerg, cMVPAR )
			xConteudo := SubStr( xContProf, 2, nTam )
			If SubStr( xContProf, 1, 1 ) == "D"
				xConteudo := CtoD( xConteudo )
			EndIf
			&(cMVPAR) := xConteudo

			// Adiciona parâmetro (MV_PAR) e conteúdo no array de retorno
			aAdd( aRetMVPAR, { cMVPAR, xConteudo } )
		EndIf
	Next nX    
Return( aRetMVPAR )

/*
+=================================================================================================+
| Função    : AGRRestSX1                                                                          |
| Descrição : Restora conteúdo anterior das perguntas lidas do perfil do usuário.                 |
| Autor     : Marlon Richard Trettin                                                              |
| Data      : 08/06/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: aSvdMVPAR - Array com os parâmetros MV_PAR99 e seus respectivos conteúdos salvos    |
|                         anteriormente (retorno da função AGRLoadSX1)                 Obrigatório|
|                         Formato : { "MV_PAR99", xConteudo }                                     |
+=================================================================================================+
|Referências: OGC003                                                                              |
+=================================================================================================+ 
*/
Function AGRRestSX1( aSvdMVPAR )
	Local nX := 0

	For nX := 1 to Len( aSvdMVPAR )
		&( aSvdMVPAR[ nX, 1 ] ) := aSvdMVPAR[ nX, 2 ]
	Next nX    
Return( NIL )

/*
+=================================================================================================+
| Função    : AGRWriteSX1                                                                         |
| Descrição : Grava configuração de perguntas no perfil do usuário.                               |
| Autor     : Marlon Richard Trettin                                                              |
| Data      : 08/06/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cGrperg  - Título do Grupo de Perguntas                                  Obrigatório|
|             aMatperg - Matriz bidimensional contendo os seguintes dados [n,y]        Obrigatório|
|                        Onde y 1 Pergunta, 2 Tipo, 3 Tamanho, 4 Decimal, 5 Validação, 6 F3, 7 GSC|       
|                               8 GRPSXG, 9 HELP, 10 IDFIL, 11 DEF.01, 12 DEF.02, 13 DEF.03       |
|                               14 DEF.04, 15 DEF.05, 16 PICTURE                                  |
+=================================================================================================+
|Referências: OGC003                                                                              |
+=================================================================================================+ 
*/
Function AGRWriteSX1( cGrPerg, aMatPerg )
	Local nX := 0
	Local cMVPAR, cTipo, xConteudo

	// Grava configuracao de perguntas no perfil do usuario
	For nX := 1 to Len( aMatperg )
		cMVPAR 	:= "MV_PAR" + StrZero( nX, 2 )
		cTipo		:= aMatPerg[ nX, 2 ] 
		xConteudo 	:= cTipo + iIf( cTipo=="D", DtoC( &(cMVPAR) ), iIf( cTipo=="N", AllTrim( cValToChar( &(cMVPAR) ) ), &(cMVPAR) ) )

		If FindProfDef( cUserName, cGrPerg, cGrPerg, cMVPAR )
			WriteProfDef(cUserName, cGrPerg, cGrPerg, cMVPAR, cUserName, cGrPerg, cGrPerg, cMVPAR, xConteudo )
		Else                
			WriteNewProf(cUserName, cGrPerg, cGrPerg, cMVPAR, xConteudo )
		Endif 
	Next nX		
Return( NIL )

/*
+=================================================================================================+
| Função    : AGRCRIASX2                                                                          |
| Descrição : Cria e/ou altera definição de tabelas                                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 12/05/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cEmpre - Código da empresa                                               Não Obrigat|
|             aMatX2 - Matriz com os dados da(s) tabela(s)                             Obrigatório|
+=================================================================================================+
|Referências:                                                                                     |
+=================================================================================================+ 
*/
Function AGRCRIASX2(cEmpre,aMatX2)
	Local nxL,nxI,aAreaLo := GetArea(),cTextX := Space(1),lNovo 
	Local lProc := If(Type("lVUPD") <> "U",.t.,.f.),lAlter 
	Local cEmpr := If(cEmpre = Nil,SM0->M0_CODIGO,cEmpre)+"0"
	If lProc
		oProcess:SetRegua2(Len(aMatx2))
	EndIf 	
	For nxL := 1 To Len(aMatX2)
		lAlter := .f.
		lNovo  := If(!AGRIFDICIONA("SX2",aMatX2[nxL,1],1,.F.),.t.,.f.)
		cTextX += If(lNovo,STR0144+" "+STR0145+" "+aMatX2[nxL,1]+" - "+aMatX2[nxL,1]+cEmpr+CRLF,"")
		AGRTRAVAREG(,lNovo	)
		For nxI := 1 To Fcount()
			If nxI <= Len(aMatX2[nxL])
				cValX2 := Alltrim(aMatX2[nxL,nxI])+If(nxI = 3,cEmpr,"")
				y      := "SX2->"+Fieldname(nxI)
				cVal   := Alltrim(&y)
				If !lNovo
					If cVal <> cValX2 .Or. cValX2 <> cVal				
						If !lAlter 
							cTextX := STR0146+" "+STR0145+" "+aMatX2[nxL,1]+" - "+aMatX2[nxL,1]+cEmpr+CRLF
							lAlter := .t.
						EndIf	
						cTextX += Fieldname(nxI)+"  "+cVal+" -> "+aMatX2[nxL,nxI]+CRLF
					EndIf
				EndIf
				y   := "SX2->"+Fieldname(nxI)
				&y. := If(nxI = 3,aMatX2[nxL,1]+cEmpr,aMatX2[nxL,nxI])
			EndIf
		Next nxI  			
		AGRDESTRAREG()
		If lProc
			oProcess:IncRegua2(STR0138+" (SX2)...")
		EndIf  	
	Next nxL
	RestArea(aAreaLo)
Return cTextX

/* 
+=================================================================================================+
| Função    : AGRCRIASX9                                                                          |
| Descrição : Cria registro de relacionameto ( SX9 )                                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/05/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: aMatX9 - Matriz com as informações do(s) relacionamento(s)               Obrigatório|
|                      ATENÇÃO: 2ª posição da matriz é obrigatório,pois, no SX9 não tem chave que |
|                               satisfaz a integridade                                            |
+=================================================================================================+  
| Retorna   : cNOMEATA - Descrição do arquivo/tabela                                              |
+=================================================================================================+
| OBSERVAÇÃO: USAR COM RESTRIÇÕES                                                                 |
+=================================================================================================+
*/
Function AGRCRIASX9(aMatX9)
	Local aAreaX9 := GetArea()
	Local nxL,nxI,cTextX := "",cFilt := "!EOF()"
	DbSelectArea("SX9")
	IndRegua('SX9',CriaTrab(NIL,.F.),'X9_DOM+X9_IDENT',,cFilt,STR0004+"...")
	ARGSETIFARQUI("SX9")

	For nxL := 1 To Len(aMatX9)
		cIdent := Space(3)
		If !Empty(aMatX9[nxL,2])
			lNovo := If(!DbSeek(aMatX9[nxL,1]+aMatX9[nxL,2]),.t.,.f.)	     
			If lNovo
				cTextX += STR0144+" "+aMatX9[nxL,1]+" - "+aMatX9[nxL,2]+" - "+aMatX9[nxL,3]+CRLF
			EndIf	
			AGRTRAVAREG(,lNovo	)
			For nxI := 1 To Fcount()
				If nxI < Len(aMatX9[nxL])
					y			:= "SX9->"+Fieldname(nxI)
					cVal	 	:= Alltrim(&y)
					cValX9	:= Alltrim(aMatX9[nxL,nxI])
					If !lNovo .And. (cVal <> cValX9 .Or. cValX9 <> cVal)				
						cTextX += STR0146+" "+Fieldname(nxI)+"  "+cVal+" -> "+cValX9+CRLF
					EndIf
					&y. := aMatX9[nxL,nxI]
				EndIf							
			Next nxI   			
			AGRDESTRAREG()
			If lNovo
				IndRegua('SX9',CriaTrab(NIL,.F.),'X9_DOM+X9_IDENT',,cFilt,STR0004+"...")
			EndIf
		EndIf			
	Next nxL
	DbselectArea("SX9")
	Set filter To
	RestArea(aAreaX9)
Return cTextX

/* 
+=================================================================================================+
| Função    : AGRCRIASXB                                                                          |
| Descrição : Cria uma consulta padrão ( SXB )                                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 14/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: vAlias - Alias da consulta ( F3 )                                        Obrigatório|
|             aSXBI  - Array com as informações da consulta                            Obrigatório|
+=================================================================================================+  
| Retorna   : cNOMEATA - Descrição do arquivo/tabela                                              |
+=================================================================================================+
*/
/*
DESCONTINUADO - Referente debito SONARQUBE
Function AGRCRIASXB(vAlias,aSXBI)
	Local aAreaXB := GetArea(),cTextXB := "",cAliXB := Alltrim(vAlias)
	Local nxL,nxI,cChaPXB := cAliXB+Space(Len(SXB->XB_ALIAS)-Len(cAliXB))
	Local cColu,lNovo := .f.,cCarC

	For nxL := 1 To Len(aSXBI)
		cColu := If(aSXBI[nxL,3] <> Nil,aSXBI[nxL,3],Space(Len(SXB->XB_ALIAS)))
		lNovo := If(!AGRIFDICIONA("SXB",cChaPXB+aSXBI[nxL,1]+aSXBI[nxL,2]+cColu,1,.f.),.t.,.f.)
		cCarC := cChaPXB+" "+aSXBI[nxL,1]+" "+aSXBI[nxL,2]+" "+cColu
		If lNovo
			cTextXB += STR0144+" "+cCarC+CRLF
		EndIf	
		AGRTRAVAREG(,lNovo	)
		For nxI := 1 To Fcount()
			If nxI <= Len(aSXBI[nxL])+1
				If nxI = 1
					SXB->XB_ALIAS := cChaPXB
				Else
					y			:= "SXB->"+Fieldname(nxI)
					cVal	 	:= Alltrim(&y)
					cValXB	:= Alltrim(aSXBI[nxL,nxI-1])
					If !lNovo .And. (cVal <> cValXB .Or. cValXB <> cVal)				
						cTextXB += STR0146+" "+Fieldname(nxI)+"  "+cVal+" -> "+cValXB+CRLF
					EndIf
					&y. := aSXBI[nxL,nxI-1]
				EndIf	
			EndIf							
		Next nxI   			
		AGRDESTRAREG()
	Next nxL
	RestArea(aAreaXB)
Return cTextXB
*/
/* 
+=================================================================================================+
| Função    : AGRCRIASIX                                                                          |
| Descrição : Cria um índice para a tabela no banco                                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 19/01/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlI   - Alias do compo para a alteração                                 Obrigatório|
|             aDados - Dados para criar o índice                                       Obrigatório|
+=================================================================================================+  
| Referências: AGRA840                                                                            |
+=================================================================================================+
*/
/*
DESCONTINUADO - Referente debito SONARQUBE
Function AGRCRIASIX(cAlI,aDados)
	Local lGravou := .f.,nF,cOrdI := ' ',cOrdIX := '1'
	Local lProc   := If(Type("lVUPD") <> "U",.t.,.f.),cChaveI
	Local cIndger := "",vVetInd := {},cMensa := "",lAlterI := .f.

	For nF := 1 To Len(aDados)
		lAlterI := .f.
		cMensa  := ""
		cChaveI := ""
		If !lProc
			If AGRRETORDEM(cAlI,aDados[nF,1],.T.) = 0
				AGRIFDICIONA("SIX",cAlI,1,.f.)
				While !Eof() .And. SIX->INDICE = cAlI
					cOrdI := SIX->ORDEM
					DbSkip()
				End
				cOrdIX := If(FindFunction("Soma1Old"),Soma1Old(cOrdI),Soma1(cOrdI))
			Endif
		Else
			If !AGRIFDICIONA("SIX",cAlI+Str(nF,1),1,.f.) 
				cOrdIX := Str(nF,1) 
			Else           
				cOrdIX := SIX->ORDEM
			EndIf   		   
		EndIf
		If !AGRIFDICIONA("SIX",cAlI+cOrdIX,1,.f.)
			cMensa := STR0144
			RecLock("SIX",.T.)
			SIX->INDICE := cAlI
			SIX->ORDEM  := cOrdIx
		Else
			RecLock("SIX",.F.)
			cChaveI := Alltrim(SIX->CHAVE)
			lAlterI := If(cChaveI <> Alltrim(aDados[nF,1]) .Or. Alltrim(aDados[nF,1]) <> cChaveI,.t.,.f.)
		EndIf

		SIX->CHAVE     := aDados[nF,1]
		SIX->DESCRICAO := aDados[nF,2]
		SIX->DESCSPA   := aDados[nF,2]
		SIX->DESCENG   := aDados[nF,2]
		If Len(aDados[nF]) > 2 .And. aDados[nF,3] <> Nil
			SIX->DESCSPA := aDados[nF,3]
		Endif
		If Len(aDados[nF]) > 3 .And. aDados[nF,4] <> Nil
			SIX->DESCENG := aDados[nF,4]
		Endif
		SIX->PROPRI		:= If(Len(aDados[nF]) > 4 .And. aDados[nF,5] <> Nil,aDados[nF,5],"S")
		SIX->SHOWPESQ	:= If(Len(aDados[nF]) > 5 .And. aDados[nF,6] <> Nil,aDados[nF,6],"N")
		MsUnLock()
		Aadd(vVetInd,cOrdIX)
		lGravou := .t.
		If lProc
			If !Empty(cMensa) .Or. lAlterI
				cIndger += If(nF > 1 .And. !Empty(cMensa),Space(11),"")+cOrdIx+" - "+If(!Empty(cMensa),Alltrim(SIX->CHAVE),cChaveI+" -> "+Alltrim(SIX->CHAVE))+_CRLF
				TcInternal(60,RetSqlName(cAlI) + "|" + RetSqlName(cAlI)+cOrdIX)
			EndIf	
		EndIf
		If lProc .And. (lAlterI .Or. !Empty(cMensa)) 
			AGRPREPAPP(cAlI)
		EndIf	
	Next nf

	If lGravou .And. !lProc
		Final(OemToAnsi(STR0018))
	Endif
Return cIndger
*/

/* 
+=================================================================================================+
| Função    : AGRRETORDEM                                                                         |
| Descrição : Retorna a ordem se o índice já existe                                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 19/01/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlias - Alias do compo para a alteração                                 Obrigatório|
|             cConte - Conteúdo do índice (chave)                                      Obrigatório|
|             lExato - Indica se a pesquisa e pelo exato ou pelo primeiro parecido     Nao Obriga.|
+=================================================================================================+  
| Retorna   : nIndRet - Número do índice - Se não encontrou retorna 0                             |
+=================================================================================================+
| Referências: AGRCRIASIX                                                                         |
+=================================================================================================+
*/
Function AGRRETORDEM(cAlias,cConte,lExato)
	Local lPosic  := If(lExato = Nil,.t.,lExato)
	Local aAreaId := GetArea(), nIndRet := 0, nIndInc := 0

	If AGRIFDICIONA("SIX",cAlias,1,.f.)
		While !Eof() .And. SIX->INDICE = cAlias
			nIndInc ++
			If lPosic
				If Alltrim(StrTran(Upper(SIX->CHAVE)," ","")) = Alltrim(StrTran(Upper(cConte)," ",""))
					nIndRet := nIndInc
					Exit
				EndIf
			Else
				If Alltrim(StrTran(Upper(cConte)," ","")) $ StrTran(Upper(SIX->CHAVE)," ","")
					nIndRet := nIndInc
					Exit
				Endif
			Endif
			Dbskip()
		End
	Endif         
	RestArea(aAreaId)
Return nIndRet

/* 
+=================================================================================================+
| Função    : AGRPROXORDIX                                                                        |
| Descrição : Retorna a próxima ordem do índice                                                   |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 19/01/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlias - Alias do índice                                                 Obrigatório|
+=================================================================================================+  
| Retorna   : cOrdPr - Número do índice                                                           |
+=================================================================================================+
*/
Function AGRPROXORDIX(vAlias)
	Local aAreaSIX := GetArea(),cOrdPr := Space(Len(SIX->ORDEM)),cUlOrd := cOrdPr
	Local aLetNu   := {{'A','B'},{'B','C'},{'C','D'},{'D','E'},{'E','F'},{'F','G'},{'G','H'},{'H','I'}}
	If AGRIFDICIONA("SIX",vAlias,1)
		cUlOrd := SIX->ORDEM
		While !Eof() .And. SIX->INDICE = vAlias
			cUlOrd := Alltrim(SIX->ORDEM)
			Dbskip()
		End
		nPosOrd := aSCAN(aLetNu,{|x| x[1] == cUlOrd})
		If nPosOrd > 0
			cOrdPr := aLetNu[nPosOrd,2]
		ElseIf cUlOrd = '9'
			cOrdPr := "A"
		Else
			cOrdPr := If(FindFunction("Soma1Old"),PADL(Soma1Old(cUlOrd),1),PADL(Soma1(cUlOrd),1))
		Endif
	Endif
	RestArea(aAreaSIX)
Return cOrdPr

/*
+=================================================================================================+
| Função    : AGRTITULO                                                                           |
| Descrição : Retorna o conteúdo do título do dicionário de dados                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 26/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cCampo  - Campo do SX3                                                   Obrigatorio|
+=================================================================================================+
| Retorna   : cTitLab - Título do camopo passado como parâmetro                                   |
+=================================================================================================+
|Referências : AGRA980                                                                            |
+=================================================================================================+ 
*/
Function AGRTITULO(cCampo)
	Local cTitLab := Space(12)

	cTitLab := FWX3Titulo(cCampo)
	
Return cTitLab

/*/{Protheus.doc} AGRDESCRI
Retorna a descrição do campo passado
@type function
@version  
@author claudineia.reinert
@since 01/11/2021
@param cCampo, character, param_description
@return variant, return_description
/*/
Function AGRDESCRI(cCampo)
	Local cDescr := Space(12)

	cDescr := GetSX3Cache(cCampo, "X3_DESCRIC")
	
Return cDescr

/*
+=================================================================================================+
| Função    : AGRSX3OBR                                                                           |
| Descrição : Retorna os campos obrigatórios da tabela                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 13/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cFamilh - Código da familia da tabela do SX3                             Obrigatorio|
+=================================================================================================+
| Retorna   : vVetObr - Vetor com os campos                                                       |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRSX3OBR(cFamilh)
	Local vVetObr := {}
	Local nX      := 0
	Local aCampos := FWSX3Util():GetAllFields( cFamilh, .f. ) //Retorna os campos de um alias específico da SX3.

	If !Empty(aCampos)

		For nX := 1 To Len(aCampos)
			If x3obrigat(aCampos[nX])
				Aadd(vVetObr,aCampos[nX])
			EndIf  
		Next nX

	EndIf   

Return vVetObr

/*
+=================================================================================================+
| Função    : AGRPREFIXOCAMP                                                                      |
| Descrição : Retorno o prefixo dos campos                                                        |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/11/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlia1 - Alias da tabela                                                 Obrigatório|
+=================================================================================================+                                                                           |  
| Retorna   : Prefixo ou Nulo                                                                     |
+=================================================================================================+
|Referências : Função AGRPREFIXOCAMP                                                               |
+=================================================================================================+ 
*/
Function AGRPREFIXOCAMP(cAlia1)
	cCampo := AGRSEEKDIC("SX3",cAlia1,1,"X3_CAMPO")
	nPosTr := At("_",cCampo)
Return If(nPosTr > 0,SubStr(cCampo,1,nPosTr-1),'')

/*
+=================================================================================================+
| Função    : AGRRETSX3BOX                                                                        |
| Descrição : Retorno todo o conteúdo ou uma opção do X3_CBOX                                     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/11/2014                                                                          |
+=================================================================================================+
| Parâmetros: cCampSX3 - Campo                                                         Obrigatório|
|             cCondSX3 - Condição de filtro                                            Não Obrigat|
+=================================================================================================+  
| Retorna   : cSX3BOX - Descrição do Sub-item do SX3 box ou todo o conteúdo                       |
+=================================================================================================+
|Referências:                                                                                     |
+=================================================================================================+ 
*/
Function AGRRETSX3BOX(cCampSX3,cCondSX3)
	Local cSX3BOX := '',aAreaAtu := GetArea(),nPosIg
	Local nv := 0,cVCondN,cStrings := ''
	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek(cCampSX3)
		cSX3BOX := AllTrim(X3CBox())
		If cCondSX3 <> Nil
			cVCondN := cCondSX3+"="
			nPosIg  := At(cVCondN,cSX3BOX)
			If nPosIg > 0
				For nv := nPosIg To Len(Alltrim(cSX3BOX))
					cCaract := Substr(cSX3BOX,nv,1)
					If cCaract = ';'
						Exit
					Else
						cStrings += cCaract
					Endif
				Next
				If Len(cStrings) > 0
					nPosIg := At("=",cStrings)
					If nPosIg > 0
						cSX3BOX := Substr(cStrings,nPosIg+1,Len(cStrings))
					Endif
				Endif
			Else 
				cSX3BOX := cStrings
			Endif
		Endif
	Endif
	RestArea(aAreaAtu)
Return cSX3BOX

// TRATAMENTO DE VALIDAÇÃO DE PARÂMETROS DE PERGUNTAS
/*
+=================================================================================================+
| Função    : AGRGRUPSX1                                                                          |
| Descrição : Retorna a variável + o tamanho do grupo de pergunta                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 26/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cPergX1 - Conteúdo do grupo da pergunta                                  Obrigatório|
+=================================================================================================+
| Retorna   : cPergEx - Conteúdo exato do grupo (cPergX1+espaço(s)) do X1_GRUPO                   |
+=================================================================================================+
*/
Function AGRGRUPSX1(cPergX1)
	Local cPergEx := Space(10),cPergRet := cPergX1
	If Len(cPergX1) < Len(cPergEx)
		cPergRet := Alltrim(cPergX1)+Space(10-Len(Alltrim(cPergX1)))
	Endif   
Return cPergRet

/*
+=================================================================================================+
| Função    : AGRDECO                                                                             |
| Descrição : Consistência do código  ( De do SX1....)                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 26/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliaA  -> Alias do arquivo de pesquisa                                  Obrigatorio|
|             cPar01  -> Código de pesquisa  ( De .... )                               Obrigatorio|
|             cPar02  -> Código de pesquisa  ( Até ... )                               Obrigatorio|
+=================================================================================================+
*/
Function AGRDECOD(cAliaA,cPar01,cPar02)
	Local cParde := If(cAliaA = "SM0",cEmpAnt+cPar01,cPar01)
	If !Empty(cPar01)
		If !ExistCpo(cAliaA,cParde)
			Return .f.
		ElseIf !Empty(cPar02) .And. cPar01 > cPar02
			Help(,1,"HELP",,STR0202,1,0)
			Return .f.   
		EndIf
	Endif        
Return .t.

/*
+=================================================================================================+
| Função    : AGRATECOD                                                                           |
| Descrição : Consistência do código  ( até do SX1....)                                           |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 26/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliaA  -> Alias do arquivo de pesquisa                                  Obrigatorio|
|             cPar01  -> Código de pesquisa  ( De .... )                               Obrigatorio|
|             cPar02  -> Código de pesquisa  ( Até ... )                               Obrigatorio|
+=================================================================================================+
*/
Function AGRATECOD(cAliaA,cPar01,cPar02)
	Local cParAte := If(cAliaA = "SM0",cEmpAnt+cPar02,cPar02)
	If Empty(cPar02)
		Help(" ",1,"ATEINVALID")
		Return .f.
	Elseif cPar02 < cPar01
		Help(" ",1,"DEATEINVAL")
		Return .f.
	Endif

	If cPar02 = replicate('Z',Len(cPar02))
		Return .t.
	ElseIf !ExistCpo(cAliaA,cParAte)
		Return .f.
	Endif
Return .t.

/*
+=================================================================================================+
| Função    : AGRATESX5                                                                           |
| Descrição : Consistência do código  ( até do SX5....)                                           |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 26/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cTabela  - Código da tabela                                              Obrigatório|
|             cChave   - Chave de acesso ( Até código )                                Obrigatório|
|             cPerg1   - Código De                                                     Obrigatório|
+=================================================================================================+
*/
Function AGRATESX5(cTabela,cChave,cPerg1)
	Local aAreaAn := GetArea()

	If Empty(cChave)
		Help(" ",1,"ATEINVALID")
		Return .f.
	Endif
	If cChave = Replicate('Z',Len(cChave))
		Return .t.
	Endif
	If Empty(FWGetSX5( cTabela, cChave )) //!ExistCpo("SX5",cTabela+cChave+Space(Len(sx5->x5_chave)-Len(cChave)))
		Return .f.
	Endif
	If cChave < cPerg1
		Help(" ",1,"DEATEINVAL")
		Return .f.
	Endif
	RestArea(aAreaAn)
Return .t.

// TRATAMENTO COM FILIAIS
/*
+=================================================================================================+
| Função    : AGRFILFIEXC                                                                         |
| Descrição : Busca todos as filiais da empresa corrente com permissão do usuário                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 26/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: lLista  - Incluir todas as filias no retorno                             Não Obrigat|
+=================================================================================================+  
| Retorna   : Vetor ou matriz conforme: lLista Com valor matriz com todas as filiais              |
|                                       lLista Nulo Vetor com a menor e a maior filial            |
+=================================================================================================+
| Referência: OGR400                                                                              |
+=================================================================================================+
*/
Function AGRFILFIEXC(lLista) 
	Local aFilUser := Asort(MatFilCalc(.f.),,,{|x,y|x[2] < y[2]})
Return If(lLista = Nil,{aFilUser[1,2],aFilUser[Len(aFilUser),2]},aFilUser)

// TRATAMENTO COM A BASE
/*
+=================================================================================================+
| Função    : AGRALTCAMBA                                                                         |
| Descrição : Altera o conteúdo de um campo da base de dados                                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 14/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlias - Alias do arquivo/tabela                                         Obrigatório|
|             cChav  - Chave de acesso                                                 Obrigatório|
|             nInd   - Indice de acesso                                                Obrigatório|
|             cCamp  - Nome do campo                                                   Obrigatório|
|             cCont  - Conteúdo a ser gravado                                          Obrigatório|
|             cFili  - Código da filial                                                Não Obrigat|
|             lFilAC - Indica se inclui o código da filial antes da chave sem a neces- Nao Obrigat|
|                      sidade de procurar se tem _FILIAL no início da chave (SIX) (.t.,.f.)       |    
+=================================================================================================+          
| Retorna   : lRet    - (.t.,.f.)                                                                 |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRALTCAMBA(cAlias,cChav,nInd,cCamp,cCont,cFili,lFilAC)
	Local aAreaAt := GetArea(),lRet := .f.,lTipI := .f.
	If AGRIFDBSEEK(cAlias,cChav,nInd,.f.,cFili,If(lFilAC <> Nil,lFilAC,Nil))
		aEstrD := DbStruct()
		If Ascan(aEstrD,{|x| x[1] == cCamp}) > 0
			cCa1 := cAlias+"->"+cCamp 
			If type(cCa1) = Valtype(cCont)
				lTipI := .t.
			ElseIf type(cCa1) = 'M' .And. Valtype(cCont) = 'C'
				lTipI := .t.
			Endif
			If lTipI   
				If &(cCa1) <> cCont
					RecLock(cAlias,.f.)
					&(cCa1) := cCont
					(cAlias)->(MSUNLOCK())
					lRet := .t.
				Endif   
			Endif
		Endif
	Endif
	RestArea(aAreaAt)
Return lRet

/*
+=================================================================================================+
| Função    : AGRAEAORDE                                                                          |
| Descrição : Seleciona o alias e o índice                                                        |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 14/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlias - Alias do arquivo\Tabela                                         Obrigatório|
+=================================================================================================+ 
|Referências : AGRA840                                                                           |
+=================================================================================================+         
*/
Function AGRAREAORDE(cAlias,nInd)
	Local nIndA := If(nInd = Nil,1,nInd)
	DbSelectArea(cAlias)
	DbSetOrder(nIndA)
Return

/*
+=================================================================================================+
| Função    : AGRIFDBSEEK                                                                         |
| Descrição : Verifica se o registro existe na base de dados                                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 14/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlias  - Alias do arquivo                                               Obrigatório|
|             cChave  - Chave de acesso  (Sem a filial)                                Obrigatório|
|             nIndic  - Índice de acesso                                               Obrigatório|
|             lMostr  - Indica se mostra mensagem                                      Nao Obrigat|
|             cFilia  - Código da filial                                               Nao Obrigat|
|             lFilAC  - Indica se inclui o código da filial antes da chave sem a neces-Nao Obrigat|
|                       sidade de procurar se tem _FILIAL no início da chave (SIX) (.t.,.f.)      |                         
+=================================================================================================+          
| Retorna   : .T.,.F. - .T. Achou,  .F. Não achou o registro                                      |
+=================================================================================================+
|Referências : AGRA980                                                                            |
+=================================================================================================+ 
*/
Function AGRIFDBSEEK(cAlias,cChave,nIndic,lMostr,cFilia,lFilAC)
	Local cFilIF := xFilial(cAlias,cFilia),lRetLo := .f.
	Local lMostT := If(lMostr = Nil,.f.,lMostr)
	Local cChaAC := If(lFilAC <> Nil .And. lFilAC,cFilIF+cChave,If(AGRFILNACHAVE(cAlias,nIndic,cFilia),cFilIf+cChave,cChave)) 
	AGRAREAORDE(cAlias,nIndic)
	lRetLo := If(MsSeek(cChaAC),.T.,.F.)
	If !lRetLo .And. lMostT
		Help(" ",1,"NAOREGISTRO",,CHR(13) + STR0024+Chr(13)+STR0025+"....: "+cAlias+Chr(13);
		+STR0026+"...: "+cChave+Chr(13)+STR0027+"...: "+Str(nIndic,2),3,0) 
	Endif
Return lRetLo

/*
+=================================================================================================+
| Função    : AGRFILNACHAVE                                                                       |
| Descrição : Verifica se no início do índice tem a filial                                        |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlias - Alias do arquivo\Tabela                                         Obrigatório|
|             nInd   - Índice de acesso                                                Obrigatório|
|             cFilAc - Filial de acesso                                                Nao Obrigat|
+=================================================================================================+          
| Retorna   : lRetF - .t.,.f.                                                                     |
+=================================================================================================+
*/
Function AGRFILNACHAVE(cAlias,nInd,cFilac)
	Local lTemFilI	:= .f.
	Local cInd			:= If(nInd > 9,AGRCONVINDI(nInd,"N"),Str(nInd,1))
	Local cDesInd 	:=  Alltrim(Posicione("SIX",1,cAlias+cInd,"CHAVE"))
	nPosTra := At("_",cDesInd)
	If nPosTra > 0
		nPosMai := At("+",cDesInd)
		cFilInc := If(nPosMai > 0,SubStr(cDesInd,nPosTra+1,(nPosMai-1)-nPosTra),;
		SubStr(cDesInd,nPosTra+1,Len(cDesInd)-nPosTra))
		lTemFilI := 'FILIAL' $ cFilInc
	Endif
Return lTemFilI

/*
+=================================================================================================+
| Função    : AGRCONVINDI                                                                         |
| Descrição : Conversão do código do índice para numérico/caracter                                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cvInd   - Conteúdo do índice                                             Obrigatório|
|             ctip    - Tipo do conteúdo                                               Obrigatório|
+=================================================================================================+          
| Retorna   : cIndi   - Índice convertido em numérico ou em caracter                              |
+=================================================================================================+
*/
Function AGRCONVINDI(cvInd,cTip)
	If cTip = "N"
		cIndi := If(cvInd > 10,Chr((cvInd - 9)+64),Str(cvInd,2))
		cIndi := Alltrim(cIndi)
	Else
		cIndi := If(cvInd > "9",(Asc(cvInd)-64)+9,Val(cvInd))
	Endif
Return cIndi

/*
+=================================================================================================+
| Função    : ARGSETIFARQUI                                                                       |
| Descrição : Seta para o início ou no final do arquivo/tabela                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlias - Alias do arquivo\Tabela                                         Obrigatório|
|             cTip   - Indica o posicionamento (Início/final)                          Nao Obrig. |
|             nInd   - Índice de acesso                                                Nao Obrig. |
+=================================================================================================+  
|Referências : AGRA840                                                                            |
+=================================================================================================+         
*/
Function ARGSETIFARQUI(cAlias,cTip,nInd)
	Local cTipP := If(cTip = Nil,"I",cTip)
	DbSelectArea(cAlias)
	If nInd <> Nil
		DbSetOrder(nInd)
	Endif   
	If cTipP = "I"
		DbGotop()
	Else
		DbGobottom()
		DbSkip()
	Endif
Return

/*
+=================================================================================================+
| Função    : ARGCLOSEAREA                                                                        |
| Descrição : Fecha uma tabela ou arquivo                                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 22/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliasA - Alias do arquivo\Tabela                                        Obrigatório|
+=================================================================================================+  
|Referências : AGRA840                                                                            |
+=================================================================================================+         
*/
Function ARGCLOSEAREA(cAliasA)
	DbSelectArea(cAliasA)
	DbcloseArea()
Return

/*
+=================================================================================================+
| Função    : AGRDBSELSKIP                                                                        |
| Descrição : Seleciona um arquivo/tabela e seta o próximo registro                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlias - Alias do arquivo\Tabela                                         Obrigatório|
|             lProxi - Próximo registro                                                Nao Obrig. |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRDBSELSKIP(cAlias,lProxi)
	Local nPAReg := If(lProxi = Nil,1,If(lProxi,1,-1))
	DbSelectArea(cAlias)
	DbSkip(nPAReg)
Return

/*
+=================================================================================================+
| Função    : AGRDELETAREG                                                                        |
| Descrição : Deleta um determinado registro                                                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 09/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliasD - Alias da Tabela                                                Não Obrigat|
|             cChavAc - Chave de acesso sem a filial                                   Não Obrigat|
|             nIndice - Número do índice de acesso                                     Não Obrigat|
+=================================================================================================+
| Retorna   : lRet    - .f.,.t.                                                                   |
+=================================================================================================+
| OBSERVAÇÃO: Se não for informado cAliasD será deletado o registro da tabela setado              |
+=================================================================================================+
|Referências : AGRA980                                                                            |
+=================================================================================================+ 
*/
Function AGRDELETAREG(cAliasD,cChavAc,nIndice)
	Local nIndiAc := If(nIndice = Nil,1,nIndice),lDeleta := .f.
	Local cAliaDe := If(cAliasD = Nil,alias(),cAliasD),lRet := .f.
	If cAliasD = Nil
		lDeleta := .t.
	ElseIf AGRIFDBSEEK(cAliaDe,cChavAc,nIndiAc,.f.)
		lDeleta := .t.
	EndIf
	If lDeleta       
		DbselectArea(cAliaDe)
		RecLock(cAliaDe,.F.)
		DbDelete()
		(cAliaDe)->(MsUnLock())
		lRet := .t.
	EndIf   
Return lRet

/*
+=================================================================================================+
| Função    : AGRDOCLOTPAI                                                                        |
| Descrição : Pesquisa qual é o lote origem do lote em questão que possui documento tecnicos(NP9) |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 02/09/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cVsafra - Código da safra do lote                                        Não Obrigat|
|             cVprod  - Código do produto do lote                                      Não Obrigat|
|             cVlote  - Código dolote                                                  Não Obrigat|
|             lPosi   - Posiciona na NP9                                               Não Obrigat|
|             lRVet   - Tipo de retorno (.t. = Vetor, .f. Chvave do Lote               Não Obrigat|
+=================================================================================================+
| OBSERVAÇÃO: Verificar condições do parâmetros e só é valida pelo NP9_TRATO = 1                  |
+=================================================================================================+
|Referências : AGRA900                                                                            |
+=================================================================================================+ 
*/
Function AGRDOCLOTPAI(cVsafra,cVprod,cVlote,lPosi,lRVet)
	Local aAreaAt  := GetArea(),aAreaNP9,aMatNP9 := {},lRet := If(lRVet = Nil,.f.,lRVet)
	Local cSafr := CriaVar("NP9_CODSAF"),cPror := CriaVar("NP9_PROD"),cLotr := CriaVar("NP9_LOTE")
	Local lSeek := If(lPosi = Nil,.f.,lPosi),csafra,cprod,clote,nRegNP9 := 0,nx 
	DbSelectArea("NP9")
	nRegNP9  := Recno() 
	aAreaNP9 := GetArea()

	If lSeeK
		AGRIFDBSEEK("NP9",cVsafra+cVprod+cVlote,1,.F.)
	EndIf

	csafra := If(lSeeK,NP9->NP9_CODSAF,cVsafra) 
	cprod  := If(lSeeK,NP9->NP9_PROD,cVprod)
	clote  := If(lSeeK,NP9->NP9_LOTE,cVlote)

	aMatNP9 :=  AGRBUSREGIS("NP9",xFilial("NP9")+csafra+clote,3,.t.,.f.,;
	"NP9->NP9_FILIAL = XFILIAL('NP9') .And. NP9->NP9_CODSAF = '"+csafra+"' .And. NP9->NP9_LOTE = '"+clote+"'",;
	{{"NP9_CODSAF"},{"NP9_PROD"},{"NP9_LOTE"}},"NP9->NP9_TRATO = '2'","M")

	If !Empty(aMatNP9) .And. aMatNP9[1] .And. !Empty(aMatNP9[2])
		For nx := 1 To Len(aMatNP9)
			cChavAX := Alltrim("NP9"+Xfilial("NP9")+Xfilial("NP9")+aMatNP9[2,1,1]+aMatNP9[2,1,2]+aMatNP9[2,1,3])
			cChavAC := cChavAX+Space(Len(AC9->AC9_ENTIDA+AC9->AC9_FILENT+AC9->AC9_CODENT)-Len(Alltrim(cChavAX)))
			If AGRIFDBSEEK("AC9",cChavAC,2,.F.)
				cSafr := aMatNP9[2,1,1]
				cPror := aMatNP9[2,1,2]
				cLotr := aMatNP9[2,1,3]
				Exit
			EndIf
		Next nx		
	EndIf

	RestArea(aAreaNP9) 
	DbGoto(nRegNP9)                                                                                                                                  
	RestArea(aAreaAt)
Return If(lRet,{cSafr,cPror,cLotr},cSafr+cPror+cLotr)

/*
+=================================================================================================+
| Função    : AGRATSTAFILHO                                                                       |
| Descrição : Atualiza o status dos lotes filhos                                                  |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 22/10/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cVsafra - Código da safra do lote                                        Não Obrigat|
|             cVprod  - Código do produto do lote                                      Não Obrigat|
|             cVlote  - Código dolote                                                  Não Obrigat|
|             lPosi   - Posiciona na NP9                                               Não Obrigat|
+=================================================================================================+
| OBSERVAÇÃO: Verificar condições do parâmetros e só é valida pelo NP9_TRATO = 1                  |
+=================================================================================================+
|Referências : AGRA960                                                                            |
+=================================================================================================+ 
*/
Function AGRATSTAFILHO(cVsafra,cVprod,cVlote,lPosi)
	Local aAreaAt := GetArea(),aMatNP9 := {},cStatus
	Local lSeek := If(lPosi = Nil,.f.,lPosi),nRegNP9 := 0,nx 

	If lSeeK
		AGRIFDBSEEK("NP9",cVsafra+cVprod+cVlote,1,.F.)
	EndIf
	DbSelectArea("NP9")
	nRegNP9  := Recno() 
	aAreaNP9 := GetArea()
	cStatus  := NP9->NP9_STATUS

	If NP9->NP9_TRATO = '2'
		aMatNP9 :=  AGRBUSREGIS("NP9",xFilial("NP9")+NP9->NP9_CODSAF+NP9->NP9_LOTE,3,.t.,.f.,;
		"NP9->NP9_FILIAL = XFILIAL('NP9') .And. NP9->NP9_CODSAF = '"+NP9->NP9_CODSAF+"' .And. NP9->NP9_LOTE = '"+NP9->NP9_LOTE+"'",;
		{{"NP9_CODSAF"},{"NP9_PROD"},{"NP9_LOTE"}},"NP9->NP9_TRATO <> '2'","M")
		For nx := 1 To Len(aMatNP9[2])
			AGRALTCAMBA("NP9",aMatNP9[2,nx,1]+aMatNP9[2,nx,2]+aMatNP9[2,nx,3],1,"NP9_STATUS",cStatus)
		Next nx		
	EndIf

	RestArea(aAreaNP9) 
	DbGoto(nRegNP9)                                                                                                                                  
	RestArea(aAreaAt)
Return

/*
+=================================================================================================+
| Função    : AGRRETCBASE                                                                         |
| Descrição : Busca um conteúdo de um registro                                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 22/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliasT - Alias da Tabela                                                Obrigatório|
|             cChaveT - Chave de acesso ( sem filial)                                  Obrigatório|
|             nIndicT - Número do índice de acesso                                     Não Obrigat|
|             cCampoR - Campo de retorno                                               Obrigatório|
+=================================================================================================+
|Referências : DICIONÁRIO,OGA600                                                                  |
+=================================================================================================+ 
*/
Function AGRRETCBASE(cAliasT,cChaveT,nIndicT,cCampoR)
	Local cCampAx := Alltrim(cCampoR)+Space(10-Len(cCampoR)),aAreaAt := GetArea()
	Local cCont := AGRINICIAVAR(cCampAx),nInd := If(nIndicT = Nil,1,nIndicT)

	If AGRIFDBSEEK(cAliasT,cChaveT,nInd,.F.)
		cCont := &(cAliasT+"->"+cCampoR)
	Endif	
	RestArea(aAreaAt)
Return cCont 

// TRATAMENTO DE TRAVAMENTO E DESTRAVAMENTO
/*
+=================================================================================================+
| Função    : AGRTRAVAREG                                                                         |
| Descrição : Trava o registro corrente                                                           |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 22/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliasT - Alias da Tabela                                                Não Obrigat|
|             lTipoTr - Tipo de travamento                                             Não Obrigat|
+=================================================================================================+
| OBSERVAÇÃO: Se não for informado cAliasT será travado o registro setado                         |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRTRAVAREG(cAliasT,lTipoTr)
	Local lTipoTl := If(lTipoTr = Nil,.f.,lTipoTr)
	Local cAliasL := If(cAliasT = Nil,alias(),cAliasT)
	DbselectArea(cAliasL)
	RecLock(cAliasL,lTipoTl)
Return 

/*
+=================================================================================================+
| Função    : AGRDESTRAREG                                                                        |
| Descrição : Destrava o registro corrente                                                        |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 22/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliasT - Alias da Tabela                                                Não Obrigat|
+=================================================================================================+
| OBSERVAÇÃO: Se não for informado cAliasT será travado o registro setado                         |
+=================================================================================================+
|Referências : AGRA960                                                                            |
+=================================================================================================+ 
*/
Function AGRDESTRAREG(cAliasT)
	Local cAliasL := If(cAliasT = Nil,alias(),cAliasT)
	DbselectArea(cAliasL)
	MsUnLock()
Return 

/*                                                                                                 
+=================================================================================================+
| Função    : AGRTRAVAROT                                                                         |
| Descrição : Travamento de um bloco de processo para o acesso de um único usuário                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 19/05/2015                                                                          | 
+=================================================================================================+ 
|Parâmetros : cFuncao - Nome da função de inicio do processo                           Obrigatório|
+=================================================================================================+ 
|Referências: AGRA900                                                                             |
+=================================================================================================+  
*/
Function AGRTRAVAROT(cFuncao)
	Local nTenta := 0
	If AGRFUNCRPO(cFuncao,.f.)
		While !LockByName(cFuncao+cEmpAnt,.T.,.T.,.T.) .And. nTenta <= 50
			nTenta ++
			Sleep(5000)
		End
		If nTenta >= 50
			MsgInfo(STR0095+" LOCKBYNAME "+STR0096+" "+cFuncao,STR0021)
			Return .f.
		EndIf
	EndIf
Return .t.

/*                                                                                                 
+=================================================================================================+
| Função    : AGRDESTROTIN                                                                        |
| Descrição : Destravamento de um bloco de processo para o acesso de um único usuário             |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 19/05/2015                                                                          | 
+=================================================================================================+ 
|Parâmetros : cFuncao - Nome da função de fim do processo                              Obrigatório|
+=================================================================================================+ 
|Referências: AGRA900                                                                             |
+=================================================================================================+  
*/
Function AGRDESTROTIN(cFuncao)
	If  AGRFUNCRPO(cFuncao,.f.)
		UnLockByName(cFuncao+cEmpAnt,.T.,.T.,.T.)
	EndIf
Return

/*
+=================================================================================================+
| Função    : AGRULTDADO                                                                          |
| Descrição : Verifica qual é o útilmo conteúdo de um campo                                       |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 22/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliasU - Alias da Tabela                                                Obrigatório|
|             cChaveU - Chave de acesso (se for tabela do sistema conter a filial)     Obrigatório|
|             nIndicU - Índice de acesso                                               Não Obrigat|
|             cWhileU - Condição do loop                                               Obrigatório|
|             cCampoU - Conteúdo do campo da tabela                                    Obrigatório|
+=================================================================================================+
| Retorna   : cRetUlt - Valor do último conteúdo do campo                                         |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRULTDADO(cAliasU,cChaveU,nIndicU,cWhileU,cCampoU) 
	Local nIndicL := If(nIndicU = Nil,1,nIndicU),aEstrut,cRetUlt
	DbselectArea(cAliasU)
	DbSetOrder(nIndicL)
	If DbSeek(cChaveU)
		aEstrut := Dbstruct()
		If Ascan(aEstrut,{|x| Alltrim(x[1]) = Alltrim(cCampoU)}) > 0
			While !Eof() .And. cChaveU = &cWhileU
				cLabelU := cAliasU+"->"+cCampoU      
				cRetUlt := &(cLabelU)
				DbSkip()
			End
		EndIf   
	EndIf
Return cRetUlt

/*
+=================================================================================================+
| Função    : AGRDELWHILE                                                                         |
| Descrição : Deleta registro em uma seguência ( Tipo While )                                     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 22/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliasD - Alias da Tabela                                                Obrigatório|
|             cChaveD - Chave de acesso (se for tabela do sistema conter a filial)     Obrigatório|
|             nIndicD - Índice de acesso                                               Não Obrigat|
|             lIndPaD - Índice se seta o primeiro registro parecido                    Não Obrigat|
|             lIndisD - Índice se seta registro antes do while                         Não Obrigat|
|             cWhileD - Condição do loop (While)                                       Obrigatório|
|             cConIfD - Condicional  (If)                                              Não Obrigat|
+=================================================================================================+
|Referências: AGRA840                                                                             |
+=================================================================================================+ 
*/
Function AGRDELWHILE(cAliasD,cChaveD,nIndicD,lIndPaD,lIndisD,cWhileD,cConIfD) 
	Local aAreaAt := GetArea()
	Local nIndicL := If(nIndicD = Nil,1,nIndicD)
	Local lIndSek := If(lIndisD = Nil,.f.,lIndisD)
	Local lIndPSe := If(lIndPaD = Nil,.f.,lIndPaD)
	Local lDeleta := .t.
	If lIndSek
		DbselectArea(cAliasD)
		DbSetOrder(nIndicL)
		DbSeek(cChaveD,lIndPSe)
	EndIf       
	While !Eof() .And. &cWhileD
		lDeleta := .t.
		If cConIfD <> Nil .And. !Empty(cConIfD)
			lDeleta := &cConIfD
		EndIf
		If lDeleta
			AGRDELETAREG()
		EndIf
		AGRDBSELSKIP(cAliasD)
	End
	RestArea(aAreaAt)
Return

/*
+=================================================================================================+
| Função    : AGRBUSREGIS                                                                         |
| Descrição : Busca os registros de acordo com parametrização                                     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliasB - Alias da Tabela                                                Obrigatório|
|             cChaveB - Chave de acesso (se for tabela do sistema conter a filial)     Obrigatório|
|             nIndicB - Índice de acesso                                               Não Obrigat|
|             lIndisB - Índice se seta registro antes do while                         Não Obrigat|
|             lIndPaB - Índice se seta o primeiro registro parecido                    Não Obrigat|
|             cWhileB - Condição do loop (While)                                       Obrigatório|
|             aMatCaB - Matriz com os campos de retorno                                Obrigatório|
|             cConIfB - Condicional  (If)                                              Não Obrigat|
|             cTipoRB - Tipo do retorno (A - Arquivo temporário,M - Matriz)            Não Obrigat|
|             vVetInB - Vetor com os índices para cTipoRB = A                          Não Obrigat|
+=================================================================================================+
|Retorna   : vVetRetB - Vetor com duas posições Onde:                                             |
|                       [1] = .t. Se não houve problemas na montagem, [2] Se cTipoRB = A Alias do |
|                                                 arquivo temporário,[3] Nome do temporário,      |
|                                                                     aMatDad Matriz com os dados |
|                       [1] = .f. Houve problemas na montagem, [2] Descrição do problema          |
|            OBSERVAÇÃO se retornar arquivo temporário após o processamento o mesmo deverá ser apa|
|                       gado                                                                      | 
+=================================================================================================+
|Referências:                                                                                     |
+=================================================================================================+ 
*/
Function AGRBUSREGIS(cAliasB,cChaveB,nIndicB,lIndisB,lIndPaB,cWhileB,aMatCaB,cConIfB,cTipoRB,vVetInB) 
	Local aAreaAt := GetArea(),aMatDad := {}
	Local nIndicL := If(nIndicB = Nil,1,nIndicB)
	Local lIndSek := If(lIndisB = Nil,.f.,lIndisB)
	Local lIndPSe := If(lIndPaB = Nil,.f.,lIndPaB)
	Local cTipoRe := If(cTipoRB = Nil,"M",cTipoRB)
	Local lGravar := .t.,nx,cMensa := Space(1)
	Local aEstrut := {},aEsTemp := {} 

	DbselectArea(cAliasB)
	aEstrut := Dbstruct()
	If aMatCaB <> Nil
		For nx := 1 To Len(aMatCaB)
			If Ascan(aEstrut,{|x| x[1] = aMatCaB[nx,1]}) = 0
				cMensa := STR0046+" "+Alltrim(aMatCaB[nx])+" "+STR0047+" "+cAliasB
				Exit
			EndIf
		Next nx
	EndIf	

	If cTipoRe <> "M"
		vRet := If(aMatCaB = Nil,AGRCRIATRB(cAliasB,aMatCab,vVetInB,"AGRBUSREGIS",.F.),;
		AGRCRIATRB(,aMatCab,vVetInB,"AGRBUSREGIS",.F.))
		If !vRet[1]
			cMensa := vRet[2]
		Else     
			cNoTemp := vRet[3]
			cAlTemp := vRet[4]
			aEstemp := Dbstruct()
		EndIf   
	EndIf

	If Empty(cMensa)
		DbselectArea(cAliasB)
		If lIndSek
			DbSetOrder(nIndicL)
			DbSeek(cChaveB,lIndPSe)
			If lIndPSe .And. AGRIFDICIONA("SX2",cAliasB,1,.F.)
				If &(cAliasB+'->'+ AGRPREFIXOCAMP(cAliasB)+'_FILIAL') <> Xfilial(cAliasB)
					DbSelectArea(cAliasB)
					Dbskip(-1)
				EndIf       
			EndIf   
		EndIf  
		DbSelectArea(cAliasB)    
		While !Eof() .And. &cWhileB
			lGravar := .t.
			If cConIfB <> Nil .And. !Empty(cConIfB)
				lGravar := &cConIfB
			EndIf
			If lGravar
				If cTipoRe = "M"
					Aadd(aMatDad,{})
					For nx := 1 To len(aMatCaB)
						cConteu := cAliasB+"->"+aMatCab[nx,1]
						Aadd(aMatDad[Len(aMatDad)],&cConteu)
					Next nx
				Else
					AGRTRAVAREG(cAlTemp,.t.)
					For nx := 1 To Fcount()
						nPos := aScan(aEstrut,{|x| AllTrim(x[1]) == Fieldname(nx)})
						If nPos > 0
							x := cAliasB+"->"+aEstrut[nPos,1]
							y := (cAlTemp)+"->"+Fieldname(nx)
							&y. := &x.
						EndIf	 
					Next nx
					(cAlTemp)->(MsUnLock())
				EndIf  
			EndIf
			AGRDBSELSKIP(cAliasB)
		End
	EndIf	
	RestArea(aAreaAt)
Return If(!Empty(cMensa),{.f.,cMensa},{.t.,If(cTipoRe = "M",aMatDad,cAlTemp)})

/*
+=================================================================================================+
| Função    : AGRSOMACAMP                                                                         |
| Descrição : Busca os registros de acordo com parametrização e soma                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 14/09/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAliasB - Alias da Tabela                                                Obrigatório|
|             cChaveB - Chave de acesso (se for tabela do sistema conter a filial)     Obrigatório|
|             nIndicB - Índice de acesso                                               Não Obrigat|
|             cWhileB - Condição do loop (While)                                       Obrigatório|
|             vVetCam - Matriz com os campos de retorno para somar                     Obrigatório|
|             cConIfB - Condicional  (If)                                              Não Obrigat|
+=================================================================================================+
|Retorna   : vVetRetB - Vetor com as somas                                                        |
+=================================================================================================+
|Referências: AGRA900                                                                             |
+=================================================================================================+ 
*/
Function AGRSOMACAMP(cAliasB,cChaveB,nIndicB,cWhileB,vVetCam,cConIfB) 
	Local aAreaAt := GetArea(),vVetRetB := {},nx
	Local nIndicL := If(nIndicB = Nil,1,nIndicB)

	For nx := 1 To Len(vVetCam)
		Aadd(vVetRetB,0)
	Next nx

	DbSelectArea(cAliasB)
	DbsetOrder(nIndicL)
	If MsSeek(cChaveB)
		While !Eof() .And. &cWhileB
			lGravar := .t.
			If cConIfB <> Nil .And. !Empty(cConIfB)
				lGravar := &cConIfB
			EndIf
			If lGravar
				For nx := 1 To Fcount()
					cCampo := Fieldname(nx)
					nPos := aScan(vVetCam,{|x| AllTrim(x) == cCampo}) 
					If nPos > 0
						y := (cAliasB)+"->"+cCampo
						vVetRetB[nPos] += &(Y)
					EndIf  
				Next nx
			EndIf	
			AGRDBSELSKIP(cAliasB)
		End
	EndIf	
	RestArea(aAreaAt)
Return vVetRetB

/*
+=================================================================================================+
| Programa  : AGRGRAVA2T                                                                          |
| Descrição : Grava conteúdo de mesma referência entre 2 arquivos e/ou tabelas (campos iguais     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/09/2014                                                                          |
+=================================================================================================+ 
| Paramêtros: cAlia1 - Alias do arquivo/tabela que irá receber os dados                Obrigatório|
|             cAlia2 - Alias do arquivo/tabela que tem os dados                        Obrigatório|
|             lTrava - Indica o tipo de travamento do registro                         Não Obrigat|
+=================================================================================================+    
|Referências :                                                                                    |
+=================================================================================================+
*/
Function AGRGRAVA2T(cAlia1,cAlia2,lTrava)
	Local lTravaL := If(lTrava = Nil,.t.,lTrava),nx,aStrut1,aStrut2
	DbSelectArea(cAlia2)
	aStrut2 := DbStruct()
	DbSelectArea(cAlia1)
	aStrut1 := DbStruct()
	AGRTRAVAREG(cAlia1,lTravaL)
	DbSelectArea(cAlia2)
	For nx := 1 To Fcount()
		nPos := aScan(aStrut1,{|x| AllTrim(x[1]) == Fieldname(nx)})
		If nPos > 0
			x := cAlia2+"->"+Fieldname(nx)
			y := cAlia1+"->"+aStrut1[nPos,1]
			&y. := &x.
		EndIf
	Next nx  
Return

/*                                                                                                 
+=================================================================================================+
| Função    : AGRGRAVAREG                                                                         |
| Descrição : Grava valor para um campo do arquivo/tabela                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 22/09/2015                                                                          | 
+=================================================================================================+ 
|Parâmetros : cAlia  - Alias do arquivo/tabela                                         Obrigatório| 
|             aMatCD - Matriz com os campos e valores                                  Obrigatório| 
+=================================================================================================+ 
|Referências: AGRA840                                                                             |
+=================================================================================================+  
*/
Function AGRGRAVAREG(cAlia,aMatCD)
	Local nx 
	For nx := 1 To Len(aMatCD)
		cCa1 := cAlia+"->"+aMatCD[nx,1] 
		&(cCa1) := aMatCD[nx,2]
	Next nx
Return

/*
+=================================================================================================+
| Programa  : AGRDESCRINNK                                                                        |
| Descrição : Retorna a descrição do resultado do desconto                                        |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 07/11/2014                                                                          |
+=================================================================================================+ 
| Paramêtros: cTabel - Código da tabela                                                Obrigatório|
|             cCodde - Código do desconto                                              Obrigatório|
|             nPerde - Perda                                                           Obrigatório|
+=================================================================================================+    
|Referências : OGA250,OGA180                                                                      |
+================================================================================================
*/
Function AGRDESCRINNK(cTabel,cCodde,nPerde)
	aRetDe := AGRBUSREGIS("NNK",xFilial("NNK")+cTabel+cCodde,1,.T.,.T.,;
	"NNK->NNK_FILIAL = XFILIAL('NNK') .And. NNK->NNK_CODDES = '"+cCodde+"' .And. NNK->NNK_CODTAB = '"+cTabel+"'",;
	{{"NNK_DESRES"}},"Str(NNK->NNK_PERINI,5,2) <= '"+Str(nPerde,5,2)+ "'" + " .And. Str(NNK->NNK_PERFIM,5,2) >= '"+Str(nPerde,5,2)+"'","M")

Return If(!Empty(aRetDe[2]),aRetDe[2,1,1],'   ')

/*                                                                                                 
+=================================================================================================+
| Função    : AGRACOLSTAB                                                                         |
| Descrição : Grava conteúdo da linha/colunas de um acols na tabela de mesmo nome de campos       |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 07/04/2015                                                                          | 
+=================================================================================================+ 
| Parâmetros: cAlia    - Alias da tabela para copiar os dados                      Não obrigatório|
|             vaHeader - Matriz com os campos(dicionário e/ou especiais)               Obrigatório|  
|             vLinCols - Vetor com o(s) dados (linha do aCols)                         Obrigatório| 
+=================================================================================================+  
|Referências : AGRA840NFE                                                                         |
+=================================================================================================+                                                                                                | 
*/
Function AGRACOLSTAB(cAlia,vaHeader,vLinCols)
	Local i,cAliaL := If(cAlia = Nil,Alias(),cAlia)
	DbSelectArea(cAliaL)
	For i := 1 To Fcount()
		xx := GDFIELDPOS(AllTrim(Fieldname(i)),vaHeader)
		If xx > 0
			vv   := cAliaL+"->"+Fieldname(i)
			&vv. := vLinCols[xx]   
		EndIf  
	Next i
Return .t. 

// TRATAMENTO DE FILTRO
/*
+=================================================================================================+
| Programa  : AGRQUEBRAFIL                                                                        |
| Descrição : Desfaz o filtro de uma tabela                                                       |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 05/01/2015                                                                          |
+=================================================================================================+ 
| Paramêtros: cAliasT - Código da tabela                                               Obrigatório|
+=================================================================================================+    
|Referências : AGRA840                                                                            |
+=================================================================================================+
*/
Function AGRQUEBRAFIL(cAliasT,nIndice)	 
	Local nIndT := If(nIndice = Nil,1,nIndice)
	DbSelectArea(cAliasT)
	DBClearFilter() 
	DbSetOrder(nIndT)       
Return .t.

/*
+=================================================================================================+
| Programa  : AGRCAMPOFIL                                                                         |
| Descrição : Retira o filtro do browse não tiver o campo                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 11/03/2015                                                                          |
+=================================================================================================+ 
| Paramêtros: oBrwF  - Objeto do browse                                                Obrigatório|
|             aEstF  - Estrutura da tabela/arquivo                                     Não Obrigat|
|             cAlias - Alias da tabela/arquivo                                         Não Obrigat|
+=================================================================================================+                                                                                                           
| OBSERVAÇÃO: aEsrF ou cAlias deve ser informado                                                  |
+=================================================================================================+    
|Referências :                                                                                    |
+=================================================================================================+
*/
Function AGRCAMPOFIL(oBrwF,aEstF,cAliasF)
	Local nx,ny,nz,aAreaL := GetArea()

	If aEstF = Nil .Or. Empty(aEstF)
		DbSelectArea(cAliasF)
		aEstF := Dbstruct()
	EndIf

	oFWFilter := FWFilter():New(GetWndDefault())
	aMat4 := oBrwF:oFWFilter:AFILTER 
	For nx := 1 To Len(aMat4)
		aMatC := aMat4[nx,4]
		For ny := 1 To Len(aMatC)
			aMat4C := aMatC[ny]
			For nz := 1 To Len(aMat4C)
				cValor := aMat4C[nz]
				lProxF := .f.
				If ValType(cValor) = "C" .And. aMat4C[nz] = "FIELD" .And. Ascan(aEstF,{|x| x[1] = aMat4C[nz-1]}) = 0
					Adel(oBrwF:oFWFilter:AFILTER,nx)
					aSize(oBrwF:oFWFilter:AFILTER,Len(oBrwF:oFWFilter:AFILTER)-1)
					lProxF := .t.
					Exit
				EndIf	
			Next nz
			If lProxF
				Exit
			EndIf
		Next ny		
	Next nx
	RestArea(aAreaL)
Return 

// TRATAMENTO COM O BANCO DO CONHECIMENTO
/*
+=================================================================================================+
| Programa  : AGRCONHECIM                                                                         |
| Descrição : Cadastramento do banco do conhecimento                                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 25/11/2014                                                                          |
+=================================================================================================+ 
| Paramêtros: cAliasT - Código da tabela                                               Obrigatório|
+=================================================================================================+    
|Referências : AGRA840                                                                            |
+=================================================================================================+
*/
Function AGRCONHECIM(cAliasT)	 
	Local aRotBack,cCadBack

	If Type("aRotina") <> "U"
		aRotBack := Aclone(aRotina)
	EndIf 
	If Type("cCadastro") <> "U"   
		cCadBack := cCadastro
	EndIf  

	aRotina   := AGREMULAROT()
	cCadastro := ARGSX2NOME(cAliasT)
	If Ascan(aRotina,{|x| x[1] = STR0051}) = 0		
		Aadd(aRotina,{STR0051,"MsDocument", 0 , 4})
	EndIf	 
	DbSelectArea(cAliasT)
	MsDocument(cAliasT,Recno(),4)

	aRotina   := If(aRotBack = Nil,{},AClone(aRotBack))
	cCadastro := If(cCadBack = Nil,"",cCadBack) 
Return .T.

/* 
+=================================================================================================+
| Função     : AGRIMPDOCCON                                                                       |
| Descrição  : Impressão dos documentos conhecimento                                              |
| Autor      : Inácio Luiz Kolling                                                                |
| Data       : 19/06/2015                                                                         |
+=================================================================================================+ 
| Parâmetros : cSemiChave - Chave de acesso (chave 2 sem o objeto)                                |
+=================================================================================================+ 
| Retorna    : lTemCon - .t.,.f. se tem documento                                                 |
+=================================================================================================+ 
| Referencias: AGRA900CONH                                                                        |
+=================================================================================================+
*/
Function AGRIMPDOCON(cSemiChav2)
	Local cCODENT := Alltrim(cSemiChav2)+Space(Len(AC9->AC9_ENTIDA+AC9->AC9_FILENT+AC9->AC9_CODENT)- Len(Alltrim(cSemiChav2)))
	Local lTemCon := .f.,cFileName	:= "",cParam 	:= "",cDir	:= "",cDrive := "",cDirDocs := MsDocPath()

	If AGRIFDBSEEK("AC9",cCODENT,2,.F.)
		lTemCon := .t.
		While !Eof() .and. AC9->AC9_FILIAL = xFilial("AC9") .and. AC9->AC9_ENTIDA+AC9->AC9_FILENT+AC9->AC9_CODENT = cCODENT
			AGRIFDBSEEK("ACB",AC9->AC9_CODOBJ,1,.f.)
			cFileName := GetTempPath()+AllTrim(ACB->ACB_OBJETO)

			SplitPath(cFileName,@cDrive,@cDir)
			cDir		  := Alltrim(cDrive)+Alltrim(cDir)
			cTempPath := GetTempPath()
			cPathFile := cDirDocs+"\"+AllTrim(ACB->ACB_OBJETO)

			Processa({|| lCopied := CpyS2T(cPathFile,cTempPath,.T.)},STR0165,STR0139+"...",.F.)
			nRet := ShellExecute("print",cFileName,cParam,cDir,1)
			AGRDBSELSKIP("AC9")
		End
	EndIf
Return lTemCon

// TRATAMENTO COM BROWSE    
/*
+=================================================================================================+
| Função    : AGRLEGEBROW                                                                         |
| Descrição : Set a legenda do browse                                                             |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 26/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oObrowse - Objeto do browse                                              Obrigatório|
|             aMatLege - Matriz com os dados para montar a legenda                     Não Obrigat|
|                        Onde: [n,1] - Condição, [n,2] - Descrição, [n,3] - Cor ->     Não Obrigat| 
|             cCampo   - Campo da tabela relacionado ao box                            Não Obrigat|
+=================================================================================================+
|Referências : AGRA751,AGRA840                                                                    |
+=================================================================================================+ 
*/
Function AGRLEGEBROW(oObrowse,aMatLege,cCampo)
	Local nx,vVetCor := {"GREEN","YELLOW","RED","BLACK","ORANGE","BLUE","BROWN","PINK","GRAY","LBLUE","BRWN","WHITE"}
	Local aMatLe := If(cCampo = Nil,Aclone(aMatLege),{})
	If cCampo <> Nil
		vPontV := Separa(AGRRETSX3BOX(cCampo),";")
		For nx := 1 To Len(vPontV)
			vIgua := Separa(vPontV[nx],"=")
			vVetO := {cCampo+' = '+"'"+vIgua[1]+"'",vIgua[2],vVetCor[nx]}
			Aadd(aMatLe,vVetO)
		Next nx
	EndIf	
	For nx := 1 To Len(aMatLe)
		If(cCampo <> Nil,oObrowse:AddLegend(aMatLe[nx,1],If(Len(aMatLe[nx]) > 2,aMatLe[nx,3],vVetCor[nx]),aMatLe[nx,2]),;
		oObrowse:AddLegend(aMatLe[nx,1],aMatLe[nx,3],aMatLe[nx,2]))
	Next nx 
Return

/*
+=================================================================================================+
| Função    : AGRORDCBROW                                                                         |
| Descrição : Ordena o FWFormBrowse(obrowse) de acordo com a seleção da coluna                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/04/2015                                                                          |
+=================================================================================================+
| Parâmetros: oBrw  - Objeto da criação do obrowse                                     Obrigatório|
|             Ctipo - Tipo de ordenação (Crescente Descrescente)                       Não Obrigat|
+=================================================================================================+ 
*/    
Function AGRORDCBROW(oBrw,cTipo)
	Local ccAlias := oBrw:Alias(),aField,cCampo,nx,cArqInd
	Local cTipOr  := If(cTipo = Nil,"C",cTipo)

	DbSelectArea(ccAlias)
	aField := Dbstruct()
	cCampo := aField[oBrw:ColPos(),1]

	If Type("vVetIcol") = "U"
		Help(,1,"HELP",,STR0172+" vVetIcol "+STR0173,1,0)
		Return .f.
	EndIf
	cCampo  := If(cTipOr = "D",'Descend('+cCampo+')',cCampo)
	cArqInd := CriaTrab(Nil,.F.)

	For nx := 1 To Len(vVetIcol)
		FErase(vVetIcol[nx]+OrdBagExt())
	Next nx

	IndRegua(ccAlias,cArqInd,cCampo,,,STR0004)
	oBrw:Refresh()
	oBrw:Gotop()
	oBrw:GoColumn(oBrw:ColPos())
	Aadd(vVetIcol,cArqInd)
Return

/*
+=================================================================================================+
| Função    : AGRINDBRWINI                                                                        |
| Descrição : Criação inicial dos indices das colunas                                             |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 26/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: aMatCEs - Matriz da estrutura para criar os índices                      Obrigatório|
+=================================================================================================+ 
*/
Function AGRINDBRWINI(aMatCEs)	
	Local vVetInd := {},aTrbIndex := {},nx

	For nx := 1 To Len(aMatCEs)
		Aadd(vVetInd,aMatCEs[nx,1])
	Next nx

	aSindi := AGRINDICONS(vVetInd,aMatCEs)
	aSeeK  := AGRMAXINDTEM(aSindi)

	// Se ainda não tiver indice
	Aadd(aTrbIndex,{})
	nIV := Len(aTrbIndex)
	For nx := 1 To Len(aSeeK)
		cINDX := "cID"+carqTRBL+cValToChar(nX)
		Public &(cINDX) := Left(carqTRBL,7)+cValToChar(nX)
		Aadd(aTrbIndex[nIV],{carqTRBL,&(cINDX)})
		IndRegua(carqTRBL,aTrbIndex[nIV,nX,2],aMatCEs[nx,1],,,STR0004)
	Next nx

	DbClearIndex()
	For nX := 1 To Len(aTrbIndex[nIV])
		DbSetIndex(aTrbIndex[nIV,nX,2] + OrdBagExt())
	Next nX 
Return

/* 
+=================================================================================================+
| Função    : AGRMAXINDTEM                                                                        |
| Descrição : Cria listbox dos campos para os índices na consulta por coluna em um FWbrowse       |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/06/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: avSindi - Matriz com todos os campos e pré-índices                      Obrigatório |  
+=================================================================================================+  
| Retorna   : aSeekR - Matriz com a quantidade máxima de índices pelo padrão ADVPL                |
+=================================================================================================+ 
|Referências:                                                                                     |
+=================================================================================================+ 
*/
Function AGRMAXINDTEM(avSindi)
	Local nx, nMaxI := 15, aSeekR := {}
	For nx := 1 To nMaxI
		Aadd(aSeekR,{avSindi[nx,1],avSindi[nx,2]})
	Next
Return aSeekR

/* 
+=================================================================================================+
| Função    : AGRORCIDBROW                                                                        |
| Descrição : Consulta em um FWbrowse com pesquisa específica de acordo com a seleção da coluna   |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/06/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oBrw  - Objeto do browse                                                Obrigatório |  
|             aMatC - Matriz com os campos                                            Obrigatório |  
|             oDlgB - Nome do objeto da tela                                          Obrigatório |  
|             cFunc - Nome de função que monta o browse                               Obrigatório | 
|             aCoDa - Matriz dos dados para montar as colunas                         Não Obrigat.| 
|             vTiOr - Tipo de ordenação (Crescente,Decrescente)                       Não Obrigat.|  
+=================================================================================================+  
| Retorna   : Nil                                                                                 |
+=================================================================================================+ 
|OBSERVAÇÃO : Deve ter chamada recursivamente com/sem recriação de FWBrwColumn() no fonte chamador|
+=================================================================================================+ 
|Referências:                                                                                     |
+=================================================================================================+ 
*/
Function AGRORCIDBROW(oBrw,aMatC,oDlgB,cFunc,aCoDa,cTiOr)
	Local ccAlias	:= oBrw:Alias(),aField,cCampo,nx
	Local cTipOr	:= If(cTiOr = Nil,"C",cTiOr)
	Local aIndi	:= {},vVetdex := {},vVetInd := {}

	DbSelectArea(ccAlias)
	aField := Dbstruct()
	cCampo := aField[oBrw:ColPos(),1]

	aSeek := {}
	nPosC := oBrw:ColPos()

	For nx := 1 To Len(aMatC)
		Aadd(vVetInd,aMatC[nx,1])
	Next nx

	aIndi := AGRINDICONS(vVetInd,aMatC)
	aSeeK := AGRMAXINDTEM(aIndi)

	If oBrw:ColPos() >= Len(aSeek) 
		If aScan(aSeek,{|x| x[1] == cCampo}) = 0
			nPosSi := aScan(aField,{|x| x[1] == cCampo})
			If nPosSi > 0

				aSeek[Len(aSeek),1] 						:= aIndi[nPosSi,1]
				aSeek[Len(aSeek),2]					 	:= aIndi[nPosSi,2]
				oBrw:adeforderseek[Len(aSeek),1]	:= aIndi[nPosSi,1]
				oBrw:adeforderseek[Len(aSeek),2] 	:= aIndi[nPosSi,2]
				oBrw:asorder[Len(aSeek),1]       	:= aIndi[nPosSi,1]
				oBrw:asorder[Len(aSeek),2]       	:= aIndi[nPosSi,2]

				cCampo  := If(cTipOr = "D",'Descend('+cCampo+')',cCampo)
				For nx := 1 To Len(aSeeK)
					cINDX := "cID"+carqTRBL+cValToChar(nX)
					Public &(cINDX) := Left(carqTRBL,7)+cValToChar(nX)
					Aadd(vVetdex,&(cINDX))
					IndRegua(carqTRBL,vVetdex[Len(vVetdex)],If(nx = Len(aSeek),cCampo,vVetInd[nx]),,,"Criando indice")
				Next nx

				DbClearIndex()
				For nX := 1 To Len(vVetdex)
					DbSetIndex(vVetdex[nX] + OrdBagExt())
				Next nX

				If oBrw <> Nil
					FreeObj(oBrw)
				EndIf

				If oDlgB <> Nil
					FreeObj(oDlgB)
				EndIf	

				AGRAREAORDE(carqTRBL,Len(aSeek))

				//	oBrw:Refresh()
				//	oBrw:Gotop()

				//			nPosC := oBrw:ColPos()
				//			oBrw:GoColumn(nPosC) // oBrw:ColPos())	

				If aCoDa <> Nil .And. !Empty(aCoDa)
					aColumns := {}
					For nx := 1 to Len(aCoDa)
						cData := Alltrim(aCoDa[nx,2])
						Aadd(aColumns,FWBrwColumn():New())
						aColumns[nx]:SetData(&("{||"+cData+"}"))
						aColumns[nx]:SetTitle( Alltrim(aCoDa[nx,1]))
						aColumns[nx]:SetPicture(Alltrim(aCoDa[nx,6]))
						aColumns[nx]:SetType(Alltrim(aCoDa[nx,3]))
						aColumns[nx]:SetSize(aCoDa[nx,4])
						aColumns[nx]:SetReadVar(cData)
					Next nx
				EndIf
				&cFunc 
			EndIf
		EndIf
	EndIf
Return 

// TRATAMENTO COM aHeader,aCols 
/*
+=================================================================================================+
| Função    : AGRCRIAGRID                                                                         |
| Descrição : Monta uma matriz expecífica dos campos do SX3 para montar um grid tipo aCols        |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 09/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cChavAc - Chave de acesso                                                Não Obrigat|
|             vVetCaR - Vetor com os campos para tratamento de retorno                 Não Obrigat|
|             lVirt   - Indica se os campos virtuais devem faz parte no retorno        Não Obrigat| 
|             lUsado  - Indica se considera os campos não usados                       Não Obrigat|             
+=================================================================================================+
| OBSERVAÇÃO: Se for informado cChavAc será retornado os campos que pertence a família, neste caso|
|             se for informado os campos no vVetCaR eles serão desconsiderados para o retorno.    |
|             Se não for informado cChavAv somente os campos informados no vVetCaR serão considera|
|             dos para o retorno                                                                  |     
+=================================================================================================+
| Retorna   : aRetCGr - Matriz com os campos que farão parte da grid                              |
+=================================================================================================+
|Referências : AGRA980                                                                            |
+=================================================================================================+ 
*/
Function AGRCRIAGRID(cChavAc,vVetCaR,lVirt,lUsado)
	Local aRetCGr  := {}
	Local nx       := 0
	Local aStruct  := {}
	Local oStruct  := Nil
	Local lVirtual := .F.
	Local cMdEdcao := ""
	Local cTab     := ""
	Local nBkpMod  := nModulo

	If cChavAc <> Nil
		DbSelectArea(cChavAc)
		(cChavAc)->(DbsetOrder(1))

		aStruct := (cChavAc)->(DbStruct())
		oStruct := FWFormStruct(1, cChavAc,,.F.)

		If !Empty(aStruct)
			For nX := 1 To Len(aStruct)
				if (cChavAc)->(ColumnPos(aStruct[nX,1])) > 0 .AND. X3Uso(posicione("SX3",2,aStruct[nX,1],"X3_USADO"))
					If Ascan(vVetCaR,{|x| x = aStruct[nX,1]}) = 0

						lVirtual := oStruct:GetProperty(aStruct[nX, 1], MODEL_FIELD_VIRTUAL)
						cMdEdcao := oStruct:GetProperty(aStruct[nX, 1], MODEL_FIELD_WHEN) 

						Aadd(aRetCGr,{Trim(RetTitle(aStruct[nX,1]))  ,; //Título
						aStruct[nX,1]                  ,; //Campo
						x3Picture(aStruct[nX,1])       ,; //Picture
						aStruct[nX,3]                  ,; //Tamanho
						aStruct[nX,4]                  ,; //Deciaml
						x3Valid(aStruct[nX, 1])        ,; //Valid
						x3Usado(aStruct[nX, 1])        ,; //Usado(.T. ou .F.)
						aStruct[nX,2]                  ,; //Tipo
						cChavAc                        ,; //Arquivo/Tabela
						IIF(!lVirtual, "R", "V")       ,; //Virtual('V' ou 'R')
						X3F3(aStruct[nX,1])            ,; //Cons. Padrão
						cMdEdcao})                        //Modo de Edição

					EndIf
				endIf
			Next nX
		EndIf

	ElseIf vVetCaR <> Nil
		For nx := 1 To Len(vVetCaR)

			If !Empty(TamSX3(vVetCaR[nX]))

				cTab := SUBSTR(vVetCaR[nX], 1, RAT("_", vVetCaR[nX])-1)

				If Len(cTab) < 3
					cTab := 'S'+cTab
				EndIf

				oStruct := FWFormStruct(1, cTab,,.F.)

				lVirtual := oStruct:GetProperty(vVetCaR[nX], MODEL_FIELD_VIRTUAL)
				cMdEdcao := oStruct:GetProperty(vVetCaR[nX], MODEL_FIELD_WHEN) 

				Aadd(aRetCGr,{Trim(RetTitle(vVetCaR[nX])),; //Título
				vVetCaR[nX]                ,; //Campo
				x3Picture(vVetCaR[nX])     ,; //Picture
				TamSX3(vVetCaR[nX])[1]     ,; //Tamanho
				TamSX3(vVetCaR[nX])[2]     ,; //Deciaml
				x3Valid(vVetCaR[nX])       ,; //Valid
				x3Usado(vVetCaR[nX])       ,; //Usado(.T. ou .F.)
				TamSX3(vVetCaR[nX])[3]     ,; //Tipo
				cTab                       ,; //Arquivo/Tabela
				IIF(!lVirtual, "R", "V")   ,; //Virtual('V' ou 'R')
				X3F3(vVetCaR[nX])          ,; //Cons. Padrão
				cMdEdcao})                    //Modo de Edição

			EndIf

		Next nx
	EndIf
	nModulo := nBkpMod
Return aRetCGr

/*
+=================================================================================================+
| Função    : AGRZERAACOLS                                                                        |
| Descrição : Alimenta uma linha do acols com valores vázios                                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 17/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: aHeadA - Matriz com os campos                                            Obrigatorio|
|             aColsA - Matriz (aCols) em uso                                           Não Obrigat|
|             lDicio - Indica se os campos são do dicionário de dados                  Não Obrigat|
+=================================================================================================+
|Referências : AGRA980                                                                            |
+=================================================================================================+ 
*/
Function AGRZERAACOLS(aHeadA,aColsA,lDicio)                 
	Local nx,cTipo,nTam
	Local lDic := If(lDicio = Nil,.t.,lDicio) 
	aCols := If(aColsA <> Nil,Aclone(aColsA),{})   
	For nx := 1 To Len(aHeada)
		cTipo := aHeada[nx,8]
		nTam  := aHeada[nx,4]
		If lDic .And. AGRIFDICIONA("SX3",aHeadA[nx,2],2)
			cTipo := aHeada[nx,8]
			nTam  := aHeada[nx,4]
		EndIf   
		If nx = 1 
			Aadd(aCols,{})
		EndIf
		If cTipo = "C" .Or. cTipo = "M"
			Aadd(aCols[Len(aCols)],Space(nTam))
		ElseIf cTipo = "N"     
			Aadd(aCols[Len(aCols)],0) 
		ElseIf cTipo = "D"     
			Aadd(aCols[Len(aCols)],Ctod("  /  /  "))
		ElseIf cTipo = "l" 
			Aadd(aCols[Len(aCols)],.t.)
		EndIf
	Next nx 
	Aadd(aCols[len(aCols)],.f.)
Return .t.

/*
+=================================================================================================+
| Programa  : AGRRENUMCOL                                                                         |
| Descrição : Recria a sequência da numeração de uma coluna da grid                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 25/01/2015                                                                          |
+=================================================================================================+     
| Retorna   : cTipooB - Tipo do objeto ("M" - MVC <> Getdados)                         Obrigatório|
|             view    - Nome da View  padrão MVC                                       Não Obrigat|
|             viewu   - Nome da View da grid MVC                                       Não Obrigat|
|             nCol    - Número da coluna para renumerar                                Obrigatório|
|             cTIncre - Tipo do incremento (Nil = Numérico)                            Não Obrigat|
|             oGetl   - Nome do objeto para Getdados                                   Não Obrigat|
+=================================================================================================+     
|Observação : Definir a variável oView como privada no programa chamador como view padrão p/ MVC  |
|             Definir a variável oGet como privada no programa chamador como GETDADOS             |
|             Definir ocorretamente o envio dos parâmentros de acordo com o objeto em uso         |
+=================================================================================================+
|Referências : AGRTROCACOL("M","VIEW_NPW","NPWUNICO",4) MVC                                       |
+=================================================================================================+
*/
Function AGRRENUMCOL(cTipooB,view,viewu,nCol,cTIncre,oGetl)
	Local nx,nColt := If(cTipooB = "M",nCol+1,nCol) 
	Local cIncre := If(cTIncre = Nil,"N",cTIncre)
	Local cVaria := ReadVar(),nLinhA

	If cTipooB = "M"
		If type("oView") <> "O"
			Help(,1,"HELP",,STR0170+" oView "+STR0171+" "+funname(),1,0)
			Return .f.
		EndIf
		oModel	:= FWModelActive()
		oStrut	:= oModel:GetModel(viewu)
		nLinhA  := oStrut:GetLine()
		oGridD	:= Aclone(oStrut:adatamodel)
		nObjeto := Getfocus()
		aMatAc  := {}
		For nx := 1 To Len(oGridD)
			Aadd(aMatAc,oGridD[nx,1,1])
		Next nx

		oGridO	:= AGRORVETMATR(aMatAc,{nColt})
		nConta  := 0
		For nx := 1 To len(oGridO)
			If !oGridD[nx,3]
				nConta ++
				oGridO[nx,nColt]          := If(cIncre = "C",Alltrim(Str(nConta)),nConta)
				oStrut:adatamodel[nx,1,1] := {}
				oStrut:adatamodel[nx,1,1] := AClone(oGridO[nx])
			EndIf	
		Next nx	

		oStrut:aCols := oGridO
		&(cVaria)    := aMatAc[nLinhA,nColt]
		oView:Refresh(view)
	Else
		If type("oGetl") <> "O"
			Help(,1,"HELP",,STR0170+" oGet "+STR0171+" "+funname(),1,0)
			Return .f.
		EndIf
		oGridO	:= AGRORVETMATR(aCols,{nColt})
		nConta	:= 0
		For nx := 1 To len(oGridO)
			If !oGridO[nx,Len(oGridO[nx])]
				nConta ++
				oGridO[nx,nColt] := If(cIncre = "C",Alltrim(Str(nConta)),nConta)
			EndIf	
		Next nx	
		&(cVaria) := oGridO[nLinhA,nColt]		
		aCols := Aclone(oGridO)
		&oGetl:oBrowse:REFRESH()
	EndIf   
Return .t.  

/*                                                                                                 
+=================================================================================================+
| Programa  : AGRSOMACOLSM                                                                        |
| Descrição : Soma coluna(s) de uma matriz tipo acols ou adatamodel-> o??:aCols (MVC)             |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/06/2016                                                                          | 
+=================================================================================================+                                                                           |  
| Parâmetros: xaDados  - Matriz com os dados e ou objeto se for em MVC                 Obrigatório|
|             vVetCols - Vetor com os nomes da(s) coluna(s) a ser(em) somada(s)        Obrigatório|
+=================================================================================================+
|Referência : OGA260,OGA270,OGA280,OGA290                                                         |
+=================================================================================================+                                                                           |  
| Retorna   : vVetSoma - Vetor com a(s) soma(s) da(s) coluna(s) ou um valor quando o tamanho do   |
|                        vetor vVetCols for igual a 1                                             | 
+=================================================================================================+  
*/
Function AGRSOMACOLSM(xaDados,vVetCols)
	Local nx,ny
	Local nLinha := 0
	Local vVetSoma[Len(vVetCols)]
	Afill(vVetSoma,0)
	If ValType(xaDados) = "A"  // Grid antiga
		nLinha := n
		For nx := 1 to Len(xaDados)
			If !Atail(xaDados[nx])
				For ny := 1 to Len(vVetCols)
					nPos := GDFIELDPOS(vVetCols[ny],aHeader)
					If nPos > 0 .And. aHeader[nPos,8] = "N"
						vVetSoma[ny] += xaDados[nx,nPos]
					EndIf
				Next ny 
			EndIf
		Next nx
		n := nLinha
	Else // Grid nova MVC
		nLinha := xaDados:GetLine()
		For nx := 1 To xaDados:Length()
			xaDados:GoLine(nx)
			If !xaDados:IsDeleted()
				For ny := 1 to Len(vVetCols)
					nPos := GDFIELDPOS(vVetCols[ny],xaDados:aHeader)
					If nPos > 0 .And. xaDados:aHeader[nPos,8] = "N"
						//vVetSoma[ny] += xaDados:acols[nx,npos]  // ou obj:adatamodel[x,1,1,npos]
						vVetSoma[ny] += xaDados:GetValue( vVetCols[ny])
					EndIf
				Next ny 
			EndIf
		Next nx
		xaDados:GoLine(nLinha)
	EndIf	
Return If(Len(vVetCols) = 1,vVetSoma[1],vVetSoma)

// TRATAMENTO DE INCIALIZAÇÃO DE VARIÁVEIS
/*
+=================================================================================================+
| Função    : AGRINICIAVAR                                                                        |
| Descrição : Inicializa uma variável de acordo com o dicionário de dados e/ou da base de dados   |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 26/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cNoVar - Nome da variável (Campo)                                        Obrigatorio|
|             lSX3   - Buscar no SX3                                                    Nao Obrig.| 
|             cAliaI - Alias para busca na base                                         Nao Obrig.|
+=================================================================================================+
| Retorna   : cConte - Conteúdo inicializado                                                      |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRINICIAVAR(cNoVar,lSX3,cAliaI)
	Local cConte  := ""
	Local cTipV   := Space(1)
	Local nTamV   := 0
	Local nDecV   := 0
	Local lPSX3   := If(lSX3 = Nil,.T.,lSX3)
	Local aAreaAl := GetArea()

	If lPSX3
		aStruct := TamSX3(cNoVar)
		If !Empty(aStruct)
			cTipV := aStruct[3]
			nTamV := aStruct[1]
			nDecV := aStruct[2]  
		EndIf
	Else
		DbSelectArea(cAliaI)
		aEstru := Dbstruct()
		nPosEs := Ascan(aEstru,{|x| x[1] == cNoVar})
		If nPosEs > 0
			cTipV := aEstru[nPosEs,2]
			nTamV := aEstru[nPosEs,3]
			nDecV := aEstru[nPosEs,4]
		EndIf
	EndIf
	If !Empty(cTipV)
		If  cTipV $ "CM"
			cConte := Space(nTamV)
		ElseIf cTipV = "N"
			cConte := If(nDecv = 0,0,0.00)
		ElseIf cTipV = "D"
			cConte := Ctod("  /  /  ")
		ElseIf cTipV = "L"
			cConte := .f.
		EndIf
	EndIf
	RestArea(aAreaAl)
Return cConte

/*                                                                                                 
+=================================================================================================+
| Função    : AGRSETAVAR                                                                          |
| Descrição : Atribui valor para a variável                                                       |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 22/09/2015                                                                          | 
+=================================================================================================+ 
|Parâmetros : aMatCD - Matriz com os campos e valores                                  Obrigatório|
+=================================================================================================+ 
|Referências: AGRA840                                                                             |
+=================================================================================================+  
*/
Function AGRSETAVAR(aMatCD)
	Local nx 
	For nx := 1 To Len(aMatCD)
		&(aMatCD[nx,1]) := aMatCD[nx,2]
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRPOVIRPICT                                                                        |
| Descrição : Verifica a quantidade de pontos e vírcula tem na picture                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/09/2014                                                                          |
+=================================================================================================+
| Paramêtros: cCampoX3 - Campo do dicionário de dados                                  Não Obrigat|
|             cPictVar - Formatação da picture                                         Não Obrigat|
==================================================================================================+
|Retorna    : nPonVir - Quantidade de pontos e vírcula                                            |
+=================================================================================================+
|Referências : ReportPrint()                                                                      |
+=================================================================================================+ 
*/  
Function AGRPOVIRPICT(cCampoX3,cPictVar) 
	Local nPonVir := 0,nx,cPicture,cPoVir := ".," 
	If cCampoX3 <> Nil
		cPicture := AGRSEEKDIC("SX3",cCampoX3,2,"X3_PICTURE")
	ElseIf cPictVar <> Nil
		cPicture := cPictVar
	EndIf
	If cPicture <> Nil 
		For nx := 1 To Len(cPicture)
			If SubStr(cPicture,nx,1) $cPoVir
				nPonVir ++
			EndIf   
		Next nx
	EndIf
Return nPonVir

/*
+=================================================================================================+
| Função    : AGROBRICAMP                                                                         |
| Descrição : Validação de campos obrigatórios                                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 24/02/2016                                                                          |
+=================================================================================================+   
| Usam      : OGA250CP,OGA250DD,OGA250CD,OGA250DE,OGA250EC,OGA500TRA                              |
+=================================================================================================+                                                                           |  
*/
Function AGROBRICAMP(vVetCam)
	Local nx
	For nx := 1 To Len(vVetCam)
		If Empty(vvetCam[nx])
			Help(,,"HELP",,STR0174,1,0)
			Return .f.
		EndIf
	Next nx		
Return .t.   

// TRATAMENTO DE PESQUISA QUANTIDADE EM VARIAVEIS , VETOR , MATRIZ
/*
+=================================================================================================+
| Programa  : AGRQTDCARAC                                                                         |
| Descrição : Calcula quantas vezes um conteúdo e está em uma variável                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 25/01/2015                                                                          |
+=================================================================================================+     
| Retorna   : cString - Conteúdo da variável                                           Obrigatório|
|             cCarac  - Conteúdo a ser procurado no conteúdo da variável               Obrigatório|
+=================================================================================================+     
|Observação : Definir as variáveis do tipo string (Caracter)                                      |
+=================================================================================================+
|Retorna    : Uma vetor de duas dimensões.  Onde a saber                                          | 
|                                       ..[1] = Quantas vezes se repete o item                    |
|                                       ..[2] = Vetor com as posições de inicio de cada ocorrência|    
+=================================================================================================+   
|Referências :                                                                                    |
+=================================================================================================+
*/
Function AGRQTDCARAC(cString,cCarac)
	Local nQtdC := Len(cCarac),nQtdO := 0,nx
	Local aMatS := {{},{}},cStrinA,vVetPos := {}
	For nx := 1 To len(cString)
		Aadd(aMatS[1],SubStr(cString,nx,1))
		Aadd(aMatS[2],nx)
	Next nx

	cStrinA := aMatS[1]
	vVetPoA := aMatS[2]
	While Len(cString) > 0
		nPos := At(cCarac,cString)
		If nPos > 0
			nQtdO ++
			Aadd(vVetPos,vVetPoA[nPos])
			cString := Alltrim(SubStr(cString,If(nPos > 0,nPos+nQtdC,nQtdC),Len(cString)))
			vVetPaX := vVetPoA
			vVetPoA := {}
			For nx := If(nPos > 0,nPos+nQtdC,nQtdC) To len(vVetPaX)
				Aadd(vVetPoA,vVetPaX[nx])
			Next nx
		Else
			Exit
		EndIf  		
	End 

Return {nQtdO,vVetPos}

/*
+=================================================================================================+
| Programa  : AGRQTDVETMAT                                                                        |
| Descrição : Pesquisa a se existe um conteúdo em ou vetor ou matriz                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 25/01/2015                                                                          |
+=================================================================================================+     
| Retorna   : vaDados - Vetor ou matriz com os dados                                   Obrigatório|
|             cTipoEs - Tipo da estrutura dos dados ("M" - Matriz, "V" - Vetor)        Obrigatório|
|             cConteu - Conteúdo a ser pesquisado                                      Obrigatório|
+=================================================================================================+     
|Retorna    : Se cTipo = "M" Matriz Onde a saber:..[1,x,1] Linha da matriz que contém o conteúdo  | 
|                                                ..[1,x,n] Colunas da matriz que contém o conteúdo|
|                                                                                                 | 
|             Se cTipo = "V" Vetor Onde a saber:     ..[n] Colunas do vetor que contém o conteúdo |    
+=================================================================================================+   
|Referências :                                                                                    |
+=================================================================================================+
*/               
Function AGRQTDVETMAT(vaDados,cTipoEs,cConteu)
	Local nx,ny,vaMatR := {}
	If cTipoEs = "M" // Matriz
		For nx := 1 To len(vaDados)
			lPrim := .t.
			For ny := 1 To len(vaDados[nx])
				If ValType(vaDados[nx,ny]) = ValType(cConteu) .And. vaDados[nx,ny] = cConteu
					If lPrim
						Aadd(vaMatR,{})
						Aadd(vaMatR[len(vaMatR)],nx)
						lPrim := .f.
					EndIf   
					Aadd(vaMatR[len(vaMatR)],ny)
				EndIf
			Next ny
		Next nx
	Else // Vetor
		For nx := 1 To len(vaDados)
			If ValType(vaDados[nx]) = ValType(cConteu) .And. vaDados[nx] = cConteu
				Aadd(vaMatR,nx)
			EndIf
		Next nx			
	EndIf
Return {vaMatR}

/*
+=================================================================================================+
| Função    : AGRQTDEXTEN                                                                         |
| Descrição : Converte um valor em quantidade por extenso                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 07/06/2016                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: nQuant - Quantidade a ser convertida                                     Obrigatório|
|             lRetVe - Indica se retorna um vetor                                      Não Obrigat|
|             cSufix - Sufixo se tiver decimais ("," ou "e")                           Não Obrigat|
+=================================================================================================+
|Retorna    : IRetVe <> Nil, Vetor [1]-String da parte inteira,[2]- Sting cSufix + Decimais (se   |
|             tiver) Senão String completa                                                        |
+=================================================================================================+
|Referências: OGA200                                                                              |
+=================================================================================================+ 
*/
Function AGRQTDEXTEN(nQuant,lRetVe,cSufix)
	Local cExt := Extenso(InT(nQuant),.t.)
	Local cExI := cExt,cEx2 := ""
	Local nDec := nQuant - InT(nQuant)
	Local lReV := If(lRetVe = Nil,.f.,.t.)
	Local cSuf := If(cSufix = Nil,',',cSufix)
	If nDec > 0
		cDec := Alltrim(Str(nDec))
		nDec := Val(StrTran(cDec,"0.",""))
		cEx2 := Extenso(nDec,.t.)
		cExI += cSuf+cEx2
	EndIf	
Return If(lReV,{cExt,cEx2},cExI)   

// TRATAMENTO DE UMA MATRIZ
/*
+=================================================================================================+
| Função    : AGRFACAESSX3                                                                        |
| Descrição : Carrega uma matriz com campos do SX3                                                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 09/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: vVetFami- Vetor com as família dos campos                                Obrigatório|
|             vVetColu- Vetor com os campos (colunas) de retorno                       Obrigatório|
|             lVirt   - Indica se os campos virtuais devem faz parte no retorno        Não Obrigat|             
+=================================================================================================+
| Retorna   : aReESX3 - Matriz com os campos                                                      |
+=================================================================================================+
|Referências : AGRA980                                                                            |
+=================================================================================================+ 
*/
Function AGRFACAESSX3(vVetFami,vVetColu,lVirt)
	Local aReESX3 := {}
	Local nX      := 0
	Local nY      := 0
	Local aCampos := {}
	Local lVirtua := If(lVirt = Nil,.t.,lVirt)

	For nx := 1 To Len(vVetFami)

		aCampos := FWSX3Util():GetAllFields( vVetFami[nX], lVirtua ) //Retorna os campos de um alias específico da SX3 - http://tdn.totvs.com/x/Agu2Fg

		If !Empty(aCampos)
			For nY := 1 To Len(aCampos)
				If x3Usado(aCampos[nY])
					If Len(vVetColu) = 2
						Aadd(aReESX3,{aCampos[nY], AllTrim(RetTitle(aCampos[nY]))})
					Else
						Aadd(aReESX3, {aCampos[nY]})
					EndIf
				EndIf
			Next nY
		EndIf

	Next nx    

Return aReESX3

/*
+=================================================================================================+
| Função    : AGRMATVETOR                                                                         |
| Descrição : Retorma um vetor a partir de uma matriz                                             |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/12/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: aMatriz - Matriz que contém as informações                               Obrigatório|
|             nColinh - Número da coluna e/ou linha que irá formar o vetor             Obrigatório|
|             cTipoIn - Incremento que irá formar o vetor ("C" -Coluna, "L" -linhas)   Não Obrigat|             
+=================================================================================================+
| Retorna   : vVetor  - Vetor contendo as informaçoes                                             |
+=================================================================================================+
|Referências:                                                                                     |
+=================================================================================================+ 
*/
Function AGRMATVETOR(aMatriz,nColLinh,cTipoIn)
	Local cTipInc := If(cTipoIn = Nil,"C",cTipoIn)
	Local vVetor  := {},nx
	If !Empty(aMatriz)
		If cTipInc = "C" 
			If nColLinh <= Len(aMatriz[1])
				For nx := 1 To Len(aMatriz)
					Aadd(vVetor,aMatriz[nx,nColLinh])
				Next nx
			EndIf
		Else
			If nColLinh <= Len(aMatriz)
				vVetor := Aclone(aMatriz[nColLinh])
			EndIf
		EndIf
	EndIf
Return vVetor				

// TRATAMENTO COM SERVIDOR
/*
+=================================================================================================+
| Função    : AGRRETCSER                                                                          |
| Descrição : Retorna o caminho do servidor                                                       |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 17/07/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cQserve - Tipo do servidor (Root, Star)                                  Obrigatorio|
+=================================================================================================+
|Referências : AGRA980                                                                            |
+=================================================================================================+ 
*/
Function AGRRETCSER(cQserve)
	Local cBarras := If(isSRVunix(),"/","\")
	cpath := If(cQserve = "Root",AllTrim(GetSrvProfString("RootPath",cBarras)),;
	AllTrim(GetSrvProfString("StartPath",cBarras)))
	cpath += If(SubStr(cpath,Len(cpath),1) <> cBarras,cBarras,"")
Return cpath

// TRATAMENTO DE COMPARAÇÃO
/*
+=================================================================================================+
| Função    : AGRCOMPARA                                                                          |
| Descrição : Compara duas informações                                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 09/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cInfo1 - Primeira informação a comparar                                  Obrigatório|
|             cSinal - Sinal para a comparação                                         Obrigatório|
|             cInf02 - Segunda informação a ser camparar(com a Primeira0               Obrigatório|
|             lInvCo - Inverte a afirmação na mensagem                                 Não Obrigat|
|             lMostR - Mostra na tela o resultado da comporação                        Não Obrigat| 
|             cMensE - Mensagem especial se não for verdadeira a comparação            Não Obrigat|             
+=================================================================================================+
| OBSERVAÇÃO: A comparação é baseada na forma afirmativa. Ex: 1 > 2 Resultado: 1 não é maior que 2|
+=================================================================================================+
| Retorna   : .t.,.f.                                                                             |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRCOMPARA(cInfo1,cSinal,cInfo2,lInvCo,lMostR,cMensE)
	Local lMenL := If(lMostR = Nil,.f.,lMostR)
	Local lInvL := If(lInvCo = Nil,.f.,lInvCo)
	Local cMens := Space(1)
	Local aCond := {{">",STR0029},{"<",STR0030},{">=",STR0031},{"<=",STR0032},;
	{"=",STR0033},{"<>",STR0034},{"$",STR0035}}
	If ValType(cInfo1) <> ValType(cInfo2)
		Alert(STR0039)
		Return .f.
	EndIf

	nPosS := Ascan(aCond,{|x| (Alltrim(x[1])) == Alltrim(cSinal)})
	If nPosS > 0
		If ValType(cInfo1) = "N" .Or. ValType(cInfo1) = "D"
			cInfo1C := If(ValType(cInfo1) = "N",Alltrim(Str(cInfo1,20)),Dtoc(cInfo1))
		Else
			cInfo1C := cInfo1
		EndIf
		If ValType(cInfo2) = "N" .Or. ValType(cInfo2) = "D"
			cInfo2C := If(ValType(cInfo2) = "N",Alltrim(Str(cInfo2,20)),Dtoc(cInfo2))
		Else
			cInfo2C := cInfo2
		EndIf 

		cCondIf := If(cSinal <> "$",&(cInfo1C+" "+cSinal+" "+cInfo2C),cInfo1C $ cInfo2C)
		If !cCondIf
			cInf1 := If(lInvL,cInfo2C,cInfo1C)
			cInf2 := If(lInvL,cInfo1C,cInfo2C)
			cPare := If(cSinal <> "$",STR0037+" "+aCond[nPosS,2]+" "+STR0038+" "+STR0036,STR0040)
			cMens := Upper(STR0038)+" "+STR0036+" "+cInf1+" "+cPare+" "+cInf2
		Endif
	Endif

	If !Empty(cMens) .And. lMenL
		Alert(If(cMensE <> Nil,cMensE,cMens))
	Endif

Return If(Empty(cMens),.t.,.f.)

/*
+=================================================================================================+
| Função    : AGRPROCNLIST                                                                        |
| Descrição : Procura em uma lista o valor condicional (>,<)                                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 08/05/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: vVetDad - Vetor com dadas a serem comparados                             Obrigatório|
|             cSinal  - Sinal para a comparação                                        Não Obrigat|
+=================================================================================================+
| Retorna   : Conteúdo da condição solicitada                                                     |
+=================================================================================================+
|Referências :                                                                                    |
+=================================================================================================+ 
*/
Function AGRPROCNLIST(vVetDad,cSinal)
	Local lMai := If(cSinal = Nil,.t.,If(cSinal = ">",.t.,.f.))
	Local vVeO := If(lMai,aSort(vVetDad,,,{|x,y| x > y}),aSort(vVetDad,,,{|x,y| x < y}))
Return vVeO[1] 

/*
+=================================================================================================+
| Função    : AGRDTFECHAEST                                                                       |
| Descrição : Verifica data de fechamento do estoque                                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 05/01/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: dVDATAF - Data de lançamento                                             Obrigatório|
|             lMENSAI - Indica saída na tela                                           Não Obrigat|
+=================================================================================================+
| Retorna   : .t.,.f.                                                                             |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRDTFECHAEST(dVDATAF,lMENSAI)
	Local dDTULMES := GetMv("MV_ULMES"),lSAIMEN := If(lMENSAI = Nil,.t.,lMENSAI)
	If dVDATAF <= dDTULMES
		If lSAIMEN
			ShowHelpDlg("FECHTO",{STR0052},2,{STR0053+DTOC(dDTULMES)},2)
		Endif
		Return .f.
	Endif
Return .t.

// TRATAMENTO COM METODOLOGIA MVC
/*                                                                                                 
+=================================================================================================+
| Função    : AGRCAMPDEF                                                                          |
| Descrição : Adiciona campos na estrutura ModelDef                                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 01/10/2015                                                                          | 
+=================================================================================================+ 
|Parâmetros : oObj - Nome do objeto do ModelDef                                        Obrigatório|
|             aMat - Matriz com as caracteristicas dos campos                          Obrigatório|
+=================================================================================================+  
|Referências: AGRA840                                                                             |
+=================================================================================================+  
*/
Function AGRCAMPDEF(oObj,aMat)
	Local nx
	For nx := 1 To Len(aMat)
		oObj:AddField(aMat[nx,1],aMat[nx,2],aMat[nx,3],aMat[nx,4],aMat[nx,5],;
		If(Len(aMat[nx]) > 5  .And. aMat[nx,6]  <> NIL,aMat[nx,6],0),;    // 6
		If(Len(aMat[nx]) > 6  .And. aMat[nx,7]  <> NIL,aMat[nx,7],),;     // 7
		If(Len(aMat[nx]) > 7  .And. aMat[nx,8]  <> NIL,aMat[nx,8],NIL),;  // 8
		If(Len(aMat[nx]) > 8  .And. aMat[nx,9]  <> NIL,aMat[nx,9],),;     // 9
		If(Len(aMat[nx]) > 9  .And. aMat[nx,10] <> NIL,aMat[nx,10],NIL),; // 10
		If(Len(aMat[nx]) > 10 .And. aMat[nx,11] <> NIL,aMat[nx,11],),;    // 11
		If(Len(aMat[nx]) > 11 .And. aMat[nx,12] <> NIL,aMat[nx,12],NIL),; // 12
		If(Len(aMat[nx]) > 12 .And. aMat[nx,13] <> NIL,aMat[nx,13],),;    // 13
		If(Len(aMat[nx]) > 13 .And. aMat[nx,14] <> NIL,aMat[nx,14],.F.))  // 14
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRCAMPVIEW                                                                         |
| Descrição : Adiciona campos na estrutura da View                                                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 02/10/2015                                                                          | 
+=================================================================================================+ 
|Parâmetros : oObj - Nome do objeto do ModelDef                                        Obrigatório|
|             aMat - Matriz com as caracteristicas dos campos                          Obrigatório|
+=================================================================================================+  
|Referências: AGRA840                                                                             |
+=================================================================================================+  
*/
Function AGRCAMPVIEW(oObj,aMat)
	Local nx
	For nx := 1 To Len(aMat)
		oObj:AddField(aMat[nx,1],aMat[nx,2],aMat[nx,3],aMat[nx,4],aMat[nx,5],aMat[nx,6],aMat[nx,7],;
		If(Len(aMat[nx]) > 7  .And. aMat[nx,8]  <> NIL,aMat[nx,8],NIL),;  // 8
		If(Len(aMat[nx]) > 8  .And. aMat[nx,9]  <> NIL,aMat[nx,9],),;     // 9
		If(Len(aMat[nx]) > 9  .And. aMat[nx,10] <> NIL,aMat[nx,10],.T.),; // 10
		If(Len(aMat[nx]) > 10 .And. aMat[nx,11] <> NIL,aMat[nx,11],NIL),; // 11
		If(Len(aMat[nx]) > 11 .And. aMat[nx,12] <> NIL,aMat[nx,12],NIL),; // 12
		If(Len(aMat[nx]) > 12 .And. aMat[nx,13] <> NIL,aMat[nx,13],),;    // 13
		If(Len(aMat[nx]) > 13 .And. aMat[nx,14] <> NIL,aMat[nx,14],NIL),; // 14
		If(Len(aMat[nx]) > 14 .And. aMat[nx,15] <> NIL,aMat[nx,15],NIL),; // 15
		If(Len(aMat[nx]) > 15 .And. aMat[nx,16] <> NIL,aMat[nx,16],.F.),; // 16
		If(Len(aMat[nx]) > 15 .And. aMat[nx,17] <> NIL,aMat[nx,17],NIL))  // 17
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRGRIDMVC                                                                          |
| Descrição : Monta grid do MVC                                                                   |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 09/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oStruOBJ - Objeto do grid do MVC                                         Obrigatório|
|             cAliaMVC - Alias da tabela para montar as colunas                        Obrigatório|
|             vVetCamp - Vetor com os campos                                           Obrigatório|
|             lRetira  - Indica se retira o campo ou somente permanece os informados   Não Obrigat|    
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRGRIDMVC(oStruOBJ,cAliaMVC,vVetCamp,lRetira)
	LOcal nX       := 0
	Local aCampos  := FWSX3Util():GetAllFields( cAliaMVC ) //Retorna os campos de um alias específico da SX3 - http://tdn.totvs.com/x/Agu2Fg

	If !Empty(aCampos)
		For nX := 1 To Len(aCampos)
			If x3Usado(aCampos[nX])
				nPosi := Ascan(vVetCamp,{|x| Alltrim(x) = Alltrim(aCampos[nX])})
				If !Empty(nPosi) 
					If lRetira 
						oStruOBJ:RemoveField(Alltrim(vVetCamp[nPosi]))
					EndIf
				Else 
					If !lRetira      
						oStruOBJ:RemoveField(Alltrim(aCampos[nX]))
					EndIf 
				EndIf
			EndIf
		Next nX
	EndIf

Return

/*
+=================================================================================================+
| Função    : AGRVALIDMVC                                                                         |
| Descrição : Seta a propriedade do valid do campo da grid do MVC                                 |
| Autor     : Ináaio Luiz Kolling                                                                 |
| Data      : 09/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oStruOBJ - Objeto do grid do MVC                                         Obrigatório|
|             vVetCamp - Vetor com os campos                                           Obrigatório|
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRVALIDMVC(oStruOBJ,vVetCamp)
	Local nx
	For nx := 1 To Len(vVetcamp)
		oStruOBJ:SetProperty(vVetCamp[nx],MODEL_FIELD_VALID,{| oFields | AGRRETTRUE( oFields )})
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRVALDEMVC                                                                         |
| Descrição : Seta a propriedade do valid para estrutura dos campos da grid do MVC                |
| Autor     : Ináaio Luiz Kolling                                                                 |
| Data      : 09/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oStruOBJ - Objeto do grid do MVC                                         Obrigatório|
|             aMatCamp - Matriz com os campos e validação                              Obrigatório|
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRVALDEMVC(oStruOBJ,aMatCamp)
	Local nx
	For nx := 1 To Len(aMatcamp)
		oStruOBJ:SetProperty(aMatCamp[nx,1],MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,aMatCamp[nx,2]))
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRRETTRUE                                                                          |
| Descrição : Seta o retorno sempre como verdadeiro                                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 09/08/2014                                                                          |
+=================================================================================================+       
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRRETTRUE()
Return .t.

/*
+=================================================================================================+
| Função    : AGRRETFALSO                                                                         |
| Descrição : Seta o retorno sempre como falso                                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 14/11/2014                                                                          |
+=================================================================================================+       
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRRETFALSO()
Return .F.

/*
+=================================================================================================+
| Função    : AGRCHANGEMVC                                                                        |
| Descrição : Seta a propriedade do CHANGE do campo da grid do MVC                                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 09/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oStruOBJ - Objeto do grid do MVC                                         Obrigatório|
|             vVetCamp - Vetor com os campos                                           Obrigatório|
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRCHANGEMVC(oStruOBJ,vVetCamp)
	Local nx
	For nx := 1 To Len(vVetcamp)
		oStruOBJ:SetProperty(vVetCamp[nx],MVC_VIEW_CANCHANGE,.F.)
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGROBRIGMVC                                                                         |
| Descrição : Set a propriedade do OBRIGAT do campo da grid do MVC                                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 09/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oStruOBJ - Objeto do grid do MVC                                         Obrigatório|
|             vVetCamp - Vetor com os campos                                           Não Obrigat|
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGROBRIGMVC(oStruOBJ,vVetCamp)
	Local nx
	If vVetCamp <> Nil .And. !Empty(vVetCamp) 
		For nx := 1 To Len(vVetcamp)
			oStruOBJ:SetProperty(vVetCamp[nx], MODEL_FIELD_OBRIGAT,.F.)
		Next nx
	Else
		oStruOBJ:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F.)
	EndIf	
Return

/*
+=================================================================================================+
| Função    : AGRTITULOMVC                                                                        |
| Descrição : Seta a propriedade para alterar o título do campo da grid do MVC                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 21/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oStruOBJ - Objeto do grid do MVC                                         Obrigatório|
|             aMatCamp - Matriz com os campos e títulos                                Obrigatório|
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRTITULOMVC(oStruOBJ,aMatCamp)
	Local nx
	For nx := 1 To Len(aMatCamp)
		oStruOBJ:SetProperty(aMatCamp[nx,1],MVC_VIEW_TITULO,aMatCamp[nx,2])
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRORDEMMVC                                                                         |
| Descrição : Seta a propriedade para alterar a ordem do campo da grid do MVC                     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 21/08/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oStruOBJ - Objeto do grid do MVC                                         Obrigatório|
|             aMatCamp - Matriz com os campos e ordem                                  Obrigatório|
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRORDEMMVC(oStruOBJ,aMatCamp)
	Local nx,cOrdem
	For nx := 1 To Len(aMatCamp)
		cOrdem := If(Len(aMatCamp[nx]) = 2,aMatCamp[nx,2],StrZero(nx,3))
		oStruOBJ:SetProperty(aMatCamp[nx,1],MVC_VIEW_ORDEM,cOrdem)
	Next nx
Return	

/*
+=================================================================================================+
| Função    : AGRWHENMVC                                                                          |
| Descrição : Seta a propriedade when MVC                                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 06/11/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oStruOBJ - Objeto do grid do MVC                                         Obrigatório|
|             aMatCamp - Matriz com os campos                                          Não Obrigat|
+=================================================================================================+
|Referências : OGRA180                                                                            |
+=================================================================================================+ 
*/
Function AGRWHENMVC(oStruOBJ,aMatCamp)
	Local nx
	If aMatCamp <> Nil .And. !Empty(aMatCamp)
		For nx := 1 To Len(aMatCamp)
			lWhen := If(Len(aMatCamp[nx]) > 1,aMatCamp[nx,2],'.f.')
			oStruOBJ:SetProperty(aMatCamp[nx,1],MODEL_FIELD_WHEN,FWBuildFeature(STRUCT_FEATURE_WHEN,lWhen)) //".F.")
		Next nx
	Else
		oStruOBJ:SetProperty( '*', MODEL_FIELD_WHEN,NIL )   
	EndIf
Return	

/*
+=================================================================================================+
| Função    : AGRINIPADMVC                                                                        |
| Descrição : Seta a propriedade inicializador padrão em MVC                                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 06/11/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oStruOBJ - Objeto do grid do MVC                                         Obrigatório|
|             aMatCamp - Matriz com os campos                                          Obrigatório|
+=================================================================================================+
|Referências : OGRA180                                                                            |
+=================================================================================================+ 
*/
Function AGRINIPADMVC(oStruOBJ,aMatCamp)
	Local nx
	For nx := 1 To Len(aMatCamp)
		oStruOBJ:SetProperty(aMatCamp[nx,1],MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,aMatCamp[nx,2]))
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRINIPADIVE                                                                        |
| Descrição : Seta a propriedade inicializador padrão em MVC IVE   {||...}                        |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 06/11/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oStruOBJ - Objeto do grid do MVC                                         Obrigatório|
|             vVetCamD - Vetor com o campo e dado                                      Obrigatório|
+=================================================================================================+
|Referências:                                                                                     |
+=================================================================================================+ 
*/
Function AGRINIPADIVE(oBjto,vVetCamD)
	oBjto:SetProperty(vVetCamD[1],MODEL_FIELD_INIT,{|| vVetCamD[2]})
Return 
/*
+=================================================================================================+
| Função    : AGRLIMPAGRID                                                                        |
| Descrição : limpa todos os dados da grid                                                        |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 06/11/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oGridOBJ - Objeto Model da grid                                          Obrigatório|
+=================================================================================================+
|Referências :                                                                                    |
+=================================================================================================+ 
*/
Function AGRLIMPAGRID(oGridOBJ,oVIEWGRID)
	oGridOBJ:cleardata()
	oGridOBJ:InitLine()
	If ValType(oView) != "U"
		oView:Refresh(oVIEWGRID)
	EndIf
Return

/*                                                                                                 
+=================================================================================================+
| Função    : AGRLIMPCMVC                                                                         |
| Descrição : Limpo campos da grid em MVC                                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 02/10/2015                                                                          | 
+=================================================================================================+ 
|Parâmetros : oObj     - Nome do objeto da grid                                        Obrigatório|
|             nLin     - Linha da grid                                                 Obrigatório|
|             vVetCamp - Vetor com os campos para limpar                               Obrigatório|
+=================================================================================================+  
|Referências: AGRA840                                                                             |
+=================================================================================================+  
*/
Function AGRLIMPCMVC(oBjto,nLin,vVetCamp)
	Local nx 
	For nx := 1 To Len(vVetCamp)
		nPosC := Ascan(oBjto:OFORMMODELSTRUCT:AFIELDS,{|x| Alltrim(x[3]) = vVetCamp[nx]})
		If nPosC > 0
			oBjto:ADATAMODEL[nLin,1,1,nPosC] := If(oBjto:OFORMMODELSTRUCT:AFIELDS[nPosC,4] = 'C',;
			Space(oBjto:OFORMMODELSTRUCT:AFIELDS[nPosC,5]),;
			If(oBjto:OFORMMODELSTRUCT:AFIELDS[nPosC,4] = 'N',0,"  /  /    "))

		EndIf
	Next nx
Return

/*                                                                                                 
+=================================================================================================+
| Função    : AGRSETVALUE                                                                         |
| Descrição : Atribui valor para o campo da grid em MVC                                           |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 22/09/2015                                                                          |
+=================================================================================================+ 
|Parâmetros : oGrid  - Objeto da grid                                                  Obrigatório| 
|             aMatCD - Matriz com os campos e valores                                  Obrigatório| 
+=================================================================================================+ 
|Referências: AGRA840                                                                             |
+=================================================================================================+  
*/
Function AGRSETVALUE(oGrid,aMatCD)
	Local nx 
	For nx := 1 To Len(aMatCD)
		oGrid:SetValue(aMatCD[nx,1],aMatCD[nx,2])
	Next nx
Return

/*                                                                                                 
+=================================================================================================+
| Função    : AGRLOADVALUE                                                                        |
| Descrição : Atribui valor para o campo da grid em MVC                                           |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 22/09/2015                                                                          |
+=================================================================================================+ 
|Parâmetros : oGrid  - Objeto da grid                                                  Obrigatório| 
|             aMatCD - Matriz com os campos e valores                                  Obrigatório| 
+=================================================================================================+ 
|Referências: AGRA840                                                                             |
+=================================================================================================+  
*/
Function AGRLOADVALUE(oGrid,aMatCD)
	Local nx 
	For nx := 1 To Len(aMatCD)
		oGrid:LoadValue(aMatCD[nx,1],aMatCD[nx,2])
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRYESNOMVC                                                                         |
| Descrição : Opção do tipo YESNO para MVC                                                        |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 11/11/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cMensa - Mensagem da tela                                                Obrigatório|
|             cTitul - Título do janela                                                Não obrigat|
+=================================================================================================+
|Referências : OGRA180                                                                            |
+=================================================================================================+ 
*/
Function AGRYESNOMVC(cMensa,cTitul)
	Local lRet := .f.,cTitu := If(cTitul <> Nil,cTitul,'')
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlgYesNo TITLE STR0021 From 4,20 To 16,60 OF oMainWnd COLOR CLR_BLACK,CLR_WHITE
	@ 5,09 GROUP oGroup TO 070,150 LABEL OemtoAnsi(cTitu) OF oDlgYesNo PIXEL COLOR CLR_BLUE
	oGroup:oFont := oFont
	@ 12,12 GET oProb VAR cMensa MEMO SIZE 135,56 PIXEL OF oGroup NO MODIFY NO BORDER
	Define sButton From 074,090 Type 1 Enable Of oDlgYesNo Action (lRet := .T., oDlgYesNo:End())
	Define sButton From 074,120 Type 2 Enable Of oDlgYesNo Action oDlgYesNo:End()
	Activate MsDialog oDlgYesNo Centered
Return lRet

/*
+=================================================================================================+
| Função    : AGRREADVAMVC                                                                        |
| Descrição : Identifica a variável de leitura ( focada )                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 20/02/2015                                                                          |
+=================================================================================================+                                                                           |  
| Retorna   : cVariavel - Nome da variável                                                        |
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRREADVAMVC() 
	Local ovieAtual := FWViewActive()
Return ovieAtual:GetCurrentSelect()[2]

/*
+=================================================================================================+
| Função    : AGRSETNOLINE                                                                        |
| Descrição : Seta a linha da grid                                                                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/12/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oBjto  - Objeto da grid                                             Não Obrigatório | 
|             lInser - Inserir nova linha                                         Não Obrigatório |
|             lAlter - Altera a linha                                             Não Obrigatório |
|             lDelet - Deleta a linha                                             Não Obrigatório |
|             MdGrid - Nome da grid                                               Não Obrigatório |
+=================================================================================================+
|Referências : AGRA900                                                                            |
+=================================================================================================+ 
*/
Function AGRSETNOLINE(oBjto,lInser,lAlter,lDelet,MdGrid)
	If lInser <> Nil
		If oBjto <> Nil .And. MdGrid = Nil
			oBjto:SetNoInsertLine(lInser)
		EndIf	
		If MdGrid <> Nil
			oBjto:GetModel(MdGrid):SetNoInsertLine(lInser)
		EndIf
	EndIf
	If lAlter <> Nil	
		If oBjto <> Nil .And. MdGrid = Nil
			oBjto:SetNoUpdateLine(lAlter)
			If MdGrid <> Nil
				oBjto:GetModel(MdGrid):SetNoUpdateLine(lAlter)
			EndIf
		EndIf		
	EndIf
	If lDelet <> Nil
		If oBjto <> Nil .And. MdGrid = Nil
			oBjto:SetNoDeleteLine(lDelet)
		EndIf	
		If MdGrid <> Nil
			oBjto:GetModel(MdGrid):SetNoDeleteLine(lDelet)
		EndIf	
	EndIf
Return

/*
+=================================================================================================+
| Função    : AGRSETDESCRIP                                                                       |
| Descrição : Seta o titulo da grid                                                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/12/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oBjto   - Objeto                                                        Obrigatório |
|             aMatDes - Matriz com grid e descrição                                   Obrigatório |
+=================================================================================================+
|Referências : AGRA900                                                                            |
+=================================================================================================+ 
*/
Function AGRSETDESCRIP(oBjto,aMatDes)
	Local nx
	For nx := 1 To Len(aMatDes)
		oBjto:GetModel(aMatDes[nx,1]):SetDescription(aMatDes[nx,2])
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRCRIABOX                                                                          |
| Descrição : Monta box                                                                           |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/12/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oBjto   - Objeto                                                        Obrigatório |
|             aMatBox - Matriz nome do box e tamanho                                  Obrigatório |
+=================================================================================================+
|Referências : AGRA900                                                                            |
+=================================================================================================+ 
*/
Function AGRCRIABOX(oBjto,aMatBox)
	Local nx
	For nx := 1 To Len(aMatBox)
		oBjto:CreateHorizontalBox(aMatBox[nx,1],aMatBox[nx,2])
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRSETOWNERV                                                                        |
| Descrição : Set Owner                                                                           |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/12/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oBjto    - Objeto                                                       Obrigatório |
|             aMatView - Matriz nome do Field e box                                   Obrigatório |
+=================================================================================================+
|Referências : AGRA900                                                                            |
+=================================================================================================+ 
*/
Function AGRSETOWNERV(oBjto,aMatView)
	Local nx
	For nx := 1 To Len(aMatView)
		oBjto:SetOwnerView(aMatView[nx,1],aMatView[nx,2])
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRENABTVIEW                                                                        |
| Descrição : Set titulo da view                                                                  |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/12/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oBjto    - Objeto                                                       Obrigatório |
|             vVetView - Vetor com os nomes da view                                   Obrigatório |
+=================================================================================================+
|Referências : AGRA900                                                                            |
+=================================================================================================+ 
*/
Function AGRENABTVIEW(oBjto,vVetView)
	Local nx
	For nx := 1 To Len(vVetView)
		oBjto:EnableTitleView(vVetView[nx])
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRFwFldPut                                                                         |
| Descrição : Carrega campos com valor                                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 23/12/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: aMatCaDa - Matriz com os campos e dados                                 Obrigatório |
+=================================================================================================+
|Referências : AGRA890                                                                            |
+=================================================================================================+ 
*/
Function AGRFwFldPut(aMatCaDa)
	Local nx
	For nx := 1 To Len(aMatCaDa)
		FwFldPut(aMatCaDa[nx,1],aMatCaDa[nx,2])
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRMENUMVC                                                                          |
| Descrição : Monta o menu def                                                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 28/12/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: aMatMenu - Matriz com as opções do menu                                 Obrigatório |
+=================================================================================================+
|Referências : AGRA900...                                                                         |
+=================================================================================================+ 
*/
Function AGRMENUMVC(aMatMenu)
	Local nx,aMenu := {}
	For nx := 1 To Len(aMatMenu)
		ADD OPTION aMenu Title aMatMenu[nx,1] Action aMatMenu[nx,2] OPERATION aMatMenu[nx,3] ACCESS If(len(aMatMenu[nx]) > 3,aMatMenu[nx,4],0)
	Next nx 
Return aMenu

/*
+=================================================================================================+
| Função    : AGRGROUPMVC                                                                         |
| Descrição : Inclui campos no grupo                                                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/02/2016                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: oBjto   - Objeto                                                        Obrigatório |
|             cGrupo  - Nome do grupo                                                 Obrigatório |
|             vVetCam - Vetor com os campo do grupo                                   Obrigatório |
+=================================================================================================+
|Referências : AGRA900                                                                            |
+=================================================================================================+ 
*/
Function AGRGROUPMVC(oBjto,cGrupo,vVetCam)
	Local nx
	For nx := 1 To Len(vVetCam)
		oBjto:SetProperty(vVetCam[nx],MVC_VIEW_GROUP_NUMBER,cGRUPO)
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRMODELAUT                                                                         |
| Descrição : Geração automática de uma regra de negócio (ModelDef/ViewDef)                       |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 20/04/2016                                                                          |
+=================================================================================================+
|Parâmetros : cAliaP  - Alias da tabela pai                                            Obrigotório|
|             aCampP  - Matriz com os campos e dados tabela pai                        Obrigotório|
|             cMLoadP - Nome do LoadModel pai para instânciamento                      Obrigotório|
|             cGetMoP - Nome do getModel dos campos do pai                             Obrigotório|
|             aModelF - Matriz com os dados para o(s) filho(s)                         Não Obrigot|
|             cFuncao - Nome da função que chamou                                      Não Obrigot|
|             cNoProc - Nome do processo                                               Não Obrigot|
|             cFilTab - Código da filial                                               Não Obrigot|
+=================================================================================================+
|OBSERVAÇÃO : aModelF... onde:{alias,Getmodel,matriz com os campos e dados}                       |
|             Variáveis privadas usadas no model e/ou no dicionário de dados deverão serem defini-|
|             das no programa que chama a atualização automática                                  |
|                                                                                                 |
|             ATENÇÃO: Se ter mensagem de erro,verificar TODOS os atributos do campo no dicionário|
|                      de dados (SX3, Valid,relacao,obrigat,when, etc)                            |  
+=================================================================================================+
|Referência : AGR                                                                                 |
+=================================================================================================+
|Retorna    : lRetor (.t.,.f.)                                                                    |
+=================================================================================================+ 
*/
Function AGRMODELAUT(cAliaP,aCampP,cMLoadP,cGetMoP,aModelF,cFuncao,cNoProc,cFilTab)
	Local vVetEr 	:= {STR0237,STR0238,STR0239,STR0240,STR0241,STR0242,STR0243,STR0244,STR0245}
	Local oModel
	Local oAux
	Local oStruct
	Local lRetor 	:= .T.
	Local lInclui 	:= " "
	Local nx		:= 0
	Local ny		:= 0
	Local nf		:= 0
	Local nitemE 	:= 0
	Local aCampos 	:= {}
	Local cFilAtu 	:= cFilAnt
	Local cProces 	:= If(cNoProc = Nil,AGRSX2NOME(cAliaP),cNoProc)
	Local cFunc   	:= If(cFuncao = Nil,FunName(),cFuncao)

	If type("inclui") <> "U"
		lInclui := inclui
	EndIf	
	inclui := .t.

	cFilAnt := If(cFilTab <> Nil,cFilTab,cFilAnt)			

	DbSelectArea(cAliaP)
	DbSetOrder(1)

	SetFunName(cFunc) 
	oModel := FWLoadModel(cMLoadP)

	//A princípio só inclusão
	oModel:SetOperation(3)

	// Ativar o modelo
	oModel:Activate()

	// Instancia cabeçalho
	oAux := oModel:GetModel(cGetMoP)

	// Estrutura do cabeçalho
	oStruct := oAux:GetStruct()
	aCampos := oStruct:GetFields()

	If lRetor
		For nx := 1 To Len(aCampP)
			If aScan(aCampos,{|x| AllTrim(x[3]) == AllTrim(aCampP[nx,1])}) > 0
				If !oModel:LoadValue(cGetMoP,aCampP[nx,1],aCampP[nx,2])
					lRetor := .F.
					Exit
				EndIf
			EndIf
		Next nx
	EndIf

	If lRetor .And. aModelF <> Nil .And. !Empty(aModelF)
		For nf := 1 To Len(aModelF)
			DbSelectArea(aModelF[nf,1])
			DbSetOrder(1)
			cGetMoF := aModelF[nf,2]
			aCampF  := aModelF[nf,3]
			// Instanciamos Model Filho
			oAux := oModel:GetModel(cGetMoF)
			// Estrutura de dados do item
			oStruct := oAux:GetStruct()
			aCampos := oStruct:GetFields()
			nitemE  := 0
			For nx := 1 To Len(aCampF)
				If nx > 1
					// Nova linha
					If (nitemE := oAux:AddLine()) <> nx
						lRetor := .F.
						Exit
					EndIf
				EndIf
				For ny := 1 To Len(aCampF[nx])
					// Estrutura de dados do item
					If aScan(aCampos,{|x| AllTrim(x[3]) == AllTrim( aCampF[nx,ny,1])}) > 0
						If !oModel:LoadValue(cGetMoF,aCampF[nx][ny,1],aCampF[nx,ny,2])
							lRetor := .F.
							nitemE := nx
							Exit
						EndIf
					EndIf
				Next ny
				If !lRetor
					Exit
				EndIf
			Next nx
			If !lRetor
				Exit
			EndIf
		Next nf
	EndIf

	If lRetor
		If oModel:VldData()
			lRetor := oModel:CommitData()
		Else 
			lRetor := .F.
		EndIf
	EndIf

	If !lRetor
		aErro := oModel:GetErrorMessage()
		aErro[7] := STR0246+" (_PICTURE,_VALID,_RELACAO,_OBRIGAT,_VLDUSER,_WHEN,...)"+" "+STR0247 
		AutoGrLog(cProces) 
		AutoGrLog(STR0248+" ( SX3 )")
		AutoGrLog("")
		For nx := 1 To Len(vVetEr)
			AutoGrLog(vVetEr[nx]+" "+If(nx > 7,If(ValType(aErro[nx]) = "N",Alltrim(Str(aErro[nx])),;
			If(ValType(aErro[nx]) = "D",Dtoc(aErro[nx]),;
			AllToChar(aErro[nx]))),AllToChar(aErro[nx])))
		Next nx
		If nitemE > 0
			AutoGrLog(STR0249+" "+AllTrim(AllToChar(nitemE)))	//"Erro no Item..............: "

		EndIf
		MostraErro()
	EndIf

	// Desativamos o Model pai
	oModel:DeActivate()

	If !Empty(lInclui)
		inclui := lInclui
	EndIf

	cFilAnt := cFilAtu
Return lRetor

/* 
+=================================================================================================+
| Função    : AGRGETLISMVC                                                                        |
| Descrição : Monta tele com gets no modelo MVC                                                   |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/03/2016                                                                          |
+=================================================================================================+
|Parâmetros : cAlia - Alias da tabela                                                  Obrigotório|
|             nAltu - Altura da tela                                                   Não Obrigat|
|             nLarg - Largura da tela                                                  Não Obrigat|
|             vVetC - Vetor com os campos da tabela                                    Não Obrigat|
|             cTipo - Indica se os campos do vVetC são para retirar ou somente eles    Não Obrigat|
|             aMatE - Matriz com os campos especiais                                   Não Obrigat|
|                     Onde: {"Campo"} -> Busca do dicionario de dados,                            |
|                           {Titulo,Descrição,Campo,Tipo,Tamanho,Decimal,Validação,when,          |
|											Valores (Combo),Obrigatório,Relação,Chave,Editável,Virtual,          |
|                            Help,Picture,Picture Var,F3,Pasta,Agrupamento,Box,                   |
|                            Tamanho opção combo,Ini do Browse,Picture Variável}                  |   
|             cFunF - Nome da função de consistência final                             Não Obrigat|
|             cInTi - Incrementação do título da janela                                Não Obrigat|
|             cFuMD - Nome da função de manipulação do ModelDef - Propried. x dicion.  Não Obrigat| 
|             cFuVD - Nome da função de manipulação do VieWDef - Propried. x dicion.   Não Obrigat| 
|=================================================================================================+
|Retorno    : aCoDad- Matriz com os nome dos campo e conteúdo                                     |
+=================================================================================================+
|Referência :                                                                                     |
+=================================================================================================+
*/
Function AGRGETLISMVC(cAlia,nAltu,nLarg,vVetC,cTipo,aMatE,cFunF,cInTi,cFuMD,cFuVD)
	Local oFWMVCW
	Local aCoDad	:= {}
	Local aCoors 	:= FWGetDialogSize(oMainWnd)
	Local nAltuI	:= If(nAltu = Nil,aCoors[3],nAltu)
	Local nLargI	:= If(nLarg = Nil,aCoors[4],nLarg)
	Local cPrefi := AGRPREFIXOCAMP(cAlia)
	//   Copiar,  Recortar,  Colar,  Calculad,   Spool,  Imprimir, Confirmar,Cancelar, 
	Local aButt	:= {{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.T.,nil},{.T.,nil},;
	{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil}}
	//WalkTrhough,Ambiente ,Mashup   ,Help     ,Form HTML,ECM{}
	Private _cTipL   := If(cTipo = Nil,"D",cTipo)
	Private _cAliasP := cAlia
	Private _vVetCam := If(vVetC <> Nil,Aclone(vVetC),{})
	Private _cFunPos := cFunF 
	Private _cFuMDef := cFuMD 
	Private _cFuVDef := cFuVD 
	Private _aMatCEs := If(aMatE <> Nil,Aclone(aMatE),{})
	// Usadas nas funções (cFuMD,cFuVD) de atribuição de propriedades
	Private _oStruPM 
	Private _oStruPV

	INCLUI := .T.

	bCondIni := "{||oview:GETMODEL('AGRUTIL01_M'):GETSTRUCT():SETPROPERTY('"+cPrefi+"'+'_FILIAL',"+;
	STRZERO(MODEL_FIELD_INIT,2)+",{|| '"+XFILIAL(cAlia)+"'})}"
	oView    := FwLoadView("AGRUTIL01")
	oView:SetOperation(MODEL_OPERATION_INSERT)
	oView:SetViewCanActive({|| AGRACTIVA(bCondIni)})
	oView:SetCloseOnOk({|oView|aRet := AGRCONFIR(oView),.T.})

	oFWMVCW := FWMVCWindow():New()
	oFWMVCW:SetUseControlBar(.T.)
	oFWMVCW:SetView(oView)
	oFWMVCW:SetCentered(.T.)
	oFWMVCW:SetPos(aCoors[1],aCoors[2])
	If cInTi <> Nil
		oFWMVCW:SetTitle(cInTi)
	EndIf	 
	oFWMVCW:SetSize(nAltuI,nLargI)
	oFWMVCW:Activate(,,aButt)                

	If !oView:GetbuttonWasPressed() == VIEW_BUTTON_OK
		aCoDad := {}
	EndIf

	oView:DeActivate()
	FreeObj(oView)
	oFWMVCW:DeActivate()
	FreeObj(oFWMVCW)
Return aCoDad

/*
+=================================================================================================+
| Função    : AGRACTIVA                                                                           |
| Descrição : Ativação model                                                                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/03/2016                                                                          |
+=================================================================================================+
|Referência : AGRGETLISMVC                                                                        |
+=================================================================================================+
*/
Static Function AGRACTIVA(bIniCond)
	Local cTitulo	 := ''
	eval(&(bInicond))
	oView:EnableTitleView("AGRUTIL01_V",cTitulo)
Return .t.

/*
+=================================================================================================+
| Função    : AGRCONFIR                                                                           |
| Descrição : Confirmação do model                                                                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/03/2016                                                                          |
+=================================================================================================+
|Referência : AGRGETLISMVC                                                                        |
+=================================================================================================+
*/
Static function AGRCONFIR(Oview)
	Local oModel		 	:= oView:GetModel()
	Local oModelPAD	 	:= oModel:GetModel("AGRUTIL01_M")
	Local aViewPADCp	:= oview:GetViewStruct('AGRUTIL01_V'):Getfields() 
	Local aCoDadL 		:= {}		  
	Local nx				

	// Nome do campo, e o Seu Conteúdo 
	For nx 	:= 1 to Len(aViewPADCp)
		aAdd(aCoDadL,{aViewPADCp[nx,MVC_VIEW_IDFIELD],oModelPAD:GetValue(aViewPADCp[nx,MVC_VIEW_IDFIELD])})
	Next nx
Return aCoDadL

// TRATAMENTO COM CALENDÁRIO
/*
+=================================================================================================+
| Função    : AGRHCALENDA                                                                         |
| Descrição : Transforma os dados binários referente calendário (SH7) para o formato hora (hh:mm) |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 11/09/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cCalenda - Código do Calendário                                          Obrigatório|
|             cFil     - Código da Filial                                              Não Obrigat|
+=================================================================================================+
| Retorna:   aMatret - Matriz com os horários do calendário  onde:  [1,1] Qtd Horas disponíveis,  |
|                        [DIA,2,{}] - Horários por dia da semana                                  |
+=================================================================================================+
|Referências : Função ARGPRIMDHCALE                                                               |
+=================================================================================================+ 
*/
Function AGRHCALENDA(cCalenda,cFil)
	Local aAreaAt  := GetArea()
	Local aDISPBIN := {}, aMATRET := {},aAHDISP := {}
	Local nTAMAN,X,Y,nTOTHORA,nPOS1C,nPOS2C
	Local cALOC,cHORAFCA,cHORAICA
	Local cFilSH7 := If(cFil <> Nil,xFilial("SH7"),cFIL)
	If !AGRIFDBSEEK("SH7",cCalenda,1,.f.,cFilSH7)
		RestArea(aAreaAt)
		Return(aDISPBIN)
	Endif

	cALOC  := SH7->H7_ALOC
	nTAMAN := Len(cALOC) / 7
	Aadd(aDISPBIN, "")
	While Len(cALOC) > 0
		Aadd(aDISPBIN, SubStr(cALOC,1,nTAMAN) + " ")
		cALOC := SubStr(cALOC,nTAMAN + 1)
	End

	aDISPBIN[1] := aDISPBIN[8]
	aDel(aDISPBIN,8)
	aSize(aDISPBIN,7)

	For X := 1 to Len(aDISPBIN)
		Store 0 To nPOS1C,nPOS2C,nTOTHORA
		aAHDISP := {}
		For Y := 1 to Len(aDISPBIN[X])
			If substr(aDISPBIN[X],Y,1) == "x" .and. nPOS1C = 0
				nPOS1C := Y
			ElseIf substr(aDISPBIN[X],Y,1) == " " .And. nPOS1C # 0
				nPOS2C   := Y
				cHORAICA := Substr(Bit2Tempo(nPOS1C-1),3)
				cHORAFCA := SubStr(Bit2Tempo(nPOS2C-1),3)
				nTOTHORA := nTOTHORA + AGRHTOM(cHORAFCA)-AGRHTOM(cHORAICA)
				nPOS1C   := 0
				Aadd(aAHDISP,{cHORAICA,cHORAFCA})
			Endif
		Next
		Aadd(aMATRET,{AGRMTOH(nTOTHORA),aAHDISP})
	Next
	RestArea(aAreaAt)
Return(aMATRET)

/*
+=================================================================================================+
| Função    : ARGPRIMDHCALE                                                                       |
| Descrição : Procura a primeira data e hora disponível para o calendário apartir de uma data     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 11/09/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: dtini    - Data início                                                   Obrigatório|
|             cCalenda - Calendário                                                    Obrigatório|
+=================================================================================================+
| Retorna:   vVetR - Vetor onde [1] dia  [2] hora                                                 |
+=================================================================================================+
|Referências : UBAC005                                                                            |
+=================================================================================================+ 
*/
Function ARGPRIMDHCALE(dtini,cCalenda)
	Local dDinV := dtini,aCalenC := AGRHCALENDA(cCalenda)
	Local vVetR := {Ctod("  /   /   "),Space(5)}
	If !Empty(aCalenC)
		While .t.
			If aCalenC[Dow(dDinV),1] <> "00:00"
				vVetR := {dDinV,aCalenC[Dow(dDinV),2,1,1]}
				Exit
			EndIf
			dDinV ++
		End
	EndIf
Return vVetR

/*
+=================================================================================================+
| Função    : ARGPRIMDHCALE                                                                       |
| Descrição : Procura a última data e hora disponível para o calendario apartir de uma data      	 |
| Autor     : MAICOL LANGE                                                               		      |
| Data      : 16/09/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: dtini    - Data início                                                   Obrigatório|
|             cCalenda - Calendário                                                    Obrigatório|
+=================================================================================================+
| Retorna:   vVetR - Vetor onde [1] dia  [2] hora                                                 |
+=================================================================================================+
|Referências : AGRA615                                                                            |
+=================================================================================================+ 
*/
Function ARGULTMDHCALE(dtini,cCalenda)
	Local dDinV := dtini,aCalenC := AGRHCALENDA(cCalenda)
	Local vVetR := {Ctod("  /   /   "),Space(5)}
	Local nX,nY
	Local bFound := .F. 
	If !Empty(aCalenC)
		For nX := 1 To Len(aCalenC[Dow(dDinV),2])
			//percore periodo
			For nY := 1 To Len(aCalenC[Dow(dDinV),2,nX])
				if (aCalenC[Dow(dDinV),2,nX,nY]= "00:00")			 			
					vVetR := {dDinV,AGRMTOH(AGRHTOM(aCalenC[Dow(dDinV),2,nX,nY+1])+60)}
					bFound = .t.
					Exit				
				endif   					
			Next
			if  bFound 
				Exit
			endif	
		end
	EndIf
Return vVetR

// TRATAMENTO COM HORAS
/*
+=================================================================================================+
| Função    : AGRTOHONOR                                                                          |
| Descrição : Calcula horas percorridas entra duas datas/Horas (horas normais)                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 10/02/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: dDataIn - Data inicial                                                   Obrigatório|
|             hHorIni - Hora inicial                                                   Obrigatório|
|             dDataFi - Data final                                                     Obrigatório|
|             hHorFim - Hora final                                                     Obrigatório|
|             cTipoRe - Tipo de hora do retorno (C,N)                                  Nâo Obrigat|
+=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRTOHONOR(dDataIn,hHorIni,dDataFi,hHorFim,cTipoRe)
	Local nSoma := 0,nHoreto := 0,cTpRet := If(cTipoRe = Nil,"C",cTipoRe)
	Local nIni  := (AGRHTOM(hHorIni)/60)
	Local nFim  := (AGRHTOM(hHorFim)/60)

	If dDataFi > dDataIn
		nSoma:= ((dDataFi - dDataIn)*24)
	EndIf

	nHoraFi := (nFim+nSoma) - nIni
	cHoraca := Alltrim(Str(nHoraFi))
	nPosvis := At('.',cHoraca)
	If nPosvis > 0
		cHoraIni := Substr(cHoraca,1,nPosvis-1)
		cMinuIni := Alltrim(Substr(cHoraca,nPosvis+1,3))
		If Len(Alltrim(cMinuIni)) > 2
			cPriminu := Substr(cMinuIni,1,1)
			cSegminu := Substr(cMinuIni,2,1)
			cTerminu := Substr(cMinuIni,3,1)
			cSomminu := If(cSegminu = cTerminu,Str(Val(cSegminu)+1),cSegminu)
			nHoracer := Val(cHoraIni+'.'+cPriminu+Alltrim(cSomminu))
		Else
			nHoracer := nHoraFi
		Endif
		nHoreto := nHoracer
	Else
		nHoreto := nHoraFi
	Endif
Return If(cTpRet = "N",nHoreto,AGRNTOH(nHoreto))

/*
+=================================================================================================+
| Função    : AGRNTOH                                                                             |
| Descrição : Converte horas númerica e horas caracter                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 10/02/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: nHoras - Horas em numérico para converter                                Obrigatório|
+=================================================================================================+
|Referências : AGRTOHONOR                                                                         |
+=================================================================================================+ 
*/
Function AGRNTOH(nHoras)
	If nHoras = 0
		Return '00:00'
	EndIf
Return AGRMTOH(nHoras*60)

/*
+=================================================================================================+
| Função    : AGRHTON                                                                             |
| Descrição : Converte horas caracter em númerica                                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 10/02/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cHoras - Horas em caracter para converter                                Obrigatório|
+=================================================================================================+
|Referências : AGRTOHONOR                                                                         |
+=================================================================================================+ 
*/
Function AGRHTON(cHoras)
Return Round(AGRHTOM(cHoras)/60,2)

/*
+=================================================================================================+
| Função    : AGRHTOM                                                                             |
| Descrição : Converte horas em minutos                                                           |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 11/09/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cHora - Hora                                                             Obrigatório|
+=================================================================================================+
| Retorna:   Hora em minutos                                                                      |
+=================================================================================================+
|Referências : Função AGRHCALENDA                                                                 |
+=================================================================================================+ 
*/
Function AGRHTOM(cHora)
	Local nHora,nMinuto,Pos
	Pos := At(":",cHora)
	If Pos == 0
		Return 0
	Endif
	nHora   := Val(SubStr(cHora,1,(Pos-1)))
	nMinuto := Val(SubStr(cHora,(Pos+1)))
Return (nHora*60)+nMinuto

/*
+=================================================================================================+
| Função    : AGRMTOH                                                                             |
| Descrição : Converte minutos em horas                                                           |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 11/09/2014                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: nMinuto - Minutos                                                        Obrigatório|
+=================================================================================================+
| Retorna:   Minutos em horas                                                                     |
+=================================================================================================+
|Referências : Função AGRHCALENDA                                                                 |
+=================================================================================================+ 
*/
Function AGRMTOH(nMinuto)
	Local nHoras,nRest,cRet,cHoraC := Alltrim(Str(nMinuto))
	Local nPonVi := At(".",cHoraC)
	Local lNegativo := .f.,nx

	If nPonVi = 0
		nPonVi := At(",",cHoraC)
	Endif

	nHoras := Int(nMinuto / 60)
	nRest  := Int(nMinuto % 60)

	If nPonVi = 0
		nPonVi := At(",",cHoraC)
	Endif
	If nPonVi > 0
		nMinuM := Val(SubStr(cHoraC,nPonVi+1,1))
		If nMinuM > 5
			nRest += 1
		Endif
	Endif

	If nMinuto < 0
		lNegativo := .t.
		nHoras := nHoras * -1
	Endif
	If nRest < 0
		nRest := nRest * -1
	Endif

	nZerosH := 2
	For nx := 2 To 16
		cValHo := Replicate("9",nx)
		If nHoras > Val(cValHo)
			nZerosH := nx+1
		EndIf
	Next nx

	cRet := StrZero(nHoras,nZerosH) + ":" + StrZero(nRest,2)

	If lNegativo .AND. At('-',cRET) == 0
		cRET := '-'+cRET
	Endif
Return cRET

// TRATAMENTO CONSULTA PADRÃO MVC  
/*
+=================================================================================================+
| Programa  : AGRCONPAD                                                                           |
| Descrição : Cria uma consulta padrão com arquivo temporário                                     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/09/2014                                                                          |
+=================================================================================================+     
| Paramêtros: cTitulo   - Título da consulta                                           Obrigatório|
|             cAliaTRB  - Alias do arquvivo temporário                                 Obrigatório|
|             cNomeTRB  - Nome do arquvivo temporário                                  Obrigatório|
|             aArrDados - Array com os dados para montar a consulta                    Obrigatório|
|             vVetInds  - Vetor dos índices                                            Obrigatório|
|             lsetT     - Indica se é temporaria                                       Não obrigat|
|             lsetDBF   - Indica se set os índices                                     Não obrigat|
|             lsetUse   - Indica se set os filtros                                     Não obrigat|
|             lDetails  - Indica se ativa detalhes                                     Não obrigat|                                 
|             cNomFunDC - Nome da função duplo click no item                           Não obrigat|
|             aOpcoes   - Matriz com as opções especiais                               Não obrigat|
|             aMatCaTot - Matriz com os campos referente aos totalizadores             Não obrigat|
|             vVetdados - Matriz com os totalizadores                                  Não obrigat|
|             cNomFunRT - Nome da função para recalculo dos totalizadores após filtro  Não obrigat|
|             cNomFuF12 - Nome da função chamada ao teclar F12                         Não obrigat|
|             vVetVisu  - Vetor com os dados para montar a visualização                Não obrigat|
|             aSemafar  - Matriz com os dados para montar a legenda                    Não obrigat|
|             aGrafico  - Matriz com os dados para montar o gráfico                    Não obrigat|
+=================================================================================================+
*/
Function AGRCONPAD(cTitulo,cAliaTRB,cNomeTRB,aArrDados,vVetInds,lsetT,lsetDBF,lsetUse,lDetails,;
	cNomFunDC,aOpcoes,aMatCaTot,vVetdados,cNomFunRT,cNomFuF12,vVetVisu,aSemafar,aGrafico)
	Local nx
	Local aCoorsX  := FWGetDialogSize( oMainWnd )
	Local aMatr    := {}
	Local vVetVi   := If(vVetVisu <> Nil,Aclone(vVetVisu),{})
	Local nH	

	Default lsetT		:= .T.
	Default lsetDBF		:= .T.
	Default lsetUse		:= .T. 	
	Default lDetails	:= .F. 	

	Private cAliVTRB  := cAliaTRB
	Private cNomVTRB  := cNomeTRB
	Private cTitul    := cTitulo
	Private aGrafic   := Aclone(aGrafico)

	cAliaVx := cAliaTRB
	cChaveA := Nil
	nIndice := Nil
	lSetaVi := .f.

	If ! Empty( cNomFuF12 )	
		Set Key VK_F12 To  
		SetKey(VK_F12,{|| AGRCONDF12(cNomFuF12)}) 
	EndIf 

	Private cTitu     := cTitulo
	Private oBrowsX   := Nil
	Private oColumn   := Nil
	Private oDlgX     := Nil 
	Private aTotdores := {}
	Private lTotalm   := .t.
	Private aSeek     := {}
	Private vVetPar   := If(vVetdados <> Nil,Aclone(vVetdados),{}) 
	Private aMatCam   := If(aMatCaTot <> Nil,Aclone(aMatCaTot),{})
	Private aMatCamB  := Aclone(aArrDados)
	Private cAliaT    := cAliaTRB
	Private cFuncRec  := If(cNomFunRT <> Nil,cNomFunRT,"")

	If !Empty(vVetVi)
		cAliaVx  := If(vVetVi[1] = Nil,cAliaTRB,vVetVi[1])
		cChaveA  := If(vVetVi[2] = Nil,'',vVetVi[2])
		nIndice  := If(vVetVi[3] = Nil,'',vVetVi[3])
		lSetaVi  := If(vVetVi[4] = Nil,.f.,vVetVi[4])
	EndIf

	aSeek := AGRINDICONS(vVetInds,aArrDados)
	aMatr := AGRITEMCBRW(aArrDados)

	oSize := FWDefSize():New(.T.)
	oSize:AddObject('DLGX',100,100,.T.,.T.)    
	oSize:SetWindowSize(aCoorsX)
	oSize:aMargins := {3,3,3,3} 
	oSize:lProp    := .T.      
	oSize:Process()
	nMCo := oSize:aPosObj[1,4] - 100
	nLin := 5 
	nCol := oSize:aPosObj[1,2]

	DEFINE MSDIALOG oDlgX FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL
	If !Empty(vVetPar)
		// Instancia o layer
		oFWL1 := FWLayer():New()

		// Inicia o Layer
		oFWL1:init( oDlgX,.F.)

		If Len( vVetPar[1] ) > 1
			// Cria uma linha unica para o Layer
			nH := iIf( Len(vVetPar) > 2, ( Len(vVetPar) * 4 ) + 6, 15)
			If nH > 35
				nH := 35
			EndIf
			oFWL1:addLine( 'SUP', 100-nH , .F.)
			oFWL1:addLine( 'INF', nH , .F.)
		Else
			// Cria uma linha unica para o Layer
			oFWL1:addLine( 'SUP', 85 , .F.)
			oFWL1:addLine( 'INF', 15 , .F.)
		EndIf

		// Cria colunas 
		oFWL1:addCollumn('ESQ',100,.T.,'INF' )
		oPnlLine1 := oFWL1:getLinePanel('SUP') 
		oPnDir    := oFWL1:getColPanel('ESQ','INF')
	EndIf	

	DEFINE FWFORMBROWSE oBrowsX DATA TABLE ALIAS cAliVTRB DESCRIPTION cTitulo OF If(Empty(vVetPar),oDlgX,oPnlLine1)
	oBrowsX:SetTemporary( lsetT )
	oBrowsX:SetFieldFilter(AGRITEMCBRW(aArrDados))	
	oBrowsX:SetDBFFilter( lsetDBF )
	oBrowsX:SetUseFilter( lsetUse )
	oBrowsX:DisableDetails( lDetails )
	oBrowsX:SetSeek(,aSeek)

	If aSemafar <> Nil .And. !Empty(aSemafar)
		AGRMONTALE(oBrowsX,aSemafar)
	EndIf

	If cNomFunRT <> Nil
		oBrowsX:BVLDEXECFILTER := {|| AGRCONDRT()}
	EndIf

	For nx := 1 To Len(aArrDados)
		ADD COLUMN oColumn DATA &('{||'+aArrDados[nx,1]+'}') Title aArrDados[nx,5] SIZE aArrDados[nx,3] PICTURE aArrDados[nx,6] Type aArrDados[nx,6] Of oBrowsX
	Next nx 

	If cNomFunDC <> Nil
		oBrowsX:SetDoubleClick(&('{||'+ cNomFunDC+'}'))  
	EndIf 

	If aOpcoes <> Nil  
		For nx := 1 To Len(aOpcoes)
			oBrowsX:AddButton(aOpcoes[nx,1],aOpcoes[nx,2],aOpcoes[nx,3],aOpcoes[nx,4],aOpcoes[nx,5]) 
		Next nx
	EndIf

	If !Empty(vVetPar)
		oBrowsX:AddButton(STR0043,{|| AGRIMPRPAD(cTitu,cAliaT,aMatCamB,aMatCam,vVetPar)},,8,0)
	EndIf

	If vVetVisu <> Nil 
		oBrowsX:AddButton(STR0049,{||	AGRVISUALIZA(cAliaVx,cChaveA,nIndice,lSetaVi,cTitu,aMatCamB)},,8,0)
	EndIf

	oBrowsX:AddButton(STR0041,{|| oDlgX:end()},,9,0)      
	ACTIVATE FWFORMBROWSE oBrowsX

	If !Empty(vVetPar)
		AGRMOSTOTAIS(aMatCam,vVetPar,,@oBrowsX)
		If lsetUse .and. cNomFunRT <> Nil
			AGRCONDRT() //para atualizar os totais conforme filtro
		EndIf
	EndIf
	
	ACTIVATE MSDIALOG oDlgX CENTER
	Set Key VK_F12 To 
Return

/*
+=================================================================================================+
| Função    : AGRINDICONS                                                                         |
| Descrição : Monta uma matriz com os nome dos campos do indices                                  |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 11/03/2014                                                                          |
+=================================================================================================+     
| Paramêtros: aIndices - Matriz com os indices                                         Obrigatório|
|             aAdad    - Matriz com a estrutura do arquivo temporário                  Obrigatório|
+=================================================================================================+  
|Referências : Função AGRCONPAD                                                                   |
+=================================================================================================+ 
*/  
Function AGRINDICONS(aIndices,aAdad)
	Local aSeekC := {},ny,nx
	For nx := 1 To Len(aIndices)
		cIndice := aIndices[nx]
		cIndice := StrTran(cIndice," ","")
		//  cIndice := StrTran(cIndice,"+Str(",")  
		cIndice := StrTran(cIndice,"Dtos(","") 
		cIndice := StrTran(cIndice,"Descend(","") 
		cIndice := StrTran(cIndice,")","")
		cDescIn := Space(1)
		vVetInT := {}
		While !Empty(cIndice) 
			nPos := At("+",cIndice)
			If nPos > 0
				cCam := Alltrim(SubStr(cIndice,1,nPos-1))
			Else
				cCam := Alltrim(SubStr(cIndice,1,Len(cIndice)))
			EndIf  
			Aadd(vVetInT,cCam)
			cIndice := StrTran(cIndice,If(nPos > 0,cCam+"+",cCam),"")
		End
		cTamInd := 0
		aVetInd := {}
		For ny := 1 To Len(vVetInT)
			nPos1 := Ascan(aAdad,{|x| Alltrim(x[1]) == Alltrim(vVetInT[ny])})
			If nPos1 > 0
				cDescIn += Alltrim(aAdad[nPos1,5])+If(ny < len(vVetInT)," + ","")
				cTamInd += aAdad[nPos1,3]
			EndIf
			Aadd(aVetInd,{"",aAdad[nPos1,2],aAdad[nPos1,3],aAdad[nPos1,4],aAdad[nPos1,5],aAdad[nPos1,6]})
		Next ny
		Aadd(aSeekc,{cDescIn,aVetInd})
	Next nx
Return aSeekc

/*
+=================================================================================================+
| Função    : AGRITEMCBRW                                                                         |
| Descrição : Prepara a matriz para mostrar os item no browse                                     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 09/10/2014                                                                          |
+=================================================================================================+     
| Paramêtros: aArqTem - Matriz com a estrutura dos campos do arquivo temporário        Obrigatório|
+=================================================================================================+  
|Referências : Função AGRCONPAD                                                                   |
+=================================================================================================+ 
*/  
Function AGRITEMCBRW(aArqTem)
	Local aMatBw := {},nx
	For nx := 1 To Len(aArqTem)
		Aadd(aMatBw,{aArqTem[nx,1],aArqTem[nx,5],aArqTem[nx,2],aArqTem[nx,3],aArqTem[nx,4],Alltrim(aArqTem[nx,6])})
	Next nx     
Return aMatBw

/*
+=================================================================================================+
| Função    : AGRMONTALE                                                                          |
| Descrição : Prepara para as condições da legenda                                                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 09/10/2014                                                                          |
+=================================================================================================+     
| Paramêtros: oBjto   - Objeto em uso                                                  Obrigatório|
|             aMatDad - Matriz com as informações para montar o semaforo               Obrigatório| 
|                       Onde: {Condição,descrição,cor}.. Ex: {'B1_tipo = "1"',"Ativo","VE"}       |
+=================================================================================================+  
|Referências : Função AGRCONPAD                                                                   |
+=================================================================================================+ 
*/   
Function AGRMONTALE(oBjto,aMatDad)
	Local aCores := {{"GREEN","BR_VERDE","VE"},{"RED","BR_VERMELHO","VO"},{"BLUE","BR_AZUL","AL"},{"YELLOW","BR_AMARELO","AO"},;
	{"BLACK","BR_PRETO","PO"},{"ORANGE","BR_LARANJA","LA"},{"BROWN","BR_MARROM","MM"},{"PINK","BR_PINK","RA"},;
	{"GRAY",,"VC"},{"LBLUE",'LIGHTBLU',"AC"},{"BRWN",'BRANCO',"MC"},{"WHITE","BR_BRANCO","BO"},;
	{"BR_CANCEL","BR_CANCEL","XX"}} //	"BR_CINZA"
	Local nx,ny,vVetCorU := {}

	For nx := 1 To Len(aMatDad)
		cCor := aCores[len(aCores),1]
		If Len(aMatDad[nx]) = 3
			cCor := Alltrim(aMatDad[nx,3])
			nPos := aScan(aCores,{|x| AllTrim(x[3]) = cCor})
			cCor := If(nPos > 0,aCores[nPos,2],cCor)
			Aadd(vVetCorU,cCor)
		Else
			For ny := 1 To Len(aCores)
				nPos := aScan(vVetCorU,{|x| AllTrim(x) == aCores[ny,1]})
				If nPos = 0
					cCor := aCores[ny,1]
					Aadd(vVetCorU,cCor)
					Exit
				EndIf
			Next ny
		EndIf
		cConteu := aMatDad[nx,1]
		ADD LEGEND DATA aMatDad[nx,1] COLOR cCor  TITLE aMatDad[nx,2] Of oBjto
	Next nx    
Return

/*
+=================================================================================================+
| Função    : AGRLENGESP                                                                          |
| Descrição : Prepara para as condições da legenda especial                                       |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 12/02/2016                                                                          |
+=================================================================================================+     
| Paramêtros: cCampo  - Campo de referência a condição                                 Obrigatório| 
|             aMatDad - Matriz com as informações para montar o semaforo               Obrigatório| 
|                       Onde: {Condição,cor}.. Ex: {"1"',"BR_CINZA"}                              |
+=================================================================================================+  
|Referências : OGA250                                                                             |
+=================================================================================================+ 
*/ 
Function AGRLENGESP(cCampo,aMatC)
	Local nx,vVetCor := {"BR_CINZA","BR_VERDE","BR_VERMELHO","BR_AZUL","BR_AMARELO","BR_PRETO","BR_LARANJA","BR_MARROM",;
	"BR_PINK","BR_BRANCO","BR_CANCEL","LIGHTBLU",'BRANCO',"BR_CANCEL"}
	Local oLegenda  :=  FWLegend():New() 

	For nx := 1 To Len(aMatC)
		oLegenda:Add("",If(aMatC[nx,2] = Nil,vVetCor[nx],aMatC[nx,2]),X3CboxDesc(cCampo,aMatC[nx,1]))
	Next nx
	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
Return

/*
+=================================================================================================+
| Função    : AGRLEGBWESP                                                                         |
| Descrição : Prepara a legenda especial no browse                                                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 12/02/2016                                                                          |
+=================================================================================================+     
| Paramêtros: cCampo  - Campo de referência a condição                                 Obrigatório| 
|             aMatDad - Matriz com as informações para montar o semaforo               Obrigatório| 
|                       Onde: {Condição,cor}.. Ex: {"1"',"BR_CINZA"}                              |
+=================================================================================================+  
|Referências : OGA250                                                                             |
+=================================================================================================+ 
*/ 
Function AGRLEGBWESP(cCampo,aMatc)
	Local nx,vVetCor := {"BR_CINZA","BR_VERDE","BR_VERMELHO","BR_AZUL","BR_AMARELO","BR_PRETO","BR_LARANJA","BR_MARROM",;
	"BR_PINK","BR_BRANCO","BR_CANCEL","LIGHTBLU",'BRANCO',"BR_CANCEL"}
	For nx := 1 To Len(aMatc)
		If cCampo = aMatc[nx,1]
			Return If(aMatc[nx,2] <> Nil,aMatc[nx,2],vVetCor[nx])
		EndIf
	Next nx
Return

/*
+=================================================================================================+
| Função    : AGRCONDF12                                                                          |
| Descrição : Prepara para recriar o novo filtro via F12                                          |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/09/2014                                                                          |
+=================================================================================================+
|Referências : AGRIMPRPAD                                                                         |
+=================================================================================================+ 
*/     
Function AGRCONDF12(cNomFuF12)
	oBrowsX:SetUseFilter(.f.)
	&(cNomFuF12)
	If Type("oBrowsX") <> "U"	
		oBrowsX:Refresh(.T.)	
	EndIf 
Return .t.   

/* 
+=================================================================================================+
| Função    : AGRCONDRT                                                                           |
| Descrição : Filtragem do arquivo temporário                                                     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/09/2014                                                                          |
+=================================================================================================+ 
|Referências : AGRIMPRPAD                                                                         |
+=================================================================================================+                                                                           |  
*/
Function AGRCONDRT()
	oBrowsX:ExecuteFilter(.t.)
	oBrowsX:SetUseFilter(.T.)
	&( cFuncRec )
	ARGSETIFARQUI(alias())	
Return

/*
+=================================================================================================+
| Função    : AGRIMPRPAD                                                                          |
| Descrição : Impressão de uma consulta padrão                                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/09/2014                                                                          |
+=================================================================================================+
| Parâmetros: cTitulo - Título da consulta                                             Obrigatório|                                                                           |  
|             cAliaT  - Alias do arquivo temporário                                    Obrigatório|
|             aMatCam - Matriz com os campos da consulta (Estrutura)                   Obrigatório|
|             aMatCTo - Matriz com os campos totalizadores                             Não Obrigat|
|             vVetDTo - Vetor com os valores dos totalizadores                         Não Obrigat|
+=================================================================================================+
|Referências : AGRAC003                                                                           |
+=================================================================================================+ 
*/
Function AGRIMPRPAD(cTitu,cAliaT,aMatCam,aMatCTo,vVetDTo)
	Private oReport
	Private cAliasP := cAliaT
	Private aMatCaP := Aclone(aMatCam)
	Private aMatCIT := If(ValType("aMatCTo") <> "U",Aclone(aMatCTo),{})
	Private vVetDIT := If(ValType("vVetDTo") <> "U",Aclone(vVetDTo),{})
	Private cTitulo := cTitu

	If FindFunction("TRepInUse") .And. TRepInUse()
		oReport:= ReportDef()
		oReport:PrintDialog()	
	EndIf
Return

/*
+=================================================================================================+
| Função    : ReportDefD                                                                          |
| Descrição : Impressão de uma consulta padrão                                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/09/2014                                                                          |
+=================================================================================================+
|Referências : AGRIMPRPAD                                                                         |
+=================================================================================================+ 
*/  
Static Function ReportDef() 
	Static oSection0  
	oReport := TReport():New("AGRIMPPAD",OemToAnsi(cTitulo),,{|oReport| ReportPrint()}," ",.T.)
	oSection0 := TRSection():New (oReport, STR0094, {cAliasP} ) 
Return oReport

/*
+=================================================================================================+
| Função    : ReportPrint                                                                         |
| Descrição : Impressão de uma consulta padrão                                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/09/2014                                                                          |
+=================================================================================================+
|Referências : ReportDef                                                                          |
+=================================================================================================+ 
*/  
Static Function ReportPrint() 
	Local vVetCol  	:= {}
	Local vVetCabC 	:= {}
	Local nx,ny,nv,nz,nMax,nTamReg := 0
	Local cCabec 	:= Space(1), nCol := 1
	Local aUsados	:= AGRUSADORESER()
	Local aTotais	:= {}
	Local aStcAliasP:= {}
	Local nPos  	:= 0
	Local cTpDado	:= ""
	Local nPosOn    := 0
	Local cTabel    := ""

	ARGSETIFARQUI(cAliasP)              
	For nx := 1 To Fcount() 
		nPos := aScan(aMatCap,{|x| AllTrim(x[1]) == Fieldname(nx)})
		If nPos > 0
			If aMatCap[nPos,2] = "N"
				nMax   := Max(aMatCap[nPos,3],Len(Alltrim(aMatCap[nPos,5])))
				nTamCa := Max(nMax,Len(Alltrim(aMatCap[nPos,6]))-3)
				nQtdPV := AGRPOVIRPICT(,aMatCap[nPos,6])
			Else
				nTamCa := Max(aMatCap[nPos,3],Len(Alltrim(aMatCap[nPos,5])))
			Endif
			cLabel  := Alltrim(aMatCap[nPos,5]) 
			nCol    := Len(cCabec) 
			cCabec += If(aMatCap[nPos,2] <> "N",cLabel+Space(nTamCa-Len(cLabel)+2),;
			Space(nTamCa-Len(cLabel))+"  "+cLabel)
			Aadd(vVetCabC,If(aMatCap[nPos,2] <> "N",nCol,nCol+If(Len(Alltrim(aMatCap[nPos,5])) > aMatCap[nPos,3],;
			Len(Alltrim(aMatCap[nPos,5])) - aMatCap[nPos,3],0)))
		EndIf
		DbselectArea(cAliasP)
	Next nx

	If Len(cCabec) > 160  
		vVetCol := {10,900,1900}
		ARGSETIFARQUI(cAliasP)

		aStcAliasP := (cAliasP)->(dbStruct())

		oSection0:Init()
		oReport:SetMeter( RecCount() ) 
		While !Eof() 
			oReport:IncMeter() 
			oReport:FatLine() 
			oReport:SkipLine()
			oReport:HideHeader()
			oReport:HideFooter()
			For nx := 1 To FCount()
				nCol := 1   
				nLinha := oReport:nRow
				For ny := nx To nx+2 
					If ny <= FCount()
						cLabel := " "       
						nPos := aScan(aMatCap,{|x| AllTrim(x[1]) == Fieldname(ny)})
						If nPos > 0 
							cLabel := Alltrim(aMatCap[nPos,5])
						EndIf   
						cNomeP := cLabel+Replicate(".",12-Len(cLabel))+": " 

						nPos := aScan(aStcAliasP, {|x| AllTrim(x[1]) == AllTrim(Fieldname(ny))})

						If nPos > 0
							cTpDado := aStcAliasP[nPos, 2]
						EndIf

						If cTpDado = "D" 
							cConteu := Dtoc(&(cAliasP+"->"+Fieldname(ny)))
						ElseIf cTpDado = "N" 
							cConteu := Alltrim(Transform(&(cAliasP+"->"+Fieldname(ny)),Trim(aMatCap[nPos,6]))) 
						Else     
							cConteu := &(cAliasP+"->"+Fieldname(ny))  
						EndIf 
						oReport:PrintText(cNomeP+cConteu,nLinha,vVetCol[nCol]) 
						nCol ++
					EndIf 
				Next ny 
				oReport:SkipLine()
				nx += 2    
				DbselectArea(cAliasP)
			Next nx  
			oReport:SkipLine()
			AGRDBSELSKIP(cAliasP)
		End 
		oSection0:Finish() 
	Else 
		ARGSETIFARQUI(cAliasP)

		oSection0:Init() 
		oReport:SetMeter(RecCount())

		oReport:SkipLine()
		nLinha := oReport:nRow 
		oReport:PrintText(cCabec,nLinha,10) 
		oReport:SkipLine()
		oReport:FatLine()

		While !Eof() 
			oReport:IncMeter() 
			oReport:SkipLine()
			nLinha := oReport:nRow
			nCol := 1
			For nx := 1 To Fcount() 
				nPos := aScan(aMatCap,{|x| AllTrim(x[1]) == Fieldname(nx)})
				If nPos > 0
					If ValType(cAliasP+"->"+Fieldname(nx)) = "D" 
						cConteu := Dtoc(&(cAliasP+"->"+Fieldname(nx)))
					ElseIf ValType(cAliasP+"->"+Fieldname(nx)) = "N" 
						cConteu := Transform(&(cAliasP+"->"+Fieldname(nx)),aMatCap[nPos,6]) //Trim(aMatCap[nPos,6])) 
					Else     
						cConteu := &(cAliasP+"->"+Fieldname(nx))  
					EndIf 
					oReport:PrintText(cConteu,nLinha,vVetCabC[nPos]*15)
					nCol ++ 
				EndIf 
			Next ny 
			AGRDBSELSKIP(cAliasP)
		End 
	EndIf 

	//--Seção imprime totais
	//--Se array não estiver vazio - imprime
	If !Empty(aMatCIT)
		For nv := 1 To Len(aMatCit)
			If !Empty(TamSx3(aMatCit[nv,1]))

				nPosOn := At("_",aMatCit[nv,1])
				cTabel := SubStr(aMatCit[nv,1],1,nPosOn-1)
				cTabel := If(Len(cTabel) = 2,"S"+cTabel,cTabel)

				AAdd(aTotais,{If(Len(aMatCit[nv]) > 2,aMatCit[nv,5],Trim(RetTitle(aMatCit[nv,1]))),;
				aMatCit[nv,1],;
				If(Len(aMatCit[nv]) > 1,aMatCit[nv,6],X3PICTURE(aMatCit[nv,1])),;
				If(Len(aMatCit[nv]) > 1,aMatCit[nv,3],TamSx3(aMatCit[nv,1])[1]),;
				If(Len(aMatCit[nv]) > 1,aMatCit[nv,4],TamSx3(aMatCit[nv,1])[2]),;
				X3VALID(aMatCit[nv,1]),;
				X3USADO(aMatCit[nv,1]),;
				If(Len(aMatCit[nv]) > 1,aMatCit[nv,2],TamSx3(aMatCit[nv,1])[3]),;
				cTabel,;
				AGRRETCTXT(cTabel, aMatCit[nv,1]),;
				X3F3(aMatCit[nv,1]),;
				AGRRETWHEN(aMatCit[nv,1])})

			Else
				AAdd(aTotais,{aMatCit[nv,5],aMatCit[nv,1],aMatCit[nv,6],aMatCit[nv,3],aMatCit[nv,4],"",aUsados[4,1],aMatCit[nv,2]," "," "," ",.f.})   
			EndIf
		Next nv

		If Len(cCabec) > 160 
			oReport:SkipLine()
			nLinha  := oReport:nRow 
			oReport:PrintText(STR0042,nLinha,10)
			oReport:FatLine()
			oReport:SkipLine()
			nLinha  := oReport:nRow 
			nTamReg := 1
			nCol    := 1

			For nz := 1 To Len(vVetDIT)	
				For nx := 1 To Len(aTotais)
					nPos  := aScan(aTotais,{|x| AllTrim(x[1]) == aTotais[nx,1]})
					cPict := Alltrim(aTotais[nx,3])
					If nPos > 0
						cLabel := Alltrim(aTotais[nPos,1])
						cPict := Alltrim(aTotais[nPos,3])
					EndIf

					cValor := Alltrim(Transform(vVetDIT[nz,nx],Trim(cPict))) 
					nTamReg += Len(Alltrim(cLabel))+Len(cValor)+15
					cConteu := Alltrim(cLabel)+"..: "+cValor

					If nx == Len(aTotais) 
						cLabel 	:= aTotais[nx,1]
						cPict  	:= aTotais[nx,3]
						cConteu := Alltrim(cLabel)+cValor
					EndIf

					If nTamReg > 300
						oReport:SkipLine()
						oReport:SkipLine()
						nTamReg := 1
						nCol    := 1
						nLinha  := oReport:nRow 
					EndIf
					oReport:PrintText(cConteu,nLinha,nCol * 12)
					nCol := nTamReg 
				Next nx
				oReport:SkipLine()
				oReport:SkipLine()				
				nTamReg := 1
				nCol    := 1
				nLinha  := oReport:nRow 
			Next nz
		Else
			oReport:SkipLine()
			nLinha  := oReport:nRow 
			oReport:FatLine()
			oReport:SkipLine()

			For nx := 1 To Len(aTotais)
				nPos  := aScan(aTotais,{|x| AllTrim(x[1]) == aTotais[nx,1]})
				If nPos > 0
					nCol := vVetCabC[nPos]
					If Len(aTotais[nx]) > 1
						// pelo nome e a picture do totalizador
						cPict := Alltrim(aTotais[nx,2])

						nMaxF := Max(Len(aTotais[nPos,5]),Len(Alltrim(aTotais[nPos,6])))

						nCol -= 4 
						If Len(cPict) < nMaxF
							nCol += nMaxF - Len(cPict)+4
						Else
							nCol -= Len(cPict) - nMaxF   
						EndIf   
						nCol := Int(nCol)

					EndIf
					cConteu := Transform(vVetDIT[nx],If(Len(aTotais[nx]) > 1,Trim(aTotais[nx,2]),Trim(aTotais[nPos,6]))) 
					oReport:PrintText(cConteu,nLinha,nCol*15)		
				EndIf 
			Next nx
		EndIf   
	EndIf
	oSection0:Finish() 
Return .T.

/*
+=================================================================================================+
| Programa  : AGRFUNRT                                                                            |
| Descrição : Recalculo do filtro da consulta padrão                                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/09/2014                                                                          |
+=================================================================================================+     
|Referências : Função AGRCONPAD                                                                   |
+=================================================================================================+
*/
Function AGRFUNRT()
	oBrowsX:ExecuteFilter(.t.)
	oBrowsX:SetUseFilter(.T.)
	vVetPar := {}
	AGRCRIAMATOT(@aMatCam,@vVetPar)
	ARGSETIFARQUI(cAliaTRB)
	While !Eof()
		AGRMOTMTO(cAliaTRB,@aMatCam,@vVetPar)
		AGRDBSELSKIP(cAliaTRB)
	End
	AGRMOSTOTAIS(@aMatCam,@vVetPar)
	ARGSETIFARQUI(cAliaTRB)	
Return

/*
+=================================================================================================+
| Programa  : AGRCRIAMATOT                                                                        |
| Descrição : Zera os valores dos totalizadores                                                   |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/09/2014                                                                          |
+=================================================================================================+     
| Paramêtros: aMatCam - Matriz com os campos dos totalizadores (Estrutura)             Obrigatório|
|             vVetDad - Vetor que armazena os valores dos totalizadores                Obrigatório|
+=================================================================================================+
|Referências : Função AGRCONPAD,AGRAC003                                                          |
+=================================================================================================+
*/
Function AGRCRIAMATOT(aMatCam,vVetDad)
	Local nx 
	If !Empty(aMatCam)
		For nx := 1 To Len(aMatCam)
			Aadd(@vVetDad,0)
		Next nx
	EndIf
Return

/*
+=================================================================================================+
| Programa  : AGRMOTMTO                                                                           |
| Descrição : Carrega a matriz com os valores dos totalizadores                                   |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/09/2014                                                                          |
+=================================================================================================+     
| Paramêtros: cAliaT   - Alias do arquivo temporário                                   Obrigatório|
|             aMatCam  - Matriz com os campos dos totalizadores  (Estrutura)           Obrigatório|
|             vVetDadt - Vetor que armazena os valores dos totalizadores               Obrigatório|
+=================================================================================================+
|Referências : Função AGRCONPAD,AGRAC003                                                          |
+=================================================================================================+
*/
Function AGRMOTMTO(cAliaT,aMatCam,vVetDadt)
	Local nx 
	DbSelectArea(cAliaT)
	aEstrD := DbStruct()
	For nx := 1 To Len(aMatCam)
		nPos := Ascan(aEstrD,{|x| Alltrim(x[1]) == Alltrim(aMatCam[nx,1])})
		If nPos > 0
			cCa1 := cAliaT+"->"+aMatCam[nx,1] 
			@vVetDadt[nx] += &(cCa1)
		EndIf
	Next nx
Return

/*
+=================================================================================================+
| Programa  : AGREMULAROT                                                                         |
| Descrição : Emula o menu ( aRotina )                                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 23/11/2014                                                                          |
+=================================================================================================+     
| Observação: NÃO É NECESSÁRIO CRIAR CH                                                           |
+=================================================================================================+
|Referências : Função AGRMOSTOTAIS                                                                |
+=================================================================================================+
*/
Function AGREMULAROT() 
	Local aRotemu := {{"Pesquisar"	,"AxPesqui",0,1},;
	{"Visualizar","AxVisual",0,2},;
	{"Incluir"		,"AXINCLUI",0,3},;
	{"Alterar"		,"AXALTERA",0,4},;
	{"Excluir"		,"AXALTERA",0,5}}
Return aRotemu

/*
+=================================================================================================+
| Programa  : AGRBUTTON                                                                           |
| Descrição : Adiciona botões específicos na browse                                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 23/11/2014                                                                          |
+=================================================================================================+     
*/
Function AGRBUTTON(oBrw,aMatOp)
	Local nx
	For nx := 1 To Len(aMatOp)
		ADD BUTTON oButton TITLE aMatOp[nx,1] ACTION aMatOp[nx,2] OF oBrw
	Next nx
Return                

/*
+=================================================================================================+
| Programa  : AGRMOSTOTAIS                                                                        |
| Descrição : Exibe os totalizadores na tela                                                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 30/09/2014                                                                          |
+=================================================================================================+     
| Paramêtros: aMatCam - Matriz com os campos dos totalizadores (Estrutura)             Obrigatório|
|             vVetDad - Vetor com os valores dos totalizadores                         Obrigatório|
|             oBjeto  - Objeto em que será mostrado os totalizadores                   Não Obrigat|
|             oBFWFor - Objeto do browse superior (FWFORMBROWSE)                       Não Obrigat|
|             lTamObj - .T. indica se irá utilizar o tamanho total de oBjeto para o GetDados()    |
+=================================================================================================+
|Referências : Função AGRCONPAD                                                                   |
+=================================================================================================+
*/
Function AGRMOSTOTAIS( aMatCam, vVetDad, oBjeto, oBFWFor, lTamObj )
	Local nv,nw,lTemaCols 	:= .f.,lTemaHead := .f.
	Local aUsados			:= AGRUSADORESER()
	Local nH 				:= 35
	Local nPosOn            := 0 
	Local cTabel            := ""
	Private aSize			:= MsAdvSize(,.f.,440), aObjects := {}
	Private aRotina			:= AGREMULAROT() 

	Default lTamObj := .F.
	If lTamObj
		lTamObj := ( oBjeto <> NIL ) // Segurança para não permitir passar lTamObj = .T. e não passar o oBjeto
	EndIf

	If ValType("aCols") = "A"
		aColsV := Aclone(aCols)
		lTemaCols := .t.
	EndIf
	If ValType("aHeader") = "A"
		aHeaderV := Aclone(aHeader)
		lTemaHead := .t.
	EndIf

	Public aCols   := {} 
	Public aHeader := {}               

	Aadd(aObjects,{100,100,.t.,.t.})
	Aadd(aObjects,{100,100,.t.,.t.})
	aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.) 

	For nv := 1 To Len(aMatCam)
		If !Empty(TamSx3(aMatCam[nv,1]))

			nPosOn := At("_",aMatCam[nv,1])
			cTabel := SubStr(aMatCam[nv,1],1,nPosOn-1)
			cTabel := If(Len(cTabel) = 2,"S"+cTabel,cTabel)

			AAdd(aHeader,{If(Len(aMatCam[nv]) > 4,aMatCam[nv,5],Trim(RetTitle(aMatCam[nv,1]))),;
			aMatCam[nv,1],;
			If(Len(aMatCam[nv]) > 5,aMatCam[nv,6],X3PICTURE(aMatCam[nv,1])),;
			If(Len(aMatCam[nv]) > 2,aMatCam[nv,3],TamSx3(aMatCam[nv,1])[1]),;
			If(Len(aMatCam[nv]) > 3,aMatCam[nv,4],TamSx3(aMatCam[nv,1])[2]),;
			X3VALID(aMatCam[nv,1]),;
			X3USADO(aMatCam[nv,1]),;
			If(Len(aMatCam[nv]) > 1,aMatCam[nv,2],TamSx3(aMatCam[nv,1])[3]),;
			cTabel,;
			AGRRETCTXT(cTabel, aMatCam[nv,1]),;
			X3F3(aMatCam[nv,1]),;
			AGRRETWHEN(aMatCam[nv,1])})

		Else
			AAdd(aHeader,{aMatCam[nv,5],aMatCam[nv,1],aMatCam[nv,6],aMatCam[nv,3],aMatCam[nv,4],"",aUsados[4,1],aMatCam[nv,2]," "," "," ",.f.})   
		EndIf
	Next nv
	If !Empty(Len(aHeader)) 
		If ValType( vVetDad[1] ) == "A"
			aCols := {}
			For nv := 1 To Len( vVetDad )
				aAdd( aCols, Array( Len( aHeader )+1 ) )
				For nw := 1 To Len( vVetDad[nv] )
					aCols[nv, nw] := vVetDad[nv, nw]
				Next nw
				aCols[nv, len( aCols[nv] )] := .F.
			Next nv
			nH := 22 + ( Len(vVetDad) * 10 )
			nH := iIf( nH > 90, 90, nH )
		Else
			AGRZERAACOLS(aHeader,@aCols)
			For nv := 1 To Len(vVetDad)
				aCols[1,nv] := vVetDad[nv]
			Next nv
		EndIf
		nLFBr := If(oBFWFor = Nil,aPosObj[2,3],oBFWFor:_OOWNER:NHEIGHT) 
		nLinM := Int(nLFBr / 2)

		If lTamObj 
			aPosObj := { {0,0,0,0}, { 0, 0, Int( oBjeto:nHeight / 2 ), Int( oBjeto:nWidth / 2 ) +3 } }
			nLinM   := 0
			nH      := Int( oBjeto:nHeight / 2 )
		EndIf

		If oBjeto = Nil
			oGet := MSGetDados():New(nLinM,aPosObj[2,2],nLinM+nH,aPosObj[2,4],2,"AllwaysTrue()","AllwaysTrue()",,.T.,,3,,Len(acols))
		Else   
			oGet := MSGetDados():New(nLinM,aPosObj[2,2],nLinM+nH,aPosObj[2,4]-3,2,"AllwaysTrue()","AllwaysTrue()",,.T.,,3,,Len(acols),,,,,oBjeto) 
		EndIf
		oGet:ForceRefresh()   
	EndIf

	If lTemaCols   
		aCols := Aclone(aColsV)
	EndIf
	If lTemaHead
		aHeader := Aclone(aHeaderV)
	EndIf
Return .T.

// TRATAMENTO DE VISUALIZAÇÃO E/OU SAÍDA DE TELA
/*
+=================================================================================================+
| Função    : AGRALERTESP                                                                         |
| Descrição : Cria uma saída de alerta na tela                                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 22/12/2014                                                                          |
+=================================================================================================+                                                                           |  
|Referências : AGRA840                                                                            |
+=================================================================================================+ 
*/
Function AGRALERTESP(cTitulo,vVetor)
	Local oDlgAlEs,oScroll,nx
	DEFINE DIALOG oDlgAlEs TITLE cTitulo FROM 0,0 TO 300,650 Pixel // 250 450
	oFont         := TFont():New('Courier new',,-18,.T.)
	oScroll       := TScrollBox():New(oDlgAlEs,01,01,50,450,.T.,.T.,.T.)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT
	For nx := 1 To Len(vVetor)
		TSay():New((nX-1)*10,03,&("{||'"+vVetor[nx]+"'}"),oScroll,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE)
	Next nx
	Activate MsDialog oDlgAlEs Centered  	
Return 

/*
+=================================================================================================+
| Programa  : AGRPERPIXEL                                                                         |
| Descrição : Busca o percentual da resolução da tela em relação pixel X polegadas                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 29/09/2014                                                                          |
+=================================================================================================+     
| Retorna   : nPrcVert - Valor do percentual de pixel por polegadas                               |
|=================================================================================================+
|Referências : Função AGRMOSTOTAIS                                                                |
+=================================================================================================+
*/
Function AGRPERPIXEL()
	Local nPrcVert := 1,nx
	Local aMatReso := {{934,1},{870,.93},{774,.82},{720,.77},{678,.70},{620,.65},{510,.54}}
	For nx := 1 To Len(aMatReso)
		If aSize[6] >= aMatReso[nx,1]
			nPrcVert := aMatReso[nx,2]
			Exit
		EndIf
	Next nx
Return nPrcVert

/*
+=================================================================================================+
| Programa  : AGRVISUALIZA                                                                        |
| Descrição : Monta a visualização padrão                                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/10/2014                                                                          |
+=================================================================================================+     
| Retorna   : cAliasV - Alias da tabela                                                Não Obrigat|
|             cChaveA - Chave de acesso ( Sem filial )                                 Não Obrigat|
|             nIndice - Indice de acesso                                               Não Obrigat|
|             lSetaTa - Seta tabela antes de montar                                    Não Obrigat|
|             cTitu   - Título da tela                                                 Não Obrigat|
|             aMatC   - Matriz com os campos (Arquivo Temporário)                      Não Obrigat|
|=================================================================================================+
|Referências : Função AGRCONPAD                                                                   |
+=================================================================================================+
*/
Function AGRVISUALIZA(cAliasV,cChaveA,nIndice,lSetaTa,cTitu,aMatC)
	Local aArea  := GetArea()
	Local cAliaA := If(cAliasV = Nil,Alias(),cAliasV)
	Local nIndiA := If(nIndice = Nil,1,nIndice)
	Local lSetaA := If(lSetaTa = Nil,.f.,lSetaTa)
	Local aRotin := {},cCadast := " ",lMostra := .t.
	Local lDicio := AGRIFDICIONA("SX2",cAliaA,1,.f.)
	Local cChavA := If(cChaveA <> Nil,&(cChaveA),Nil)

	If ValType('aRotina') == "A"
		aRotin := Aclone(aRotina)
	EndIf
	Private aRotina := AGREMULAROT() 

	If Type('cCadastro') = "C"
		cCadast := cCadastro
	Endif

	If lDicio 
		cCadastro := ARGSX2NOME(cAliaA) 
		If lSetaA .And. !AGRIFDBSEEK(cAliaA,cChavA,nIndiA,.t.)
			lMostra := .f.
		EndIf
		If lMostra
			AxVisual(cAliaA,Recno(),2,,,,,,,,,,,,,,)
		EndIf   
	Else
		AGRVISUTRB(cAliaA,cChavA,nIndiA,lSetaA,cTitu,aMatC)
	EndIf

	If !Empty(aRotin)
		aRotina := Aclone(aRotin)
	EndIf 
	If !Empty(cCadast)
		cCadastro := cCadast
	EndIf  
	RestArea(aArea)
Return .t.

/*
+=================================================================================================+
| Programa  : AGRVISUTRB                                                                          |
| Descrição : Monta a visualização do arquivo temporário ( Registro )                             |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/10/2014                                                                          |
+=================================================================================================+     
| Retorna   : cVAlias  - Alias do arquivo temporário                                   Não Obrigat|
|             cChaveA  - Chave de acesso ( Sem filial )                                Não Obrigat|
|             nIndice  - Indice de acesso                                              Não Obrigat|
|             lSetaVi  - Seta tabela antes de montar                                   Não Obrigat|
|             cTitu    - Título da janela                                              Não Obrigat|
|             aMatCamp - Matriz com a estrutura do arquivo temporário                  Não Obrigat|
|=================================================================================================+
|Referências : Função AGRCONPAD                                                                   |
+=================================================================================================+
*/
Function AGRVISUTRB(cVAlias,cChaveA,nIndice,lSetaVi,cTitu,aMatCamp)
	Local cCampo, nX, cCaption, cValid, nIn := 1
	Local cWhen, nLargSay, oSay, oGet
	Local cBlkGet,cBlkWhen,cBlkVld,nOpcx := 3,oGets := {},aC := {},aSay := {}
	Local XX,XP,nCL,aAreaAt := GetArea(),nCOL := 5,l11 := 3
	Local cPicA,cTitT,cAliAt := If(cValias = Nil,Alias(),cValias)
	Private bSet15,bSet24
	Private aSize := MsAdvSize(,.f.,430), aObjects := {}

	Aadd(aObjects,{100,100,.t.,.t.})
	Aadd(aObjects,{100,100,.t.,.t.})
	aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)
	cTitT   := If(cTitu <> Nil,cTitu+ " - ","")+STR0049+"      "+STR0050+" "+cAliAt

	aEstr   := Aclone(aMatCamp)

	DbselectArea(cAliAt)
	If aEstr = Nil
		aEstrA := Dbstruct()
		For nX := 1 To Len(aEstrA)
			Aadd(aEstrA[nX],aEstrA[nX,1])
			Aadd(aEstrA[nX],"@!")
		Next nx
	EndIf

	aEstr := Aclone(aEstrA)
	If aMatCamp = Nil
		aMatCamp := aClone(aEstr)
	EndIf	

	nTamL := aSize[3]-15
	For xx := nIn to Fcount()
		cPicA := aEstr[xx,6]
		Aadd(aSay,{l11,nCOL})
		Aadd(aC,{FieldName(xx),{l11+8,nCOL},&(FieldName(xx)),cPicA,,,,aEstr[xx,3]*5,CLR_BLUE})
		nCol += If(aEstr[xx,2] = "C",Max(Len(aEstr[xx,5]),aEstr[xx,3])*6,Max(Len(aEstr[xx,5]),Len(aEstr[xx,6]))*2)
		If nCol > nTamL
			nCol := 5
			l11 += 23
		EndIf      
	Next xx

	DEFINE MSDIALOG odlge TITLE OemToAnsi(cTitT) FROM 0,0 To aSize[4],aSize[3] Pixel 
	oDlgE:lEscClose := .F.
	oScrollBox := TScrollBox():new(odlge,05,03,aSize[4]-10,aSize[3]-3,.T.,.T.,.T.)
	For nCL := nIn To Len(aMatCamp)
		cCaption := SubStr(aMatCamp[nCL,5],1,13) 
		cBlKSay1 := "{|| OemToAnsi('"+cCaption+"')}"
		oSay     := TSay():New(aSay[If(nIn = 2,nCL-1,nCL),1],aSay[If(nIn = 2,nCL-1,nCL),2],&cBlkSay1,oScrollBox,,,.F.,.F.,.F.,.T.,CLR_BLACK,,,,.F.,.F.,.F.,.F.,.F.)
		nLargSay := GetTextWidth(0,cCaption) 
		cCaption := oSay:cCaption
	Next nCL
	For XP := 1 to Len(aC)
		cCampo   := aC[XP,1]
		cCaption := Iif(Empty(aC[XP,3])," ",aC[XP,3])
		cValid   := Iif(Empty(aC[XP,5]),".t.",aC[XP,5])
		cWhen    := Iif(aC[XP,7]==NIL,".t.",Iif(aC[XP,7],".t.",".f."))
		cWhen    := Iif(!(Str(nOpcx,1,0)$"346"),".f.",cWhen)
		cBlkGet  := "{ | u | If( PCount() == 0, "+cCampo+","+cCampo+":= u ) }"
		cBlKVld  := "{|| "+cValid+"}"
		cBlKWhen := "{|| AGRRETTRUE()}"
		oGet     := TGet():New(aC[XP,2,1],aC[XP,2,2],&cBlKGet,oScrollBox,aC[XP,8],,aC[XP,4],&(cBlkVld),,,,.F.,,.T.,,.F.,&(cBlkWhen),.F.,.F.,,.F.,.F.,aC[XP,6],(aC[XP,1]))
		Aadd(oGets,oGet)
	Next XP
	Activate Msdialog oDlge On Init EnchoiceBar(oDlge,{||nOpce := 1,oDlge:End()},{||oDlge:End()})
	RestArea(aAreaAt)
Return

// TRATAMENTO DE IMPRESSÃO GRÁFICA
/*
+=================================================================================================+
| Programa  : AGRIMPRGRAFI                                                                        |
| Descrição : Impressão gráfica padrão                                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/02/2015                                                                          |
+=================================================================================================+     
| Retorna   : bProcesso - Bloco de codigo (função)                                     Obrigatório|
|             lPaisgem  - Tipo do relatorio                                            Não Obrigat|
|=================================================================================================+
|Referências : AGRCRIAUPD                                                                         |
+=================================================================================================+
*/
Function AGRIMPRGRAFI(bProcesso,lPaisagem)
	Private lLandScape := If(lPaisagem = Nil,.f.,lPaisagem)
	Private nLinMax    := 0,nColMax := 0,Li := 4000,m_pag := 1
	Private oCouNew07  := TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.) //-- Modo Normal
	Private oCouNew07N := TFont():New("Courier New",07,07,,.T.,,,,.T.,.F.) //-- Modo Negrito(5o parametro New() )
	Private oCouNew08  := TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	Private oCouNew08N := TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)
	Private oCouNew10  := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	Private oCouNew10N := TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
	Private oCouNew12  := TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)
	Private oCouNew12N := TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)
	Private oCouNew15  := TFont():New("Courier New",15,15,,.F.,,,,.T.,.F.)
	Private oCouNew15N := TFont():New("Courier New",15,15,,.T.,,,,.T.,.F.)
	Private oCouNew21  := TFont():New("Courier New",21,21,,.F.,,,,.T.,.T.)
	Private oCouNew21N := TFont():New("Courier New",21,21,,.T.,,,,.T.,.T.)
	Private oArial08   := TFont():New("Arial"      ,08,08,,.F.,,,,.T.,.F.)
	Private oArial08N  := TFont():New("Arial"      ,08,08,,.T.,,,,.T.,.F.)
	Private oArial12   := TFont():New("Arial"      ,12,12,,.F.,,,,.T.,.F.)
	Private oArial12N  := TFont():New("Arial"      ,12,12,,.T.,,,,.T.,.F.)
	Private oArial16   := TFont():New("Arial"      ,16,16,,.F.,,,,.T.,.F.)
	Private oArial16N  := TFont():New("Arial"      ,16,16,,.T.,,,,.T.,.F.)

	_SetOwnerPrvt("oPrint",)

	//-- Objeto para Impressao grafica
	oPrint := TMSPrinter():New(cTitulo)

	If lLandScape
		oPrint:SetLandScape() //Modo paisagem
	Else
		oPrint:SetPortrait()  //Modo retrato
	Endif

	nLinMax := If(lLandScape,2300,3100)
	nColMax := If(lLandScape,3285,2350)

	If bProcesso != NIL
		eval(bProcesso)
		oPrint:EndPage()  // Finaliza a pagina
		oPrint:Preview()  // Visualiza antes de imprimir
	Endif
Return

/*
+=================================================================================================+
| Programa  : AGRCABECEMP                                                                         |
| Descrição : Impressão gráfica do cabecalho do relatório                                         |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 04/02/2015                                                                          |
|=================================================================================================+
|Referências : AGRUPDDET                                                                       |
+=================================================================================================+
*/
Function AGRCABECEMP()
	Local cDetCab := "",nEspaco := 0,nFc := 0,cStartPath := GetSrvProfString("Startpath","")

	Li += 40
	If Li >= nLinMax
		oPrint:EndPage()    // Finaliza a pagina
		oPrint:StartPage()  // Inicia uma nova pagina
		Li := 0
		//-- Carrega Logotipo para impressao
		cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP"   // Empresa+Filial
		If !File( cLogo )
			cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+".BMP"              // Empresa
		Endif
		Li += 20
		// Nome da Empresa / Pagina  / Logotipo
		oPrint:Line(li,50,li,nColMax)
		If File(cLogo)
			li += 50
			oPrint:SayBitmap(li,50, cLogo,400,090)
		Endif
		cDetCab := RptFolha +" " + TRANSFORM(m_pag,'999999')
		li      += 75
		oPrint:say(li,nColMax-400,cDetCab,oCouNew10)

		// Versão
		cDetCab := "SIGA /"+cNomPro+"/v."+cVersao+"  "
		li      += 50
		oPrint:say(li ,50 ,cDetCab,oCouNew10)

		//-- Titulo
		cDetCab := If(lLandScape,Trim(cTitulo),Left(Trim(cTitulo),48)) 
		nEspaco := (nColMax - Len(AllTrim(cTitulo)) *100 / 6 ) / 2
		oPrint:say(li,nEspaco,cDetCab,oArial12N)

		cDetCab := RptDtRef +" "+ DTOC(dDataBase)
		oPrint:say(li,nColMax-400,cDetCab,oCouNew10)

		// Hora da emissão / Data Emissao
		cDetCab := RptHora+" "+time()
		li      += 50
		oPrint:say(li,50,cDetCab,oCouNew10)

		cDetCab := RptEmiss+" "+DToC(MsDate())
		oPrint:say(li,nColMax-400,cDetCab,oCouNew10)
		li += 50
		oPrint:Line(li,50,li,nColMax)
		oPrint:Box(li,30,nLinMax+50,nColMax)

		If Valtype(cCabec1) = 'A'
			If Len(cCabec1) > 0
				If Valtype(cCabec1) = 'A'
					For nFC := 1 To Len(cCabec1) 
						nColP := cCabec1[nFC,2]
						cDesC := cCabec1[nFC,1]
						oPrint:say(Li,nColP,cDesC,oCouNew10N)
					Next nFC
					If Valtype(cCabec2) = 'A'
						If Len(cCabec2) > 0
							Li += 50
							oPrint:say(Li,50,cCabec2[nFC,2],cCabec2[nFC,2],oCouNew10N)
						EndIf
					EndIf
				Endif
			Endif
			Li += 50
			oPrint:Line(Li,50-20,Li,nColMax)
		Else
			If Len(Trim(cCabec1)) > 0
				oPrint:say(Li,50,cCabec1,oCouNew10N)
				If Len(Trim(cCabec2)) != 0
					Li += 50
					oPrint:say(Li,50,cCabec2,oCouNew10N)
				EndIf
				Li += 50
				oPrint:Line(Li,50-20,Li,nColMax)
			Endif
		EndIf
		m_pag++
	Endif
Return

/*
+=================================================================================================+
| Programa  : AGRSOMALINHA                                                                        |
| Descrição : Soma linha e imprime o cabeçalho                                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 17/07/2015                                                                          |
+=================================================================================================+     
|Referências : AGRR890,AGRR900                                                                    |
+=================================================================================================+
*/
Function AGRSOMALINHA()
	nLi++
	If nLi > 59 
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLi := 8
	EndIf
Return

// TRATAMENTO DE HISTÓRIO DE TABELAS
/*
+=================================================================================================+
| Programa  : AGRGRAVAHIS                                                                         |
| Descrição : Gravação do histório da tabela                                                      |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 18/02/2015                                                                          |
+=================================================================================================+     
| Retorna   : cTitmsg - Titulo o janela                                               Com Condição|
|             cTabela - Código da tabela                                              Com Condição|
|             cChave  - Chave de acesso ao registro da tabela                         Com Condição|
|             cTipoms - Tipo do histórico                                             Com Condição|
|             vVetDad - Vetor com os dados para geração automática                    Não Obrigata|
|                                              Com Condição se não informado vVetDad - Obrigatório|
|		      cIniMsg - Mensagem inicial de complemento do corpo da mensagem          Não Obrigata|
|             lTela   - Necessidade específica da confirmação pelo OGA290            Não Obrigata|
|=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+
*/
Function AGRGRAVAHIS(cTitmsg,cTabela,cChave,cTipoms,vVetDad,cIniMsg,lTela)
	Local aArea    := GetArea()
	Local nOpcao   := 2
	Local cMsgMemo := TamSX3("NK9_MSGMEM")
	Local cNomUsu  := ""	 
	Local dDate	   := dDataBase
	Local oMsg     := nil
	Local lAutma   := .f.

	Default cIniMsg := ""
	Default lTela   := .t.

	DbSelectArea("NK9")	
	If IsBlind()
		lTela := .F.
	EndIf

	If vVetDad = Nil .Or. Empty(vVetDaD)
		If lTela
			cNomUsu := UsrRetName(RetCodUsr())
			oDlg	:= TDialog():New(350,406,638,795,cTitmsg,,,,,CLR_BLACK,CLR_WHITE,,,.t.) 
			oDlg:lEscClose := .f.

			@ 038,008 SAY STR0054 PIXEL		//"Data"
			@ 038,024 MSGET dDate OF oDlg PIXEL WHEN .f.

			@ 038,092 SAY STR0055 PIXEL //"Usuário"
			@ 038,116 MSGET cNomUsu OF oDlg PIXEL WHEN .f.

			@ 058,008 SAY STR0056 PIXEL	
			@ 070,008 GET oMsg Var cMsgMemo OF oDlg Multiline Size 172,062 PIXEL VALID NaoVazio(cMsgMemo)

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcao := 1, oDlg:End()},{|| nOpcao := 0,oDlg:End()}) CENTERED
		Else
			nOpcao   := 1
			cMsgMemo := STR0262 //"Confirmação automática após alteração."
		EndIf
	Else
		nOpcao := 1
		lAutma := .t.
	EndIf	
	If nOpcao == 1 
		If lAutma
			Iif(vVetDad[3] == "W", cNomUsu == "workflow", cNomUsu := UsrRetName(RetCodUsr()))
		Else
			cNomUsu := UsrRetName(RetCodUsr())
		EndIf

		AGRTRAVAREG("NK9",.t.)
		NK9->NK9_FILIAL	:= xFilial("NK9")
		NK9->NK9_TABLE	:= If(lAutma,vVetDad[1],cTabela)
		NK9->NK9_CHAVE 	:= If(lAutma,vVetDad[2],cChave)
		NK9->NK9_DATA 	:= dDataBase
		NK9->NK9_HORA 	:= Time()
		NK9->NK9_NOMUSU	:= cNomUsu
		If .NOT. Empty(cIniMsg)
			NK9->NK9_MSGMEM := If(lAutma,vVetDad[4],cIniMsg + cMsgMemo)
		Else
			NK9->NK9_MSGMEM := If(lAutma,vVetDad[4],cMsgMemo)
		EndIf
		NK9->NK9_TIPOMS := If(lAutma,vVetDad[3],cTipoms)
		AGRDESTRAREG()
	EndIf

	RestArea(aArea)
Return nOpcao		

/*
+=================================================================================================+
| Programa  : AGRHISTTABE                                                                         |
| Descrição : Histórico da tabela                                                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 18/02/2015                                                                          |
+=================================================================================================+     
| Retorna   : cTabela - Código da tabela                                               Obrigatório|
|             cChave  - Chave de acesso ao registro da tabela                          Obrigatório|
|             nSubStr - Substring da cChave                                            Não Obrigat|
|=================================================================================================+
|Referências : AGRA840                                                                            |
+=================================================================================================+
*/
Function AGRHISTTABE(cTabela,cChave,nSubStr)
	Local aRot := If(ValType("aRotina") = "A",Aclone(aRotina),{})
	Local cCad := If(Type("cCadastro") <> "U",cCadastro," ")
	Local cFil := If(nSubStr = NIL,"NK9_TABLE = '"+cTabela+"' .And. NK9_CHAVE = '"+cChave+"'",;
	"NK9->NK9_TABLE = '"+cTabela+"' .And. SubStr(NK9->NK9_CHAVE,1,nSubStr) = '"+cChave+"'") 
	aRotina    := {{STR0057,"AxPesqui",0,1},;
	{STR0049,"AxVisual",0,2}} 
	cCadastro  := AGRSX2NOME("NK9")

	DbSelectArea("NK9")
	If TableInDic('N72')
		NK9->(DbSetOrder(3)) //ordenar por data e hora de inclusão do histórico
	EndIf           
	oBrowse    := FWMBrowse():New()
	oBrowse:SetAlias('NK9')
	oBrowse:SetDescription(Alltrim(AGRSX2NOME(cTabela))+" - "+STR0058)
	oBrowse:SetFilterDefault(cFil)
	oBrowse:Activate()
	aRotina   := Aclone(aRot)
	cCadastro := cCad
Return

/* 
+=================================================================================================+
| Função    : AGRCOMGHIST                                                                         |
| Descrição : Compara um registro de uma tabela com os dados de um arquivo temporário e gera um   |
|             registro de histórico na tabela NK9 (Se tiver dados deferentes)                     |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 28/08/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: vVetTRB - Vetor com o nome e alias do arquivo temporário                 Obrigatório|  
|             cAliD   - Alias da tabela a ser compara os dados                         Obrigatório|  
|             cChave  - Chave de acesso ao registro                                    Não Obrigat|  
|             nInd    - Número do índice de acesso                                     Não Obrigat| 
|             lDelT   - Apaga arquivo temporário                                       Não Obrigat| 
+=================================================================================================+  
|Referências: AGRA890                                                                             |
+=================================================================================================+ 
*/
Function AGRCOMGHIST(vVetTRB,cAliD,cChave,nInd,lDelT)
	Local aArea	 := GetArea()
	Local nIndA	 := If(nInd = Nil,1,nInd),lCerto := .t.
	Local cMemo	 := CriaVar("NP9_OBS"),nx
	Local cChaveI	 := cAliD+"->("+Alltrim(AGRSEEKDIC("SIX",cAliD+"1",1,"CHAVE"))+")"
	Local	cChaveA	 := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	If cChave <> Nil
		If !AGRIFDBSEEK(cAliD,cChave,nIndA,.f.)
			lCerto := .f.
		EndIf	
	EndIf
	If lCerto
		DbSelectArea(cAliD)
		aStrut1 := Dbstruct()
		For nx := 1 To Fcount()
			nPos := aScan(aStrut1,{|x| AllTrim(x[1]) == Fieldname(nx)})
			If nPos > 0
				x := cAliD+"->"+Fieldname(nx)
				y := vVetTRB[2]+"->"+aStrut1[nPos,1]
				If &x <> &y
					cComX := If(Valtype(&x) = "N",Alltrim(Str(&x)),If(Valtype(&x) = "D",Dtoc(&x),&x))
					cComY := If(Valtype(&y) = "N",Alltrim(Str(&y)),If(Valtype(&y) = "D",Dtoc(&y),&y))
					cMemo += Fieldname(nx)+"  "+Alltrim(cComY)+"  -> "+Alltrim(cComX)+"   "
				EndIf
			EndIf
		Next nx
		If !Empty(cMemo)
			AGRGRAVAHIS(,,,,{cAliD,cChaveA,"H",cMemo})
		EndIf
	EndIf
	If lDelT .And. vVetTRB[1] <> NiL
		AGRDELETRB(vVetTRB[2],vVetTRB[1])
	EndIf
	RestArea(aArea)
Return

/* 
+=================================================================================================+
| Função    : AGRHISTNREG                                                                         |
| Descrição : Compara e cria registro para o histório do registro                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 10/09/2015                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cAlia   - Alias da tabela                                                Obrigatório|  
|             nInd    - Número do índice de acesso da tabela                           Obrigatório| 
|             cAliTrb - Alias do arquivo temporário                                    Obrigatório| 
+=================================================================================================+  
|Referências: AGRA900                                                                             |
+=================================================================================================+ 
*/
Function AGRHISTNREG(cAlia,nInd,cAliTrb)
	Local aAreaAt := GetArea()
	Local nIndA   := If(nInd = Nil,1,nInd)
	Local cChavI  := Alltrim(AGRSEEKDIC("SIX",cAlia+Alltrim(Str(nIndA)),1,"CHAVE"))
	Local nPMais  := At("+",cChavI)
	Local cChavA  := (cAliTrb)+"->("+SubStr(cChavI,nPMais+1,Len(cChavI))+")"
	ARGSETIFARQUI(cAliTrb)
	While !Eof()
		If AGRIFDBSEEK(cAlia,&cChavA,nIndA,.F.)
			AGRCOMGHIST({,cAliTrb},cAlia,,,.f.)
		EndIf
		AGRDBSELSKIP(cAliTrb)	
	End
	AGRDELETRB(cAliTrb)
	RestArea(aAreaAt)
Return 

/*/{Protheus.doc} AGRA840NFE
Integração com documento de entrada (SF1 x NP9)
@author Inácio Luiz Kolling 
@version P12
@since 07/04/2015   
@type function
@uso MATA103
/*/
Function AGRA840NFE()
	Local vVetNao    := {"NP9_FILIAL","NP9_TIPLOT","NP9_STATUS","NP9_DOCD3","NP9_DOCBLQ","NP9_ENDERE","NP9_FORMUL","NP9_FORMUV",;
	"NP9_CLASS ","NP9_EGF   ","NP9_IR    ","NP9_HRINI ","NP9_HRFIM ","NP9_HRTOT ","NP9_DATAFI","NP9_DATA"}
	Local cCampN     := "NP9_PROD|NP9_QUANT|NP9_UM|NP9_2UM|NP9_QTD2UM|NP9_LOCAL|NP9_OP|NP9_CCUSTO"
	Local nx,nOPCA   := 2
	Local cMsgHstAgr := ''
	Local cAliasNP9  := GetNextAlias()
	Local lMVAGRO049 := SuperGetMv("MV_AGRO049", .F., .F. ) // .T. Indica que nas nfs. de dev. de lote de sementes
															// o Lote de sementes terá seu status setado para não
															// Aprovado. E gravado Historico ref. a alteração
	Local aRT840DV   := {}
	
	Private lAgrPE	 := .T.,cTipoNFE := "NB"
	Private aSize	 := MsAdvSize(,.f.,430),aObjects := {}
	Private INCLUI	 := .T.
	Private cLoteTSI := Nil
	Private aCols	 := {}
	Private aHeader	 := {}
	Private vVetCam	 := {}
	Private _lLWR12123 	:= GetRpoRelease() > "12.1.023"
	Aadd(aObjects,{100,100,.t.,.t.})
	Aadd(aObjects,{200,200,.t.,.t.})
	aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj  := MsObjSize(aInfo, aObjects,.t.)
	aRotina	 := AGREMULAROT()

	If ExistBlock('AGRP9NFE')
		lAgrPE := ExecBlock('AGRP9NFE',.F.,.F.)
	EndIf

	DbSelectArea("SF1")
	If SF1->F1_TIPO $ cTipoNFE .and. lAgrPE
		aHeader	:=	AGRCRIAGRID("NP9",vVetNao)
		nSafra	:=	GDFIELDPOS("NP9_CODSAF"	,aHeader) //Verificar se o campo está marcado em uso
		nProd	:=	GDFIELDPOS("NP9_PROD"	,aHeader)
		nQuant	:=	GDFIELDPOS("NP9_QUANT"	,aHeader)
		nLote	:=	GDFIELDPOS("NP9_LOTE"	,aHeader)
		nUm1   	:=	GDFIELDPOS("NP9_UM"		,aHeader)
		nUm2  	:=	GDFIELDPOS("NP9_2UM"	,aHeader)
		nQuant2	:=	GDFIELDPOS("NP9_QTD2UM"	,aHeader)
		nDtval	:=	GDFIELDPOS("NP9_DTVAL" 	,aHeader)      
		nLocal 	:=	GDFIELDPOS("NP9_LOCAL" 	,aHeader)
		nOp   	:=	GDFIELDPOS("NP9_OP"  	,aHeader)
		nCC   	:=	GDFIELDPOS("NP9_CCUSTO"	,aHeader)
		nCultra	:=	GDFIELDPOS("NP9_CULTRA"	,aHeader)
		nCtvar 	:=	GDFIELDPOS("NP9_CTVAR"	,aHeader)
		nDCtvar	:=	GDFIELDPOS("NP9_CTVDES"	,aHeader)
		nCateg 	:=	GDFIELDPOS("NP9_CATEG"	,aHeader)
		nPene 	:=	GDFIELDPOS("NP9_PENE"	,aHeader)
		nEmb	:=	GDFIELDPOS("NP9_EMB"    ,aHeader)
		nSeca	:=	GDFIELDPOS("NP9_SECA"   ,aHeader)
		nTrato 	:=	GDFIELDPOS("NP9_TRATO"	,aHeader)
		cRenasem := GDFIELDPOS("NP9_RENASE"	,aHeader)
		IF _lLWR12123
			//Virtual - Versões 17 e 23 não recuperam os campos
			nDesc	:=	GDFIELDPOS("NP9_PRDDES"	,aHeader)
			nDCultr	:=	GDFIELDPOS("NP9_CTRDES"	,aHeader) 
			nDPene	:=	GDFIELDPOS("NP9_PENDES"	,aHeader) 
		EndIf

		If AGRIFDBSEEK("SD1",SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,1,.F.)
			While !Eof() .And. SD1->D1_FILIAL = Xfilial("SD1") .And. SD1->D1_DOC = SF1->F1_DOC .And. SD1->D1_SERIE = SF1->F1_SERIE .And.;
			SD1->D1_FORNECE = SF1->F1_FORNECE .And. SD1->D1_LOJA = SF1->F1_LOJA
				If AGRIFDBSEEK("SB5",SD1->D1_COD,1,.F.) .And. SB5->B5_SEMENTE = "1" .AND. AGRIFDBSEEK("SF4",SD1->D1_TES,1,.F.) .And. SF4->F4_ESTOQUE = "S"
					If AGRIFDBSEEK("SB1",SD1->D1_COD,1,.F.) .And. SB1->B1_RASTRO = "L"
						AGRZERAACOLS(aHeader,aCols,.t.)
						aCols[Len(aCols),nProd]  	:= SD1->D1_COD
						IF _lLWR12123 .AND. nDesc > 0	
							aCols[Len(aCols),nDesc]  	:= SB1->B1_DESC
						EndIf	  
						aCols[Len(aCols),nQuant] 	:= SD1->D1_QUANT	
						aCols[Len(aCols),nLote]  	:= SD1->D1_LOTECTL	
						aCols[Len(aCols),nUm1]	 	:= SD1->D1_UM
						aCols[Len(aCols),nUm2]	 	:= SD1->D1_SEGUM
						aCols[Len(aCols),nQuant2]	:= SD1->D1_QTSEGUM
						If nDtVal > 0
							aCols[Len(aCols),nDtVal]	:= SD1->D1_DTVALID
						EndIf
						aCols[Len(aCols),nLocal]	:= SD1->D1_LOCAL
						aCols[Len(aCols),nOp]   	:= SD1->D1_OP
						aCols[Len(aCols),nCC]		:= SD1->D1_CC
						aCols[Len(aCols),nCultra]	:= SB5->B5_CULTRA
						IF _lLWR12123 .AND. nDCultr > 0
							aCols[Len(aCols),nDCultr]	:= Posicione('NP3',1,xFilial('NP3')+SB5->B5_CULTRA,'NP3_DESCRI')
						EndIf
						aCols[Len(aCols),nCtvar]	:= SB5->B5_CTVAR
						aCols[Len(aCols),nDCtvar]	:= Posicione('NP4',1,xFilial('NP4')+SB5->B5_CTVAR,'NP4_DESCRI')                   
						aCols[Len(aCols),nCateg]	:= SB5->B5_CATEG
						aCols[Len(aCols),nPene]		:= SB5->B5_PENE
						IF _lLWR12123 .AND. nDPene > 0
							aCols[Len(aCols),nDPene]	:= Posicione('NP7',1,xFilial('NP7')+SB5->B5_PENE,'NP7_DESCRI')
						EndIf
						If nEmb > 0
							aCols[Len(aCols),nEmb] := '1'
						EndIf	
						If nSeca > 0
							aCols[Len(aCols),nSeca]	:= '1'
						EndIf
						If nTrato > 0 	
							aCols[Len(aCols),nTrato] := '2'
						EndIf	   
					EndIf		                    
				EndIf
				AGRDBSELSKIP("SD1")
			End
		EndIf

		//  Ponto de Entrada que permite usuario 
		//  adicionar Campos no Aheader e 
		//  Manipular dados do acols.		
		IF !Empty(aCols)
			If (ExistBlock("AGR840DV"))
				aRT840DV := ExecBlock("AGR840DV",.F.,.F.,{aheader, acols})
				If ValType(aRT840DV)=="A" .And. Len(aRT840DV) > 0 .and. Len(aRT840DV) = 2
				   aheader := aClone( aRT840DV[1] )
				   aCols   := aClone( aRT840DV[2] )
				EndIF
			EndIF
		EndIF
		
		If !Empty(aCols)		
			Define MsDialog oDlgTela Title AGRSX2NOME("NP9") From aSize[1],aSize[2] To aSize[4],aSize[3] PIXEL STYLE DS_MODALFRAME
			oDlgTela:lMaximized := .t.   
			oDlgTela:lEscClose := .t.                                             
			oGet := MSGetDados():New(0,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],3,"AllwaysTrue()","AllwaysTrue()",,.f.,,3,,1)
			oGet:OBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
			For nx := 1 To Len(aHeader)
				If Alltrim(aHeader[nx,2]) $ cCampN .Or. aHeader[nx,10] = "V"
					oGet:aInfo[nx,4] := ".F."
				EndIf
				If Alltrim(aHeader[nx,2]) = "NP9_LOCAL"
					aHeader[nx,6] := 'ExistCpo("NNR")'
				ElseIf Alltrim(aHeader[nx,2]) = "NP9_CULTRA"	
					aHeader[nx,6] := "ExistCpo('NP3',M->NP9_CULTRA)"
				ElseIf Alltrim(aHeader[nx,2]) = "NP9_CATEG"	
					aHeader[nx,6] := "ExistCpo('SX5','K1'+M->NP9_CATEG)"
				ElseIf Alltrim(aHeader[nx,2]) = "NP9_CTVAR"	
					aHeader[nx,6] := "ExistCpo('NP4',M->NP9_CTVAR)"
				ElseIf Alltrim(aHeader[nx,2]) = "NP9_PENE"	
					aHeader[nx,6] := "ExistCpo('NP7',M->NP9_PENE)"
				Endif	
			Next
			oget:ForceRefresh()
			oget:Show()
			Activate Msdialog oDlgTela On Init EnchoiceBar(oDlgTela,{|| nOpca := 1,If(oGet:tudook() .And. AGR840LIF(),oDlgTela:End(),nOPCA := 2)},;
			{|| nOPCA := 2,If(AGR840LIS(),oDlgTela:End(),nOPCA := 0)})
			If nOPCA = 1
				For nx := 1 To Len(aCols)
					If !AGRIFDBSEEK("NP9",aCols[nx,nSafra]+aCols[nx,nProd]+aCols[nx,nLote],1,.F.)
						AGRTRAVAREG(,.t.)
						NP9->NP9_FILIAL := Xfilial("NP9")
						NP9->NP9_TIPLOT := "2"
						NP9->NP9_DOC    := SF1->F1_DOC
						NP9->NP9_SERIE  := SF1->F1_SERIE
						NP9->NP9_STATUS := "1"
						NP9->NP9_EGF    := "2"
						NP9->NP9_FORNEC := SF1->F1_FORNECE
						NP9->NP9_LOJA   := SF1->F1_LOJA
						NP9->NP9_CODSAF := aCols[nx,nSafra]
						NP9->NP9_DATA	:= SF1->F1_EMISSAO
						AGRACOLSTAB("NP9",aHeader,aCols[nx])
					Else
						AGRTRAVAREG()
						//Atualiza a nota e serie caso o mesmo lote tenha duas entradas DAGROOGD-16647
						NP9->NP9_DOC    := SF1->F1_DOC
						NP9->NP9_SERIE  := SF1->F1_SERIE
						NP9->NP9_QUANT	+= aCols[nx,nQuant]
						NP9->NP9_QTD2UM	+= ConvUm(NP9->NP9_PROD,aCols[nx,nQuant],0,2)
						NP9->NP9_RENASE := IIF(Empty(aCols[nx,cRenasem]),NP9->NP9_RENASE,aCols[nx,cRenasem])  
						If NP9->(ColumnPos('NP9_DINDEA')) > 0 
							NP9->NP9_DINDEA := IIF(Empty(aCols[nx, GDFIELDPOS("NP9_DINDEA"	,aHeader) ] ), ;
							NP9->NP9_DINDEA,;
							aCols[nx, GDFIELDPOS("NP9_DINDEA"	,aHeader) ]) 
						EndIf
						If NP9->(ColumnPos('NP9_DFASE')) > 0   
							NP9->NP9_DFASE := IIF(Empty( aCols[nx, GDFIELDPOS("NP9_DFASE"	,aHeader) ] ), ;
							NP9->NP9_DFASE,;
							aCols[nx, GDFIELDPOS("NP9_DFASE"	,aHeader) ] ) 
						EndIf
					EndIf
					AGRDESTRAREG()
				Next nx	
			EndIf
		EndIf
		ElseIF SF1->F1_TIPO == 'D' .and. lAgrPE  //Devolução de Produto lote de sementes.
		SD1->( dbSetOrder( 1 ) ) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM 
		IF SD1->( dbSeek( FWxFilial( "SF1" ) + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA) ) )
			While SD1->( !Eof() ) .And.	SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == FWxFilial( "SF1" ) + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)
				BeginSQL Alias cAliasNP9
					SELECT SC5.C5_CODSAF, SD2.D2_COD, SD2.D2_LOTECTL
					FROM %Table:SD2% SD2

					///INNER JOIN %Table:SF4% SF4
					///   ON   SF4.F4_FILIAL =  %xFilial:SF4% 
					///   AND SF4.F4_CODIGO = SD1.D1_TES
					///   AND SF4.F4_ESTOQUE = 'S'
					///   AND SF4.%notDel%
					INNER JOIN %Table:SC5% SC5
					ON SC5.C5_FILIAL = %xFilial:SC5% 
					AND SC5.C5_NUM   = SD2.D2_PEDIDO
					AND SC5.C5_CLIENT  = SD2.D2_CLIENTE
					AND SC5.C5_LOJACLI = SD2.D2_LOJA
					AND SC5.%notDel%
					
					INNER JOIN %Table:SB1% SB1
						ON  SB1.B1_FILIAL = %xFilial:SB1% 
						AND SB1.B1_COD = SD2.D2_COD 
						AND SB1.%notDel%

					INNER JOIN %Table:SB5% SB5
						ON SB5.%notDel%
						AND SB5.B5_FILIAL = %xFilial:SB5% 
						AND SB5.B5_COD = SD2.D2_COD

					INNER JOIN %Table:NP9% NP9
						ON NP9.%notDel%
						AND NP9.NP9_FILIAL = %xFilial:NP9% 
						AND NP9.NP9_CODSAF = SC5.C5_CODSAF
						AND NP9.NP9_PROD   = SD2.D2_COD
						AND NP9.NP9_LOTE   = SD2.D2_LOTECTL
					WHERE 	SD2.D2_FILIAL 	= %xFilial:SD2% 
						AND SD2.D2_DOC 		= %Exp:SD1->D1_NFORI%
						AND SD2.D2_SERIE 	= %Exp:SD1->D1_SERIORI%
						AND SD2.D2_ITEM 	= %Exp:SD1->D1_ITEMORI%
						AND SD2.%notDel%
						AND SB5.B5_SEMENTE = '1'    //é SEMENTES
						AND NP9.NP9_STATUS = '2'    //Lote 
					GROUP BY SC5.C5_CODSAF, SD2.D2_COD, SD2.D2_LOTECTL
				EndSQL

				///EECView(gETLASTQUERY()[2],"Consulta de Lote")
				
				While (cAliasNP9)->( !Eof() )
					NP9->( dbSetOrder( 1 ) )  //NP9_FILIAL+NP9_CODSAF+NP9_PROD+NP9_LOTE
					IF NP9->( dbSeek( FwXFilial( "NP9" ) + (cAliasNP9)->(C5_CODSAF + D2_COD + D2_LOTECTL ) ))
						IF RecLock('NP9', .f.)
						    IF lMVAGRO049 //Indica que deve mudar o status do lote para aguardando aprovação 
								NP9->NP9_STATUS = '1' //Retorno o Status para não aprovado
							EndIF
							If NP9->(FieldPos("NP9_LTDEV")) > 0
								NP9->NP9_LTDEV := '2' //Seta como lote devolvido
							EndIF
							NP9->( MsUnlock())
							cMsgHstAgr := "Lote Retornado por Devolução Docto. Fiscal Serie: " + SF1->F1_SERIE + ", NR: " + SF1->F1_DOC
							cMsgHstAgr += " digitada em: " +  dtoc(SF1->F1_DTDIGIT) + '.'
							AGRGRAVAHIS(,,,,{"NP9",FWxFilial("NP9")+NP9->NP9_CODSAF+NP9->NP9_PROD+NP9->NP9_LOTE,"R",cMsgHstAgr}) //Rejeitado
						EndIF
					EndIF
					(cAliasNP9)->(dbSkip())	
					
				EndDO
				(cAliasNP9)->(dbCloseArea())
				SD1->(dbSkip())
			EndDO
		EndIF
	Endif
Return

/*                                                                                                 
+=================================================================================================+
| Função    : AGR840LIF                                                                           |
| Descrição : Consistência final da integração SF1 x NP9                                          |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 07/04/2015                                                                          | 
+=================================================================================================+ 
|Referências : AGRA840NFE                                                                         |
+=================================================================================================+    
*/
Function AGR840LIF()
	Local nx,cMensa := Space(1)
	For nx := 1 To Len(aCols)
		If Empty(aCols[nx,nSafra])
			cMensa := AGRTITULO("NP9_CODSAF")+" "+STR0087
		ElseIf Empty(aCols[nx,nLote])
			cMensa := AGRTITULO("NP9_LOTE")+" "+STR0087 
		ElseIf Empty(aCols[nx,nCultra])
			cMensa := AGRTITULO("NP9_CULTRA")+" "+STR0087 
		ElseIf Empty(aCols[nx,nCtvar])
			cMensa := AGRTITULO("NP9_CTVAR")+" "+STR0087 
		ElseIf Empty(aCols[nx,nCateg])
			cMensa := AGRTITULO("NP9_CATEG")+" "+STR0087 
		ElseIf Empty(aCols[nx,nPene])
			cMensa := AGRTITULO("NP9_PENE")+" "+STR0087 
		EndIf
		If !Empty(cMensa)
			Alert(cMensa+" "+STR0088+" "+Alltrim(Str(nx,3)))
			Return .f.
		EndIf		
	Next nx
	
	//  Validação total dos dados do lote comprado
	If (ExistBlock("AGR840CP"))
	    lRet := ExecBlock("AGR840CP",.F.,.F.,{aheader, acols})
		IF ! lRet
		  Return .f.
		EndIF
	EndIF
Return .t.

/*/{Protheus.doc} AGR840LIS
Alerta ao cancelar integração NFE x NP9, para confirmar se realmente usuario deseja cancelar a tela.   
@author Inácio Luiz Kolling 
@version 1.0
@since 07/04/2015
@obs chamada AGRA840NFE
@type function
/*/
Function AGR840LIS()
 	Local lRet := .T.

	If ExistBlock("AGR840CT")
		//Validação se permite o cancelamento da tela de lotes de sementes durante a inclusão do documento de entrada.
		lRet := ExecBlock('AGR840CT', .F.,.F.)
	EndIF
	
	If lRet 
		lRet := AGRYESNOMVC(STR0092+"   "+STR0089,STR0090)
	EndIF

Return lRet

/*                                                                                                 
+=================================================================================================+
| Função    : AGROKDELNFE                                                                         |
| Descrição : Verifica se pode excluir a nota fiscal de entrada x Lote (SF1 x NP9)                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 08/04/2015                                                                          | 
+=================================================================================================+ 
|Referências : MATA103                                                                            |
+=================================================================================================+    
*/
Function AGROKDELNFE()
	Local lRetl := .t. ,aAreaAl := GetArea()
	/*
	If SF1->F1_TIPO = "N" 
	// Busca e consiste por lote + tipo
	cAlia9 := GetNextAlias()
	cQuer9 := " SELECT Count(*) As quant FROM "+RetSqlName("NP9")+" NP9 "
	cQuer9 += " WHERE NP9.NP9_FILIAL = '"+Xfilial("NP9")+"'"
	cQuer9 += " AND NP9.NP9_LOTE = '"+SD1->D1_LOTECTL+"'"
	cQuer9 += " AND NP9.NP9_TIPLOT = '2'
	cQuer9 += " AND NP9.D_E_L_E_T_ = '' "
	cQuer9 := ChangeQuery(cQuer9)

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuer9),cAlia9,.F.,.T.)
	ARGSETIFARQUI(cAlia9)
	While !Eof()
	If	(cAlia9)->quant > 1
	Alert(STR0091)
	lRetl := .f.
	Exit
	EndIf
	AGRDBSELSKIP(cAlia9)
	End
	ARGCLOSEAREA(cAlia9)	
	EndIf
	*/			

	RestArea(aAreaAl)
Return lRetl

/*                                                                                                 
+=================================================================================================+
| Função    : AGRADELENP9                                                                         |
| Descrição : Deleta o lote de beneficiamento da nota fiscal de entrada (SD1 x NP9)               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 08/04/2015                                                                          | 
+=================================================================================================+ 
|Referências : MATA103                                                                            |
+=================================================================================================+  
*/
Function AGRADELENP9()
	Local aAreaAl := GetArea()
	If SF1->F1_TIPO = "N"  
		// Busca e processa por lote + produto + tipo
		cAlia9 := GetNextAlias()
		cQuer9 := " SELECT NP9_CODSAF,NP9_PROD,NP9_LOTE FROM "+RetSqlName("NP9")+" NP9 "
		cQuer9 += " WHERE NP9.NP9_FILIAL = '"+Xfilial("NP9")+"'"
		cQuer9 += " AND NP9.NP9_PROD = '"+SD1->D1_COD+"' AND NP9.NP9_LOTE = '"+SD1->D1_LOTECTL+"'"
		//cQuer9 += " AND NP9.NP9_STATUS <= '2'"  // AND NP9.NP9_TIPLOT = '2'
		cQuer9 += " AND NP9.D_E_L_E_T_ = '' "
		cQuer9 := ChangeQuery(cQuer9)

		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuer9),cAlia9,.F.,.T.)
		ARGSETIFARQUI(cAlia9)
		While !Eof()
			If AGRIFDBSEEK("NP9",(cAlia9)->NP9_CODSAF+(cAlia9)->NP9_PROD+(cAlia9)->NP9_LOTE,1,.f.)
				If SD1->D1_QUANT = NP9->NP9_QUANT
					AGRDELETAREG()
				ElseIf NP9->NP9_QUANT > SD1->D1_QUANT
					AGRTRAVAREG()
					NP9->NP9_QUANT	-= SD1->D1_QUANT
					NP9->NP9_QTD2UM	-=	ConvUm(SD1->D1_COD,SD1->D1_QUANT,0,2)
					AGRDESTRAREG()
				EndIf	
			EndIf
			AGRDBSELSKIP(cAlia9)
		End
		ARGCLOSEAREA(cAlia9)
	EndIf				
	RestArea(aAreaAl)
Return

// TRATAMENTO COM ESTOQUE 
/*
+=================================================================================================+
| Função    : AGRSALDOSB8                            +- SaldoLote(                                |
| Descrição : Busca o saldo do lote disponivel em todos os locais                                 |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 18/10/2015                                                                          |
+=================================================================================================+
|Parâmetros : cLote - Código do lote                                                   Obrigotório|
|             cProd - Código do produto                                                Obrigotório|
|             lTipS - Tipo de saldo                                                    Não Obrigot|
|             lTipR - Tipo de retorno                                                  Não Obrigot|
|             lConC - Considera saldo a Classificar                                    Não Obrigot|
+=================================================================================================+
|Retorno    : cTipoR = .t. nSaldo Senão aSalloc [n]   [n,1] local [n,2] saldo                     |
+=================================================================================================+
|Referência : AGRA840                                                                             |
+=================================================================================================+
*/
Function AGRSALDOSB8(cLote,cProd,lTipS,lTipR,lConC)
	Local lTipoS := If(lTipS = Nil,.f.,lTipS) // fisico ou geral
	Local cTipoR := If(lTipR = Nil,"T",lTipR) // (total ou por local)
	Local lConSC := If(lConC = Nil,.f.,lConC) // Considera saldo a Classificar
	Local nSaldo := 0,nSaldoL := 0,lRastroL,lRastroS
	Local aSalLoc := {}

	DbSelectArea("SB1")
	lRastroL := Rastro(cProd,'L')
	lRastroS := Rastro(cProd,'S')	
	cAliasQry := GetNextAlias()
	cQuery := " SELECT B8_LOCAL,B8_LOTECTL,B8_NUMLOTE,B8_SALDO FROM "+RetSqlName("SB8")+" SB8 "
	cQuery += " WHERE SB8.B8_FILIAL = '"+Xfilial("SB8")+"' AND SB8.B8_PRODUTO = '"+cProd+"' AND SB8.B8_LOTECTL = '"+cLote+"'"
	cQuery += " AND SB8.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	ARGSETIFARQUI(cAliasQry)
	While !Eof()
		If lRastroL .Or. lRastroS
			nIndice := If(lRastroL,3,2)   
			cChaveA := If(lRastroL,cProd+(cAliasQry)->B8_LOCAL+cLote,(cAliasQry)->B8_NUMLOTE+cLote+cProd+(cAliasQry)->B8_LOCAL)
			AGRIFDBSEEK("SB8",cChaveA,nIndice,.F.)
			nSaldoL := SB8Saldo(nil,.t.,lConSC,nil,nil,lTipoS,nil,ddatabase)
			If cTipoR = "T" 
				nSaldo += nSaldoL
			Else
				Aadd(aSalLoc,{(cAliasQry)->B8_LOCAL,nSaldoL})
			EndIf	
		EndIf
		AGRDBSELSKIP(cAliasQry)
	End
	ARGCLOSEAREA(cAliasQry)
Return If(cTipoR = "T",nSaldo,aSalLoc)


/*------------------------------------------------------------------------
Criar a tabela temporária com base na estrutura informada
Recebe um array com duas posições
[1] Estrutura da tabela a ser criada (array)
[2] Indices da tabela a ser criada (array)
-------------------------------------------------------------------------*/
//<-Funcao movida do programa OGA385
Function AGRCRIATC(aArrStr, lObjTemp)
	//Obtem o alias para a tabela temporária
	Local cAliasTab  := GetNextAlias() 
	Local aAlfa      := {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
	Local nI         := 0
	Local aIdx       := {}
	Default lObjTemp := .F.

	For nI := 1 to Len(aArrStr[2])
		aAdd(aIdx, {cAliasTab + aAlfa[nI], aArrStr[2,nI]})
	Next nI
	AGRCRTPTB( cAliasTab, {aArrStr[1], aIdx} )

Return cAliasTab


/*------------------------------------------------------------------------
Criar a tabela temporária com base na estrutura informada
Recebe um array com duas posições
[1] Alias da tabela que será criada. O Alias pode ser passado branco e a 
função retorna o Alias ao invés do objeto (precisa ser melhorado)
[2] Array contendo a estrutura dos campos e os índices.
O índice pode ser passado vazio para criar um índice para cada campo
[3] booleano: permite indicar a criacao de indice para todos os campos da tabela   

TO-D0: Será necessário extender a função para tratar versões anteriores a 12.1.5, 
fazendo com que o programa crie as tabelas temporárias usando o CRIATRAB()
RECURSO NÃO SUPORTADO: a Classe fwtemportarytable não suporta a criação de 
indices decrescente. Abrir chamado para implementacão do método.
-------------------------------------------------------------------------*/
Function AGRCRTPTB(cAliasTmp, aArrStr, lAllInd, aOtheAlias, lExclusivo)
	Local oTempTab  := nil
	Local cTblTmpName := ""
	Local cAliasTab := ""
	Local aAlfa     := {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9"}
	Local nI        := 0
	Local aFlds     := aArrStr[1]
	Local aIndx     := aArrStr[2]
	Local cFldIx    := ""
	Local cIdxNome  := ""
	Local lRetObj   := .T.
	Local nCt1      := 0
	Local nCt2      := 0
	Local nX        := 0
	Local nFldsTam  := 0
	Default lAllInd := .F.
	Default aOtheAlias := {}
	Default lExclusivo := .T.


	If !Empty(cAliasTmp)
		cAliasTab := cAliasTmp
	Else
		lRetObj := .F.
		cAliasTab := GetNextAlias()
	EndIf
	nFldsTam := len(aFlds)
	//-------------------
	//Criação do objeto
	//-------------------
	//    cMsg := "Agora:" + dToC(time())
	//    VarInfo("cMsg", cMsg)
	oTempTab  := FWTemporaryTable():New( cAliasTab )
	//    cMsg := "Agora:" + dToC(time())
	//    VarInfo("cMsg", cMsg)

	//Define os campos da tabela
	oTempTab:SetFields( aFlds )

	// Cria o arquivo de indice para a tabela temporaria

	If len(aIndx) == 0
		lAllInd := .T.
	EndIf

	If !( lAllInd ) 
		For nI := 1 to len(aIndx)
			//Define os Indices
			//FWTemporaryTable():AddIndex( <cIndexName>, {<aFields>} )
			cIdxNome := ""
			If !Empty(aIndx[nI][1])
				cIdxNome := StrTran(aIndx[nI][1],  "SCGN", "")  
			Else
				cIdxNome := StrTran(cAliasTab,  "SCGN", "") + aAlfa[nI]
			EndIf 
			cFldIx := StrTran(aIndx[nI][2], " ", "")
			cFldIx := StrTran(cFldIx, "+", ",")
			oTempTab:AddIndex(cIdxNome, StrToKArr(cFldIx, "," ) )
		Next nI
	Else
		nCt1 := 1
		nCt2 := 0
		If FwIsInCallStack("OGA300LF4")//para evitar estouro de array no oga450,ubac005//tratamento acordo de trocas
			For nX := 1 to len(aFlds)// verifica se não há campos nulos
				If ! aFlds[nX] == nil 
					If aFlds[nX][2] == 'M'// se o campo for do tipo memo o mesmo é removido do array
						aDel( aFlds,nX)//remove o campo do array
					EndIf
				EndIf	
			Next nX
			aSize(aFlds, --nFldsTam)//pra diminuir o tamanho do aFlds
		EndIf	
		For nI := 1 to len(aFlds)
			nCt2 := nCt2 + 1
			//Define os Indices
			//FWTemporaryTable():AddIndex( <cIndexName>, {<aFields>} )
			If nCt2 > 36
				nCt1 := nCt1 + 1
				nCt2 := 1
			EndIf

			cIdxNome := StrTran(cAliasTab,  "SCGN", "") + aAlfa[nCt1] + aAlfa[nCt2] 
			oTempTab:AddIndex(cIdxNome, {allTrim(aFlds[nI][1])} )
		Next nI
	EndIf

	oTempTab:Create()

	VArinfo("", aArrStr) 

	cTblTmpName := oTempTab:GetRealName()

	If !(lRetObj)
		Return cAliasTab
	endIf

Return oTempTab

Function AGRDLTPTB(oTempTable, aOtheAlias, lNil)
	Local cFileTmp  := ""
	Local cAliasTmp := ""
	Local aNmIndice := {}
	Local nI        := 0
	Local cOtAlias  := ""
	Default aOtheAlias := {}
	Default lNil := .F.

	If ( IsV12("12.1.005") )  //Se chamada na V12 
		If .NOT.(Empty( oTempTable ))
			cAliasTmp := oTempTable::GetAlias()
			If (!Empty(cAliasTmp)) .AND. (Select(cAliasTmp) > 0)
				(cAliasTmp)->(dbCloseArea())
			EndIf

			If !(Empty(aOtheAlias))
				For nI := 1 to len(aOtheAlias)
					cOtAlias := aOtheAlias[nI] 
					If (!Empty(cOtAlias)) .AND. (Select(cOtAlias) > 0)
						(cOtAlias)->(DbCloseArea())
					EndIf
				Next nI
			EndIf         

			oTempTable:Delete()
			oTempTable := Nil
		EndIf  
	Else
		If .NOT.(Empty( oTempTable ))
			cFileTMP  := oTempTable[1]
			cAliasTmp := oTempTable[2]
			aNmIndice := oTempTable[3]

			If (!Empty(cAliasTmp)) .AND. (Select(cAliasTmp) > 0)
				(cAliasTmp)->(DbCloseArea())
			EndIf

			If !(Empty(aOtheAlias))
				For nI := 1 to len(aOtheAlias)
					cOtAlias := aOtheAlias[nI] 
					If (!Empty(cOtAlias)) .AND. (Select(cOtAlias) > 0)
						(cOtAlias)->(DbCloseArea())
					EndIf
				Next nI
			EndIf

			FErase(cFileTMP+GetDBExtension())
			For nI := 1 to Len(aNmIndice)
				FErase(aNmIndice[nI]+OrdBagExt())
			Next nI
		EndIf   
	EndIf   

	//Deletar temp Table
	If lNil 
		oTempTable := NIL
	EndIF

Return .T.

/*------------------------------------------------------------------------
Busca o Nome do indice na clase fwTemporaryTable
[1] Objeto fwTemporaryTable
[2] Nome do Alias
-------------------------------------------------------------------------*/
Function GetIdxNome(oTempTable, cIdx)
	//TMPSCAEG680_21_41741
	//INDEX TMPSCAEG680SCGN000004A_21_41741

	Local cTblRealName := oTempTable:GetRealName()
	Local cNomeIdx     := ""
	Local i := 0
	Local p := 0
	Local c := ""

	For i := 1 to len(cTblRealName)
		c := SubStr(cTblRealName, i, 1)
		If (c == "_")
			p := i
			exit
		EndIf
	Next i

	cNomeIdx := SubStr(cTblRealName, 1 , p-1) + StrTran(cIdx, "SCGN", "") + SubStr(cTblRealName, p) 

Return cNomeIdx


Function IsV12(cVersao, lAlert)
	Local cRpoRelease := GetRpoRelease()
	Local nTam        := 0
	Local cVrs        := ""
	Local cRpo        := ""
	Local lRet        := .F.
	Local cRet        := ""
	Local nVer        := 0

	Default cVersao   := ""
	Default lAlert    := .F.

	nTam        := Len(cVersao)
	cVrs        := cVersao

	//V11
	If ("R" $ cRpoRelease)
		If !Empty(cVersao)
			If ("12" == Left(cVersao, 2) )
				lRet := .F.
			Else
				lRet := (cRpoRelease >= cVersao)
			EndIf
		Else
			cRet := cRpoRelease
			Return (cRet)
		EndIf
	Else 
		If ("12" $ cRpoRelease) 
			If !Empty(cVersao)
				cRpo := StrTran(cRpoRelease, ".", "")
				nRpo := Val(cRpo)
				cVrs := StrTran(cVersao, ".", "")

				If Len(cVrs) = 2
					nVer  := Val(cVrs + "0" + "000") 
				ElseIf (Len(cVrs) > 2) .AND. (Len(cVrs)<= 3)
					nVer  := Val(cVrs + "000")
				Else 
					If (Len(cVrs) == 6)
						nVer := Val(cVrs)
					Else 
						cMsg := "Versão Inválida"
					EndIf
				EndIf

				lRet := (nRpo >= nVer)
			Else
				//Retorna a versão do RPO
				cRet := cRpoRelease 
			EndIf
		Else
			lRet := .F.
		EndIf 
	EndIf

	If lAlert
		Alert("Versão do RPO:" + cRpo)      
	EndIf

	If !Empty(cVersao)
		Return (lRet)    
	Else
		Return (cRet)
	EndIf

return .T.


/*-------------------------------------------------------------------
{Protheus.doc} AGRIsNum
Verifica se e uma string numerica

@author carlos.augusto
@since 27/02/2017
-------------------------------------------------------------------*/
Function AGRIsNum(cVarTemp)
	Local nPos
	Local nLen
	cVarTemp	:=	AllTrim( cVarTemp )
	nLen		:=	Len( cVarTemp )
	For nPos := 1 to nLen
		If !IsDigit( Substr( cVarTemp, nPos, 1 ) )
			Return .F.
		EndIf
	Next
Return .T.

/*-------------------------------------------------------------------
{Protheus.doc} AGRGerPic
Gera picture numerica de acordo com tamanho e precisao passados por parametro

@author carlos.augusto
@since 28/03/2017
-------------------------------------------------------------------*/
Function AGRGerPic(nTamTotal, nTamPrec, lTxt)
	Local aPict		:= {}
	Local nTam		 
	Local cPicture	:= "@E "
	Local nRestDiv
	Local lRet 		:= .T.
	Local nX
	Default lTxt	:= .F.

	Do Case

		Case Valtype(nTamTotal) != 'N' .Or. Valtype(nTamPrec) != 'N'
		lRet := .F.
		aAdd(aPict, .F.)
		aAdd(aPict, "")
		aAdd(aPict, "O método aceita valores numericos.")

		Case lRet .And. (nTamTotal < nTamPrec)
		lRet := .F.
		aAdd(aPict, .F.)
		aAdd(aPict, "")
		aAdd(aPict, "O tamanho total recebido esta com valor inferior ao valor da precisao.")

		Case lRet .And. (nTamTotal <= 0 .Or. nTamTotal > 16)
		lRet := .F.
		aAdd(aPict, .F.)
		aAdd(aPict, "")
		aAdd(aPict, "O tamanho total invalido.")

		Case lRet

		//Está sendo diminuido 1 do total pois virgula conta como uma posição na mascara
		If lTxt
			nTamTotal -= 1
		EndIf    
		nTam 	 := nTamTotal - nTamPrec
		nRestDiv := Mod(nTam,3)
		For nX := 1 To nTam

			If nX == 1
				If nRestDiv = 1 
					cPicture += '9'
				ElseIf nRestDiv = 2
					cPicture += '99'
				ElseIf nRestDiv == 0
					cPicture += '999'
				EndIf 
			EndIf
			If nX != 1 
				cPicture += '999'
			EndIf
			nX += 2 
			If nX < nTam
				cPicture += IIF(lTxt,"", ",")
			EndIf
		Next nX

		If nTamPrec != 0
			cPicture += "."
			cPicture := PadR(cPicture, Len(cPicture)+nTamPrec, "9")
		EndIf
		aAdd(aPict, .T.)
		aAdd(aPict, cPicture)
		aAdd(aPict, "Picture gerada com sucesso.")

	EndCase

	If Empty(aPict)
		aAdd(aPict, .F.)
		aAdd(aPict, "")
		aAdd(aPict, "Erro nao tratado.")
	EndIf

Return aPict

/*-------------------------------------------------------------------
{Protheus.doc} AGRPIV
- Função utilizada para a PictureVar dos campos De e Ate, de Grids
que possuem o campo HVI como referencia para alteração das PVars.
- Retorna a a picture referente ao campo HVI, presente na
grid contendo os campos De e Ate.
- Função utilizada para alterar a picture dos campos De e Ate
com base no campo HVI presente na mesma Grid
@param cCampo: Nome do campo hvi que contem o nome do campo do layout hvi
Exemplo: N7H_CAMPO da tabela N7H onde contem o nome dos campos da tabela
DX7, conforme o layout
@author roney.maia
@since 29/05/2017
-------------------------------------------------------------------*/
Function AGRPIV(cCampo)
Return Iif(Empty(FwFldGet(cCampo)), "@E", PesqPict("DX7", FwFldGet(cCampo)))

/*-------------------------------------------------------------------
{Protheus.doc} AGRHVI
Exibe browse. Consulta especifica DX7ES1
@author silvana.torres
@since 29/05/2017
*/
Function AGRHVI()
	Local aArea     	:= GetArea()
	Local oDlg	    	:= Nil
	Local oPnDown   	:= Nil
	Local oSize     	:= Nil
	Local lRet      	:= .T.	 	       
	Local aFieFilter 	:= {}   		
	Local aSeek 		:= {}	
	Local oBrwHVI		

	Private _aColumns 	:= {}
	Private cCmpHVI     := ReadVar()

	__cRet 		:=''
	__cAliasH 	:= GetNextAlias()

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1]/1.55, oSize:aWindSize[2]/1.55, oSize:aWindSize[3]/1.55, oSize:aWindSize[4]/1.55,;
	STR0256 , , , , , CLR_BLACK, CLR_WHITE, , , .t. )

	oPnDown := TPanel():New( oSize:GetDimension("ALL","LININI"), oSize:GetDimension("ALL","COLINI"),;
	,oDlg, ,.F. , , , ,oSize:GetDimension("ALL","COLEND")/1.57, oSize:GetDimension("ALL","LINEND")/1.90)

	//Cria tabela temporaria para browse HVI
	__cAliasH := CriaTTmpH(@_aColumns , @__cAliasH)

	Aadd(aFieFilter,{"TITULO"   , STR0257   , "C"  , 10  , 0  ,"@!" })    

	Aadd(aSeek,{STR0257 ,{{"", 'C' , 10 , 0 , "@!" }}, 1, .T. } )

	oBrwHVI := FWMBrowse():New()

	oBrwHVI:SetProfileID(STR0256)
	oBrwHVI:SetTemporary(.T.)	
	oBrwHVI:SetAlias(__cAliasH)
	oBrwHVI:SetDescription(STR0256)
	oBrwHVI:SetSeek(.T.,aSeek)
	oBrwHVI:SetColumns(_aColumns)
	oBrwHVI:SetOwner(oDlg)	
	oBrwHVI:DisableDetails()
	oBrwHVI:SetDoubleClick( {|| selecHVI(), oDlg:End() })		
	oBrwHVI:SetUseFilter(.T.)
	oBrwHVI:SetUseCaseFilter(.T.)	
	oBrwHVI:SetFieldFilter(aFieFilter)
	oBrwHVI:SetdbFFilter(.T.)
	oBrwHVI:SetMenuDef("")

	oBrwHVI:Activate(oPnDown)

	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar(oDlg,{|| selecHVI(), oDlg:End()},{||cancelHVI(), oDlg:End() },,/* @aButtons */) } )

	RestArea(aArea)

Return lRet


/*-------------------------------------------------------------------
{Protheus.doc} CriaTTmpH
Cria tabela temporaria para browse da consulta de HVI
@param:  _aColumns, __cAliasH
@author: silvana.torres
@since:  29/05/2017
------------------------------------------------------------------ */
Static Function CriaTTmpH(_aColumns , __cAliasH)
	Local aCampos 	:= {'CAMPO','TITULO' }
	Local nX
	Local aIndices 	:= {}
	Local aCampIni2 := {}

	//Definindo as colunas do Browse	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))

	AAdd(_aColumns,FWBrwColumn():New())
	_aColumns[Len(_aColumns)]:SetData( &("{||"+'TITULO'+"}"))
	_aColumns[Len(_aColumns)]:SetTitle(STR0257)
	_aColumns[Len(_aColumns)]:SetSize(10)
	_aColumns[Len(_aColumns)]:SetDecimal(0)
	_aColumns[Len(_aColumns)]:SetPicture("")
	_aColumns[Len(_aColumns)]:SetAlign( "LEFT" )//Define alinhamento	

	//Limpando temp Table
	If __oArqTemp <> Nil
		AGRDLTPTB(@__oArqTemp, NIL, .T.)
	EndIf

	//Definindo as colunas na temp table		 	
	For nX := 1 To Len(aCampos)
		AADD(aCampIni2,{aCampos[nX], "C",10,0})
	Next nX	

	aAdd(aIndices, {"", "TITULO" })

	__oArqTemp  := AGRCRTPTB(__cAliasH, {aCampIni2, aIndices },,,,.F. )	

	__cAliasH := CamposHVI( @__cAliasH )

Return __cAliasH

/*-------------------------------------------------------------------
{Protheus.doc} CamposHVI
Insere os campos HVI na temporária
@param: __cAliasH
@author: silvana.torres
@since: 29/05/17
@Uso: UBAA060
-------------------------------------------------------------------*/
Static Function CamposHVI( __cAliasH )

	Local aNoCpos	:= {{"DX7_MIC"},{"DX7_RES"},{"DX7_FIBRA"},{"DX7_UI"},{"DX7_SFI"},{"DX7_ELONG"},{"DX7_LEAF"},{"DX7_AREA"},{"DX7_CSP"},{"DX7_CG"},{"DX7_MAISB"},;
	{"DX7_RD"},{"DX7_COUNT"},{"DX7_UHM"},{"DX7_SCI"},{"DX7_MATU"}}
	Local oHash  	:= Nil
	Local oView	    := FwViewActive()
	Local nIt		:= 0
	Local nItA		:= 0
	Local oGrid	    := Nil
	Local nX	    := 0
	Local vVetCamp  := {}

	If IsInCallStack("AGRA640")
		aAdd(aNoCpos, {"DX7_ETIQ"})
		aAdd(aNoCpos, {"DX7_DATREC"})
		aAdd(aNoCpos, {"DX7_HORREC"})
		aAdd(aNoCpos, {"DX7_DATENV"})
		aAdd(aNoCpos, {"DX7_HORENV"})
	EndIf

	// Lógica utilizada somente para trazer os campos necessarios da consulta na rotina AGRX720
	If ValType(oView) != "U" .AND. oView:GetModel():GetId() == "AGRX720"
		oGrid := oView:GetModel():GetModel("N7HSUBMODEL")
		For nIt := 1 To oGrid:Length()
			For nItA := 1 To Len(aNoCpos)
				If ALLTRIM(oGrid:GetValue("N7H_CAMPO", nIt)) == aNoCpos[nItA][1] 
					aDel(aNoCpos, nItA)
					aSize(aNoCpos, Len(aNoCpos) - 1)
					Exit
				EndIf 
			Next nItA 
		Next nIt
	EndIf

	oHash := aToHM(aNoCpos)

	vVetCamp := FWSX3Util():GetAllFields( 'DX7' , .F. ) //Retorna os campos de um alias específico da SX3 - http://tdn.totvs.com/x/Agu2Fg

	For nX := 1 To Len(vVetCamp)

		If X3USADO(vVetCamp[nX]) .AND. HMGet( oHash , Alltrim(vVetCamp[nX]),  ) //procura dentro do hashmap

			Reclock(__cAliasH, .T.)
			Replace (__cAliasH)->CAMPO  With vVetCamp[nX]
			Replace (__cAliasH)->TITULO With RetTitle(vVetCamp[nX])		

			(__cAliasH)->(MsUnlock())

		EndIf

	Next nX


Return __cAliasH

/*-------------------------------------------------------------------
{Protheus.doc} AGRRetHVI
//Retorno da Consulta especifica DX7ES1
@author silvana.torres
@since 29/05/2017
@type function
-------------------------------------------------------------------*/	
Function AGRRetHVI()

Return(__cRet)

/*-------------------------------------------------------------------
{Protheus.doc} cancelHVI
//Ação do botão cancelar da Consulta especifica DX7ES1
@author silvana.torres
@since 01/06/2017
@type function
-------------------------------------------------------------------*/
Function cancelHVI()

	Local oModel	:= FWModelActive()

	If IsInCallStack("UBAA060") .Or. IsInCallStack("UBAA080")
		__cRet := oModel:GetValue('MdGrdN81HVI', 'N81_CODREG') 		
	endIf

	If  oModel:GetId() $ "OGA290|OGA280|AGRX720"
		If "N7H_HVIDES" $ cCmpHVI // Se a consulta foi acionada pelo campo N7H_DESHVI
			If oModel:GetId() == "OGA290"
				__cRet := oModel:GetModel("N7HUNICO"):GetValue("N7H_HVIDES")
				Return .T.
			ElseIf oModel:GetId() == "AGRX720"
				__cRet := ""
				Return .T.
			EndIf
		ElseIf "N7F_HVIDES" $ cCmpHVI // Se a consulta foi acionada pelo campo N7F_HVIDES
			If oModel:GetId() == "OGA290"
				__cRet := oModel:GetModel("N7FUNICO"):GetValue("N7F_HVIDES")
				Return .T.
			EndIf
		ElseIf "N78_HVIDES" $ cCmpHVI // Se a consulta foi acionada pelo campo N78_HVIDES       
			If oModel:GetId() == "OGA290"
				__cRet := oModel:GetModel("N78HVI"):GetValue("N78_HVIDES")
				Return .T.
			EndIf
		EndIf
	EndIf

Return(.T.)

/*-------------------------------------------------------------------
{Protheus.doc} selecHVI
//Ação do botão OK da Consulta especifica DX7ES1
@author silvana.torres
@since 01/06/2017
@type function
-------------------------------------------------------------------*/
Function selecHVI()

	Local oModel      := FWModelActive()
	Local oView       := FWViewActive()

	If IsInCallStack("UBAA060") .Or. IsInCallStack("UBAA080")
		__cRet := (__cAliasH)->TITULO
		oModel:LoadValue('MdGrdN81HVI', 'N81_CODREG',  IIF(Len((__cAliasH)->TITULO) > 0, (__cAliasH)->TITULO,"") )
		oModel:LoadValue('MdGrdN81HVI', 'N81_CAMPO',  IIF(Len((__cAliasH)->CAMPO) > 0, (__cAliasH)->CAMPO,"") )
	ElseIf IsInCallStack("AGRA640")
		__cRet := (__cAliasH)->TITULO
		oModel:LoadValue('ITEM_HVI', 'DX2_CAMPO', (__cAliasH)->CAMPO)
		oModel:LoadValue('ITEM_HVI', 'DX2_NOME',  (__cAliasH)->TITULO)
	Endif

	If oModel:GetId() $ "OGA290|OGA280|AGRX720"
		__cRet := (__cAliasH)->TITULO
	EndIf

	If oModel:GetId() $ "OGAA940"
		__cRet := (__cAliasH)->CAMPO
		oModel:LoadValue('NL9UNICO', 'NL9_DESHVI', (__cAliasH)->TITULO)
		oModel:LoadValue('NL9UNICO', 'NL9_CODHVI', AllTrim((__cAliasH)->CAMPO))

	EndIf

	SX3->(dbSetOrder(2))
	SX3->(dbSeek((__cAliasH)->CAMPO))

	If !oModel:GetId() $ "OGA290|OGA280|AGRX720" // não aplica o refresh para as rotinas oga290 e oga280            
		oView:Refresh()
	EndIf
Return(.T.)



/** ------------------------------------------------------------------------------------------
{Protheus.doc} GetSqlAll
Retorna um Alias com uma consulta
@param: cSqL = Consulta SQL para buscar informaçao diretamente no banco de dados
lChange = executar a instrução Changequery
@Retorno: cAliasTmp = Retorna o alias com os respectivos dados da consulta
@author: Marcelo R. Ferrari
@since: fev/2017
@Uso: SIGAAGR
------------------------------------------------------------------------------------------ **/
Function GetSqlAll(cSql, lChange)	
	Local cAliasTmp := GetNextAlias()
	Local aStrut := {}

	Default lChange := .T.

	If lChange
		cSql := ChangeQuery(cSql)
	EndIf

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAliasTmp, .F., .T.)	

	dbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbGoTOp())

	aStrut:= (cAliasTmp)->(DBStruct())

Return cAliasTmp

/* 
+=================================================================================================+
| Função    : AGRMVMOEDA                                                                            |
| Descrição : Busca a descricao da moeda na tabela de parametros                                  |
| Autor     : Marcelo R. Ferrari                                                                  |
| Data      : 04/10/2017                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: nMoeda. Obrigatório                                                                 |
+=================================================================================================+
| Retorna   : Descricao da respectiva moeda em MV_MOEDA?                                          |
+=================================================================================================+  
*/
Function AGRMVMOEDA(nMoeda)
	Local cRet := ""
	If !Empty(nMoeda)
		cRet := SuperGetMv("MV_MOEDA"+AllTrim(Str(nMoeda,2)), .F., "" )	
	Endif

Return cRet

/* 
+=================================================================================================+
| Função    : AGRMVSIMB                                                                            |
| Descrição : Busca o simbolo da moeda na tabela de parametros                                  |
| Autor     : Marcelo R. Ferrari                                                                  |
| Data      : 04/10/2017                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: nMoeda. Obrigatório                                                                 |
+=================================================================================================+
| Retorna   : Descricao da respectiva moeda em MV_MOEDA?                                          |
+=================================================================================================+  
*/
Function AGRMVSIMB(nMoeda)
	Local cRet := ""
	If !Empty(nMoeda)
		cRet := SuperGetMv("MV_SIMB"+AllTrim(Str(nMoeda,2)), .F., "" )
	Endif

Return cRet


/* 
+=================================================================================================+
| Função    : AGRMesAno                                                                           |
| Descrição : Converte uma entrada de mes e ano em vários formatos                                |
| para uma saída em MMM/AAAA OU MM/AAAA                                                           |
|FORMATOS DE ENTRADA: mmaaaa,mm/aaaa,mm-aaaa mmmaaaa,mmm/aaaa,mmm-aaaa                            |
|	                  aaaamm,aaaa/mm,aaaa-mm  aaaammm,aaaa/mmmm, aaaa-mmmm                        | 
| Data      : 04/10/2017                                                                          |
+=================================================================================================+                                                                           |  
| Parâmetros: cMA    : Texto, MesAno, obrigatório                                                 |
cTipo  : Texto, 0 ou 1(padrão), indica o tipo de retorno mm|mmm/aaaa                |
+=================================================================================================+
| Retorna   : Retorna o mes e ano de acordo com o tipo                                            |
+=================================================================================================+  
*/
Function AGRMesAno(cMA, cTipo)
	//Formatos permitidos
	//mmaaaa,mm/aaaa,mm-aaaa mmmaaaa,mmm/aaaa,mmm-aaaa
	//aaaamm,aaaa/mm,aaaa-mm  aaaammm,aaaa/mmmm, aaaa-mmmm

	Local cRet   := ""
	//Local oModelN79	:= oView:GetModel():GetModel("N79UNICO")
	//Local cMesAno   := oModelN79:GetValue("N79_VMESAN")
	Local cMesAno   := cMA
	Local aMesesBr  := StrToKArr("JAN,FEV,MAR,ABR,MAI,JUN,JUL,AGO,SET,OUT,NOV,DEZ" , ",")
	Local cMesesTr  := STR0258 //"JAN,FEV,MAR,ABR,MAI,JUN,JUL,AGO,SET,OUT,NOV,DEZ"
	Local aMesesTr  := {}  
	Local nTam      := 0
	Local nSep      := 0
	Local cV1       := ""
	Local cV2       := ""
	Local cMes      := ""
	Local cAno      := ""
	Local nMes      := 0 

	Default cTipo := '1'

	If Empty(cMesAno)
		Return cRet
	EndIF

	nTam      := len(AllTrim(cMesAno))
	If nTam < 6   // 12017 ou 20172  => 012017 ou 201702
		Return "000000"
	EndIf

	aMesesTr  := StrToKArr(cMesesTr, ",")

	nSep := At("/", cMesAno)   //Procura separador de data /
	If nSep = 0
		nSep := At("-", cMesAno)   //Procura separador de data /  
	EndIf

	IF nSep > 0
		cV1 := SubStr(cMesAno, 1, nSep -1)
		cV2 := AllTrim(SubStr(cMesAno, nSep +1))

		If isNumeric(cV1)
			If len(cV1) == 2  //Mês numérico
				cMes  := aMesesTR[val(cV1)]
				nMes := Val(cV1)
				If nMes == 0 .OR. nMes > 12 
					Return "000000"
				EndIf
				cAno := cV2
			ElseIf len(cV1) == 4   //Ano   2017/FEB
				if isNumeric(cV2)
					nMes := Val(cV2)
					If nMes == 0 .OR. nMes > 12 
						Return "000000"
					EndIf 
				else
					nMes := aScan(aMesesBr, cV2)
					if nMes == 0
						nMes := aScan(aMesesTr, cV2)
					endif
				endif
				If nMes == 0 
					Return "000000"
				Else
					cMes := aMesesTr[nMes]
					cAno := cV1
				EndIf
			EndIf
		Else	
			If len(cV1) == 3 //Mes abreviado
				nMes := aScan(aMesesBr, cV1)
				If nMes != 0
					cMes := aMesesTr[nMes]
				Else
					nMes := aScan(aMesesTr, cV1)
					If nMes != 0
						cMes := aMesesTr[nMes] 
					Else
						Return "000000"
					EndIf
				EndIf
				if IsNumeric(SubStr(cV2, 2, 4))
					cAno := cV2
				Else
					Return cRet := "000000"
				Endif
			EndIF
		Endif

	ELSE  //Sem separador

		If SubStr(cMesAno, 1, 2) >= "19" //Se iniciar com 20 então anomes
			cAno := SubStr(cMesAno, 1, 4)
			cMes := AllTrim(SubStr(cMesAno, 5))
			if IsNumeric(cMes)
				nMes := Val(cMes)

				If nMes <= 12 .AND. nMes != 0
					cMes := aMesesTr[nMes]
				Else
					Return cMes := "000000" 
				EndIf
			else
				//Identifica o número do mês 
				nMes := aScan(aMesesBr, cMes)
				if nMes = 0    //Se o nome for diferenet de JAN,FEV,MAR...
					nMes := aScan(aMesesTr, cMes)  //Vefifica pela tradução 
				endIF
				if nMes = 0  
					Return cRet := "000000"
				Else
					cMes := aMesesTr[nMes]  //Obtém  o nome do mês traduzido
				endIF
			endIf

		Else
			If SubStr(cMesAno, 1, 2) >= "19"
				if IsNumeric(SubStr(cMesAno, 1, 2))
					nMes := Val(SubStr(cMesAno, 1, 2))
					cMes := aMesesTr[nMes]  //Obtém  o nome do mês traduzido 
					cAno := AllTrim(SubStr(cMesAno, 3))
				else
					cMes := SubStr(cMesAno, 1, 3)
					cAno := AllTrim(SubStr(cMesAno, 4))
					//Identifica o número do mês 
					nMes := aScan(aMesesBr, cMes)
					if nMes = 0    //Se o nome for diferenet de JAN,FEV,MAR...
						nMes := aScan(aMesesTr, cMes)  //Vefifica pela tradução 
					endIF
					If nMes == 0
						Return "000000"
					EndIf
					If nMes <= 12 .AND. nMes != 0
						cMes := aMesesTr[nMes]
					Else
						Return cMes := "000000" 
					EndIf
				endIf
			EndIf   
		EndIf
	ENDIF

	//Retorno para gravação do valor 
	If cTipo = 1
		cRet := AllTrim(cMes) + "/" + AllTrim(cAno)
	Else
		cRet := AllTrim(cAno) + StrZero(nMes, 2)  
	EndIf

Return cRet

/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGRTABDIC
Verifica se o array de tabelas existi no dicionario de dados
@param: aTab = Array com as tabelas para verificar se existem no dicionario
@Retorno: lRet = Retorna true se todas as tabelas do array exixtirem no dicionario, senão retorna false
@author: Claudineia H. Reinert
@since: 11/2017
@Uso: SIGAAGR
------------------------------------------------------------------------------------------ **/
Function AGRTABDIC(aTab)
	Local lRet := .F.
	Local nX := 0
	For nX := 1 to Len( aTab )
		If !TableInDic(aTab[nX])
			lRet := .F.
			Exit
		EndIf
		lRet := .T.
	Next nX

Return lRet



/*
{Protheus.doc} AGRSql2Trb
Executa a query específica e carrega os dados na tabela temporária
@sample
AGRSql2Trb(cQuery, aStruTmp, cAliasTmp, lChangeQuery, lAddNil )
cQuery = Consulta SQL que será executada
aStruTMP = Array com a estrutura dos campos do SQL
cAliasTmp = Alias da tabela temporária que será gravado os dados
lChangeQuery = Indica se o comando ChageQuery deve ser executado.
Em caso de houver subselects dentro da instrução SELECT
principal o ChangeQuery provoca um erro devido a posiçao do
primeiro FROM .
lAddNil = Inclui um registro em branco na tabela temporária.
Isso é utilizado quando o grid deve ter um registro par apresentar
mesmo que seja em branco. (ver agra870a)
@author Marcelo R. Ferrari
@since 20/11/2016
@version 1.0
*/
Function AGRSql2Trb( cQuery, aStruTmp, cAliasTmp, lChangeQuery, lAddNil )
	Local nI        := 0
	Local nJ        := 0
	Local nF        := 0
	Local nTotalRec := 0
	Local aStruQry  := {}
	Local nCnt      := 0
	Default lChangeQuery := .T.
	Default lAddNil      := .T.

	IF lChangeQuery
		cQuery := ChangeQuery(cQuery)
	EndIF
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP", .F., .T.)
	For nJ := 1 to Len(aStruTmp)
		If !(aStruTmp[nJ,2] $ 'CM')
			//TCSetField() -> Altera o tratamento, do tipo de dado ou precisão, para um campo/coluna retornada através de uma query.
			TCSetField("TMP", aStruTmp[nJ,1], aStruTmp[nJ,2],aStruTmp[nJ,3],aStruTmp[nJ,4])
		EndIf
	Next nJ
	nTotalRec:= TMP->(RecCount())
	aStruQry := TMP->(DbStruct())
	nF            := Len(aStruQry)
	TMP->(DbGoTop())
	ProcRegua( nTotalRec )
	While ! TMP->(Eof())
		nCnt := nCnt + 1
		IncProc()
		(cAliasTmp)->(DbAppend())
		For nI := 1 To nF
			If (cAliasTmp)->(FieldPos(aStruQry[nI,1])) > 0     .And. aStruQry[nI,2] <> 'M'
				(cAliasTmp)->(FieldPut(FieldPos(aStruQry[nI,1]), TMP->(FieldGet(TMP->(FieldPos(aStruQry[nI,1] ) ) ) ) ) )
			Endif
		Next nI
		TMP->(DbSkip())
	End

	If lAddNil .AND. nCnt == 0
		(cAliasTmp)->(DbAppend())
		For nI := 1 To nF
			If (cAliasTmp)->(FieldPos(aStruQry[nI,1])) > 0     .And. aStruQry[nI,2] <> 'M'
				If aStruQry[nI,2] = 'N'
					(cAliasTmp)->(FieldPut(FieldPos(aStruQry[nI,1]), 0 ) )
				Else
					(cAliasTmp)->(FieldPut(FieldPos(aStruQry[nI,1]), "" ) )
				EndIF
			Endif
		Next nI
	EndIf

	TMP->(dbCloseArea())
	DbSelectArea(cAliasTmp)
Return Nil

/** ------------------------------------------------------------------------------------------
{Protheus.doc} GetDataSql
Retorna um Alias com base em uma consulta
@param: cSqk = Consulta SQL para buscar informaçao diretamente no banco de dados
@author: Marcelo R. Ferrari
@since: fev/2017
@Uso: SIGAAGR
------------------------------------------------------------------------------------------ **/
Function GetDataSql(cSql, lChange)
	Local uRet := NIL
	Local cAliasTmp := GetNextAlias()
	Local aStrut := {}

	Default lChange := .T.


	If lChange
		cSql := ChangeQuery(cSql)
	EndIf

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAliasTmp, .F., .T.)	

	dbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbGoTOp())

	aStrut:= (cAliasTmp)->(DBStruct())

	uRet := (cAliasTmp)->&(aStrut[1][1])
	(cAliasTmp)->(DbcloseArea())

Return uRet


/** ------------------------------------------------------------------------------------------
{Protheus.doc} GetDataSqA
Retorna um Vetor com base em uma consulta.
O vetor retorna os valores na posicao das colulas da consulta
@param: cSql = Consulta SQL para buscar informaçao diretamente no banco de dados
@author: Marcelo R. Ferrari
@since: NOV/2018
@Uso: SIGAAGR
------------------------------------------------------------------------------------------ **/
Function GetDataSqA(cSql, lChange)
	Local aRet := {}
	Local cAliasTmp := GetNextAlias()
	Local aStrut := {}
	Local nX     := 0

	Default lChange := .T.

	If lChange
		cSql := ChangeQuery(cSql)
	EndIf

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAliasTmp, .F., .T.)	

	dbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbGoTOp())

	aStrut:= (cAliasTmp)->(DBStruct())

	for nX := 1 to len(aStrut)
		aAdd(aRet, (cAliasTmp)->&(aStrut[nX][1]) )
	Next nX
	(cAliasTmp)->(DbcloseArea())

Return aRet

/*/{Protheus.doc} IsSelected
//Função para verificação de existencia de registro selecionado
@author bruna.rocio
@since 04/04/2017
@version undefined
@param cAliasGrid, characters, descricao
@param oGrid, object, descricao
@type function
/*/
Function AGRIsSelec( cAliasGrid, oGrid )
	Local aArea := GetArea()
	Local lRet  := .F.

	dbSelectArea(cAliasGrid)
	dbGoTop()

	While .Not. Eof()	

		If oGrid:IsMark()
			lRet := .T.
			Return lRet
		Endif

		DbSkip()
	EndDo	

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} AGRColPos
//Função para verificação da existencia de campos novos 
//proteção de fonte 12.1.017-outubro
//columnsPos não esta funcionando
@author claudineia.reinert
@since 16/10/2017
@version undefined
@param cCampo, characters, descricao
@type function
/*/
Function AGRColPos(cCampo)
	Local lRet := .F.
	//Atualiza tamanho 	
	DbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	if SX3->(DbSeek(cCampo))
		lRet := .T.
	EndIf

Return lRet


/*/{Protheus.doc} F3MODINCLUI
@Description Essa função foi criada para ser chamada via consulta padrão e o retorno dela é o parâmetro 
de acesso ao modulo enviado
@author felipe.mendes
@param 	cFuncao - Funcao de inclusão 
cModulo - Modulo de inclusão
@since 12/01/2018
@version undefined
@type function
/*/
Function F3MODINCLUI(cFuncao,cModulo)
	Default cModulo := "29" // Modulo EEC

Return &("01#(nModulo := "+cModulo+", SetMBrExecute(3), "+cFuncao+"(), nModulo := 67)")


/*/{Protheus.doc} AGRUTILHR
//Logica importada do GFE - GFEVLDHR()
@author carlos.augusto
@since 08/03/2018
@version undefined
@param cHora, characters, hora para validacao "08:30" ou "0830"
@type function
/*/
Function AGRUTILHR(cHora)

	If At(":", cHora) > 0
		cHora := AllTrim(StrTran(cHora, ":", ""))
	EndIf

	If !(SubStr(cHora,1,2) <= "23" .And. SubStr(cHora,1,2) >= "00" .And. SubStr(cHora,3,2) <= "59" .And. SubStr(cHora,3,2) >= "00") .Or. ;
	Len(AllTrim(cHora)) < 4 .Or. Len(AllTrim(SubStr(cHora,1,2))) != 2 .Or. Len(AllTrim(SubStr(cHora,3,2))) != 2
		Help( ,, STR0021,, STR0259, 1, 0,) //Atencao"Hora inválida."
		Return .F.
	EndIf

	Return .T.

	/*/{Protheus.doc} AGRUTILUN()
	Valida o valor digitado no campo NJR_CTREXT que não pdoe se repetir
	@type  Function
	@author rafael.kleestadt
	@since 28/03/2018
	@version 1.0
	@param param, param_type, param_descr
	@return lRet, Logycal, True or False
	@example
	(examples)
	@see (links_or_references)
	/*/
Function AGRUTILUN()
	Local lRet     := .T.
	Local aAreaNJR := {}

	aAreaNJR := NJR->(GetArea())

	DbSelectArea("NJR")
	NJR->(DbSetOrder(7))
	If NJR->(DbSeek(xFilial("NJR") + FwFldGet("NJR_CTREXT")))
		Help( , , STR0260, , STR0261 + NJR->NJR_CODCTR, 1, 0 ) //"Ajuda" ## "O contrato externo já está sendo usado no contrato nº: " 
		Return .F.
	EndIf

	RestArea(aAreaNJR)

Return lRet



/*/{Protheus.doc} AGRTITULO2
//Retorna a descricao do campo solicitado. Paleativo para Sonar
//Sugestao de melhoria em http://jiraproducao.totvs.com.br/browse/DFRM1-9333
@author carlos.augusto
@since 24/04/2018
@version undefined
@param cCampo, characters, descricao
@param cTable, characters, descricao
@type function
/*/
Function AGRTITULO2(cCampo, cTable)
	Local oStrX			:= FwFormStruct( 1, cTable )	
	Local aCposX		:= oStrX:GetFields()
	Local aAreaTL		:= GetArea()
	Local nX
	Local cDescricao	:= Space(TamSX3(cCampo)[1])

	For nX := 1 to len(aCposX)
		If AllTrim(cCampo) == AllTrim(aCposX[nX][3])	
			cDescricao := aCposX[nX][1]
			exit
		EndIf
	Next nX	

	RestArea(aAreaTL)
Return cDescricao


/*/{Protheus.doc} AGRRomDoAg
Retorna o númedo do Agendamento do Agro(Romaneio) a partir do agendamento do GFE 
@author silvana.torres
@since 18/05/2018
@version undefined
@param cNrAgen, characters, número do agendamento do GFE
@type function
/*/
Function AGRRomDoAg(cNrAgen)

	Local aRet		:= {}
	Local aAreaAtu 	:= {}

	aAreaAtu := GetArea()

	DbSelectArea("NJJ")	

	NJJ->(DbSetOrder(4))

	If NJJ->(MsSeek(FwxFilial("NJJ") + cNrAgen))
		Aadd(aRet,NJJ->NJJ_CODROM)
		Aadd(aRet,NJJ->NJJ_TOETAP)		
	EndIf
	NJJ->(DbCloseArea())

	RestArea(aAreaAtu)

Return aRet

/*/{Protheus.doc} AGRXPERGROM
//TODO Descrição auto-gerada.
@author thiago.rover
@since 23/05/2018
@version undefined

@type function
/*/
Function AGRXPERGROM()

	Local lRetorno := .T.
	Local aArea    := GetArea()
	Local lFunAgr  := .F.

	If IsInCallStack("OGA440") .OR. IsInCallStack("OGA440NFE") // Movimentações do Romaneio
		lFunAgr := .T.	
	ElseIf IsInCallStack("OGC003") // Movimentações do Romaneio
		lFunAgr := .T.
	ElseIf IsInCallStack("OGA250F") .Or. IsInCallStack("OGA250G") // Informar documento de referência / Confirmação do romaneio
		lFunAgr := .T.
	ElseIf IsInCallStack("OGA250") .OR. IsInCallStack("OGA251") // Opção "SPED NFe" do OGA250/OGA251
		lFunAgr := .T.
	EndIf

	If lFunAgr
		Pergunte("TOTVSSPED",.F.)
		MV_PAR01 := "1"	
		lRetorno := .F.		
	EndIf

	RestArea(aArea)

Return lRetorno

/*/{Protheus.doc} AGRXPARMROM
//TODO Descrição auto-gerada.
@author thiago.rover
@since 23/05/2018
@version undefined

@type function
/*/
Function AGRXPARMROM()

	Local lRetorno := .T.
	Local aArea  := GetArea()

	If IsInCallStack("OGA250") .Or. IsInCallStack("OGA251") .Or. IsInCallStack("OGA440") .Or. IsInCallStack("OGC003") 

		Pergunte("SPEDNFE",.F.)

		MV_PAR01 := "1"
		MV_PAR02 := "2"
		MV_PAR03 := ""

		lRetorno := .F.

	EndIf

	RestArea(aArea)

	Return lRetorno

	/*/{Protheus.doc} AGRXPERG()
	função chamada pelo ponto de entrada nos fontes DANFEII e DANFEIII para carregar os parametros de impressão da danfe e não mostrar a tela de parametros.
	@type  Function
	@author rafael.kleestadt
	@since 21/05/2018
	@version 1.0
	@param param, param_type, param_descr
	@return _lDanfe, logical, quando chamado pelo botão DANFE fica .F. para não abrir a tela de parametros do DANFEII e DANFEIII
	@example
	(examples)
	@see (links_or_references)
	/*/
Function AGRXPERG()

	Local cDoc   := ""
	Local cSerie := ""
	Local nTipo  := 0
	Local lRet   := .T.
	Local aArea  := GetArea()

	If IsInCallStack("OGA440").Or. IsInCallStack("OGA250") .Or. IsInCallStack("OGA251") .Or. IsInCallStack("OGC003") 

		nTipo := IIF( NJJ->NJJ_TIPO $ "2|4|6|8|11" , 2, 1 ) //[Operacao] NF de Saida ou NF de Entrada

		Pergunte("NFSIGW",.F.)

		If nTipo == 2 //Saida
			cDoc   := SF2->F2_DOC
			cSerie := SF2->F2_SERIE
		Else //Entrada
			cDoc   := SF1->F1_DOC
			cSerie := SF1->F1_SERIE
		EndIf

		MV_PAR01 := cDoc
		MV_PAR02 := cDoc
		MV_PAR03 := cSerie
		MV_PAR04 := nTipo //[Operacao] NF de Saida ou NF de Entrada
		MV_PAR05 := 2 //[Frente e Verso] Nao
		MV_PAR06 := 2 //[DANFE simplificado] Nao

		lRet := .F.

	EndIf

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRHELP
//Simplifica a execucao do comando help
@author marcelo.ferrari
@since 01/11/2018
@version 1.0
@return ${return}, ${return_description}
@param cTitulo, characters, descricao
@param cMensagem, characters, descricao
@param cSolucao, characters, descricao
@type function
/*/
Function AGRHELP(cTitulo, cMensagem, cSolucao)

	Help(NIL, NIL, cTitulo, NIL, cMensagem, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})

	Return

	/*/{Protheus.doc} AGRRETRELA(cCampo)
	Retorna o inicializador padrão do campo passado no parâmetro.
	@type  Function
	@author rafael.kleestadt / marcos.wagner
	@since 11/12/2018
	@version 1.0
	@param cCampo, caractere, campo a ser verificado
	@return xRet, Undefined, retorno da função GetSX3Cache
	@example
	(examples)
	@see (links_or_references)
	/*/
Function AGRRETRELA(cCampo)
	Local xRet := NIL

	xRet := GetSX3Cache(cCampo,"X3_RELACAO")

	Return xRet

	/*/{Protheus.doc} AGRRETWHEN(cCampo)
	Retorna o modo de edição do campo passado no parâmetro.
	@type  Function
	@author rafael.kleestadt / marcos.wagner
	@since 11/12/2018
	@version 1.0
	@param cCampo, caractere, campo a ser verificado
	@return xRet, Undefined, retorno da função GetSX3Cache
	@example
	(examples)
	@see (links_or_references)
	/*/
Function AGRRETWHEN(cCampo)
	Local xRet := NIL

	xRet := GetSX3Cache(cCampo,"X3_WHEN")

Return xRet

/*/{Protheus.doc} AGRRETCTXT
Retorna o contexto do campo passado no parâmetro.
@type  Function
@author rafael.kleestadt
@since 11/12/2018
@version 1.0
@param cTab, caractere, Tabela a ser verificada
@param cCampo, caractere, campo a ser verificado
@return cContexto, caractere, virtual ou real
@example
(examples)
@see (links_or_references)
/*/
Function AGRRETCTXT(cTab, cCampo)
	Local aAreaAtu  := GetArea()
	Local cContexto := ""
	Local oStruct   := FWFormStruct(1, cTab)

	If Ascan(oStruct:aFields,{|x| x[3] = cCampo}) > 0 //Senão estiver na estrutura, é campo virtual
		cContexto := IIF(oStruct:GetProperty(cCampo, MODEL_FIELD_VIRTUAL),"V","R")
	Else
		cContexto := "V"
	EndIf

	RestArea(aAreaAtu)

	Return cContexto

	/*/{Protheus.doc} AGRRETNIV(cCampo)
	Retorna o nível do campo passado no parâmetro.
	@type  Function
	@author rafael.kleestadt
	@since 12/12/2018
	@version 1.0
	@param cCampo, caractere, campo a ser verificado
	@return xRet, Undefined, retorno da função GetSX3Cache
	@example
	(examples)
	@see (links_or_references)
	/*/
Function AGRRETNIV(cCampo)
	Local xRet := NIL

	xRet := GetSX3Cache(cCampo,"X3_NIVEL")

Return xRet


/*/{Protheus.doc} AGRLOGAAPI
//Recebe a filial a qual o usuário quer se logar quando enviado uma requisição REST.
@author brunosilva
@since 10/02/2019
@version 1.0
@param cFilLog, characters, Filial.
@type function
/*/
Function AGRLOGAAPI(cFilLog)
	Local lRet 		:= .T.

	Default cFilLog := ""

	if EMPTY(cFilLog)
		//Validar se a filial existe.
		lRet := .F.
	else
		IF FWFilExist(cEmpAnt, cFilLog)
			cFilAnt := cFilLog
		else
			lRet := .F.
		endIf
	endIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRBOXGERM

Cria opcoes para o campo C6_GERMINA

@return cRet -> Texto a ser apresentado

@author AgroIndustria
@since 29/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function AGRBOXGERM()

Local nI	:= 0
Local cRet	:= ""
Local aOpc	:= {}

Local clista    := SUPERGETMV("MV_AGRO051",.F.,"1=Indefinido;2=80-84;3=85-100;4=90-100")
Local cListaAux
Local aOpc		:= {}
Local nI		:= 0
Local cVal		:= ''

cListaAux 	:=	StrTran(cLista,"-","%-")

aOpc		:=	Separa(cListaAux,";")


For Ni = 1 TO Len ( aOpc )
    
	cAux :=	SUBSTR( aOpc[nI] , AT("-" ,aOpc[nI]) + 1,Len( aOpc[nI] )) 

	////IF Val( cAux ) > 0
	IF IsNumeric( cAux )
	   aOpc[nI] := aOpc[nI] + "%"
	EndIF

next Ni
 
cListaAux := ''

For nI:=1 To Len(aOpc)
	cListaAux += IIf(empty(cListaAux),'',';') + aOpc[nI]
Next

Return (cListaAux)


//-------------------------------------------------------------------
/*/{Protheus.doc} AGRVLDGERM() 

Valid do Campo C6_GERMINA

@return cRet -> Valide de acordo com as opções

@author AgroIndustria
@since 29/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function AGRVLDGERM()

Local nI	:= 0
Local aOpc	:= {}

Local clista    := SUPERGETMV("MV_AGRO051",.F.,"1=Indefinido;2=80-84;3=85-100;4=90-100")
Local cListAux  := ''
Local aOpc		:= {}
Local nI		:= 0
Local lReturn	:= .f. 

aOpc		:=	Separa(cLista,";")

For Ni = 1 TO Len ( aOpc )
    
	cAux :=	SUBSTR( aOpc[nI] , 1 , AT("=" ,aOpc[nI] )-1  ) 

	aOpc[nI] := cAux

next Ni
 
 
For nI:=1 To Len( aOpc )
	cListAux += aOpc[nI] + "|"
Next


IF Empty( M->C6_GERMINA  )
   lReturn := .t.
ElseIF M->C6_GERMINA $ cListAux
   lReturn := .t.
Else
   lReturn := .f.
EndIF

Return ( lReturn )
