#include "PLSMGER.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSPMA1350
Auditoria de itens do PTU A1350

@author    Francisco Edcarlo
@since     16/12/2016
/*/
//------------------------------------------------------------------------------------------
Function PLSPMA1350
	Private oMark
	
	// Instanciamento do classe
	oMark := FWMarkBrowse():New()
	// Definição da tabela a ser utilizada
	oMark:SetAlias('B5D')
	oMark:SetMenuDef( "PLSPMA1350" )
	oMark:DisableDetails()
	oMark:ForceQuitButton()
	oMark:SetProfileID( '0' )
	oMark:SetWalkthru( .F. )
	oMark:SetAmbiente( .F. )
	// Define a titulo do browse de marcacao
	oMark:SetDescription('Auditoria de Itens do PTU 1350')
	// Define o campo que sera utilizado para a marcação
	oMark:SetFieldMark( 'B5D_OK' )
	
	//oMark:SetFilter('B5D_FILIAL+B5D_CODIGO', xFilial("B5C") + B5C->B5C_CODIGO, xFilial("B5C") + B5C->B5C_CODIGO)
	
	oMark:SetFilterDefault("B5D_STATUS <> '2' .AND. B5D->B5D_FILIAL + B5D->B5D_CODIGO = xFilial( 'B5D' ) + B5C->B5C_CODIGO")
	
	oMark:Activate()
Return NIL

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef

@author    Francisco Edcarlo
@since     16/12/2016
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE 'Processar' ACTION 'staticCall( PLSPMA1350,conAud1350 )' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE '(Des)Marcar Todos' ACTION 'staticCall( PLSPMA1350,PLSP1350MA )' OPERATION 2 ACCESS 0
Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} COMP25PROC
Processa objetos selecionados

@author    Francisco Edcarlo
@since     16/12/2016
/*/
//------------------------------------------------------------------------------------------
static Function conAud1350()
	Local aArea := GetArea()
	Local cMarca:= oMark:Mark()
	local aCampos := {}
	local aErros := {}
	local lParcial := .F.
	local oDialog   := nil
	local bOK     := {|| RestArea(aArea) , nOpca :=1 , oDialog:End()}
	local bCancel := {|| RestArea(aArea) , nOpca :=2 , oDialog:End()}
	local nFor		
	local cCod    := B5D->B5D_CODIGO			   
	aCab01  := { {"Matricula","@C",040} , {"Critica","@C",200 }  }
	aCritRea:= {}	
	aBut	:= {}
	oCriti01:= nil
	nFor := 1
	B5D->( dbGoTop() )	  
    B5D->( MsSeek(xFilial("B5D") +cCod ))
    If ( MsgYesNo("Os registros selecionados serão atualizados, deseja continuar?") )
		
		While !B5D->( EOF() ) .AND. B5D->B5D_CODIGO = B5C->B5C_CODIGO .AND. B5D->B5D_FILIAL = xFilial("B5D")
			aadd( aCampos,{ B5D->B5D_NOMBEN	, "BA1_NOMUSR" 	, "BTS_NOMUSR"	} )	// Nome Completo
			aadd( aCampos,{ B5D->B5D_NOMSOC	, "BA1_NREDUZ" 	, ""			} ) // Nome Social
			aadd( aCampos,{ B5D->B5D_NOMMAE	, "BA1_MAE"	 	, "BTS_MAE"		} )	// Nome Mãe Beneficiario
			aadd( aCampos,{ B5D->B5D_DTNASC	, "BA1_DATNAS" 	, "BTS_DATNAS"	} ) // Data Nascimento Beneficiario
			aadd( aCampos,{ B5D->B5D_SEXO	, "BA1_SEXO"	, "BTS_SEXO"	} )	// Tipo Sexo
			aadd( aCampos,{ B5D->B5D_ECIVIL	, "BA1_ESTCIV" 	, "BTS_ESTCIV"	} ) // Cod Estado Civil
			aadd( aCampos,{ B5D->B5D_CPF	, "BA1_CPFUSR" 	, "BTS_CPFUSR"	} )	// CPF
			aadd( aCampos,{ B5D->B5D_IDENTI	, "BA1_DRGUSR" 	, "BTS_DRGUSR"	} ) // RG
			aadd( aCampos,{ B5D->B5D_ORGEMI	, "BA1_ORGEM"	, "BTS_ORGEM"	} )	// Orgao Emissor
			aadd( aCampos,{ B5D->B5D_CDPAIS	, ""			, "BTS_CDPAIS"	} ) // Codigo Pais
			aadd( aCampos,{ B5D->B5D_CDCNS	, "" 			, "BTS_NRCRNA"	} )	// CNS
			aadd( aCampos,{ B5D->B5D_CDPIS	, "BA1_PISPAS" 	, "BTS_PISPAS"	} ) // PIS
			aadd( aCampos,{ B5D->B5D_NATMUN	, "BA1_CODMUN" 	, "BTS_CODMUN"	} )	// Cod Mun
			aadd( aCampos,{ B5D->B5D_INDRES	, "BA1_RESEXT" 	, "BTS_RESEXT"	} ) // Indica Residencia		
			aadd( aCampos,{ B5D->B5D_LOGRAD	, "BA1_ENDERE" 	, "BTS_ENDERE"	} )	// Descricao Logradouro
			aadd( aCampos,{ B5D->B5D_NUMRES	, "BA1_NR_END" 	, "BTS_NR_END"	} ) // Numero Logradouro
			aadd( aCampos,{ B5D->B5D_COMPLE	, "BA1_COMEND" 	, "BTS_COMEND"	} )	// Complento Logradouro
			aadd( aCampos,{ B5D->B5D_BAIRRO	, "BA1_BAIRRO" 	, "BTS_BAIRRO"	} ) // Descricao Bairro
			aadd( aCampos,{ B5D->B5D_CIDADE	, "BA1_MUNICI" 	, "BTS_MUNICI"	} )	// Cidade
			aadd( aCampos,{ B5D->B5D_MUNRES	, "BA1_MUNRES" 	, "BTS_MUNRES"	} ) // Cod Mun
			aadd( aCampos,{ B5D->B5D_CEP	, "BA1_CEPUSR" 	, "BTS_CEPUSR"	} )	// Cep
			aadd( aCampos,{ B5D->B5D_UF		, "BA1_ESTADO" 	, "BTS_ESTADO"	} ) // UF		
			aadd( aCampos,{ B5D->B5D_DDD	, "BA1_DDD"	 	, "BTS_DDD"		} ) // DDD
			aadd( aCampos,{ B5D->B5D_NUMTEL	, "BA1_TELEFO" 	, "BTS_TELEFO"	} )	// Telefone		
			aadd( aCampos,{ B5D->B5D_EMAIL	, "BA1_EMAIL"	, "BTS_EMAIL"	} ) // Email
	
	
			If B5D->(oMark:IsMark(cMarca)) .AND. B5D->B5D_STATUS <> '2'
				B5D->(AtDadosBen(aCampos, @aErros))
			EndIf
			
			If ( B5D->B5D_STATUS <> '2' .AND. !lParcial)
				lParcial := .T.
			EndIf
			B5D->( dbSkip() )
		End
	
		//Atualia status B5C para auditado		
		B5C->(RecLock("B5C", .F.))
			B5C->B5C_STATUS = IIf(lParcial,B5C->B5C_STATUS, "3")
		B5C->(MsUnlock())
		
		cMsg := IIf(len(aErros) > 0, "Existem criticas a serem analisadas.", "")
		ApMsgInfo( 'Os registros foram atualizados.' + CRLF + cMsg) 
		
		RestArea( aArea )
		
		if (len(aErros) > 0)
			DEFINE MSDIALOG oDialog TITLE "Criticas" FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()
		
			@ 014,003 FOLDER oFolder SIZE 350,185 OF oDialog PIXEL PROMPTS  OemtoAnsi("Criticas do arquivo")	
			If Len(aErros) > 0
				
				oCriti01 := TcBrowse():New( 012, 005, 340, 140,,,, oFolder:aDialogs[1],,,,,,,,,,,, .F.,, .T.,, .F., )
				aCritRea := aClone(aErros)
				For nFor := 1 To Len(aCab01)
					bBlock := "{ || aCritRea[oCriti01:nAt, "+Str(nFor,4)+"] }"
					bBlock := &bBlock
					oCriti01:AddColumn(TcColumn():New(aCab01[nFor,1],bBlock,aCab01[nFor,2],nil,nil,nil,aCab01[nFor,3],.F.,.F.,nil,nil,nil,.F.,nil))
				Next
				oCriti01:SetArray(aCritRea)
				aErros := {}
			Endif
			
			Aadd(aBut, {"RELATORIO",{ || ImpCriT(aCritRea,aCab01/*,aResum,aCab02,aCritNot,aCab03,aNota,aCab04*/,"Criticas","M",132) },"Imprimir"} )
		
			ACTIVATE MSDIALOG oDialog  ON INIT EnchoiceBar(oDialog,bOK,bCancel,.F.,aBut) CENTER
		EndIf
	EndIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtDadosBen
