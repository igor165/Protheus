#include "VDFM210.CH"
#include "totvs.ch"
#Include "FWBROWSE.ch"
#Include "Protheus.ch"
#include "Fileio.ch"
#include "shell.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ?VDFM210  ?Autor ?Totvs                      ?Data ?19/11/2013 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Editor Itens de Atos/Portarias                                     ³±?
±±?         ?                                                                  ³±?
±±?         ?                                                                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?Generico                                                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±±±±±±±±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿±±
±±³Programador   ?Data   ?PRJ/REQ-Chamado ? Motivo da Alteracao                       ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivia F.      ?9/11/13³PRJ. M_RH001     ?GSP-Cria uma publicacao.                   ³±?
±±?             ?       ³REQ. 001851      ?                                           ³±?
±±³Fabricio      ?8/11/13³PRJ. M_RH001     ?GSP-Ajustes para gerar FILIAL e MATRICULA  ³±?
±±³Amaro         ?       ³REQ. 001851      ?    do Substituto                          ³±?
±±?             ?       ?                ?                                           ³±?
±±³Fabricio      ?9/11/13³PRJ. M_RH001     ?GSP-Ajustes na composição da CHAVE, que    ³±?
±±³Amaro         ?       ³REQ. 001851      ?    não ir?mais receber FILIAL e MATRICULA³±?
±±?             ?       ?                ?    Ajuste no dbSeek de					 ³±±±±±±±±±±±±±±±±±±±?
±±?             ?       ?                ?    DbSeek(FWXFILIAL(cAlias)+ cChave)  para					±±
±±?             ?       ?                ?    DbSeek(FWXFILIAL(cAlias)+ cFilMat + cMatric + cChave)	±±
±±³Everson jr    ?4/02/14³PRJ M_RH001      ?    AJUSTE  NA QUERY TRB PARA FECHAR A AREA EM USO 	    	±±
±±³Everson jr    ?4/02/14³REQ 001851       ?                                                   	    	±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFM210
Editor Itens de Atos/Portarias
@sample 	VD020MkOne( oObjMark )
@param		aParametro[1] 	Classificação do funcionario 	- Tabela Aux S101.
            aParametro[2]	Tipo de documento.           	- Tabela Aux S100.
            aParametro[3]	Categoria do funcionario.    	- Tabela SQ3 ou SRA.
            aParametro[4]	Matricula do funcionario
            aParametro[5]	Alias da tabela corrente.
            aParametro[6]	Status 1=Automatico,2=Manual ou 3=Reservado
            aParametro[7]   Chave de gravação RI6
            aParametro[8]   Filial do funcionario
            aParametro[9]   CPF do funcionario
            aParametro[10]  Data de Efeito
            aParametro[11]  Indice do alias da tabela corrente.
            aParametro[12]  Filial do Substituto
            aParametro[13]  Matricula do Substituto

@chave    	REY->REY_FILIAL + REY_CPF + REY_CODCON + REY_CODFUN		Nomeação
			SR8->R8_FILIAL + R8_MAT + DTOS(R8_DATAINI) + R8_TIPOAFA	Afastamento
			SRA->RA_FILIAL + RA_MAT										Inclusão na Folha/ Alteração Servidor
			SRE->RE_EMPP + RE_FILIALP + RE_MATP + DtoS(RE_DATA)		Transferência - Lotação/Relotação/Remoção
