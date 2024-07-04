#include "protheus.ch"
#include "OFINJD30.CH"
#include "fileio.ch"
#include "topconn.ch"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "004135_2"

/*/{Protheus.doc} OFINJD30 "Reprocessamento de base de DPM"
	Rotina utilizada para reprocessar a base do DPM quando acontece algum problema de valores por má utilização

	Pontos de entrada:

	Parametros:

	@author Vinicius Gati
	@since  14/09/2015
/*/
Function OFINJD30()
	Private oDtCont := DMS_DataContainer():New()
	Private oSqlHlp := DMS_SqlHelper():New()
	Private oUtil   := DMS_Util():New()
	Private oDPM    := DMS_DPM():New()
	Private oArHlp  := DMS_ArrayHelper():New()
	Private lAbort  := .T.

	CriaSX1()
	Pergunte( "ONJD30_1" , .F. )
	ONJD30Tela()
Return

/*/{Protheus.doc} ONJD30Tela
	Mostra UI para controle do processamento

	Pontos de entrada:

	Parametros:

	@author Vinicius Gati
	@since  14/09/2015
/*/
Function ONJD30Tela()
	// configuracao do formbatch
	Local aButtons := {;
		{ 5, .T., { || Pergunte( "ONJD30_1" ,.T. )                                                   }},;
		{ 1, .T., { || Processa( {|lAbort| ONJD30Proc(@lAbort) }, STR0011 /*"Limpeza"*/, "", .T. )   }},;
		{ 2, .T., { || FechaBatch()                                                                  }} ;
	}
	FORMBATCH(STR0001 /* "Limpeza de base DPM da Jhonn Deere " */ ,;
		     {STR0002 /* "Esta rotina é utilizada em caso de valores errôneos no DPM " */,;
		      STR0003 /* "e só deve ser usada em casos específicos avaliados e recomendados pela TOTVS(DMS)" */},;
		      aButtons)
Return

/*/{Protheus.doc} ONJD30Proc
	Processa a ação de reprocessamento usando as datas escolhidas

	Pontos de entrada:

	Parametros:

	@author Vinicius Gati
	@since  14/09/2015
/*/
Function ONJD30Proc(lAbort)
	dData1 := MV_PAR01
	dData2 := MV_PAR02

	If EMPTY(dData1) .OR. EMPTY(dData2)
		MSGINFO( STR0004 /*"Por favor configure as 2 datas de intervalo para limpeza de base"*/, STR0005 /*"Atenção"*/)
		Return .F.
	Else

		nDias := 1
		ProcRegua(dData2-dData1)

		while dData1 <= dData2
			oDpm:ClrDemanda(dData1)
	
			IncProc( STR0008 /*Faltam*/ + ALLTRIM(STR(dData2-dData1)) + STR0009/*" dias para terminar o processo."*/ )
			dData1 := dData1 + 1
			nDias  := nDias  + 1
		EndDo
	
		MSGINFO(STR0010 /*"Processo finalizado, o reprocessamento ocorrerá na execução do scheduler da rotina OFINJD12"*/, STR0007 /*"Informação"*/)

	EndIf
	FechaBatch()
Return .T.

/*/{Protheus.doc} CriaSX1
	padrao de criacao de pergunte

	Pontos de entrada:

	Parametros:

	@author Vinicius Gati
	@since  14/09/2015
/*/
Static Function CriaSX1()
	Local aSX1       := {}
	Local aEstrut    := {}
	Local i          := 0
	Local j          := 0
	Local lSX1       := .F.
	Local cPErg      := "ONJD30_1"

	aEstrut := { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL",;
	"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2",;
	"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4",;
	"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aAdd a Pergunta        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aAdd(aSX1,{cPerg,"01",STR0012 /*"Data I:"*/,"","","MV_CH1","D", 8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
	aAdd(aSX1,{cPerg,"02",STR0013 /*"Data F:"*/,"","","MV_CH2","D", 8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})

	ProcRegua(Len(aSX1))

	dbSelectArea("SX1")
	dbSetOrder(1)
	For i:= 1 To Len(aSX1)
		If !Empty(aSX1[i][1])
			If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
				lSX1 := .T.
				RecLock("SX1",.T.)
				
				For j:=1 To Len(aSX1[i])
					If !Empty(FieldName(FieldPos(aEstrut[j])))
						FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
					EndIf
				Next j

				dbCommit()
				MsUnLock()
			EndIf
		EndIf
	Next i
Return