Atualiza dados do Beneficiario de acordo com itens B5D

@author    Francisco Edcarlo
@since     16/12/2016
/*/
//------------------------------------------------------------------------------------------
static Function AtDadosBen(aCampos, aErros)
	local cMatric := (B5D->B5D_CODINT) + (B5D->B5D_MATRIC)
	local nCont := 1
		
	If ExistBlock( "PLCP1350" )
		aCampos := ExecBlock( "PLCP1350", .F., .F., {aCampos} )
	EndIf
	
	BA1->(dbSetOrder(2))
	If BA1->(MsSeek(xFilial("BA1") + cMatric))
		BA1->(Reclock("BA1", .F.))
		while nCont <= len(aCampos)
			cValB5D := aCampos[nCont][1]
			cCampo := aCampos[nCont][2]
			If ( !Empty( cValB5D ) .AND. !Empty( cCampo ) )
				If "BA1_RESEXT" == cCampo
					cCmd := "BA1->" + aCampos[ nCont ][ 2 ] + " := IIf('" + AllTrim(cValB5D)+ "' = '1', '0', '1')"
				Else
					cCmd := "BA1->" + aCampos[ nCont ][ 2 ] + " := '" + AllTrim(cValB5D) +"'"
				EndIf
				&(cCmd)
			End
			nCont++
		enddo
		BA1->(Msunlock())
		//Alteração SIB
		AlteraSIB(aCampos)
		
		cMatVida := BA1->BA1_MATVIDA
		AtDadoVida(cMatVida, aCampos)
		//Atualiza o status do registro para auditado
		B5D->(RecLock("B5D", .F.))
		B5D->B5D_STATUS := '2'
		B5D->(MsUnlock())
		
		//Atualiza o status do arquivo para auditado parcial
		If (B5C->B5C_STATUS <> '3')
			B5C->(RecLock("B5C", .F.))
				B5C->B5C_STATUS := '2' //2-Parcial, 3-Completo
			B5C->(MsUnlock())
		EndIf
	Else
		aadd(aErros, { B5D->B5D_CODINT + B5D->B5D_MATRIC , "Matricula não encontrada" } )
	EndIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtDadosBen
Atualiza dados da Vida (BTS) de acordo com itens B5D

@author    Francisco Edcarlo
@since     19/12/2016
/*/
//------------------------------------------------------------------------------------------
static Function AtDadoVida(cMatVida, aCampos)
	local nCont := 1
	
	BTS->(dbSetOrder(1))
	If BTS->(MsSeek(xFilial("BTS") + cMatVida))
		BTS->(Reclock("BTS", .F.))
		while nCont <= len(aCampos)
			cValB5D := aCampos[nCont][1]
			cCampo := aCampos[nCont][3]
			If ( !Empty( cValB5D ) .AND. !Empty( cCampo ) )
				If "BTS_RESEXT" == cCampo
					cCmd := "BTS->" + aCampos[ nCont ][ 3 ] + " := IIf('" + cValB5D + "' = '1', '0', '1')"
				Else
					cCmd := "BTS->" + aCampos[ nCont ][ 3 ] + " := '" + cValB5D + "'"
				EndIf
				&(cCmd)
			End
			nCont++
		enddo
		BTS->(Msunlock())
	EndIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP1350MA
