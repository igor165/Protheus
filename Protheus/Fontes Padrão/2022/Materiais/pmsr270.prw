#include "Protheus.ch"
#include "pmsr270.ch"
#include "pmsicons.ch"

#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

//-----------------------------RELEASE 4--------------------------------------//
Function PMSR270()

	If PMSBLKINT()
		Return Nil
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()


	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf	

	oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef ºAutor  ³Paulo Carnelossi    º Data ³  14/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Construcao Release 4                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef()
Local cPerg		:= "PMR270"
Local cDesc1	:= STR0001 //"Este relatorio ira imprimir uma relacao dos projetos, sua estrutura e o cronograma financeiro previsto x realizado para execucao do projeto."
Local cDesc2	:= ""
Local cDesc3	:= ""

Local oReport
Local oProjeto
Local oTarefa
Local nX

Local aOrdem  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oReport := TReport():New("PMSR270",STR0002, cPerg, ;
			{|oReport| ReportPrint(oReport)},;
			cDesc1 )
 //STR0002-"Cronograma Financeiro Previsto x Realizado"
oReport:SetLandScape()

oProjeto := TRSection():New(oReport, STR0014, { "AF8", "AFE", "SA1" }, aOrdem /*{}*/, .F., .F.)
oProjeto:SetLeftMargin(10)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oProjeto,	"AF8_PROJET"	,"AF8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"AF8_DESCRI"	,"AF8",/*Titulo*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"AF8_CLIENT"	,"AF8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"AF8_LOJA"		,"AF8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"A1_NOME"		,"SA1",/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"AFE_REVISA"	,"AFE",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"AFE_DATAF"		,"AFE",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"AFE_HORAF"		,"AFE",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

TRPosition():New(oProjeto, "SA1", 1, {|| xFilial("SA1") + AF8->AF8_CLIENT})
TRPosition():New(oProjeto, "AFE", 1, {|| xFilial("AFE") + AF8->AF8_PROJET + AF8->AF8_REVISA})

oProjeto:Cell("AF8_DESCRI"):SetLineBreak()
oProjeto:Cell("A1_NOME"):SetLineBreak()

