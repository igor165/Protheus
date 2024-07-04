#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPXFUNEDI.CH"


Static cOption	:= "" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณMicrosiga           บ Data ณ  04/04/05         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a tela de escolha para tratar a tabela RCO                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                               บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ FNC  ณ  Motivo da Alteracao                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤดฑฑ
ฑฑณCecilia C.  ณ20/05/14ณTPQAJ1ณIncluido o fonte da 11 para a 12 e efetuada a   ณฑฑ
ฑฑณ            ณ        ณ      ณlimpeza.                                        ณฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function fRegPatronal( l1Elem , cPreSelect , _cAlias)
Local aNewSelect		:= {}
Local aPreSelect		:= {}
Local cTitulo			:= ""
Local MvParDef			:= ""
Local MvRetor			:= ""
Local MvParam			:= ""
Local lRet				:= .T.
Local nFor				:= 0
Local nAuxFor			:= 1
Local MvPar     		:= NIL
Local cFilRCO			:= ""
Local nCampo			:= 0

If Alltrim(_cAlias) == "RCO"
	cFilRCO	:= xFilial("RCO")
	nCampo	:= TamSx3("RCO_CODIGO")[1] //4
	__afVerbas__	:= {}
ElseIf Alltrim(_cAlias) == "DE9"
	cFilRCO	:= xFilial("DE9")
	nCampo	:= TamSx3("DE9_CODLAY")[1] //6
Endif
        
DEFAULT cPreSelect		:= ""
DEFAULT l1Elem			:= .F.
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Static Utilizadas na Funcao RetOrdem()                       ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Static __aRetOrdem

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Static Utilizadas na Funcao fVerbas()                        ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Static __afVerbas__