Processa objetos selecionados

@author    Francisco Edcarlo
@since     16/12/2016
/*/
//------------------------------------------------------------------------------------------
static Function PLSP1350MA()
	oMark:AllMark()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AlteraSIB
Verifica se os registros importados alteram SIB
@author Lucas Nonato
@since 	19/12/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function AlteraSIB(aCmps)
Local cCmpSIB 	:= GetNewPar("MV_PLSSIB","BA1_DATNAS;BA1_SEXO;BA1_CPFUSR;BA1_NOMUSR;BA1_MAE;BA1_TIPUSU;BA1_ENDERE;BA1_CEPUSR;BA1_MUNICI;BA1_ESTADO")
Local cSeq 		:= PLBX1NEW()
Local cAlias	:= "BA1"
Local nCmpSib	:= 1
Local aCmpSIB 	:= {}
Local aAux		:= {}

BA1->(dbSetOrder(2)) // BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO
If BA1->(MsSeek(xFilial("BA1") + B5D->(B5D_CODINT + B5D_MATRIC)	))

	aCmpSIB:= StrTokArr( cCmpSIB, ";" )
	For nCmpSib := 1 To Len(aCmpSIB)
		nPos:= aScan(aCmps,{|x| AllTrim(x[2]) == aCmpSIB[nCmpSib]})
		If nPos <> 0 .And. !Empty(aCmps[nPos][1])
			aAdd(aAux, {aCmpSIB[nCmpSIB], aCmps[nPos][1]})
		EndIF
	Next

	If Len(aAux) >= 1
		Begin Transaction
		
		BX1->( RecLock("BX1",.T.) )
			BX1->BX1_FILIAL   	:= xFilial("BX1")
			BX1->BX1_SEQUEN   	:= cSeq
			BX1->BX1_ALIAS    	:= cAlias
			BX1->BX1_RECNO    	:= StrZero( &(cAlias+"->(Recno())") ,Len(BX1->BX1_RECNO))		
			BX1->BX1_TIPO 		:= "A"			
			BX1->BX1_USUARI   	:= Upper(PLRETOPE())
			BX1->BX1_DATA     	:= Date()
			BX1->BX1_HORA     	:= Time()
			BX1->BX1_ESTTRB   	:= GetComputerName()		
			If BX1->(FieldPos("BX1_ROTINA")) > 0
				BX1->BX1_ROTINA := FunName()
			EndIf
		BX1->( MsUnLock() )
		
		End Transaction
	EndIf
	
	For nCmpSib := 1 to Len(aAux)	
		Begin Transaction
		
		BX2->( RecLock("BX2",.T.) )
			BX2->BX2_FILIAL   := xFilial("BX2")
			BX2->BX2_SEQUEN   := BX1->BX1_SEQUEN
			BX2->BX2_CAMPO    := aAux[nCmpSib][1]
			BX2->BX2_TITULO   := Posicione("SX3",2,AllTrim(aAux[nCmpSib][1]),"X3_TITULO")
			BX2->BX2_ANTVAL   := &(cAlias)->(aAux[nCmpSib][1])
			BX2->BX2_NOVVAL   := AllTrim(aAux[nCmpSib][2])
		BX2->( MsUnLock() )
		
		End Transaction
	Next 
	
	If Len(aAux) >= 1
		BA1->(Reclock("BA1", .F.))
			BA1->BA1_LOCSIB := '7'
		BA1->( MsUnLock() )
	EndIf
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpCriT
Imprime criticas
@author Lucas Nonato
@since 11/05/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function ImpCriT(aCritRea,aCab01,aResum,/*aCab02,aCritNot,aCab03,aNota,aCab04,*/cTitulo,cTpRel,nTmRel)
LOCAL aPrints := {}
LOCAL nI := 0