@return		Nil
@author		Nivia Ferreira
@since		17/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFM210(aParametro, lAut)
	Local aArea      	:= GetArea()
	Local aAreaSRA		:= SRA->( GetArea() )
	Local cClassif   	:= aParametro[1]
	Local cTpdoc     	:= aParametro[2]
	Local cCateg     	:= aParametro[3]
	Local cMatric    	:= aParametro[4]
	Local cAlias     	:= aParametro[5]
	Local cStatus    	:= aParametro[6]
	Local cChave     	:= aParametro[7]
	Local cFilmat    	:= aParametro[8]
	Local cCpf       	:= aParametro[9]
	Local dDtEfeito  	:= aParametro[10]
	Local cIndice		 := aParametro[11]
	Local cFilSub		 := aParametro[12]
	Local cMatSub		 := aParametro[13]
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
	Local aFldRel		:= {"RA_NOME", "RA_RACACOR"}
	Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
	Local cFileOpen  	:= ""
	Local cArq_Item  	:= "\inicializadores\s101_item_"+cClassif+"_"+cCateg+".ini"     //arquivo item com categoria
	Local cArq_ItemG 	:= "\inicializadores\s101_item_"+cClassif+"_p.ini"              //arquivo item geral
	Local cArq_Hist  	:= "\inicializadores\s101_itemhist_"+cClassif+"_"+cCateg+".ini" //arquivo historico com categoria
	Local cArq_HistG 	:= "\inicializadores\s101_itemhist_"+cClassif+"_p.ini"          //arquivo historico geral

	Local _cArqTO1   	:= cArq_Item
	Local _cArqTO2   	:= cArq_ItemG
	Local _cArqTO11  	:= cArq_Hist
	Local _cArqTO21  	:= cArq_HistG

	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}

	Local lRet       	:= .F.
	Local lTok       	:= .F.
	Local cTexto1    	:= ''
	Local cTexto2    	:= ''
	Local bOk        	:= {||lRet:=.t.,cTexto1:=oTSmpEdit1:GetText(),cTexto2:=oTSmpEdit2:GetText(),oDlg:End()}
	Local bCancel    	:= {||oDlg:End()}
	Local cClassExo  	:= ""
	Local aTabS101		:= {}
	Local nS			  	:= 0

	Local oDlg
	Local oTSmpEdit1
	Local oTSmpEdit2

	DEFAULT lAut := .F.

	IF !lAut
		//Tratamento de acesso a Dados Sensíveis
		If lBlqAcesso
			//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
			Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
			Return
		EndIf

		MsgInfo(STR0002, STR0001)			//'ATENÇÃO'//'Clique em OK e Aguarde a carga dos inicializadores...'
	ENDIF

	//Inicializa tabelas principais
	dbselectarea("SRJ")
	dbselectarea("SQ3")
	dbselectarea("RI6")
	dbselectarea("RI5")
	dbselectarea("REY")
	dbselectarea("SR6")
	dbselectarea("SQB")
	dbselectarea("RBR")
	dbselectarea("RB6")

	cFileOpen :=_cArqTO1

	If !File(cFileOpen)
		cFileOpen := _cArqTO2

		If !File(cFileOpen)
			MsgInfo(STR0005 + cArq_Item + STR0003, STR0004)//' não localizado'//'ATENÇÃO'//'Arquivo '
			lTok := .F.
			Return lTok
		Endif
	Endif

	//Posiciona na tabela/chave passada como parametro.
	(cAlias)->(dbSetOrder(VAl(cIndice)))
	If 	cAlias == 'REY'
		(cAlias)->(DbSeek(cFilMat + cChave))
	ElseIf !cAlias == 'SRE'
		(cAlias)->(DbSeek(cFilMat + cMatric + cChave))
	Else
		(cAlias)->(DbSeek(cChave))
	Endif


		//Editor de Texto
		cTexto1 := VD210ITEM(cFileOpen, aParametro)

		cFileOpen :=_cArqTO11
		If !File(cFileOpen)
			cFileOpen := _cArqTO21
			If !File(cFileOpen)
				MsgInfo(STR0007+ cArq_Hist + STR0006, "" )//' não localizado'//'Arquivo '
				lTok := .F.
				Return lTok
			Endif
		Endif

		//Editor de Texto
		cTexto2 := VD210ITEM(cFileOpen,aParametro)

	IF !lAut
		Begin Sequence
			aAdvSize		:= MsAdvSize()
			aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
			aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
			aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

			DEFINE MSDIALOG oDlg TITLE STR0008 FROM aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL//'Inclusão de Item'

				oTPanel2:= TPanel():New(10,10,"",oDlg,,,,,,100,100)
				oTPanel2:Align := CONTROL_ALIGN_TOP	//ALLCLIENT

				oTPanel1:= TPanel():New(10,10,"",oDlg,,,,,,100,100)
				oTPanel1:Align := CONTROL_ALIGN_ALLCLIENT	//BOTTOM

				//nTop, nLeft, nHeight, nWidth , cTitle, cText, nFormat, lShowOkButton, lShowCancelButton, oOwner
				oTSmpEdit2 := tSimpEdit():New( , , , , "",  @cTexto2, 1, .F., .F.,oTPanel2)
				oTSmpEdit1 := tSimpEdit():New( , , , , "",  @cTexto1, 1, .F., .F.,oTPanel1)

			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)
		End Sequence
	Else
		lRet:= .T.
	Endif
		If lRet
			Begin Transaction

				If cAlias=='REY'

					//Busca na S101 os enquadramentos das classificacoes
					fCarrTab( @aTabS101, "S101", Nil)
					For nS := 1 to len(aTabS101)
						If aTabS101[nS,7] $ '4/5' 			//4-Exoneracao 5-Tornar sem Efeito
							cClassExo += aTabS101[nS,1]+'/'
						EndIf
					Next nS

					DbSelectArea("REY")
					DbSetOrder(Val(cIndice))

					If (DbSeek(cFilMat + cChave)) //(DbSeek(FWXFILIAL("REY")+cCPF))
						RecLock("REY",.F.)

						If  (cClass $ cClassExo)
							REY->REY_EXONER := dNomeac
						Else
							REY->REY_NOMEAC := dNomeac
							REY->REY_POSSE  := dPosse
							REY->REY_EXONER := ctod("  /  /  ")
							REY->REY_OK     := '  '
						Endif

						MsUnLock()
					Endif
				Endif

				//Grava tabela RI6-Itens de Documento
				VD210RI6({cAlias,;				  //RI6_TABORI
						'',;								  //RI6_CODITE
						cCpf,;								//RI6_CPF
						cFilmat,;							//RI6_FILMAT
						cMatric,;							//RI6_MAT
						cTpdoc,;							//RI6_TIPDOC
						cClassif,;						//RI6_CLASTP
						cTexto1,;							//RI6_TXTITE
						cTexto2,;							//RI6_TXTHIS
						cStatus,;							//RI6_STATUS
						cChave,;							//RI6_CHAVE
						'',;								  //RI6_ANO
						'',;								  //RI6_NUMDOC
						,;                    //RI6_DTATPO
						dDtEfeito,;  					//RI6_DTEFEI
						cIndice,;							//RI6_CHVIDX
						cFilSub,;             //RI6_FILSUB
			            cMatSub,;
	    	       		XFILIAL("RI6") /*SQ3->Q3_FILIAL*/,;     //RI6_FILCRG
	    	       		"" /*SQ3->Q3_CARGO*/})                    //RI6_CARGO

			lTok := .T.

		End Transaction
	Endif

	RestArea( aArea )
	RestArea( aAreaSRA )