//-------------------------------------------------------------
oTarefa := TRSection():New(oReport, STR0015, {"AF9"}, /*{aOrdem}*/, .F., .F.)
oTarefa:SetHeaderPage()
oTarefa:SetColSpace(2) 
TRCell():New(oTarefa, "AF9_TAREFA","AF9",ALLTRIM(LEFT(STR0005,30))/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oTarefa, "AF9_DESCRI","AF9",/*Titulo*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oTarefa, "AF9_INDIC" ,"","P/R"/*Titulo*/,"@!"/*Picture*/,1/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

oTarefa:Cell("AF9_TAREFA"):SetLineBreak()
oTarefa:Cell("AF9_DESCRI"):SetLineBreak()

For nX := 1 TO 6   // no relatório deve ter sempre 6 periodos
	TRCell():New(oTarefa, "PERIODO-"+Str(nX,1)+"_V","",STR0011+"-"+Str(nX,1)+CRLF+STR0012/*Titulo*/,"@E 999,999,999,999.99"/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Periodo"###"Valor"
	TRCell():New(oTarefa, "PERIODO-"+Str(nX,1)+"_P","",STR0011+"-"+Str(nX,1)+CRLF+STR0013/*Titulo*/,"@E 999"/*Picture*/,4/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Periodo"###"Perc."
Next

Return(oReport)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrint ºAutor  ³Paulo Carnelossi  º Data ³  14/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Construcao Release 4                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportPrint(oReport)
Local oProjeto 		:= oReport:Section(1)
Local oTarefa	 	:= oReport:Section(2)
Local dAuxFim
Local dAuxIni
Local aAuxImp  := {}
Local cFilUsu  := oProjeto:GetAdvplExp()
Local lLoop := .T.

PRIVATE nValPrj	:= 0
Private lIniData	:= Empty(mv_par06).Or.empty(mv_par07)

If Empty(cFilUsu)
	cFilUsu := ".T."
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³
//³ MV_PAR01 : Projeto   de ?                                              ³
//³ MV_PAR02 : Projeto  Ate ?                                              ³
//³ MV_PAR03 : Data projeto de                                    		   ³
//³ MV_PAR04 : Data projeto ate                                   		   ³
//³ mv_par05 : Nivel ?                                                     ³
//³ mv_par06 : Data de previsao de  ?                                      ³
//³ mv_par07 : Data de previsao Ate ?                                      ³
//³ mv_par08 : Aglutina - 1:Diario 2:Semanal 3:Mensal                      ³
//³ mv_par09 : Projecao do valor 1:Acumulado , 2:Saldo                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CrteFilIni()

oReport:SetMeter(AF8->(RecCount()))
dbSelectArea("AF8")
dbSeek(xFilial("AF8")+mv_par01,.T.)
While !Eof() .And. AF8->(AF8_FILIAL+AF8_PROJET) <= xFilial("AF8")+mv_par02

	oReport:IncMeter()
	
	If  AF8->AF8_DATA > mv_par04 .Or. ;
		AF8->AF8_DATA < mv_par03 ;
		.Or. !&( cFilUsu )
		dbSkip()
		Loop
	EndIf

	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+AF8->AF8_CLIENT+AF8->AF8_LOJA))

	dbSelectArea("AFE")
	dbSetOrder(1)
	dbSeek(xFilial("AFE")+AF8->AF8_PROJET)
	While !Eof() .And. AFE->AFE_FILIAL+AFE->AFE_PROJET==xFilial("AFE")+AF8->AF8_PROJET .AND. lLoop
	
		// verifica as versoes a serem impressas
		// se estiver em branco so imprime a ultima versao. (AF8_REVISA)
		If !PmrPertence(AFE->AFE_REVISA,mv_par10).Or.;
			(Empty(mv_par10).And.AFE->AFE_REVISA!=AF8->AF8_REVISA)
			dbSkip()
			Loop
		EndIf
	
		If lIniData
			mv_par06 := AF8->AF8_START
			mv_par07 := AF8->AF8_FINISH
		EndIf
		
		aAuxImp  := {}
		dAuxFim	 := Nil
		Do Case
			Case mv_par08==1
				dAuxIni := mv_par06
			Case mv_par08==2
				dAuxIni := mv_par06
				If DOW(dAuxIni)<>1
					dAuxIni -= DOW(dAuxIni)-1
				EndIf
			Case mv_par08==3
				dAuxIni := CTOD("01/"+StrZero(MONTH(mv_par06),2,0)+"/"+StrZero(YEAR(mv_par06),4,0))-1
		EndCase

		aHandle	:= PmsIniCRTE(AF8->AF8_PROJET,AFE->AFE_REVISA,PMS_MAX_DATE)
		nValPrj	:= PmsRetCRTE(aHandle,2,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)))[1]
		aHandle2:= PmsIniCOTP(AF8->AF8_PROJET,AFE->AFE_REVISA,PMS_MAX_DATE)
		nValPrj2:= PmsRetCOTP(aHandle,2,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)))[1]
		
		PmR270AFC(AF8->AF8_PROJET,AFE->AFE_REVISA,AF8->AF8_PROJET,aAuxImp,4, oReport)
		
		While dAuxFim==Nil .Or. dAuxFim < mv_par07
			Do Case
				Case mv_par08 == 1
					dAuxFim := dAuxIni+5
				Case mv_par08==2
					dAuxFim := dAuxIni+(5*7)
				Case mv_par08==3
					dAuxFim := dAuxIni+(5*31)
					dAuxFim := CTOD("01/"+StrZero(MONTH(dAuxFim),2,0)+"/"+StrZero(YEAR(dAuxFim),4,0))-1
			EndCase
			dx := dAuxIni
			While dx <= dAuxFim
				aHandle	:= PmsIniCRTE(AF8->AF8_PROJET,AFE->AFE_REVISA,dx)
				aHandle2:= PmsIniCOTP(AF8->AF8_PROJET,AFE->AFE_REVISA,dx)
				PmR270AFC(AF8->AF8_PROJET,AFE->AFE_REVISA,AF8->AF8_PROJET,aAuxImp,2, oReport)
				Do Case
					Case mv_par08 == 1
						dx++
					Case mv_par08==2
						dx+= 7
					Case mv_par08==3
						dx+= 35
						dx := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))-1
				EndCase
			End
			dAuxIni := dx
		End
		
		lLoop := PmR270_Imp(@oReport, aAuxImp)
		
		If oReport:Cancel()
			oReport:SkipLine()
			oReport:PrintText(STR0016) //"*** CANCELADO PELO OPERADOR ***"
			//lRet := .F.
		Endif

		oReport:EndPage(.T.)
		
		dbSelectArea("AFE")
		dbSkip()
		
	End
	
	If !lLoop
		dbSelectArea("AF8")
		dbSetOrder(1)
		dbClearFilter() //Set Filter to
		Exit
	Endif
	
	dbSelectArea("AF8")
	dbSkip()
	
End

