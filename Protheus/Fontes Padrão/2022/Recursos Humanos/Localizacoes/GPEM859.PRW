#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include "Topconn.ch"
#include "GPEM859.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma    ณGPEM859   บAutor  ณTiago Malta         บ Data ณ  03/31/11   บฑฑ
ฑฑฬออออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.       ณ Rotina para gera็ใo do ARC.                                บฑฑ
ฑฑบ            ณ                                                            บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso         ณ Venezuela.                                                 บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ Data     ณ   BOPS    ณ  Motivo da Alteracao                บฑฑ
ฑฑฬออออออออออออุออออออออออุอออออออออออุอออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบTiago Malta ณ11/05/2011ณ009206/2011ณAltera็ใo de Estrutura de campos     บฑฑ
ฑฑบ            ณ          ณ           ณ para o ARI.                         บฑฑ
ฑฑบ            ณ          ณ           ณ                                     บฑฑ
ฑฑบJonathan Glzณ04/05/2015ณ PCREQ-4256ณSe realiza ajuste a funcion GPEM859, บฑฑ
ฑฑบ            ณ          ณ           ณse elimina la modificacion al diccio-บฑฑ
ฑฑบ            ณ          ณ           ณnario de datos (SX1) por motivo de   บฑฑ
ฑฑบ            ณ          ณ           ณadeciacion de nueva estructura de SXsบฑฑ
ฑฑบ            ณ          ณ           ณpara version 12                      บฑฑ
ฑฑศออออออออออออสออออออออออสอออออออออออสอออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function GPEM859()

Local aArea			:= GetArea()
Local cFilRGS			:= ""
Local nOpca			:= 0
Local aIndexSRA		:= {}				//Variavel Para Filtro
Private bFiltraBrw 	:= {|| Nil}		//Variavel para Filtro
Private cCadastro 	:= OemToAnsi(STR0001)

	DbSelectArea("SRA")
	SRA->(DbsetOrder(1))
	SRA->(DbGoTop())

	cFiltraRh := CHKRH("GPEM859","SRA","1")
	bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
	Eval(bFiltraBrw)

	aRotina :=  MenuDef()

	mBrowse( 6, 1,22,75,"SRA",,,,,,,,,,,,,,/*cFilRGS*/)
	EndFilBrw("SRA",aIndexSRA)

RETURN()

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao   ณMenuDef  ณ Autor ณTiago Malta                      ณ Data ณ 03/02/09  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricaoณ Menu da Manutencao ARC  							                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso     ณ Microsiga-Venezuela			                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
Static Function MenuDef()

Local aRotina :=	{	{STR0002,"PesqBrw"  		, 0 , 1,,.F.},; //"Pesquisar"
						{STR0003,"GPEM859M"    , 0 , 4},;
						{STR0004,"GPER857"  		, 0 , 7} } //"Imprimir ARC"
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPEM859M  บAutor  ณMicrosiga           บ Data ณ  03/31/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para Manuten็ใo do ARC.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPEM859M()

Local aAdvSize		:= MsAdvSize()
Local aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
Local aObjSize      := {}
Local aHeader       := {}
Local aObjCoords    := {}
Local i
Local oGroup1
Local oGroup2
Local oGroup3
Local oButton1
Local oButton2
Local oFont