Return lTok

//------------------------------------------------------------------------------
/*/{Protheus.doc} VD210ITEM
Tratamento do arquivo texto.

@sample 	VD210ITEM(cFileOpen,cCPF,cMatric,cFilmat)
@param		cFileOpen 		Nome do arquivo texto.
			aParametro[1] 	Classificação do funcionario - Tabela Aux S101.
            aParametro[2]	Tipo de documento.           - Tabela Aux S100.
            aParametro[3]	Categoria do funcionario.    - Tabela SQ3 ou SRA.
            aParametro[4]	Matricula do funcionario
            aParametro[5]	Alias da tabela corrente.
            aParametro[6]	Status 1=Automatico,2=Manual ou 3=Reservado
            aParametro[7]   Chave de gravação RI6
            aParametro[8]   Filial do funcionario
            aParametro[9]   CPF do funcionario

			cCPF		 Cpf do funcionário.
			cMatric     Matricula do funcionário.
			cFilmat     Filial do funcionário.

@return		cRetorno  	Texto com as devidas alterações.
@author	    Nivia Ferreira
@since		17/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD210ITEM(cFileOpen,aParam)

	Local aArea    := GetArea()
	Local aAreaSRA := SRA->( GetArea() )
	Local aAreaSQG := SQG->( GetArea() )
	Local aAreaREW := REW->( GetArea() )
	Local aAreaREY := REY->( GetArea() )

	Local nLinha   := 0
	Local cRetorno := ""

	If !Empty(aParam[8]) .And. !Empty(aParam[4])
		DbSelectArea("SRA")
		DbSetOrder(1)
		DbSeek(aParam[8]+aParam[4])
	Else
		DbSelectArea("SQG")
		DbSetOrder(3)
		DbSeek(FWXFILIAL("SQG")+aParam[9])

		DbSelectArea("REY")
		DbSetOrder(1)
		DbSeek(FWXFILIAL("REY")+aParam[7])

		DbSelectArea("REW")
		DbSetOrder(1)
		DbSeek(FWXFILIAL("REW")+REY->REY_CODCON)
	Endif

	FT_FUSE(cFileOpen)         //ABRIR
	FT_FGOTOP()                //PONTO NO TOPO

	While !FT_FEOF()
		IncProc()
		cBuffer  := FT_FREADLN()
		cRetorno := cRetorno + VD210Macro(cBuffer) //Funcao para substituir macro.

		nLinha++
		FT_FSKIP()
	endDo
	FT_FUSE()

	RestArea( aAreaSQG )
	RestArea( aAreaSRA )
	RestArea( aAreaREW )
	RestArea( aAreaREY )
	RestArea( aArea )
Return(cRetorno)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD210Macro
Tratamento do arquivo texto.
@sample 	VD210Macro(cTexto)
@param		cTexto 		Texto que sera substituido.
@return		cRetorno  	Texto com as devidas alterações.
@author    	Nivia Ferreira
@since		17/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD210Macro(cTexto)
	Local aArea      := GetArea()
	Local cBuffer    := ""
	Local cTabela    := ""
	Local cCampo     := ""
	Local cRetorno   := ""
	Local cSX3       := {}
	Local nTamanho   := 0
	Local nInicial   := 0
	Local nFinal     := 0
	Local I          := 0
	Local oError 	 := ErrorBlock({|e| Aadd(aErro,"Mensagem de Erro: " +chr(10)+ e:Description)})
	Local aErro		 := {}
	Local cErro		 := ""
	Local n			 := 1
	Local cAux       := ""

	ctexto := StrTran( cTexto, "&quot;", '"' )

	If type("dPosse") == 'U'
		dPosse := ctod('//')
	EndIf
	If type("dNomeac") == 'U'
		dNomeac := ctod('//')
	EndIf

	cBuffer  := cTexto
	nTamanho := Len( cBuffer )

	IF At("-&gt;", cBuffer) > 0
		cBuffer := StrTran(cBuffer, "-&gt;", "->")
	Endif

	For I:=1 TO nTamanho

		If (AT("[*",Substr(cBuffer,i,2))> 0)
			nInicial := I+1
		Endif
		If (AT("*]",Substr(cBuffer,i,2))> 0)
			nFinal := I
		Endif

		If (AT("[{*",Substr(cBuffer,i,3))> 0)
			nInicial := I+2
		Endif
		If (AT("*}]",Substr(cBuffer,i,3))> 0)
			nFinal := I
			I++
		Endif

		IF (nInicial==0 .And. nFinal==0)
			cRetorno := cRetorno+Substr(cBuffer,i,1)
		Else
			IF nInicial<>0 .and. nFinal<>0
				cTabela := Substr(cBuffer,nInicial+1,3)
				cCampo  := Padr(Substr(cBuffer,nInicial+6,(nFinal-nInicial)-6),10)
				If substr(cCampo,3,1) == '_' .or. substr(cCampo,4,1) == '_'

					cSX3 := VD210TAB(cTabela,cCampo)
					If !Empty(cSX3[1,1])
						nInicial := 0
						nFinal   := 0
						I++

						If cSX3[1,1] == 'D'
							cRetorno := cRetorno + DTOC(&(cTabela+'->'+cCampo))
						ElseIf cSX3[1,1] == 'C'
							cRetorno := cRetorno + ALLTRIM(&(cTabela+'->'+cCampo))
						ElseIf cSX3[1,1] == 'N'
							cRetorno := cRetorno + ALLTRIM(Transform(&(cTabela+'->'+cCampo),cSX3[1,2]))
						Else
							cRetorno := cRetorno + &(cTabela+'->'+cCampo)
						Endif
					Endif
				Endif
			Endif
		Endif

		IF nInicial<>0 .and. nFinal<>0
			cTempBuf := ALLTRIM((Substr(cBuffer,nInicial+1,((nFinal-1)-nInicial))))

			//Se for Pocisione ou Fdesc, executa dbselectarea, pois esta ocorrendo erro devido a tabela nao estar aberta
			If UPPER(left(cTempBuf,10)) == "POSICIONE("
				//Troca as aspas duplas por simples
				cTempBuf := strtran(cTempBuf,'"',"'")
				dbselectarea(substr(cTempBuf,12,3))
				RestArea( aArea )
			ElseIf UPPER(left(cTempBuf,6)) == "FDESC("
				//Troca as aspas duplas por simples
				cTempBuf := strtran(cTempBuf,'"',"'")
				dbselectarea(substr(cTempBuf,8,3))
				RestArea( aArea )
			EndIf

			if valtype(cTempBuf) <> Nil .AND. valtype(&cTempBuf) <> NIL
				oAux := &cTempBuf
				If valtype(oAux) == "C" .and. !empty(oAux)
					cRetorno := cRetorno + ALLTRIM(oAux)+ ' '
				ElseIf valtype(oAux) == "D" .and. !empty(oAux)
					cRetorno := cRetorno + dtoc(oAux)+ ' '
				ElseIf valtype(oAux) == "N" .and. !empty(oAux)
					cRetorno := cRetorno + strzero(oAux)+ ' '
				Else
					cRetorno := cRetorno + "********* "
				Endif
			Endif

			I 		 := I+1
			nInicial := 0
			nFinal   := 0
		Endif

		IF nInicial <> 0 .and. nFinal <> 0
			cAux := Substr(cBuffer,nInicial,nFinal-nInicial + 1)
			IF At("-&gt;", cAux) > 0
				cAux := StrTran(cAux, "-&gt;", "->")
			Endif
			cRetorno += cAux
		ENDIF
	Next

	ErrorBlock(oError)
	If LEN(aErro) > 0
		For n := 1 To Len(aErro)
			cErro += aErro[n] + Chr(13) + Chr(10)
		Next n
		MsgInfo(STR0004 + Chr(13) + Chr(10) + cErro) // Atenção
		BREAK
	EndIf

	RestArea( aArea )
Return(cRetorno)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD210TAB
Acha o campos na SX3 e verifica o tipo.
@sample 	VD210TAB(cTabela,cCampo)
@param		cTabela 	Tabela para pesquisa.
cCampo		Nome do campo para pesquisa.
@return		cRetorno  	Tipo do campo.
@author	    Nivia Ferreira
@since		17/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static function VD210TAB(cTabela,cCampo)
	Local cRetorno:= {{,}}

	SX3->(dbSetOrder(1))
	SX3->(DbSeek(cTabela))
	While SX3->(!EOF())

		If (SX3->X3_CAMPO==cCampo)
	        cRetorno[1][1] := SX3->X3_TIPO
	        cRetorno[1][2] := SX3->X3_PICTURE
		Endif
		SX3->(dbSkip())
	End
Return (cRetorno)


//------------------------------------------------------------------------------
/*/{Protheus.doc}VD210RI6