Begin Sequence

	CursorWait()
		For nFor := 1 To Len( cPreSelect ) Step nCampo
			aAdd( aPreSelect , SubStr( cPreSelect , nFor , nCampo ) )
		Next nFor
	
		cAlias 	:= Alias() 
		MvPar	:= &(Alltrim(ReadVar()))	
		mvRet	:= Alltrim(ReadVar())		
		
		If !( l1Elem )
			For nFor := 1 TO Len(alltrim(MvPar))
				Mvparam += Subs(MvPar,nAuxFor,nCampo)
				MvParam += Replicate("*",nCampo)
				nAuxFor := (nFor * nCampo) + 1
			Next
		Endif
		mvPar 	:= MvParam
		IF Empty( __afVerbas__ )
			__afVerbas__	:= BldafVerbas( cFilRCO , _cAlias )
		EndIF
	CursorArrow()
	
	IF !( lRet := !Empty( __afVerbas__ ) )
		Help(" ",1,"GPENFILIAL")	//Cadastro de verbas nao existe para a filial
		Break
	EndIF	
    
	CursorWait()
		For nFor := 1 To Len( __afVerbas__ )
			IF ( aScan( aPreSelect , SubStr( __afVerbas__[ nFor ] , 1 , 3 ) ) == 0.00 )
				MvParDef+=Left(__afVerbas__[ nFor ],Iif(_cAlias=="DE9",TamSx3("DE9_CODLAY")[1],TamSx3("RCO_CODIGO")[1] ) )
				aAdd( aNewSelect , __afVerbas__[ nFor ] )
			EndIF
		Next nFor
	CursorArrow()
	
	IF f_Opcoes(@MvPar,cTitulo,aNewSelect,MvParDef,12,49,l1Elem,nCampo,10)
		CursorWait()
			For nFor := 1 To Len( mVpar ) Step 	nCampo
				IF ( SubStr( mVpar , nFor , nCampo ) # "****" )
					mvRetor += SubStr( mVpar , nFor , nCampo )
				Endif
			Next nFor
			&MvRet := Mvretor
		CursorArrow()	
	EndIF

End Sequence

dbSelectArea(cAlias)

Return( lRet )

/*
ฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟ
ณFuno    ณBldafVerbas   ณ Autor ณ					      ณ Data ณ05/04/2005ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤด
ณDescrio ณCarregar as Verbas do SRV conforme Filial                    	ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณParametrosณcFilRCO - Filial do RCO											ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณRetorno   ณaVerbas - Array com a String de Codigo + Descricao da Verba	    ณ
ภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Static Function BldafVerbas( cFilRCO ,_cAlias )

Local aArea		:= GetArea()
Local aQuery	:= {}
Local aVerbas	:= {}
Local _aElem	:= {}
Local bSkip	

If Alltrim(_cAlias)=="RCO"
	bSkip		:= { || aAdd( aVerbas , ( RCO_CODIGO + " - " + RCO_NOME	 ) ) , .F. }
ElseIf Alltrim(_cAlias)=="DE9"
	bSkip		:= { || aAdd( aVerbas , ( DE9_CODLAY + " - " + DE9_DSCLAY	 ) ) , .F. }
Endif

If Alltrim(_cAlias) == "RCO"
	aQuery		:= Array( 03 )
	aQuery[01]	:= "RCO_FILIAL='"+cFilRCO+"'"
	aQuery[02]	:= " AND "
	aQuery[03]	:= "D_E_L_E_T_=' ' "
ElseIf Alltrim(_cAlias) == "DE9"
	aQuery		:= Array( 03 )
	aQuery[01]	:= "DE9_FILIAL='"+cFilRCO+"'"
	aQuery[02]	:= " AND "
	aQuery[03]	:= "D_E_L_E_T_=' ' "
EndIf

If Alltrim(_cAlias)=="RCO"
  RCO->( GdMontaCols(NIL				,;	
					NIL				,;
					NIL				,;
					NIL				,;
					NIL				,;
					{"RCO_FILIAL","RCO_CODIGO","RCO_NOME"},;
					NIL				,;
					"RCO"			,; 
					cFilRCO			,;
					NIL				,;
					bSkip			,;
					.F.				,;
					.F.				,;
					.F.				,;
					NIL				,;
					.F.				,;
					.F.				,;
					aQuery			,;
					.F.				,;
					.T.				,;
					.F.				,;
					.T.				,;
					.F.				,;
					.F.				,;
					.F.				 ;
				   );
	  )

ElseIf Alltrim(_cAlias)=="DE9"
  DE9->( GdMontaCols(NIL			,;	
					NIL				,;
					NIL				,;
					NIL				,;
					NIL				,;
					{"RE9_FILIAL","DE9_CODLAY","DE9_DSCLAY"},;
					NIL				,;
					"DE9"			,; 
					cFilRCO			,;
					NIL				,;
					bSkip			,;
					.F.				,;
					.F.				,;
					.F.				,;
					NIL				,;
					.F.				,;
					.F.				,;
					aQuery			,;
					.F.				,;
					.T.				,;
					.F.				,;
					.T.				,;
					.F.				,;
					.F.				,;
					.F.				 ;
				   );
	  )

Endif


RestArea( aArea )
Return( aClone( aVerbas ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณMicrosiga           บ Data ณ  04/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta funcao, filtra o parametro da rotina Empregados  do   บฑฑ
ฑฑบ          ณEDI. Fazendo o tratamento dos parametros usados.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
 // Parametro usado no LayOut Empregados, importa็ใo do EDI
 	GPEM01  ฆ01      ฆCliente de ?
 	GPEM01  ฆ02      ฆFilial de ?
 	GPEM01  ฆ03      ฆCliente ate ?
 	GPEM01  ฆ04      ฆFilial ate ?
 	GPEM01  ฆ05      ฆEmpregados de ?
 	GPEM01  ฆ06      ฆFilial de ?
 	GPEM01  ฆ07      ฆEmpregados ate ?
 	GPEM01  ฆ08      ฆFilial ate ?
 	GPEM01  ฆ09      ฆDt Movimento de ?
 	GPEM01  ฆ10      ฆDt Movimento ate ?
	GPEM01  ฆ11      ฆRegistro Patronal ?
 	GPEM01  ฆ12      ฆGerar Alta ?
 	GPEM01  ฆ13      ฆGerar Baixas ?
 	GPEM01  ฆ14      ฆGerar Modif. Salario ?
/*/
User Function fFiltraParMx()   

Local lRetorno	:= .f.
Local nCont		:= 1
Local cRegAux	:= ""

Static _cReg := ""


If (	RCP->RCP_FILIAL+RCP->RCP_MAT >= MV_PAR06+MV_PAR05 .And. ;
		RCP->RCP_FILIAL+RCP->RCP_MAT <= MV_PAR08+MV_PAR07 .And. ;
		Dtos(RCP->RCP_DTMOV) >= Dtos(mv_par09) .And. Dtos(RCP->RCP_DTMOV) <= Dtos(mv_par10) )

	//Registro Patronal
	If Empty(_cReg)
		For nCont := 1 To Len( MV_PAR11 ) Step 4
			_cReg := _cReg + SubStr( MV_PAR11 , nCont , 4 )+"*"
		Next nCont
	Else
		//Caso seja gerado um arquivo para um Registro Patronal, 
		//e depois o usuario inicie uma nova gera็ใo selecionando
		//outro Registro Patronal, recarrega a Static com o novo
		//Registro Patronal - Igor 29/07/2009
		For nCont := 1 To Len( MV_PAR11 ) Step 4
			cRegAux := cRegAux + SubStr( MV_PAR11 , nCont , 4 )+"*"
		Next nCont
		If ( _cReg != cRegAux )
			_cReg := cRegAux
		EndIf
    Endif

	//Igor - 29/07/2009    
   	//If RCO->RCO_CODIGO $ _cReg .And. Empty(RCP->RCP_DTIMSS) .And. (Empty(RCP->RCP_HRIMSS) .oR. RCP->RCP_HRIMSS == "  :  :  ") 
   	If RCP->RCP_CODRPA $ _cReg .And. Empty(RCP->RCP_DTIMSS) .And. (Empty(RCP->RCP_HRIMSS) .oR. RCP->RCP_HRIMSS == "  :  :  ") 
		lRetorno	:= .T.
   	Endif
Endif

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณMicrosiga           บ Data ณ  05/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Trata a aberturas dos alias que o EDI utiliza para a rotinaบฑฑ
ฑฑบ          ณde importacao Empregados.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Customizada                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function OpenAlias()
	DbSelectArea("RCO")
	DbSelectArea("RCP")
	DbSelectArea("SRA")
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณMicrosiga           บ Data ณ  05/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Apos a gravacao do arquivo TXT dos empregados, ele grava   บฑฑ
ฑฑบ          ณ 2 campos na tabela RCP(DTIMSS e HRIMSS) para flag enviado. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function ReadPut(nSet)

Local 	nCont 			:= 0
Local 	aAreaGrava	   	:= {}
Static  dDataInicio	   	:= Date()
Static  cTimeInicio    	:= Time()  
Static  aGravaRegister 	:= {}

If nSet == 1
	dDataInicio		:= NIL
	cTimeInicio  	:= NIL
	aGravaRegister	:= NIL
ElseIf nSet == 2
	Aadd(aGravaRegister,RCP->(Recno()))
ElseIf nSet == 3	
    dbSelectArea("RCP")
	aAreaGrava	:= GetArea()
    For nCont:= 1 to Len(aGravaRegister)
      dbGoto(aGravaRegister[nCont])
      RecLock("RCP",.f.)
        Replace RCP->RCP_DTIMSS	With dDataInicio
        Replace RCP->RCP_HRIMSS	With cTimeInicio    
      MsUnlock()
	Next    
	RestArea(aAreaGrava)
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณMicrosiga           บ Data ณ  04/20/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFiltra o grupo de pergunta na rotina do EDI.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
Parametro usado no LayOut do SUA da rotina de importacao do EDI.
GPEM02  ฆ01      ฆCliente de ?
GPEM02  ฆ02      ฆFilial de ?
GPEM02  ฆ03      ฆCliente ate ?
GPEM02  ฆ04      ฆFilial ate ?
GPEM02  ฆ05      ฆMes Ano Processamento ?
GPEM02  ฆ06      ฆRegistro Patronal ?
GPEM02   07       Geracao de Empregados ?
*/
User Function fFiltra2ParMx()
Local lRetorno	:= .f.
Local nCont		:= 1
Local cRegAux	:= ""

Static _cReg := ""

If RCQ->RCQ_ANOMES == MV_PAR05
	//Registro Patronal	
	If Empty(_cReg)
		For nCont := 1 To Len( MV_PAR06 ) Step 4
			_cReg := _cReg + SubStr( MV_PAR06 , nCont , 4 )+"*"
		Next nCont		
	Else
		//Caso seja gerado um arquivo para um Registro Patronal, 
		//e depois o usuario inicie uma nova gera็ใo selecionando
		//outro Registro Patronal, recarrega a Static com o novo
		//Registro Patronal - Igor 29/07/2009
		For nCont := 1 To Len( MV_PAR11 ) Step 4
			cRegAux := cRegAux + SubStr( MV_PAR11 , nCont , 4 )+"*"
		Next nCont
		If ( _cReg != cRegAux )
			_cReg := cRegAux
		EndIf
    Endif

	lRetorno	:= .T.

  	If MV_PAR07 == 2
  		If !( AnoMes(RCQ->RCQ_DTMOV) == MV_PAR05 )
  			lRetorno := .F.
  		EndIf
  	EndIf
  	
Endif

Return (lRetorno) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณIgor Franzoi	     บ Data ณ  04/20/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFiltra o grupo de pergunta na rotina do EDI. Funcao		  บฑฑ
ฑฑบ          ณutilizada apenas na gera็ใo do Arquivo SUAI - Infonavit     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
Parametro usado no LayOut do SUA da rotina de importacao do EDI.
GPEM02  ฆ01      ฆCliente de ?
GPEM02  ฆ02      ฆFilial de ?
GPEM02  ฆ03      ฆCliente ate ?
GPEM02  ฆ04      ฆFilial ate ?
GPEM02  ฆ05      ฆMes Ano Processamento ?
GPEM02  ฆ06      ฆRegistro Patronal ?
GPEM02   07       Geracao de Empregados ?
*/
User Function fFiltra3ParMx()

Local lRetorno	:= .F.
Local nCont		:= 1
Local cRegAux	:= ""

Static _cReg := ""

//Registro Patronal	
If Empty(_cReg)
	For nCont := 1 To Len( MV_PAR06 ) Step 4
		_cReg := _cReg + SubStr( MV_PAR06 , nCont , 4 )+"*"
	Next nCont		
Else
	//Caso seja gerado um arquivo para um Registro Patronal, 
	//e depois o usuario inicie uma nova gera็ใo selecionando
	//outro Registro Patronal, recarrega a Static com o novo
	//Registro Patronal - Igor 29/07/2009
	For nCont := 1 To Len( MV_PAR11 ) Step 4
		cRegAux := cRegAux + SubStr( MV_PAR11 , nCont , 4 )+"*"
	Next nCont
	If ( _cReg != cRegAux )
		_cReg := cRegAux
	EndIf
    Endif

If ( MV_PAR07 == 2 )
	If ( RCQ->RCQ_ANOMES == MV_PAR05 )
		lRetorno := .T.
	EndIf
Else
	lRetorno := .T.
EndIf

Return (lRetorno) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณMicrosiga           บ Data ณ  04/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณnValor - o valor a ser convertido e tratado o ponto da dec. บฑฑ
ฑฑบ          ณnPos - para tratar de quantos digitos ้ o campo             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Converte o valor para caracter na geracao do TXT.          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function TransfValor(nValor,nPos)

Local cConverte 	
Local nValor1

nValor1 := Int(nValor * 100 )
cConverte := Strzero(nValor1,7)

Return(cConverte)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณMicrosiga           บ Data ณ  04/28/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Transforma a DATA em formato ( dia XX/ mes XX / Ano XXXX ) บฑฑ
ฑฑบ          ณcaracter.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function TransfData(dDataRec)
	Local cRetorno	:= ""
	Local cDataRetDia	:= IIf (Len(ALLTRIM(STR(DAY(dDataRec)))) < 2,"0"+ALLTRIM(STR(DAY(dDataRec))),ALLTRIM(STR(DAY(dDataRec))) )
	Local cDataRetMes	:= Iif (Len(ALLTRIM(STR(MONTH(dDataRec)))) < 2,"0"+ALLTRIM(STR(MONTH(dDataRec))),ALLTRIM(STR(MONTH(dDataRec))) )
	Local cDataRetAno	:= ALLTRIM(STR(YEAR(dDataRec)))
	cRetorno	:= cDataRetDia+cDataRetMes+cDataRetAno
	IIf (Empty(cRetorno),cRetorno:=Space(8),cRetorno)

Return(cDataRetDia+cDataRetMes+cDataRetAno)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณMicrosiga           บ Data ณ  04/28/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a equivalencia dos tipos na importacao do EDI - SUA.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function TransfMov(cTipoMot)
	If Alltrim(cTipoMot) == "04"
		cTipoMot	:= "02"				//IMSS = Baixa
	ElseIf Alltrim(cTipoMot) == "05"
		cTipoMot	:= "07"				//IMSS = Modifica็ใo de Salแrio
	ElseIf Alltrim(cTipoMot) == "06"
		cTipoMot	:= "08"				//IMSS = Reingresso
	EndIf
Return(cTipoMot)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณMicrosiga           บ Data ณ  04/28/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Trata o campo RCQ->RCQ_VALINF quanto ao seu status         บฑฑ
ฑฑบ          ณna import.ele trata de acordo com um formato (pos. 157- 164)บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function TransfVlrDesc(nValorDesc)

Local cValorInt	:= ""
Local cValorDec	:= 0
Local cValorRet	:= ""

If nValorDesc == 0
  Return(Replicate("0",8))
Endif

cValorInt	:= AllTrim(Str(INT(nValorDesc)))

If Alltrim(RCQ->RCQ_TIPINF) == "1" 		// dois inteiros e dois decimais (Ex. 00999900 )
	
	cValorDec	:= SubStr( AllTrim(Str(Round(nValorDesc,2))),At( ".", AllTrim(Str(Round(nValorDesc,2))) )+1,12)
	
	cValorRet	:= Replicate( "0", 2 ) + SubStr( StrZero(Val(cValorInt),4),3,Len(StrZero(Val(cValorInt),4)) ) + SubStr(cValorDec,1,2 ) + Replicate( "0", 4-Len(AllTrim(cValorDec)) )	

ElseIf Alltrim(RCQ->RCQ_TIPINF) == "2"  // quatro inteiros e duas decimais ( Ex. 99999900 )
	
	cValorDec	:= SubStr( AllTrim(Str(Round(nValorDesc,2))),At( ".", AllTrim(Str(Round(nValorDesc,2))) )+1,12)
	
	cValorRet	:= Replicate( "0", 4-Len(cValorInt) ) + cValorInt + SubStr(cValorDec,1,2 ) + Replicate( "0", 4-Len(AllTrim(cValorDec)) )	

ElseIf Alltrim(RCQ->RCQ_TIPINF) == "3"	// tres inteiros e quatro decimais ( Ex. 09999999 )
	
	cValorDec	:= SubStr( AllTrim(Str(nValorDesc)),At( ".", AllTrim(Str(nValorDesc)) )+1,12)
	
	cValorRet	:= Replicate( "0", 1 ) + SubStr( StrZero(Val(cValorInt),4),2,Len(StrZero(Val(cValorInt),4)) ) + SubStr(cValorDec,1,Len(cValorDec) ) + Replicate( "0", 4-Len(AllTrim(cValorDec)) ) 	
		
ElseIf Empty(RCQ->RCQ_TIPINF)
	cValorRet	:= Alltrim(Str(NoRound(nValorDesc),12,2)) + Replicate("0",8-Len(Alltrim(Str(NoRound(nValorDesc),12,2))))
Endif

Return(cValorRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณMicrosiga           บ Data ณ  05/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se existe algum arquivo TXT no diretorio MV_EDIDIREบฑฑ
ฑฑบ          ณ e permite excluir ou nao os mesmos.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Customizado utilizado na importacao EDI - S.U.A.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function fClearFiles()
Local cWay		:= GetMv("MV_EDIDIRE")
Local aFiles	:= Directory(cWay+"SUA*.TXT")
Local nCont		:= 0
// Tratando os arquivos gerados do SUA
If Len(aFiles) > 0
	If MsgYesNo(STR0001,STR0002)// "Existem arquivos gerados no diret๓rio. Deseja apaga-los ?" //"Encontrado Arquivos"
		For nCont:=1 To Len(aFiles)
			fErase(cWay+aFiles[nCont][1])
		Next
	EndIF
Endif

// Apagando os arquivos gerados do IMSS
aFiles		:= Directory(cWay+"F*.TXT")
nCont		:= 0
If Len(aFiles) > 0
	For nCont:=1 To Len(aFiles)
		fErase(cWay+aFiles[nCont][1])
	Next
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณMicrosiga           บ Data ณ  07/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Fun็ใo para tratar o nome do arquivo a ser criado.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function fNomeArq()
	Static cNomArq := RCO->RCO_CODIGO+Substr(time(),1,2)+Substr(time(),4,2)+Substr(time(),7,2)+".TXT"              
Return(Alltrim(cNomArq))



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณMicrosiga           บ Data ณ  07/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณUsado para tratar o tipo do LayOut a ser gerado. 001 ou 002 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ primeiro layout                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function fCarre1Var(cOpcao)
Static lFirst

If !Empty(cOpcao)
 lFirst	:=Iif(Alltrim(cOpcao) == "000001",.t.,.f.)
ElseIf (cOpcao == Nil)
	lFirst := .T.
Endif
Return lFirst

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณMicrosiga           บ Data ณ  07/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณUsado para tratar o tipo do LayOut a ser gerado. 001 ou 002 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ segundo layOut                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function fCarre2Var(cOpcao)
Static lSecond

If !Empty(cOpcao)
	lSecond:=Iif(Alltrim(cOpcao) == "000002",.t.,.f.)
Endif

Return lSecond

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGeraEmp  บAutor  ณMicrosiga           บ Data ณ  07/25/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Controla a geracao do arquivo para todos os empregados ou  บฑฑ
ฑฑบ          ณ somente para os movimentos do mes selecionado              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function fGeraEmp()

Local lRet := .F.             
Local lReing := .F.
Local aArea		:= GetArea()

//Se o funcionario tem reingresso no mes selecionado, deve gerar a ultima admissao antes do reingresso no arquivo 
// de Empregados
DbSelectArea("RCP")
dbSetOrder(1)
If dbSeek(RCQ->RCQ_FILIAL+RCQ->RCQ_MAT)
	While !RCP->(Eof()) .And. RCQ->RCQ_FILIAL+RCQ->RCQ_MAT == RCP->RCP_FILIAL+RCP->RCP_MAT
		If AnoMes(RCP->RCP_DTMOV)== mv_par05 .And. RCP->RCP_TPMOV == "06"
			lReing := .T.
			Exit
		Endif
		RCP->(dbSkip()	)
	Enddo	
Endif
RestArea(aArea)				

If mv_par07 == 1    //Geracao para todos os empregados
	lRet:= If(RCQ->RCQ_TPMOV $ "01|03",.T.,.F.) 
ElseIf mv_par07 == 2 //Geracao somente entradas no mes ou Emp. com Credito Infonavit
	If (RCQ->RCQ_TPMOV $ "01|03") .And.	 (AnoMes(RCQ->RCQ_DTMOV) == MV_PAR05 .Or.;
		If(RCQ->RCQ_VALINF > 0,.T.,.F.) .Or. lReing )
		lRet:= .T.
	Endif
Endif		

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGeraMov  บAutor  ณMicrosiga           บ Data ณ  07/25/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Controla a geracao do arquivo para todos os empregados ou  บฑฑ
ฑฑบ          ณ somente para os movimentos do mes selecionado              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function fGeraMov()

Local lRet := .F.
Local lReing := .F.
Local aArea		:= GetArea()

DbSelectArea("RCP")
dbSetOrder(1)
If dbSeek(RCQ->RCQ_FILIAL+RCQ->RCQ_MAT)
	While !RCP->(Eof()) .And. RCQ->RCQ_FILIAL+RCQ->RCQ_MAT == RCP->RCP_FILIAL+RCP->RCP_MAT
		If AnoMes(RCP->RCP_DTMOV)== mv_par05 .And. RCP->RCP_TPMOV == "06"
			lReing := .T.
			Exit
		Endif
		RCP->(dbSkip()	)
	Enddo	
Endif
RestArea(aArea)				

If mv_par07 == 1    //Geracao para todos os empregados
	lRet:= If(!(RCQ->RCQ_TPMOV $ "01|03" ),.T.,.F.) 
ElseIf mv_par07 == 2 
	If (!(RCQ->RCQ_TPMOV $ "01|03" ) .And. AnoMes(RCQ->RCQ_DTMOV)==MV_PAR05 ) .Or. (RCQ->RCQ_TPMOV == "02";
		.And. lReing )
		lRet := .T.
	Endif	
Endif		

Return lRet                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfFiltroIn บAutor  ณMicrosiga           บ Data ณ  03/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
 // Parametro usado no LayOut Empregados, importa็ใo do EDI
/*	GPEM03  ฆ01      ฆFilial de ?
 	GPEM03  ฆ02      ฆFilial Ate?
 	GPEM03  ฆ03      ฆCliente De ?
 	GPEM03  ฆ04      ฆLoja De ?
 	GPEM03  ฆ05      ฆCliente Ate?
 	GPEM03  ฆ06      ฆLoja Ate ?
 	GPEM03  ฆ07      ฆFuncionario De ?
 	GPEM03  ฆ08      ฆFuncionario Ate ?
 	GPEM03  ฆ09      ฆDt Movimento de ?
 	GPEM03  ฆ10      ฆDt Movimento ate ?
	GPEM03  ฆ11      ฆRegistro Patronal ?*/
              
User Function fFiltroInc()

Local lRetorno	:= .f.
Local nCont		:= 1
Static _cReg := ""

If ( SR8->R8_FILIAL+SR8->R8_MAT >= MV_PAR01+MV_PAR07 ) .And. (SR8->R8_FILIAL+SR8->R8_MAT <= MV_PAR02+MV_PAR08) .And. ;
	(DTOS(SR8->R8_DATAINI) >= Dtos(mv_par09)) .And. (Dtos(SR8->R8_DATAFIM) <= Dtos(MV_PAR10) )

	//Registro Patronal
	If Empty(_cReg)
		For nCont := 1 To Len( MV_PAR11 ) Step 4
			_cReg := _cReg + SubStr( MV_PAR11 , nCont , 4 )+"*"
		Next nCont		
	Else
		//Caso seja gerado um arquivo para um Registro Patronal, 
		//e depois o usuario inicie uma nova gera็ใo selecionando
		//outro Registro Patronal, recarrega a Static com o novo
		//Registro Patronal - Igor 29/07/2009
		For nCont := 1 To Len( MV_PAR11 ) Step 4
			cRegAux := cRegAux + SubStr( MV_PAR11 , nCont , 4 )+"*"
		Next nCont
		If ( _cReg != cRegAux )
			_cReg := cRegAux
		EndIf
    Endif
	
	//Igor - 29/07/2009  	
  	//If RCO->RCO_CODIGO $ _cReg 
  	If ( SR8->R8_CODRPAT $ _cReg )
		lRetorno	:= .T.
  	Endif
Endif

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfRetInc   บAutor  ณSilvia Taguti       บ Data ณ  03/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna Ausencias do tipo Incapacidade                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function fRetInc(cVerba)
Local lRet := .F.

dBSelectArea("SRV")
DbSetOrder(1)
SRV->(DbSeek(xFilial("SRV")+cVerba ) )

If SRV->RV_CODFOL $ "0439|0583|0438"  //Incapacidades
	lRet := .T.
Endif		

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfRamaSeg  บAutor  ณSilvia Taguti       บ Data ณ  03/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a Rama de Incapacidad                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function fRamaSeg(cVerba)
Local cRama := " "

dBSelectArea("SRV")
DbSetOrder(1)
SRV->(DbSeek(xFilial("SRV")+cVerba ) )

If SRV->RV_CODFOL == "0439"  //Riesgo de Trabajo
	cRama := "1"
ElseIf SRV->RV_CODFOL == "0583" 	//Enfermedad General
	cRama := "2"
ElseIf SRV->RV_CODFOL == "0438"     	//Maternidad
	cRama := "3"
Else
	cRama := " "
Endif		

Return(cRama)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfNewVarTotบ Autor ณ Igor Franzoi       บ Data ณ  26/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Zera variavel private que esta na fun็ใo U_EDITOTAL, para  บฑฑ
ฑฑบ          ณ quando for gerado um novo arquivo sem sair do Remote		  บฑฑ
ฑฑบ          ณ recomece a contagem										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ EDI - GPXFUNEDI											  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function fNewVarTot()

If ValType(VAR_IXB) != "U"
	VAR_IXB := NIL
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfPosPrimRCPบ Autor ณ Igor Franzoi      บ Data ณ  26/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Posiciona no primeiro registro do RCO conforme o Registro  บฑฑ
ฑฑบ          ณ Patronai Selecionado do RCP								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ EDI - GPXFUNEDI											  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function fPosRCPP()
//alterado de fPosPrimRCP para fPosRCPP
Local cRegFisrt := ""

If !Empty(MV_PAR11)
	cRegFisrt := SubStr( MV_PAR11 , 1 , 4 )
EndIf

Return cRegFisrt

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfPosPrimRCQบ Autor ณ Igor Franzoi      บ Data ณ  26/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Posiciona no primeiro registro do RCO conforme o Registro  บฑฑ
ฑฑบ          ณ Patronai Selecionado do RCQ								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ EDI - GPXFUNEDI											  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function fPosRCQP()
//alterado de fPosPrimRCQ para fPosRCQP 
Local cRegFisrt := ""

If !Empty(MV_PAR06)
	cRegFisrt := SubStr( MV_PAR06 , 1 , 4 )
EndIf

cRegFisrt := U_fCodRegPat( "", cRegFisrt )

Return cRegFisrt

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfCodRegPatบ Autor ณ Igor Franzoi      บ Data ณ  29/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Posiciona no Registro Patronal							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ EDI - GPXFUNEDI											  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function fCodRegPat( cCodFil, cCodReg, nOpc )

Local aArea 	:= GetArea()

Local nCont		:= 0

Local cRegAux	:= ""
Local cNrPat 	:= ""
Local cFilFind	:= xFilial("RCO")

Default nOpc	:= 0

If ( nOpc == 0 )

	If Len(Alltrim(cFilFind)) = 0
		cCodFil := cFilFind
	EndIf
	
	dbSelectArea("RCO")
	dbSetOrder(RetOrder("RCO","RCO_FILIAL+RCO_CODIGO+RCO_NREPAT"))
	If (dbSeek(cCodFil+cCodReg))
		cNrPat := RCO->RCO_NREPAT
	EndIf

ElseIf ( nOpc == 1 )

	If Len(AllTrim(cFilFind)) = 0
		cCodFil := cFilFind
	EndIf
	
	dbSelectArea("RCO")
	dbSetOrder(RetOrder("RCO","RCO_FILIAL+RCO_CODIGO+RCO_NREPAT"))
	For nCont := 1 To Len(AllTrim(MV_PAR06)) Step 4
		cRegAux := SubStr( MV_PAR06 , nCont , 4 )
		If (dbSeek(cCodFil+cRegAux))
			cNrPat += RCO->RCO_NREPAT+"/"
		EndIf
	Next

EndIf

RestArea(aArea)

Return cNrPat

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfValCodRPatบ Autor ณ Igor Franzoi     บ Data sณ  26/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna os registros patronais							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ EDI - GPXFUNEDI											  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function fValCodRPat()

Local nCont		:= 0
Local cRegAux 	:= ""

Static _cReg := ""

//Registro Patronal
If Empty(_cReg)
	For nCont := 1 To Len( MV_PAR11 ) Step 4
		_cReg := _cReg + SubStr( MV_PAR11 , nCont , 4 )+"*"
	Next nCont
Else
	//Caso seja gerado um arquivo para um Registro Patronal, 
	//e depois o usuario inicie uma nova gera็ใo selecionando
	//outro Registro Patronal, recarrega a Static com o novo
	//Registro Patronal - Igor 29/07/2009
	For nCont := 1 To Len( MV_PAR11 ) Step 4
		cRegAux := cRegAux + SubStr( MV_PAR11 , nCont , 4 )+"*"
	Next nCont
	If ( _cReg != cRegAux )
		_cReg := cRegAux
	EndIf
Endif

Return _cReg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPXFUNEDI บAutor  ณIgor Franzoi        บ Data ณ  04/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo utilizada para valida็ใo de Layout x Cliente		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function fValCliLay( nOption, cLayout )

Local lRet		:= .F.

Local aArea		:= GetArea()

DEFAULT nOption	:= 0

//So passa a primeira vez para carregar a Variavel Static cOption
If ( nOption == 1 )
	cOption := cLayout
EndIf

//Para cada cliente configurado foi criado um tipo de layout,
//para nใo gerar conflito quando for efetuada a gera็ใo dos arquivos
//Os c๓digos de clientes estใo fixos nesta rotina, mas podem ser alterados sem problema algum

//MV_PAR01 - Representa a pergunta - Cliente DE
//MV_PAR02 - Representa a pergunta - Cliente ATE
If ( !Empty(cOption) .and. nOption != 1 )
	//Arquivo de Reingresso
	If ( AllTrim(MV_PAR01) == "200000" .and. AllTrim(MV_PAR03) ==  "200000" .and. AllTrim(cOption) == "000001" )
		lRet := .T.
	//Arquivo de Modifica็ใo de Salแrio	
	ElseIf ( AllTrim(MV_PAR01) == "200001" .and. AllTrim(MV_PAR03) ==  "200001" .and. AllTrim(cOption) == "000002" )
		lRet := .T.
	//Arquivo de Baixa
	ElseIf ( AllTrim(MV_PAR01) == "200002" .and. AllTrim(MV_PAR03) ==  "200002" .and. AllTrim(cOption) == "000003" )
		lRet := .T.
	//SUA Empregados
	ElseIf ( AllTrim(MV_PAR01) == "300000" .and. AllTrim(MV_PAR03) ==  "300000" .and. AllTrim(cOption) == "000004" )
		lRet := .T.
	//SUA Movimentos
	ElseIf ( AllTrim(MV_PAR01) == "300001" .and. AllTrim(MV_PAR03) ==  "300001" .and. AllTrim(cOption) == "000005" )
		lRet := .T.
    //SUA Movimento de Credito
	ElseIf ( AllTrim(MV_PAR01) == "300002" .and. AllTrim(MV_PAR03) ==  "300002" .and. AllTrim(cOption) == "000006" )
		lRet := .T.
	EndIf
EndIf

RestArea(aArea)

Return lRet