If Len(aCritRea) > 0
	aadd(aPrints,{"criticas do arquivo",aCritRea,aCab01})
Endif

For nI:=1 To Len(aPrints)
	If MsgYesNo("Imprimir "+aPrints[nI][1]+" ?")
		RImpCriT(aPrints[nI][2],aPrints[nI][3],aPrints[nI][1],cTpRel,nTmRel)
	Endif
Next

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RImpCriT
Imprime criticas
@author Lucas Nonato
@since 11/05/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function RImpCriT(aDados,aCabec,cTit,cTpRel,nTmRel)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis padroes para todos os relatorios...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nFor
LOCAL nFor2
LOCAL cDado
LOCAL uDado
LOCAL cPerg       := nil // Pergunta padrao (SX1) dos parametros
PRIVATE nQtdLin     := 58       // Qtd de Linhas Por Pagina
PRIVATE nLimite     := 132       // Limite de Colunas
PRIVATE cTamanho    := "M"       // P=Pequeno;M=Medio;G=Grande -> P=80;M=132;G=220 (colunas)
PRIVATE cTitulo     := cTit // Titulo do Relatorio
PRIVATE cDesc1      := cTitulo // Descritivo para o usuario
PRIVATE cDesc2      := "" // Descritivo para o usuario
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BA1" // Alias
PRIVATE cRel        := "IMPCRIGEN" // Nome do Relatorio
PRIVATE nli         := 01   // Variavel padrao para controlar numero de linha
PRIVATE nQtdini     := nli  // Variavel para controlar numero de linha inicial
PRIVATE m_pag       := 1    // Variavel padrao para contar numero da pagina
PRIVATE lCompres    := .F. // nao mude e padrao
PRIVATE lDicion     := .F. // nao mude e padrao
PRIVATE lFiltro     := .F. // Habilitar o filtro ou nao
PRIVATE lCrystal    := .F. // nao mudar controle do crystal reports
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } // padrao nao mude
PRIVATE lAbortPrint := .F. // Controle para abortar (sempre como esta aqui)
PRIVATE cCabec1     := "" // Primeira linha do cabecalho ;
PRIVATE cCabec2     := "" // utilizado pela funcao cabec...
PRIVATE nColuna     := 03 // Numero da coluna que sera impresso as colunas