Grava RI6.
@sample 	VD210RI6(aCampo)
@param		cCampo
@return
@author		Nivia Ferreira
@since		24/09/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD210RI6(aCampo)
	Local cCodItem := RI6CODITE()

	//Grava RI6
	RecLock("RI6",.T.)
		RI6_FILIAL	:= FWxFilial("RI6")
		RI6_TABORI	:= aCampo[01]
		RI6_CODITE	:= cCodItem
		RI6_CPF 	:= aCampo[03]
		RI6_FILMAT	:= aCampo[04]
		RI6_MAT  	:= aCampo[05]
		RI6_TIPDOC	:= aCampo[06]
		RI6_CLASTP	:= aCampo[07]
		RI6_TXTITE	:= aCampo[08]
		RI6_TXTHIS	:= aCampo[09]
		RI6_STATUS	:= aCampo[10]
		RI6_CHAVE 	:= aCampo[11]
		RI6_ANO		:= aCampo[12]
		RI6_NUMDOC	:= aCampo[13]
		RI6_DTATPO	:= aCampo[14]
		RI6_DTEFEI	:= aCampo[15]
		RI6_CHVIDX	:= aCampo[16]
		RI6_FILSUB	:= aCampo[17]
		RI6_MATSUB	:= aCampo[18]
		If RI6->(ColumnPos("RI6_FILCRG")) > 0
			RI6_FILCRG	:= aCampo[19]
		EndIf
		If RI6->(ColumnPos("RI6_CARGO")) > 0
			RI6_CARGO	:= aCampo[20]
		EndIf
	RI6->(MsUnLock())