CrteFilEnd()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pmr270_ImpºAutor  ³Paulo Carnelossi    º Data ³  14/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Construcao Release 4                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pmr270_Imp(oReport, aAuxImp)

Local oProjeto 		:= oReport:Section(1)
Local oTarefa	 	:= oReport:Section(2)

Local dAuxFim
Local dAuxIni
Local dCabFim
Local nX
Local cAF9Indic     := "P"
Local nPeriodo
Local lRet := .T.

oTarefa:Cell("AF9_TAREFA"):SetBlock({|| If(aAuxImp[nx][1]=="AFC", AFC->AFC_EDT, AF9->AF9_TAREFA) })
oTarefa:Cell("AF9_DESCRI"):SetBlock({|| If(aAuxImp[nx][1]=="AFC", ;
											 Repli(".",Val(AFC->AFC_NIVEL)-1)+Substr(AFC->AFC_DESCRI,1,36-Val(AFC->AFC_NIVEL)-1),;
											 Repli(".",Val(AF9->AF9_NIVEL)-1)+Substr(AF9->AF9_DESCRI,1,36-Val(AFC->AFC_NIVEL)-1)) ;
									 })
oTarefa:Cell("AF9_INDIC"):SetBlock({|| cAF9Indic })

Do Case
	Case mv_par08==1
		dAuxIni := mv_par06
	Case mv_par08==2
		dAuxIni := mv_par06
		If DOW(dAuxIni)<>1
			dAuxIni -= DOW(dAuxIni)-1
		EndIf
	Case mv_par08==3
		dAuxIni := CTOD("01/"+StrZero(MONTH(mv_par06),2,0)+"/"+StrZero(YEAR(mv_par06),4,0))-1
EndCase
dCabIni := dAuxIni

Do Case
	Case mv_par08 == 1
		dCabFim := dCabIni+5
	Case mv_par08==2
		dCabFim := dCabIni+(5*7)
	Case mv_par08==3
		dCabFim := dCabIni+(5*31)
		dCabFim := CTOD("01/"+StrZero(MONTH(dCabFim),2,0)+"/"+StrZero(YEAR(dCabFim),4,0))-1
EndCase

dx := dCabIni
nPeriodo := 1
While dx <= dCabFim
	oTarefa:Cell("PERIODO-"+Str(nPeriodo,1)+"_V"):SetTitle(DTOC(dx)+CRLF+"Valor")
	oTarefa:Cell("PERIODO-"+Str(nPeriodo,1)+"_P"):SetTitle(DTOC(dx)+CRLF+"%Perc.")
	nPeriodo++
	Do Case
		Case mv_par08 == 1
			dx++
		Case mv_par08==2
			dx+= 7
		Case mv_par08==3
			dx+= 35
			dx := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))-1
	EndCase
End

oProjeto:Init()
oProjeto:PrintLine()
oProjeto:Finish()

oReport:FatLine()

oTarefa:Init()