Private oGet
Private aCols         := {}

	Pergunte("GPEM859",.T.)

	aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )

	dbSelectArea("SX3")
	SX3->(dbSetOrder(1))
	SX3->(dbSeek("RH9"))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "RH9"
		If X3Uso(SX3->X3_USADO) .AND. SX3->X3_CAMPO <> "RH9_MAT"
			Aadd(aHeader,	{	Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,	;
			SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,,SX3->X3_WHEN,	;
			SX3->X3_VISUAL,SX3->X3_VLDUSER, SX3->X3_PICTVAR,SX3->X3_OBRIGAT	})
		EndIf

		SX3->(dbSkip())
	EndDo

	AAdd(aCols,Array(Len(aHeader)+1))
	For i := 1 To Len(aHeader)
			aCols[Len(aCols)][i] := CriaVar(aHeader[i,2])
	Next i
	aCols[Len(aCols)][Len(aHeader)+1] := .F.

	// Fun็ใo que carrega registros
	GP859CRG()

	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL

	    @ aObjSize[1,1]+2  , aObjSize[1,1]+5 GROUP oGroup1 TO aObjSize[1,3]-2 , aObjSize[1,4]*(29/100) PROMPT STR0005 OF oDlg COLOR 0, 16777215 PIXEL
	    @ aObjSize[1,1]+8  , aObjSize[1,1]+15 SAY SRA->RA_MAT SIZE 120,20 OF oDlg PIXEL
	    oGroup1:oFont:= oFont

	    @ aObjSize[1,1]+2 , aObjSize[1,4]*(30/100) GROUP oGroup2 TO aObjSize[1,3]-2, aObjSize[1,4]*(70/100) PROMPT STR0006 OF oDlg COLOR 0, 16777215 PIXEL
	    oGroup2:oFont:= oFont
	    @ aObjSize[1,1]+8  , aObjSize[1,4]*(30/100)+10 SAY SRA->RA_NOME SIZE 120,20 OF oDlg PIXEL

	    @ aObjSize[1,1]+2 , aObjSize[1,4]*(71/100) GROUP oGroup3 TO aObjSize[1,3]-2, aObjSize[1,4]*(92/100) PROMPT STR0007 OF oDlg COLOR 0, 16777215 PIXEL
	    oGroup3:oFont:= oFont
	    @ aObjSize[1,1]+8  ,aObjSize[1,4]*(71/100)+10 SAY SRA->RA_ADMISSA SIZE 120,20 OF oDlg PIXEL

   		@ aObjSize[1,1]+4 , aObjSize[1,4]*(93/100) BUTTON oButton2 PROMPT STR0008 Action(oDlg:end()) SIZE 25, 012 OF oDlg PIXEL

	  	oGet := MsNewGetDados():New(	aObjSize[2][1]+2					,;
										aObjSize[2][2]	 					,;
										aObjSize[2][3]						,;
										aObjSize[2][4]						,;
										0                                  ,;
										""							        	,;
										""								       ,;
										nil							        	,;
										nil							        	,;
										0							        	,;
										0							        	,;
										Nil										,;
										Nil										,;
										nil							        	,;
										oDlg									,;
										aHeader								,;
										aCols				 					)

	ACTIVATE MSDIALOG oDlg Centered

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGP859CRG   บAutor  ณTiago Malta        บ Data ณ  04/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para carregar informa็๕es na Tela.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GP859CRG()