Return ()


//------------------------------------------------------------------------------
/*/{Protheus.doc}RI6CODITE
Busca o proximo RI6_CODITEM utilizando query com o MAX(Ri6_CODITE)
Atenção: não substituir por GETSXENUM
@sample 	RI6CODITE()
@return		cCodItem
@author		Marcos Pereira
@since		27/08/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function RI6CODITE()

Local cQuery 	:= ''
Local cCodItem 	:= strzero(1,TAMSX3('RI6_CODITE')[1])

If Select("QTRBRI6") > 0
	QTRBRI6->( dbCloseArea())
EndIf
cQuery := " Select Max(RI6_CODITE) RI6_CODITE"
cQuery += " From "+RetSqlName("RI6")+" RI6 "
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "QTRBRI6", .F., .T.)
dbSelectArea("QTRBRI6")
If !Empty(QTRBRI6->RI6_CODITE)
	cCodItem := Soma1(QTRBRI6->RI6_CODITE)
Endif
QTRBRI6->( dbCloseArea() )

Return(cCodItem)


/*/{Protheus.doc} ShowError
	Função responsável em mostrar todos os erros, já fazendo tratativa
para situações do ExecAuto.
	Explicação para existência dessa função:
	A ideia da função HELP é que ela pode ser utilizada junto com o MVC
