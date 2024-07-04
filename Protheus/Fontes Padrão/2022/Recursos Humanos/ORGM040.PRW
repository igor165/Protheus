#INCLUDE "ORGM040.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "HEADERGD.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ORGM040    ³ Autor ³ Rogerio R. Cruz      ³ Data ³ 18/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro Estrutura da Conta                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ORGM040()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³01/08/14³TQEIB9³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±³Tiago Malta ³24/08/15³PCREQ ³Ajustes no controle de alterações de      ³±±
±±³			   ³		³-4824 ³ dicionarios para utilização na versão 12.³±±
±±³		       ³		³	   ³Changeset 244117 Data 04/08/2014          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ORGM040()
	Private aRotina		:= MenuDef()
	Private cCadastro 	:= STR0001  // "Cadastro de Configuracao de Segmentos"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MBrowse(,,,,"RH1", NIL, NIL, NIL, NIL, NIL, LegendDef() )	
Return
                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ORGM040Rot ³ Autor ³ Rogerio R. Cruz      ³ Data ³ 19/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao Linha da getdados - Estrutura Conta              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ORGM040Rot()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ORGM040Rot(cAlias, nReg, nOpc)
	Local aSaveArea 	:= GetArea()
	Local nOpca		:= 0
	Local nGetSX8Len:= GetSX8Len()
	
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjCoords	:= {}
	Local aObjSize		:= {}
	
	Private oDesc
	//Private aTELA[0][0],aGETS[0]
	Private aCols 		:= {}
	Private aHeader		:= {}
	Private nUsado 		:= 0
	Private nPosDig, nPosDesc, nPosSep, nPosSeq

	Private cTesteDig	:= Space(20)
	Private oGetTeste
	Private oEnch
	            
	SetMemVar("RETURNVAL",	"",	.T.)
	             
	RegToMemory(cAlias, (nOpc == 3))
	
	If nOpc == 3
		cKeySeek	:= ""
		bSeekWhile	:= {|| "*"}
	Else
		cKeySeek	:= xFilial("RH0")+RH1->RH1_CODIGO
		bSeekWhile	:= {|| RH0->RH0_FILIAL+RH0->RH0_CODIGO}
	EndIf

	aCols	:= RH0->(GdMontaCols(	@aHeader,;
					 				@nUsado,;
									NIL,;
									NIL,;
									NIL,;			//5
									{"RH0_FILIAL", "RH0_CODIGO"},;
									NIL,;
									"RH0",;
									cKeySeek,;
								    bSeekWhile	 )	)
								    
	If nOpc == 3
		aCols[1,1]:= "01"
	EndIf

	nPosDig	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "RH0_DIGITO"})
	nPosDesc:= Ascan(aHeader,{|x|Alltrim(x[2]) = "RH0_DESC"})
	nPosSep	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "RH0_SEPARA"})
	nPosSeq := Ascan(aHeader,{|x|Alltrim(x[2]) = "RH0_SEGMEN"})
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize := MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )  
	
	DEFINE MSDIALOG oDlg TITLE STR0003 FROM aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL //"Cambio Moedas Contabeis"
   	
		DEFINE FONT oFnt NAME "Tahoma" Size 12,22 
    	    
		oEnch	:= MsmGet():New(	"RH1"		,;
									nReg		,;
									nOpc		,;
									NIL			,;
									NIL			,;
									NIL			,;
									{"RH1_TABELA", "RH1_CAMPO"}	,;
									{aObjSize[1,1], aObjSize[1,2]+5, aObjSize[1,3]*0.18,aObjSize[1,4]* 0.75},; //{17, 5, 32, 315}
									{"RH1_TABELA", "RH1_CAMPO"}	,;
									NIL			,;
									NIL			,;
									NIL			,;
									oDlg		,;
									NIL			,;
									.F.			,;
									NIL			,;
									.F.			 ;
								)
				    

	    oGet := 	MSGetDados():New(	aObjSize[1,1]* 4.2,;    
										aObjSize[1,2]+5,;       
										aObjSize[1,3]* 0.69,;   
										aObjSize[1,4]* 0.75,;   
										nOpc,;
										"ORGM040Linok",;
										"ORGM040Tudok",;
										"+RH0_SEGMEN",;
										.T.,;
										NIL,;
										NIL,;
										NIL,;
										NIL,;
										NIL,;
										NIL,;
										NIL,;
										"ORGM040Exibe")
	    
		@ aObjSize[1,1]+(aObjSize[1,3]*0.66),aObjSize[1,2]+5 TO aObjSize[1,1]+(aObjSize[1,3]*0.77),;
		  aObjSize[1,2]+(aObjSize[1,4]*0.75) LABEL STR0015 OF oDlg PIXEL COLOR CLR_RED
		
		@ aObjSize[1,1] + (aObjSize[1,3]* 0.69),aObjSize[1,2]+10;
		  SAY oDesc PROMPT space(50) OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE
        
        @ aObjSize[1,1] + (aObjSize[1,3]* 0.79),aObjSize[1,2]+5 TO aObjSize[1,1] + (aObjSize[1,3]* 0.90),;
          aObjSize[1,2] + (aObjSize[1,4]* 0.75) LABEL STR0002 OF oDlg PIXEL COLOR CLR_RED //Teste de digitação
		
		@ aObjSize[1,1] + (aObjSize[1,3]* 0.83),aObjSize[1,2] +10 MSGET oGetTeste; 	
					VAR cTesteDig ;
					SIZE 070,08;
					F3 "SGTEST";
					VALID Vazio() .OR. ValidaSegmento();					
					OF oDlg PIXEL
		
		ORGM040Exibe()
								
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
		   				{||nOpca:=1,If(nOpc = 3 .Or. nOpc = 4,If(ORGM040Tudok(),oDlg:End(),nOpca:=0),oDlg:End())},;
						{||oDlg:End()}		)
	
	
	If nOpca == 1						
		BEGIN TRANSACTION
			ORGM040Grava(nOpc)
			
			While ( GetSX8Len() > nGetSX8Len )
				ConfirmSX8()
			End While	
		END TRANSACTION
	Else
		While ( GetSX8Len() > nGetSX8Len )
			RollBackSX8()
		End While
	EndIf	
	
	RestArea(aSaveArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ORGM040LinOk ³ Autor ³ Rogerio R. Cruz      ³ Data ³ 19/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao Linha da getdados - Estrutura Conta              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ORGM040LinOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ORGM040LinOk()
	Local nCont
	Local nTamMax := GetSx3Cache(M->RH1_CAMPO, "X3_TAMANHO")
	Local nTamConta := 0
	Local lRet		:= .T.

	For nCont := 1 To n
		If !aCols[nCont][nUsado+1]
			nTamConta += Val(aCols[nCont][nPosDig]) + Len( RTrim(aCols[nCont][nPosSep]) )
		EndIf
	Next nCont
	
	If nTamConta > nTamMax		
		Help(" ",1,"CT130MAIOR")
		lRet := .f.
	EndIf
Return lRet	
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ORGM040Tudok ³ Autor ³ Rogerio R. Cruz      ³ Data ³ 19/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da getdados - Estrutura da Conta                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ORGM040Tudok()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ORGM040Tudok()
	Local nCont
	Local nTamMax 	:= GetSx3Cache(M->RH1_CAMPO, "X3_TAMANHO")
	Local nTamConta := 0
	Local lRet		:= .T.
	   
	DBSelectArea("RH1")
	DBSetOrder(2)

	If DBSeek(xFilial("RH1") + M->RH1_TABELA + M->RH1_CAMPO)
		If RH1->RH1_CODIGO != M->RH1_CODIGO
			MsgAlert(STR0003) //"Tabela/Campo já cadastrados!"
			Return .F.
		EndIf
	EndIf
	
	For nCont := 1 To Len(aCols)
		If !aCols[nCont][nUsado+1]
			nTamConta += Val(aCols[nCont][nPosDig]) + Len(RTrim(aCols[nCont][nPosSep]))
		EndIf
	Next nCont
	
	If nTamConta > nTamMax		
		Help(" ",1,"CT130MAIOR")
		lRet := .f.
	EndIf
Return lRet	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ORGM040Exibe ³ Autor ³ Rogerio R. Cruz      ³ Data ³ 19/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe Estrutura da conta                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ORGM040Exibe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ORGM040Exibe()
	Local nCont
	Local cConta := ""
	
	For nCont := 1 To Len(aCols)
		If !aCols[nCont][nUsado+1]
			cConta += Replicate("X", Val(aCols[nCont][nPosDig]))
			cConta += RTrim(aCols[nCont][nPosSep])
	    EndIf
	Next nCont
	
	IF Type("oDesc")=="O"
		oDesc:SetText(cConta)
	Endif
	
	IF Type("oGetTeste")=="O"	
		oGetTeste:Picture:= "@! " + cConta
	Endif
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ORGM040Grava ³ Autor ³ Rogerio R. Cruz      ³ Data ³ 19/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao dos dados - Estrutura Conta                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA130                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1=Codigo da Mascara                                    ³±±
±±³          ³ ExpN1=Numero da Opcao escolhida                            ³±±
±±³          ³ ExpC2=Descricao da Mascara                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ORGM040Grava(nOpc)
	Local aSaveArea := GetArea()
	Local nCont, nField

	dbSelectArea("RH0")
	dbSetOrder(1)        

	If nOpc == 3 .Or. nOpc == 4			// Inclusao / Alteracao
		DBSelectArea("RH1")
		DBSetOrder(1)
		
		If !DBSeek(xFilial("RH1") + M->RH1_CODIGO)
			RecLock("RH1",.T.)
			RH1->RH1_FILIAL:= xFilial("RH1")
			RH1->RH1_CODIGO:= M->RH1_CODIGO
			RH1->RH1_TABELA:= M->RH1_TABELA
			RH1->RH1_CAMPO := M->RH1_CAMPO
			RH1->RH1_STATUS:= M->RH1_STATUS
			MsUnlock()
	    EndIf
	    
   		DBSelectArea("RH0")
		DBSetOrder(1)

		For nCont := 1 To Len(aCols)
			If aCols[nCont][nUsado+1] == .F. .And. !Empty(aCols[nCont][nPosDig])
				If !DBSeek(xFilial("RH0") + M->RH1_CODIGO + aCols[nCont][1])
					RecLock("RH0",.T.)
					RH0->RH0_FILIAL:= xFilial("RH0")
					RH0->RH0_CODIGO:= M->RH1_CODIGO
				Else
					RecLock("RH0",.F.)
				EndIf	
				        
				For nField:= 1 To Len(aHeader)
					If IsHeadRec(aHeader[nField, __AHEADER_FIELD__]) .OR. IsHeadAlias(aHeader[nField, __AHEADER_FIELD__])
						Loop
					EndIf
					
					RH0->(FieldPut(FieldPos(aHeader[nField, __AHEADER_FIELD__]), aCols[nCont, nField]))
				Next
				
				MsUnlock()
			Else
				If dbSeek(xFilial("RH0") + M->RH1_CODIGO + aCols[nCont][1])
					RecLock("RH0", .F., .T.)
					dbDelete()
					MsUnlock()
				EndIf			
			EndIf
		Next nCont    
		
	ElseIf nOpc == 5				// Exclusao       
		DBSelectArea("RH0")
		DBSetOrder(1)
		
		If DBSeek(xFilial("RH0") + M->RH1_CODIGO)
			While !Eof() .And. ;
					xFilial("RH0") == RH0->RH0_FILIAL .And. ;
					M->RH1_CODIGO == RH0->RH0_CODIGO
				RecLock("RH0",.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo	
		EndIf

		DBSelectArea("RH1")
		DBSetOrder(1)
		
		If DBSeek(xFilial("RH1") + M->RH1_CODIGO)
			RecLock("RH1",.F.,.T.)
			dbDelete()
			MsUnlock()
		EndIf
	EndIf
	
	RestArea(aSaveArea)
Return
                         
Function ValidaSegmento(cTableName, cFieldName)
	Local nIniPos:= 1
	Local cReadVar:= ReadVar()
	Local cTempVar:= __ReadVar
	Local lReturn:= .T.
	                         
	Default cTableName:= M->RH1_TABELA
	Default cFieldName:= M->RH1_CAMPO
	
	Private xReadVar                  	
	
	__ReadVar:= "xReadVar"

	DBSelectArea("RH1")
	DBSetOrder(2)

	If !DBSeek(xFilial("RH1") + cTableName + cFieldName)
		Return .T.
	EndIf
	
	DBSelectArea("RH0")
	DBSetOrder(1)
		
	RH0->(DBSeek(xFilial("RH0") + RH1->RH1_CODIGO))
	
	While .NOT. RH0->(EOF()) .AND.;
			RH0->RH0_FILIAL == xFilial("RH0") .AND.;
			RH0->RH0_CODIGO ==  RH1->RH1_CODIGO .AND.;
			lReturn
		xReadVar:= SubStr(&(cReadVar), nIniPos, Val(RH0->RH0_DIGITO))
		
		If .NOT. Empty(RH0->RH0_VALID)
			lReturn:= &(RH0->RH0_VALID)
		EndIf
		
		nIniPos+= Val(RH0->RH0_DIGITO) + Len(Rtrim(RH0->RH0_SEPARA))

		RH0->(DBSkip())
	EndDo
	
	__ReadVar:= cTempVar

/*	If lReturn
		lReturn:= ExistChav("SQB") .And. FreeForUse("SQB", M->QB_DEPTO)
	EndIf*/
Return lReturn

Function VldSegSQB(cTableName, cFieldName)
	Local lReturn
	Local cChave 	:= &(ReadVar())
	Local bIniCpo
	Local cTemp
	Local aAreaSX3	:= SX3->(GetArea())
	Local aAlter	:= {}
	
	Default cTableName:= M->RH1_TABELA
	Default cFieldName:= M->RH1_CAMPO
	
	bIniCpo	:= &("{ || SetMemVar('"+cFieldName+"', '" +cChave+ "', .T.) }")
	
	SX3->(DbSetOrder(1))
	SX3->(DbSeek(cTableName))

	While SX3->X3_ARQUIVO == cTableName
		cTemp:= AllTrim(SX3->X3_CAMPO)

		If cTemp != cFieldName
			Aadd(aAlter, cTemp)
		EndIf
		
		SX3->(DBSkip())
	EndDo
		
	//DbSetOrder(nOrdem)
	lReturn:= (cTableName)->(DbSeek(xFilial(cTableName)+cChave))

	IF !lReturn
		lReturn:= AxInclui(cTableName, NIL, NIL, NIL, NIL, aAlter, NIL, NIL, NIL, NIL, {bIniCpo, {|| .T.}, {|| .T.}, {|| .T.}})  == 1
	EndIf

	SX3->(RestArea(aAreaSX3))
Return lReturn

Function ConsultaSegmento(cTableName, cFieldName)
	Local cCampo	:= ""
	Local lSeek		:= .F.
	
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjCoords	:= {}
	Local aObjSize		:= {}
	
	Local bSet15			:= { || NIL }
	Local bSet24			:= { || NIL }
	
	Default cTableName:= M->RH1_TABELA
	Default cFieldName:= M->RH1_CAMPO

	cFieldName:= PadR(cFieldName, 10)
	//cCampo	:= Replicate("*", GetSx3Cache(cFieldName, "X3_TAMANHO"))
	
	Private oDlgPesquisa
	Private oBigGet
	Private oScroll 
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize := MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )  
	
	DEFINE MSDIALOG oDlgPesquisa FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL TITLE OemToAnsi(STR0010)//"Pesquisa"
		
		@ aObjSize[1,1]* 1.2,aObjSize[1,2]+5 MSGET oBigGet VAR cCampo SIZE 206,10 READONLY PIXEL
		
		bSet15	:= {|| lSeek:= .T., oDlgPesquisa:End()}
		bSet24	:= {|| oDlgPesquisa:End()}
		
		@aObjSize[1,1] + (aObjSize[1,1]* 1.4),aObjSize[1,2]+5 MSPANEL oPPreview SIZE 205,84 OF oDlgPesquisa
		@aObjSize[1,1] + (aObjSize[1,1]* 1.4),aObjSize[1,2]+5 SCROLLBOX oScroll VERTICAL SIZE 84,205 BORDER
		
		DrawSegments(@oScroll, cTableName, cFieldName)
																						
	ACTIVATE MSDIALOG oDlgPesquisa ON INIT EnchoiceBar(oDlgPesquisa, bSet15 , bSet24) CENTERED

	If lSeek	
		//SetMemVar("RETURNVAL", cCampo, .T.)
		&(ReadVar()):= cCampo
	EndIf
Return lSeek

Static Function DrawSegments(oDialog, cTableName, cFieldName)

	Local nTop:= 5
	Local nSegment	:= 1
	Local nIniPos	:= 1
	Local nWidthGet
	Local nWidthSay
	Local cPict
	Local cVar
	Local bGet
	Local bSay
	Local bValid
	Local cPictFull:= ""
	Local cSepar
	
	_SetOwnerPrvt("aSegments", {})
	
	DBSelectArea("RH1")
	DBSetOrder(2)	

	If !DBSeek(xFilial("RH1") + cTableName + cFieldName)
		Return .T.
	EndIf
	
	DBSelectArea("RH0")
	DBSetOrder(1)
		
	RH0->(DBSeek(xFilial("RH0") + RH1->RH1_CODIGO))
	
	While .NOT. RH0->(EOF()) .AND.;
			RH0->RH0_FILIAL == xFilial("RH0") .AND.;
			RH0->RH0_CODIGO == RH1->RH1_CODIGO
		ASize(aSegments, nSegment)

		//cPict := If(Empty(RH0->RH0_PICTUR), NIL, AllTrim(RH0->RH0_PICTUR))
		cPict:= Replicate("X", Val(RH0->RH0_DIGITO))
		cSepar:= RTrim(RH0->RH0_SEPARA)
		cPictFull+= cPict + cSepar
		nWidthGet := CalcFieldSize("C", Val(RH0->RH0_DIGITO), 0, NIL, " ") + IIF(Empty(RH0->RH0_CONPAD), 0, 15)
		nWidthSay := CalcFieldSize("C", GetSx3Cache("RH0_DESC", "X3_TAMANHO"), 0, NIL, " ")
		aSegments[nSegment] := Space(Val(RH0->RH0_DIGITO))

		cVar	:= "aSegments[" + StrZero(nSegment, 2) + "]"
		bSay	:= &("{ | | '" + RH0->RH0_DESC + "'}")
		bGet	:= &("{ |u| If( PCount() == 0, " + cVar + "," + cVar + " := u)}")
		bValid	:= &("{ | | ValidSegment("+ Str(nIniPos) + "," + RH0->RH0_DIGITO + ", '" + RH0->RH0_VALID + "' ) }")
		
		TSay():New(nTop+2, 10, 			  bSay, oDialog, NIL, NIL, .F., .F., .F., .T., NIL, NIL, nWidthSay, 15, .F., .F., .F., .F., .F.)
		TGet():New(nTop,   nWidthSay+10, bGet, oDialog, nWidthGet, 10, cPict, bValid, NIL, NIL, NIL, .F., NIL, .T., NIL, .F., NIL, .F., .F., NIL, .F., .F., IIF(Empty(RH0->RH0_CONPAD), NIL, RH0->RH0_CONPAD), cVar, NIL, NIL, NIL, .T.)
			     
		nIniPos+= Val(RH0->RH0_DIGITO) + Len(cSepar)
		nSegment++
		nTop+= 15
		RH0->(DBSkip())
	EndDo
	
	cPictFull:= AllTrim(cPictFull)
	
	oBigGet:Picture:= "@! " + cPictFull
	oBigGet:cText:= Replicate("*", Len(cPictFull))	
Return

Function ValidSegment(nIniPos, nTamanho, cValid)
	Local lReturn	:= .T.
	Local xValue	:= &(ReadVar())

	If !Empty(cValid)
		lReturn	:= &(cValid)
	EndIf
	
	If lReturn .AND. !Empty(xValue)
		oBigGet:cText:= Stuff(oBigGet:cText, nIniPos, nTamanho, xValue)
	Else
		oBigGet:cText:= Stuff(oBigGet:cText, nIniPos, nTamanho, Replicate("*", nTamanho))
	EndIf	
Return lReturn

Function ORGM040Tab()
	Local lReturn:= ExistCpo("SX2")

	ORGM040Exibe()
Return lReturn


Function ORGM040Cam()
	Local lReturn:= ExistCpo("SX3", NIL, 2)
	
	ORGM040Exibe()
Return lReturn


Function ORGM040Sep()
	ORGM040Exibe()
Return .T.


Function ORGM040Dig()
	ORGM040Exibe()
Return .T.

Function ORGM040Vld()
	Local lReturn:= CheckExecForm(&(ReadVar()), .T.)

	ORGM040Exibe()
Return lReturn

Function ORGM040Cpd()
	Local lReturn:= ExistCpo("SXB")
		
	ORGM040Exibe()
Return lReturn

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡…o    ³LegendDef	   ³Autor³Rogerio Ribeiro       ³ Data ³05/07/2007³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descri‡…o ³											    		    ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Sintaxe   ³<Vide Parametros Formais>									³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Parametros³<Vide Parametros Formais>									³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Uso       ³										              		³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function LegendDef()
	Local aCores:=	{{"RH1->RH1_STATUS  = '1'", 'BR_BRANCO'},;		// Não aplicado
					 {"RH1->RH1_STATUS  = '2'", 'BR_AZUL'}	}		// Aplicado

Return aCores

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡…o    ³LegendPopUp  ³Autor³Rogerio Ribeiro       ³ Data ³05/07/2007³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descri‡…o ³											    		    ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Sintaxe   ³<Vide Parametros Formais>									³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Parametros³<Vide Parametros Formais>									³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Uso       ³										              		³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function ORGM040Leg()
	BrwLegenda(cCadastro, STR0015,	{	{'BR_BRANCO',	OemToAnsi(STR0016)},;		// Não aplicado
										{'BR_AZUL',		OemToAnsi(STR0017)} } )		// Aplicado
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ORGM040Exibe ³ Autor ³ Rogerio R. Cruz      ³ Data ³ 19/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe Estrutura da conta                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ORGM040Exibe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()
	Local aRotina 	:= {	{ STR0009,"AxPesqui",   0 , 1, NIL, .F.},;	 //"Pesquisar"
							{ STR0010,"ORGM040Rot", 0 , 2},;	//"Visualizar"
							{ STR0011,"ORGM040Rot", 0 , 3},;	//"Incluir"
							{ STR0012,"ORGM040Rot", 0 , 4},;	//"Alterar"
							{ STR0013,"ORGM040Rot", 0 , 5},;	//"Excluir"
							{ STR0015,"ORGM040Leg", 0 , 6} }	//"Legenda"
Return aRotina