While (dAuxFim==Nil .Or. dAuxFim < mv_par07) .AND. lRet

	Do Case
		Case mv_par08 == 1
			dAuxFim := dAuxIni+5
		Case mv_par08==2
			dAuxFim := dAuxIni+(5*7)
		Case mv_par08==3
			dAuxFim := dAuxIni+(5*31)
			dAuxFim := CTOD("01/"+StrZero(MONTH(dAuxFim),2,0)+"/"+StrZero(YEAR(dAuxFim),4,0))-1
	EndCase
	
	For nx := 1 to Len(aAuxImp)
		
		If aAuxImp[nx][1]=="AFC"
			AFC->(dbGoto(aAuxImp[nx,2]))
		Else
			AF9->(dbGoto(aAuxImp[nx,2]))
		EndIf
		nColuna := 0
		dx := dAuxIni

		cAF9Indic := "P"
		oTarefa:Cell("AF9_TAREFA"):Show()
		oTarefa:Cell("AF9_DESCRI"):Show()
		nPeriodo := 1

		While dx <= dAuxFim
		
			If !Empty(aAuxImp[nx,3])

				nPos := aScan(aAuxImp[nx][3],{|x|x[1]==dx})
				If nPos > 0 .And. aAuxImp[nx,8]
					oTarefa:Cell("PERIODO-"+Str(nPeriodo,1)+"_V"):SetValue(If(mv_par09==1,aAuxImp[nx,3,npos,3],aAuxImp[nx,3,npos,3]-aAuxImp[nx,9]))
					oTarefa:Cell("PERIODO-"+Str(nPeriodo,1)+"_P"):SetValue(If(mv_par09==1,aAuxImp[nx,3,npos,3],aAuxImp[nx,3,npos,3]-aAuxImp[nx,9])/aAuxImp[nx,7]*100)
					
					aAuxImp[nx][9] := aAuxImp[nx,3,npos,3]
					If (aAuxImp[nx,3,npos,3]/aAuxImp[nx,7]*100) > 100
						aAuxImp[nx,8] := .F.
					EndIf
				Else
					oTarefa:Cell("PERIODO-"+Str(nPeriodo,1)+"_V"):SetValue(0)
					oTarefa:Cell("PERIODO-"+Str(nPeriodo,1)+"_P"):SetValue(0)
				EndIf

			EndIf
			
			Do Case
				Case mv_par08 == 1
					dx++
				Case mv_par08==2
					dx+= 7
				Case mv_par08==3
					dx+= 35
					dx := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))-1
			EndCase
			nColuna++
			nPeriodo++

		End

		oTarefa:PrintLine()
		oTarefa:Cell("AF9_TAREFA"):Hide()
		oTarefa:Cell("AF9_DESCRI"):Hide()

		nColuna := 0
		dx := dAuxIni
		cAF9Indic := "R"
		nPeriodo := 1

		While dx <= dAuxFim
			If !Empty(aAuxImp[nx,3])
				nPos := aScan(aAuxImp[nx][3],{|x|x[1]==dx})
				If nPos > 0 .And. aAuxImp[nx,5]
					oTarefa:Cell("PERIODO-"+Str(nPeriodo,1)+"_V"):SetValue(If(mv_par09==1,aAuxImp[nx,3,npos,2],aAuxImp[nx,3,npos,2]-aAuxImp[nx,6]))
					oTarefa:Cell("PERIODO-"+Str(nPeriodo,1)+"_P"):SetValue(If(mv_par09==1,aAuxImp[nx,3,npos,2],aAuxImp[nx,3,npos,2]-aAuxImp[nx,6])/aAuxImp[nx,4]*100)
					aAuxImp[nx][6] := aAuxImp[nx,3,npos,2]

				Else
					oTarefa:Cell("PERIODO-"+Str(nPeriodo,1)+"_V"):SetValue(0)
					oTarefa:Cell("PERIODO-"+Str(nPeriodo,1)+"_P"):SetValue(0)
				EndIf
			EndIf

			Do Case
				Case mv_par08 == 1
					dx++
				Case mv_par08==2
					dx+= 7
				Case mv_par08==3
					dx+= 35
					dx := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))-1
			EndCase

			nColuna++
			nPeriodo++
			
		End
		
		oTarefa:PrintLine()
		oTarefa:Cell("AF9_TAREFA"):Show()
		oTarefa:Cell("AF9_DESCRI"):Show()
		
		oReport:SkipLine()

		If oReport:Cancel()
			lRet := .F.
			Exit
		Endif
		
	Next nX

	dAuxIni := dx
	dCabIni := dx
	Do Case
		Case mv_par08 == 1
			dCabFim := dCabIni+5
		Case mv_par08==2
			dCabFim := dCabIni+(5*7)
		Case mv_par08==3
			dCabFim := dCabIni+(5*31)
			dCabFim := CTOD("01/"+StrZero(MONTH(dCabFim),2,0)+"/"+StrZero(YEAR(dCabFim),4,0))-1
	EndCase

	dx := dCabIni
	nPeriodo := 1
	
	While dx <= dCabFim

		oTarefa:Cell("PERIODO-"+Str(nPeriodo,1)+"_V"):SetTitle(DTOC(dx)+CRLF+"Valor")
		oTarefa:Cell("PERIODO-"+Str(nPeriodo,1)+"_P"):SetTitle(DTOC(dx)+CRLF+"%Perc.")
		nPeriodo++

		Do Case
			Case mv_par08 == 1
				dx++
			Case mv_par08==2
				dx+= 7
			Case mv_par08==3
				dx+= 35
				dx := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))-1
		EndCase
		
	End

	If dAuxFim < mv_par07
		oReport:EndPage()
	EndIf

End

oTarefa:Finish()

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ PMR270AFC   ³ Autor ³ Edson Maricate      ³ Data ³21.06.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a impressao do detalhe AFC.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PMR270AFC()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PmR270AFC(cProjeto,cRevisa,cEDT,aAuxImp,nPosArray,oReport)
Local aArea    := {}
Local x        := 0

Local aNodes := {}
Local nNode  := 0
Local oTarefa := oReport:Section(2)

Local cFilUsu := IIf(ValType(oTarefa) == "O",oTarefa:GetAdvplExp(),"")