Local cQuery := ""
Local aItens:= {}
Local i
Local nPos   := 0

	cQuery += "SELECT RD_FILIAL,RD_MAT,RD_PD,RD_HORAS,RD_VALOR,RD_DATARQ, RV_DIRF,RV_TIPOCOD FROM " + RetSqlName("SRD") + " SRD "
	cQuery += "INNER JOIN " + RetSqlName("SRV") + " SRV ON RV_COD = RD_PD "
	cQuery += "WHERE SRV.D_E_L_E_T_ = '' AND SRD.D_E_L_E_T_ = '' "
	cQuery += "AND RV_DIRF <> '' "
	cQuery += "AND SUBSTRING(RD_DATARQ,1,4) = '"+MV_PAR01+"' "
	cQuery += "AND RD_FILIAL = '"+SRA->RA_FILIAL+"' "
	cQuery += "AND RD_MAT = '"+SRA->RA_MAT+"' "
	cQuery += "AND ( RD_ROTEIR = 'NOM' OR RD_ROTEIR = 'UTA' OR RD_ROTEIR = 'UTF' OR RD_ROTEIR = 'CES' OR RD_ROTEIR = 'GAN') "
	cQuery += "ORDER BY RD_DATARQ,RV_DIRF ,RD_MAT,RD_PD"

	IF SELECT("TMPSRD") > 0
		TMPSRD->( DBCLOSEAREA() )
	ENDIF
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPSRD",.F.,.T.)

	Acols := {}

	TMPSRD->(dbgotop())
	While TMPSRD->(!eof())

		IF TMPSRD->RV_DIRF <= "06"
			IF ( nPos := aScan( aItens, {|x| x[1] == SUBSTR(TMPSRD->RD_DATARQ,1,4) .AND. x[2] == SUBSTR(TMPSRD->RD_DATARQ,5,2)  } ) ) == 0
				aAdd( aItens , {SUBSTR(TMPSRD->RD_DATARQ,1,4),SUBSTR(TMPSRD->RD_DATARQ,5,2),IIF(TMPSRD->RV_TIPOCOD$"13",TMPSRD->RD_VALOR,TMPSRD->RD_VALOR*-1),0,0,IIF(TMPSRD->RV_TIPOCOD$"13",TMPSRD->RD_VALOR,TMPSRD->RD_VALOR*-1),0,.F.} )
				nPos := len(aItens)
			ELSE
				aItens[nPos][3] += IIF(TMPSRD->RV_TIPOCOD$"13",TMPSRD->RD_VALOR,TMPSRD->RD_VALOR*-1)
			ENDIF
			aItens[nPos][6] := 0
			aEval(aItens, {|e| aItens[nPos][6] += e[3] })
		ELSEIF TMPSRD->RV_DIRF == "07"
			IF ( nPos := aScan( aItens, {|x| x[1] == SUBSTR(TMPSRD->RD_DATARQ,1,4) .AND. x[2] == SUBSTR(TMPSRD->RD_DATARQ,5,2)  } ) ) == 0
				aAdd( aItens , {SUBSTR(TMPSRD->RD_DATARQ,1,4),SUBSTR(TMPSRD->RD_DATARQ,5,2),0,TMPSRD->RD_HORAS,IIF(TMPSRD->RV_TIPOCOD$"13",TMPSRD->RD_VALOR,TMPSRD->RD_VALOR*-1),0,IIF(TMPSRD->RV_TIPOCOD$"13",TMPSRD->RD_VALOR,TMPSRD->RD_VALOR*-1),.F.} )
				nPos := len(aItens)
			ELSE
				aItens[nPos][4] := IIF( TMPSRD->RD_HORAS > aItens[nPos][4] ,TMPSRD->RD_HORAS, aItens[nPos][4])
				aItens[nPos][5] += IIF(TMPSRD->RV_TIPOCOD$"13",TMPSRD->RD_VALOR,TMPSRD->RD_VALOR*-1)
			ENDIF
			aItens[nPos][7] := 0
			aEval(aItens, {|e| aItens[nPos][7] += e[5] })
		ENDIF

		TMPSRD->(DBSKIP())
	ENDDO

	IF LEN(aItens) > 0
		FOR i:=1 to LEN(aItens)
			IF aItens[i][3] < 0
				aItens[i][3] *= -1
			ENDIF
			IF aItens[i][4] < 0
				aItens[i][4] *= -1
			ENDIF
			IF aItens[i][5] < 0
				aItens[i][5] *= -1
			ENDIF
			IF aItens[i][6] < 0
				aItens[i][6] *= -1
			ENDIF
			IF aItens[i][7] < 0
				aItens[i][7] *= -1
			ENDIF

			aAdd( Acols , aItens[i] )
		NEXT i
	ENDIF

	DBSELECTAREA("RH9")
	IF RH9->( DBSEEK( xFilial("RH9") + SRA->RA_MAT + MV_PAR01 ) )
		While RH9->(!EOF()) .AND. RH9->RH9_FILIAL == SRA->RA_FILIAL .AND. RH9->RH9_MAT == SRA->RA_MAT .AND. RH9->RH9_ANO == MV_PAR01

			Reclock("RH9",.F.)
			DBDELETE()
		    RH9->( MsUnlock() )

		    RH9->(dbskip())
		ENDDO
	ENDIF

    IF Len(Acols) > 0
		For i:=1 to Len(Acols)
	   		Reclock("RH9",.T.)
			RH9_FILIAL 	:= xFilial("RH9")
			RH9_MAT    	:= SRA->RA_MAT
			RH9_ANO    	:= Acols[i][1]
			RH9_MES	   	:= Acols[i][2]
			RH9_REMUNE		:= Acols[i][3]
			RH9_PERIMP		:= Acols[i][4]
			RH9_VLIMPO		:= Acols[i][5]
			RH9_REMACM		:= Acols[i][6]
			RH9_IMPACM		:= Acols[i][7]
	  		RH9->( MsUnlock() )
	 	Next i
	Endif

Return()