de maneira que ela guarde na memória os erros que ocorreram, mas
isso não estava acontecendo corretamente. Digamos que fosse passado
4 dependentes num vetor, sendo que todos são válidos, exceto a posição 3,
nesse caso, quando ele passasse pela posição 4, ele limparia os erros que
ocorreram na posição 3.
	Verificar de quando o Framework corrigir alterar essa função.
@author PHILIPE.POMPEU
@since 18/08/2015
@version 12.1.7
@param cMsg, caractere, Mensagem ou Código do Help
@param lIsHelp, lógico, Caso <cMsg> deva ser tratado como um código de Help
@param cTitle, caractere, Título da Tela de Help
@return Nil, Valor Nulo
@project 12.1.7
/*/
Static Function ShowError(cMsg,lIsHelp,cTitle,lCodHlp)
	DEFAULT cMsg 	:= ''
	DEFAULT lIsHelp	:= .F.
	DEFAULT cTitle 	:= OemToAnsi(STR0001) //Atenção
	DEFAULT lCodHlp	:= .F.

	If lGp020Auto
		AutoGrLog(cTitle + ':' + cMsg)
	Else
		If(lIsHelp)
			If lCodHlp
				Help(" ",1,cMsg)
			Else
				Help(,,'HELP',, cMsg,1,0 )
			EndIf
		Else
			MsgInfo(cMsg,cTitle)
		EndIf
	EndIf
Return (Nil)