If Empty(cFilUsu)
	cFilUsu := ".T."
EndIf

Aadd( aArea, AFC->( GetArea() ) )
Aadd( aArea, AF9->( GetArea() ) )
Aadd( aArea, GetArea() )

dbSelectArea("AFC")
dbSetOrder(1)
dbSeek(xFilial("AFC")+cProjeto+cRevisa+cEDT)
cProjeto	:= AFC->AFC_PROJET
cRevisa		:= AFC->AFC_REVISA
cEDT		:= AFC->AFC_EDT

If PmrPertence(AFC->AFC_NIVEL,mv_par05).And. PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,1,"ESTRUT",cRevisa)
	nPosAux := aScan(aAuxImp,{|x|x[1]=="AFC" .And. x[2]==AFC->(REcNo()) })
	If nPosAux <= 0
		aAdd(aAuxImp,{"AFC",AFC->(RecNo()),{},Nil,.T.,0,Nil,.T.,0})
		nPosAux := Len(aAuxImp)
	EndIf
	nVal	:= PmsRetCRTE(aHandle,2,AFC->AFC_EDT)[1]
	nVal2	:= PmsRetCOTP(aHandle2,2,AFC->AFC_EDT)[1]	
	If nPosArray==4
		aAuxImp[nPosAux][4] := nVal
		aAuxImp[nPosAux][7] := nVal2
	Else
		aAdd(aAuxImp[nPosAux][3],{dx,nVal,nVal2})
	EndIf
EndIf

dbSelectArea("AF9")
dbSetOrder(2)
dbSeek(xFilial("AF9")+cProjeto+cRevisa+cEDT)
While !Eof() .And. xFilial("AF9")+cProjeto+cRevisa+cEDT==;
	AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI

	If &(cFilUsu)	
		aAdd(aNodes, {PMS_TASK,;
		              AF9->(Recno()),;
	                If(Empty(AF9->AF9_ORDEM), "000", AF9->AF9_ORDEM),;
	                AF9->AF9_TAREFA})
	EndIf	               
	dbSkip()
End
dbSelectArea("AFC")
dbSetOrder(2)
dbSeek(xFilial("AFC")+cProjeto+cRevisa+cEDT)
While !Eof() .And. xFilial("AFC")+cProjeto+cRevisa+cEDT==;
	AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI
	
	aAdd(aNodes, {PMS_WBS,;
	              AFC->(Recno()),;
	              If(Empty(AFC->AFC_ORDEM), "000", AFC->AFC_ORDEM),;
	              AFC->AFC_EDT})
	dbSelectArea("AFC")
	dbSkip()
End

aSort(aNodes, , , {|x, y| x[3]+x[4] < y[3]+y[4]})

For nNode := 1 To Len(aNodes)
	If aNodes[nNode][1] = PMS_TASK
		AF9->(dbGoto(aNodes[nNode][2]))
		PmR270AF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,aAuxImp,nPosArray)
	Else
		AFC->(dbGoto(aNodes[nNode][2]))
		PmR270AFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,aAuxImp,nPosArray,oReport)	
	EndIf
Next

For x := 1 to Len(aArea)
	RestArea(aArea[x])
Next
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ PMR270AF9   ³ Autor ³ Edson Maricate      ³ Data ³21.06.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a impressao do detalhe AF9.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PMR270AF9()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PmR270AF9(cProjeto,cRevisa,cTarefa,aAuxImp,nPosArray)
Local aArea    := {}
Local x        := 0

Aadd( aArea, AF9->( GetArea() ) )
Aadd( aArea, GetArea() )

If PmrPertence(AF9->AF9_NIVEL,mv_par05).And.PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"ESTRUT",cRevisa)
	nPosAux := aScan(aAuxImp,{|x|x[1]=="AF9" .And. x[2]==AF9->(REcNo()) })
	If nPosAux <= 0
		aAdd(aAuxImp,{"AF9",AF9->(RecNo()),{},Nil,.T.,0,Nil,.T.,0})
		nPosAux := Len(aAuxImp)
	EndIf
	nVal := PmsRetCRTE(aHandle,1,AF9->AF9_TAREFA)[1]
	nVal2:= PmsRetCOTP(aHandle2,1,AF9->AF9_TAREFA)[1]
	If nPosArray==4
		aAuxImp[nPosAux][4] := nVal
		aAuxImp[nPosAux][7] := nVal2
	Else
		aAdd(aAuxImp[nPosAux][3],{dx,nVal,nVal2})
	EndIf
EndIf

For x := 1 to Len(aArea)
	RestArea(aArea[x])
Next


Return