DEFAULT cTpRel     := "M"
DEFAULT nTmRel     := 132

nLimite     := nTmRel
cTamanho    := cTpRel
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama SetPrint (padrao)                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRel  := SetPrint(cAlias,cRel,cPerg,@cTitulo,"","","",,{},,cTamanho,{},lFiltro,lCrystal)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi cancelada a operacao (padrao)                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nLastKey  == 27 // Verifica o cancelamento...
	Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura impressora (padrao)                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cAlias)

@ ++nLi, nColuna pSay "**** "+cTit+" ****"

@ ++nLi, nColuna pSay Replicate("*",nLimite-nColuna)
cDado := ""
For nFor := 1 To Len(aCabec)
	cDado += aCabec[nFor,1]+Space(10)
Next
@ ++nLi, nColuna pSay cDado
@ ++nLi, nColuna pSay Replicate("*",nLimite-nColuna)

For nFor := 1 To Len(aDados)
	cDado := ""
	For nFor2 := 1 To Len(aCabec)
		uDado := aDados[nFor,nFor2]
		If     ValType(uDado) == "C"
			cDado += uDado+Space(02)
		ElseIf ValType(uDado) == "D"
			cDado += dtoc(uDado)+Space(02)
		ElseIf ValType(uDado) == "N"
			cDado += str(uDado,17,4)+Space(02)
		Endif
	Next
	@ ++nLi, nColuna pSay cDado
Next

@ ++nLi, nColuna pSay Replicate("*",nLimite-nColuna)
@ ++nLi, nColuna pSay StrZero(Len(aDados),2)+" Registro(s) Listado(s)"
@ ++nLi, nColuna pSay Replicate("*",nLimite-nColuna)

If  aReturn[5] == 1
	Set Printer To
	Ourspool(cRel)
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
