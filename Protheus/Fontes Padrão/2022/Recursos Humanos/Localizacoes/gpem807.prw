#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM807.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GPEM807  บAutor  ณ Cesar Perea             บ Data ณ 01/12/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Geracao de arquivo T-Registro                                   บฑฑ
ฑฑบ          ณ                                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localizacao Peru                                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  บฑฑ
ฑฑฬออออออออออออัออออออออัอออออออออออัออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ Data   ณ BOPS/FNC  ณ  Motivo da Alteracao                     บฑฑ
ฑฑฬออออออออออออุออออออออุอออออออออออุออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ            ณ        ณ           ณ                                           ฑฑ
ฑฑฬออออออออออออุออออออออุอออออออออออุออออออออออออออออออออออออออออออออออออออออออนฑฑ
*/
Function GPEM807()

Local aSays     := {}
Local aButtons  := {}
Local cPerg     := "GPM807"


If !VerBasePDT()
    MsgInfo(OemToAnsi(STR0009))  //"Antes de prosseguir ้ necessแrio executar a atualiza็ao 'Geracao do arquivo PDT layout 12/2011', disponํvel para o m๓dulo SIGAGPE no compatibilizador RHUPDMOD."
    Return(.F.)
EndIf

Pergunte(cPerg,.F.)

AADD(aSays,STR0016) //"Es el Registro de Informaci๓n Laboral de los empleadores, trabajadores,pensionistas,"
AADD(aSays,STR0017) //"prestadores  de servicios, personal  en formaci๓n  – modalidad  formativa laboral y "
AADD(aSays,STR0018) //"otros (practicantes), personal de terceros y derechohabientes."
AADD(aSays,STR0019) //"Comprende informaci๓n laboral, de seguridad  social y otros  datos  sobre el tipo de "
AADD(aSays,STR0020) //"ingresos de los sujetos registrados." 

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.) } } )
AADD(aButtons, { 1,.T.,{|| If( GPM807Ok(), FechaBatch(), ) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( "T-Registro", aSays, aButtons )

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GPM807Ok บAutor  ณ Ademar Fernandes   บ Data ณ 16/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Usado na funcao principal                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localizacao Peru                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM807Ok()

Local aTabEmp   := {}

Local cEps    := ""
Local cRuc    := ""
Local cCodEst := ""
Local cTipEst := ""
Local cRisco  := ""
Local cDescr  := ""

Private aLogFile	:= {}
Private aLogTitle	:= {}
Private lGerou 		:= .F.
Private lErro		:= .F.
Private lTpCic		:= .F.
Private lCic		:= .F.
/*
Parametros da Rotina
MV_PAR01 - Fecha base inicial
MV_PAR02 - Archivo destino
MV_PAR03 - Generar archivos
MV_PAR04 - Codigo del formulario
*/
If Empty(MV_PAR01) .OR. Empty(MV_PAR02) .OR. Empty(MV_PAR03)
	Alert(STR0003)	//"Preencher os Parametros"
	Return(.F.)
EndIf

Private dDataIni	:= FirstDate(MV_PAR01)
Private dDataFim	:= LastDate(MV_PAR01)
Private cAnoMesArq	:= AnoMes(MV_PAR01)

fRetTab(@aTabEmp,"S002",,,dDataBase)

If Len(aTabEmp) > 0
	cEps    := aTabEmp[5]
	cRuc    := iif (valtype(aTabEmp[6])=="N",alltrim(str(aTabEmp[6])),alltrim(aTabEmp[6]))
	cCodEst := aTabEmp[9]
	cTipEst := aTabEmp[10]
	cRisco  := aTabEmp[11]
EndIf

nPOS := fPosTab("S027", cTipEst, "==", 04)
If nPOS > 0
	cDescr := fTabela("S027",nPOS,05)
EndIf

Processa( {|lEnd| GPM807Proc(cRuc,cCodEst,cTipEst,cRisco,cDescr), STR0001 })	//"Gerando Arquivos... Aguarde!"

If lGerou
	MsgInfo(STR0005)	//"PDT Gerado com Sucesso!!"
Else
	MsgInfo(STR0010) 	//"Nenhum arquivo gerado!"
EndIf

If Len(aLogFile) > 0
	aAdd(aLogTitle , STR0015 ) //'Se encontraron inconsistencias en la generaci๓n del PDT'
	
	fMakeLog(	{aLogFile}															,;	//Array que contem os Detalhes de Ocorrencia de Log
				aLogTitle															,;	//Array que contem os Titulos de Acordo com as Ocorrencias
				"GPM807"															,;	//Pergunte a Ser Listado
				.T.																	,;	//Se Havera "Display" de Tela
				NIL																	,;	//Nome Alternativo do Log
				CriaTrab( NIL , .F. )												,;	//Titulo Alternativo do Log
				"G"																	,;	//Tamanho Vertical do Relatorio de Log ("P","M","G")
				"L"																	,;	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
				NIL																	,;	//Array com a Mesma Estrutura do aReturn
				.F.																	 ;	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
			 )
EndIf

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM807ProcบAutor  ณ Ademar Fernandes   บ Data ณ 16/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Usado na funcao principal                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localizacao Peru                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM807Proc(cRuc,cCodEst,cTipEst,cRisco,cDescr)

Local cDir		:= Alltrim(MV_PAR02)
Local cQbr		:= "|"
Local aTexto	:= {}
Local aTexto2	:= {}
Local aTabRCC	:= {}
Local cTipoRes	:= ""
Local cMadreRes := ""
Local cOcupac	:= ""
Local cVer5Cat	:= fCargaPd('1118')
Local nDias		:= 0

PRIVATE cAliasSRA	:= "QSRA"
PRIVATE cAliasRGC	:= "QRGC"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posiciona as areas primarias                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("RGB")
dbSetOrder(1)
dbSelectArea("SRD")
dbSetOrder(1)
dbSelectArea("SRJ")
dbSetOrder(1)
dbSelectArea("SRQ")
dbSetOrder(1)
dbSelectArea("SRG")
dbSetOrder(1)
dbSelectArea("SRV")
dbSetOrder(1)
dbSelectArea("RCM")
dbSetOrder(1)
dbSelectArea("SRA")
dbSetOrder(1)

ProcRegua( ("SRA")->(RecCount()) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 1 - "Datos de Establecimientos Propios"								ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "1" $ MV_PAR03

	IncProc(STR0006+STR0021)	//"Processando Estrutura "###"1 (Establec. Propios...)"

	aTexto := {}
	cArquivo := "RP_" + cRuc + ".esp"


	BeginSql alias cAliasRGC	

		SELECT RGC.RGC_FILIAL,RGC.RGC_KEYLOC,RGC.RGC_RIESGO,RGC.RGC_FECINI,RGC.RGC_FECFIN
		FROM %table:RGC% RGC      
		WHERE RGC.RGC_TIPO='1'
			AND ( ( RGC.RGC_FECINI >= %exp:DToS(dDataIni)% AND RGC.RGC_FECINI <= %exp:DToS(dDataFim)%)  OR 
			  	  ( RGC.RGC_FECFIN >= %exp:DToS(dDataIni)% AND RGC.RGC_FECFIN <= %exp:DToS(dDataFim)%)  OR 
			  	  ( RGC.RGC_FECINI <= %exp:DToS(dDataIni)% AND RGC.RGC_FECFIN >= %exp:DToS(dDataIni)%)  OR
			  	  ( RGC.RGC_FECINI <= %exp:DToS(dDataFim)% AND RGC.RGC_FECFIN = %exp:' '%) )
			AND RGC.%notDel%
	    ORDER BY RGC.RGC_KEYLOC
	    

	EndSql
	
	While (cAliasRGC)->( !Eof() )

		aAdd(aTexto,;
				Alltrim((cAliasRGC)->RGC_KEYLOC) + cQbr + ;				//01- Tipo de documento del trabajador
				Alltrim((cAliasRGC)->RGC_RIESGO) +  cQbr )						//02- Numero de documento del trabajador

		(cAliasRGC)->( DbSkip() )
		
	EndDo		    		

	(cAliasRGC)->(DbCloseArea())


	If Len(aTexto) > 0
		GerarArq( cArquivo, aTexto, cDir )
		aTexto := Array(0)
	EndIf

	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 2 - "Empleadores a quienes destaco o desplazo personal"	   			ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "2" $ MV_PAR03

	IncProc(STR0006+STR0022)	//"Processando Estrutura "###"2 (Empleadores a quienes...)"

	fCarrTab( @aTabRCC,'S045', MV_PAR01 , .T. )

   	aTexto 	:= {}
	aTexto2 := {}

	BeginSql alias cAliasRGC	

		SELECT RGC.RGC_FILIAL,RGC.RGC_KEYLOC,RGC.RGC_RIESGO,RGC_DOMICI,RGC_RUC,RGC.RGC_FECINI,RGC.RGC_FECFIN
		FROM %table:RGC% RGC      
		WHERE RGC.RGC_TIPO='2'
			AND ( ( RGC.RGC_FECINI >= %exp:DToS(dDataIni)% AND RGC.RGC_FECINI <= %exp:DToS(dDataFim)%)  OR 
			  	  ( RGC.RGC_FECFIN >= %exp:DToS(dDataIni)% AND RGC.RGC_FECFIN <= %exp:DToS(dDataFim)%)  OR 
			  	  ( RGC.RGC_FECINI <= %exp:DToS(dDataIni)% AND RGC.RGC_FECFIN >= %exp:DToS(dDataIni)%)  OR
			  	  ( RGC.RGC_FECINI <= %exp:DToS(dDataFim)% AND RGC.RGC_FECFIN = %exp:' '%) )
			AND RGC.%notDel%
	    ORDER BY RGC.RGC_KEYLOC
	    

	EndSql
	
	While (cAliasRGC)->( !Eof() )

		aAdd(aTexto,;
				IIF((cAliasRGC)->RGC_DOMICI="1",(cAliasRGC)->RGC_RUC,"           ") + cQbr + ;				//01- Tipo de documento del trabajador
				"(cAliasRGC)->RGC_SEVPRE" + cQbr + ;	
				QrConvData((cAliasRGC)->RGC_FECINI) + cQbr + ;	
				QrConvData((cAliasRGC)->RGC_FECFIN) +  cQbr )						//02- Numero de documento del trabajador


		aAdd(aTexto2,;
				IIF((cAliasRGC)->RGC_DOMICI =="1",(cAliasRGC)->RGC_RUC,"           ") + cQbr +; 			// 01 - RUC del empleador a quien destaco o desplazo personal
				 AllTrim((cAliasRGC)->RGC_KEYLOC) + cQbr +;      		// 02 - Codigo del establecimiento del empleador a donde destaco o desplazo personal.
				 AllTrim((cAliasRGC)->RGC_RIESGO) + cQbr )	// 03 - Indicador si personal desarrollarแ actividad de riesgo SCTR.		

		(cAliasRGC)->( DbSkip() )
	EndDo		    		

	(cAliasRGC)->(DbCloseArea())

	If !Empty(aTexto)
		cArquivo := "RP_" + cRuc + ".edd"
		GerarArq( cArquivo , aTexto , cDir )
		cArquivo := "RP_" + cRuc + ".ldd"
		GerarArq( cArquivo , aTexto2 , cDir )		
	EndIf

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 3 - "Empleadores que me destacan o desplazan personal"	   			ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "3" $ MV_PAR03

	IncProc(STR0006+STR0023)	//"Processando Estrutura "###"3 (Emp. que me dest...)"

	aTexto := {}
	
	If Empty(aTabRCC)
		fCarrTab( @aTabRCC,'S045', MV_PAR01 , .T. )
	EndIf
		
	cArquivo := "RP_" + cRuc + ".med"

	BeginSql alias cAliasRGC	

		SELECT RGC.RGC_FILIAL,RGC.RGC_KEYLOC,RGC.RGC_RIESGO,RGC_DOMICI,RGC_RUC,RGC.RGC_FECINI,RGC.RGC_FECFIN
		FROM %table:RGC% RGC      
		WHERE RGC.RGC_TIPO='3'
			AND ( ( RGC.RGC_FECINI >= %exp:DToS(dDataIni)% AND RGC.RGC_FECINI <= %exp:DToS(dDataFim)%)  OR 
			  	  ( RGC.RGC_FECFIN >= %exp:DToS(dDataIni)% AND RGC.RGC_FECFIN <= %exp:DToS(dDataFim)%)  OR 
			  	  ( RGC.RGC_FECINI <= %exp:DToS(dDataIni)% AND RGC.RGC_FECFIN >= %exp:DToS(dDataIni)%)  OR
			  	  ( RGC.RGC_FECINI <= %exp:DToS(dDataFim)% AND RGC.RGC_FECFIN = %exp:' '%) )
			AND RGC.%notDel%
	    ORDER BY RGC.RGC_KEYLOC
	EndSql
	
	While (cAliasRGC)->( !Eof() )
		aAdd(aTexto,;
				(cAliasRGC)->RGC_RUC + cQbr + ;				//01- Tipo de documento del trabajador
				"(cAliasRGC)->RGC_SEVPRE" + cQbr + ;	
				QrConvData((cAliasRGC)->RGC_FECINI) + cQbr + ;	
				QrConvData((cAliasRGC)->RGC_FECFIN) +  cQbr )						//02- Numero de documento del trabajador
		(cAliasRGC)->( DbSkip() )
	EndDo		    		
	(cAliasRGC)->(DbCloseArea())
	GerarArq( cArquivo, aTexto, cDir )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ (*) Inicia as variaveis principais dos arquivos a serem gerados		ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aTxt05 := {}
cArq05 := "RP_" + cRuc + ".tra"

aTxt09 := {}
cArq09 := "RP_" + cRuc + ".pfl"

aTxt10 := {}
cArq10 := "RP_" + cRuc + ".ter"

aTxt11 := {}
cArq11 := "RP_" + cRuc + ".per"

aTxt12 := {}
cArq12 := "0601" + AnoMes(MV_PAR01) + cRuc +  ".or5"

aTxt13 := {}
cArq13 := "RD_" + cRuc + "_" + Substr(DTOS(MV_PAR01),7,2) + Substr(DTOS(MV_PAR01),5,2) + Substr(DTOS(MV_PAR01),1,4) + "_ALTA.txt"

aTxt15 := {}
cArq15 := "0601" + AnoMes(MV_PAR01) + cRuc + ".snl"

aTxt17 := {}
cArq17 := "RP_" + cRuc + ".est"

aTxt18 := {}
cArq18 := "0601" + AnoMes(MV_PAR01) + cRuc + ".rem"

aTxt23 := {}
cArq23 := "RP_" + cRuc + ".lug"

aTxt24 := {}
cArq24 := "RD_" + cRuc + "_" + Substr(DTOS(dDataBase),7,2) + Substr(DTOS(dDataBase),5,2) + Substr(DTOS(dDataBase),1,4) + "_BAJA.txt"

aTxt26 := {}
cArq26 := "0601" + AnoMes(MV_PAR01) + cRuc + ".toc"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 4 - "Datos principales del trabajador, pensionista, prestador de	ณ
//ณ      servicios-modalidades	formativas y personal de terceros"		ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "4" $ MV_PAR03

aTxt04 := {}
cArq04 := "RP_" + cRuc + ".ide"

	IncProc(STR0006+STR0024 ) //"Processando Estrutura "###"4 (Datos princ. trab...)"

		BeginSql alias cAliasSRA

			SELECT  SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_TPCIC, SRA.RA_CIC, SRA.RA_CODPAIS, SRA.RA_NASC, SRA.RA_PRISOBR,
					SRA.RA_SECSOBR, SRA.RA_PRINOME, SRA.RA_SEXO, SRA.RA_NACIONA, SRA.RA_CODAREA, SRA.RA_TELEFON, SRA.RA_EMAIL,
					SRA.RA_TIPOVIA, SRA.RA_ENDEREC, SRA.RA_NUMERO, SRA.RA_COMPLEM, SRA.RA_TPZONA, SRA.RA_REFER, SRA.RA_CEP,
					SRA.RA_NUMINT,SRA.RA_MZA,SRA.RA_LOTE,SRA.RA_KM,SRA.RA_BLOQUE,SRA.RA_ETAPA,
					SRA.RA_TIPOVI2,SRA.RA_NUMER2,SRA.RA_CEP2,SRA.RA_NUMIN2,SRA.RA_MZA2,SRA.RA_LOTE2,SRA.RA_KM2,SRA.RA_BLOCK2,
					SRA.RA_ETAPA2,SRA.RA_TPZON2,SRA.RA_REFER2,SRA.RA_CEP2,SRA.RA_SECNOME,SRA.RA_DDN,SRA.RA_DIRESSA
			FROM %table:SRA% SRA
			WHERE SRA.%notDel% 
				AND SRA.RA_ADMISSA BETWEEN  %exp:DToS(dDataIni)% AND %exp:DToS(dDataFim)%
		    ORDER BY SRA.RA_FILIAL, SRA.RA_MAT 
	    
	    EndSql
	
	While (cAliasSRA)->( !Eof() )

		aAdd(aTxt04,;
					AllTrim((cAliasSRA)->RA_TPCIC) + cQbr + ;									//01 - Tipo de documento
					AllTrim((cAliasSRA)->RA_CIC) + cQbr + ;											//02 - Numero de documento
					IIF(AllTrim((cAliasSRA)->RA_TPCIC)=="07",AllTrim((cAliasSRA)->RA_CODPAIS),"   ") + cQbr + ;									//03 - Pais emissor do documento
					QrConvData((cAliasSRA)->RA_NASC) + cQbr + ;									//04 - Fecha de nacimiento
					AllTrim((cAliasSRA)->RA_PRISOBR) + cQbr + ;									//05 - Apellido paterno
					AllTrim((cAliasSRA)->RA_SECSOBR) + cQbr + ;									//06 - Apellido materno
					ALLTRIM((cAliasSRA)->RA_PRINOME) + " " + ALLTRIM((cAliasSRA)->RA_SECNOME) + cQbr + ;						   			//07 - Nombres
					Iif((cAliasSRA)->RA_SEXO=="M","1","2") + cQbr + ;					   			//08 - Sexo
					Iif(AllTrim((cAliasSRA)->RA_TPCIC) $ "04/07",(cAliasSRA)->RA_NACIONA,"    ") + cQbr + ;	//09 - Nacionalidad
					AllTrim((cAliasSRA)->RA_DDN) + cQbr + ;						   			//10 - Codigo Larga Distancia Nacional
					AllTrim((cAliasSRA)->RA_TELEFON) + cQbr + ;									//11 - Tel้fono
					AllTrim((cAliasSRA)->RA_EMAIL) + cQbr + ;										//12 - Correo electr๓nico
					AllTrim((cAliasSRA)->RA_TIPOVIA) + cQbr + ;									//13 - Domicilio del trabajador - Tipo de vํa
					AllTrim(FDESCRCC("S018",(cAliasSRA)->RA_TIPOVIA,1,2,3,20)) + cQbr + ;									//14 - Domicilio del trabajador - Nombre de vํa
					AllTrim((cAliasSRA)->RA_NUMERO) + cQbr + ;										//15 - Domicilio del trabajador - N๚mero de vํa
					AllTrim(FDESCRCC("S020",SUBSTR((cAliasSRA)->RA_CEP,1,2),1,2,3,25)) + cQbr + ;							//16 - Domicilio del trabajador - Departamento
					AllTrim((cAliasSRA)->RA_NUMINT) + cQbr +	;						//17 - Domicilio del trabajador - Interior
					AllTrim((cAliasSRA)->RA_MZA) + cQbr +	;						//18 - Domicilio del trabajador - Manzana
					AllTrim((cAliasSRA)->RA_LOTE)+ cQbr +	;						//19 - Domicilio del trabajador - Lote
					AllTrim((cAliasSRA)->RA_KM) + cQbr +	 ;						//20 - Domicilio del trabajador - Kilometro
					AllTrim((cAliasSRA)->RA_BLOQUE) + cQbr +	 ;						//21 - Domicilio del trabajador - Block
					AllTrim((cAliasSRA)->RA_ETAPA) + cQbr +	 ;						//22 - Domicilio del trabajador - Etapa
					AllTrim((cAliasSRA)->RA_TPZONA) + cQbr +	 ;				//24 - Domicilio del trabajador - Nombre de zona
					Alltrim(fDescRCC("S019",(cAliasSRA)->RA_TPZONA,1,2,3,25)) + cQbr +	 ;				//24 - Domicilio del trabajador - Nombre de zona
					AllTrim((cAliasSRA)->RA_REFER) + cQbr + ;							   			//25 - Domicilio del trabajador - Referencia
					AllTrim((cAliasSRA)->RA_CEP) + cQbr + ;										//26 - Domicilio del trabajador - Ubigeo
					AllTrim((cAliasSRA)->RA_TIPOVI2) + cQbr + ;									//13 - Domicilio del trabajador - Tipo de vํa
					AllTrim(FDESCRCC("S018",(cAliasSRA)->RA_TIPOVI2,1,2,3,20)) + cQbr + ;									//14 - Domicilio del trabajador - Nombre de vํa
					AllTrim((cAliasSRA)->RA_NUMER2) + cQbr + ;										//15 - Domicilio del trabajador - N๚mero de vํa
					AllTrim(FDESCRCC("S020",SUBSTR((cAliasSRA)->RA_CEP2,1,2),1,2,3,25)) + cQbr + ;							//16 - Domicilio del trabajador - Departamento
					AllTrim((cAliasSRA)->RA_NUMIN2) + cQbr +	;						//17 - Domicilio del trabajador - Interior
					AllTrim((cAliasSRA)->RA_MZA2) + cQbr +	;						//18 - Domicilio del trabajador - Manzana
					AllTrim((cAliasSRA)->RA_LOTE2)+ cQbr +	;						//19 - Domicilio del trabajador - Lote
					AllTrim((cAliasSRA)->RA_KM2) + cQbr +	 ;						//20 - Domicilio del trabajador - Kilometro
					AllTrim((cAliasSRA)->RA_BLOCK2) + cQbr +	 ;						//21 - Domicilio del trabajador - Block
					AllTrim((cAliasSRA)->RA_ETAPA2) + cQbr +	 ;						//22 - Domicilio del trabajador - Etapa
					AllTrim((cAliasSRA)->RA_TPZON2) + cQbr +	 ;				//24 - Domicilio del trabajador - Nombre de zona
					Alltrim(fDescRCC("S019",(cAliasSRA)->RA_TPZON2,1,2,3,25)) + cQbr +	 ;				//24 - Domicilio del trabajador - Nombre de zona
					AllTrim((cAliasSRA)->RA_REFER2) + cQbr + ;							   			//25 - Domicilio del trabajador - Referencia
					AllTrim((cAliasSRA)->RA_CEP2) + cQbr + ;										//26 - Domicilio del trabajador - Ubigeo
					AllTrim((cAliasSRA)->RA_DIRESSA) + cQbr )
		
		(cAliasSRA)->( DbSkip() )	
		
	EndDo		    		

	(cAliasSRA)->(DbCloseArea())

	If Len(aTxt04) > 0
		GerarArq( cArq04, aTxt04, cDir )
		aTxt04 := Array(0)
	EndIf

EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 5 - "Datos del trabajador"											ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "5" $ MV_PAR03

	IncProc(STR0006+STR0025)	//"Processando Estrutura "###"5 (Datos del trabajador)"

	BeginSql alias cAliasSRA

		SELECT 	SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_TPCIC, SRA.RA_CIC, SRA.RA_CODPAIS, SRA.RA_GRINRAI,SRA.RA_CODFUNC,
				SRA.RA_SITEPS, SRA.RA_CTDEPSA, SRA.RA_CUSPP, SRA.RA_SCTRPEN, SRA.RA_MOTCON, SRA.RA_SINDICA, SRA.RA_SALARIO,	
				SRA.RA_TPFUNC, SRA.RA_TIPOPGT, SRA.RA_CONV2TR, SRA.RA_SITTRAB, SQ3.Q3_OCUPRIV
				
		FROM %table:SRA% SRA
		
		INNER JOIN %table:SQ3% SQ3
		    ON SRA.RA_CARGO = SQ3.Q3_CARGO
	        
	    
		WHERE ( SRA.RA_SITFOLH <> 'D' OR SUBSTRING(RA_DEMISSA,1,6) = %exp:cAnoMesArq% )
			AND SRA.%notDel%
			AND SQ3.%notDel%
	    
	    ORDER BY SRA.RA_FILIAL, SRA.RA_MAT 
	    
	EndSql

	While (cAliasSRA)->( !Eof() )

		aAdd(aTxt05,;
					AllTrim((cAliasSRA)->RA_TPCIC) + cQbr + ;																	//01 - Tipo de documento del trabajador
					AllTrim((cAliasSRA)->RA_CIC) + cQbr + ;																			//02 - Numero de documento del trabajador
					Alltrim((cAliasSRA)->RA_CODPAIS) + cQbr + ;																	//03 - Pais emissor do documento
					"1" + cQbr + ;																									//04 - Regimen Laboral => 1:Privado e 2:Publico
					AllTrim((cAliasSRA)->RA_GRINRAI) + cQbr + ;																  	//05 - Nivel educativo
					Alltrim((cAliasSRA)->Q3_OCUPRIV) + cQbr + ;																		//06 - Ocupaci๓n
					"0" + cQbr + ;																									//07 - Discapacidad
					AllTrim((cAliasSRA)->RA_CUSPP) + cQbr + ;																		//08 - CUSPP
					Alltrim(Iif(Empty((cAliasSRA)->RA_SCTRPEN),"0","2")) + cQbr + ; 												//09 - SCTR Pension
					AllTrim((cAliasSRA)->RA_MOTCON) + cQbr + ;																		//10 - Tipo de contrato de trabajo
					"0" + cQbr + ;																									//11 - Trabajador sujeto a r้gimen alternativo, acumulativo o atํpico de jornada de trabajo y descanso
					"0" + cQbr + ;																									//12 - Trabajador sujeto a jornada de trabajo mแxima
					"0" + cQbr + ;																									//13 - Trabajador sujeto a horario nocturno
					AllTrim(Iif(Empty((cAliasSRA)->RA_SINDICA),"0","1")) + cQbr + ; 												//14 - Es sindicalizado
					Iif((cAliasSRA)->RA_TIPOPGT=="M","1",Iif((cAliasSRA)->RA_TIPOPGT=="S","3","5")) + cQbr + ;					//15 - Periodicidad de la remuneraci๓n o retribuci๓n
					AllTrim((cAliasSRA)->RA_SALARIO) + cQbr + ; 																	//16 - Monto de la remuneraci๓n bแsica inicial de los trabajadores sujetos al r้gimen del D.Leg. 728
					AllTrim((cAliasSRA)->RA_SITEPS) + cQbr + ;																		//17 - Situacion
					"0" + cQbr + ;																									//18 - Rentas de quinta categorํa exoneradas (inciso e) del Art. 19 de la Ley del Impuesto a la Renta)
					Iif(Empty((cAliasSRA)->RA_SITTRAB) .Or. (cAliasSRA)->RA_SITTRAB=="3","0",(cAliasSRA)->RA_SITTRAB) +cQbr+ ; 	//19 - Situacion especial del trabajador
					Iif(Empty((cAliasSRA)->RA_CTDEPSA),"1","2") + cQbr + ;															//20 - Tipo de pago
					AllTrim((cAliasSRA)->RA_TPFUNC) + cQbr + ;																		//21 - Categorํa ocupacional del trabajador
					AllTrim((cAliasSRA)->RA_CONV2TR) + cQbr + ;																  	//22 - Convenio para evitar la doble tributacion
					Iif((cAliasSRA)->RA_TPFUNC=="67", Alltrim((cAliasSRA)->RA_CIC), "") + cQbr  )									//23 - N. de RUC
		
		(cAliasSRA)->( DbSkip() )	
		
	EndDo		    		

	(cAliasSRA)->(DbCloseArea())

	If Len(aTxt05) > 0
		GerarArq( cArq05, aTxt05, cDir )
		aTxt05 := Array(0)
	EndIf

EndIf
		
		
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 13 - "Importar Datos de derechohabientes - ALTAS"              		ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "D" $ MV_PAR03

	IncProc(STR0006+STR0026)	//"Processando Estrutura "###"13 (ALTAS Derechohabientes)"

	BeginSql alias cAliasSRA

		SELECT 	SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_TPCIC, SRA.RA_CIC, SRA.RA_CODAREA, SRA.RA_TELEFON, SRA.RA_EMAIL,
				SRB.RB_TPCIC, SRB.RB_CIC, SRB.RB_PAISPAS, SRB.RB_DTNASC, SRB.RB_NOMEPAT, SRB.RB_NOMEMAT, SRB.RB_NOME,
				SRB.RB_GRAUPAR,	SRB.RB_TPDOCPA, SRB.RB_DOCPAT, SRB.RB_MESCONC, SRB.RB_LOGRADO, SRB.RB_ENDEREC, SRB.RB_ENDEREC,
				SRB.RB_COMPLEM, SRB.RB_SEXO, SRB.RB_TPZONA,  SRB.RB_REFEREN, SRB.RB_CEP, SRB.RB_NUMERO	
		FROM %table:SRA% SRA
		
		INNER JOIN %table:SRB% SRB
		    ON SRA.RA_FILIAL = SRB.RB_FILIAL
			AND	SRA.RA_MAT = SRB.RB_MAT
	    
		WHERE ( SRA.RA_SITFOLH <> 'D' OR SUBSTRING(RA_DEMISSA,1,6) = %exp:cAnoMesArq% )
			AND SRB.RB_DTBAIXA = ' '
			AND SRB.%notDel%
			AND SRA.%notDel%
	    
	    ORDER BY SRA.RA_FILIAL, SRA.RA_MAT 
	    
	EndSql

	While (cAliasSRA)->( !Eof() )

		aAdd(aTxt13,;
					Alltrim((cAliasSRA)->RA_TPCIC) + cQbr + ; 						//01- Tipo de documento funcionario
					Alltrim((cAliasSRA)->RA_CIC) + cQbr + ; 							//02- Numero do documento
					Alltrim((cAliasSRA)->RB_TPCIC) + cQbr + ; 							//03- Tipo de documento dependente
					Alltrim((cAliasSRA)->RB_CIC) + cQbr + ; 							//04- Numero do documento dependente
					Alltrim((cAliasSRA)->RB_PAISPAS) + cQbr + ;						//05- Pais emissor passaporte
					QrConvData((cAliasSRA)->RB_DTNASC,10) + cQbr + ;					//06- Data nascimento
					Alltrim((cAliasSRA)->RB_NOMEPAT) + cQbr + ;						//07- Nome paterno
					Alltrim((cAliasSRA)->RB_NOMEMAT) + cQbr + ;						//08- Nome materno
					Alltrim((cAliasSRA)->RB_NOME) + cQbr + ;							//09- Nome dependente
					Iif((cAliasSRA)->RB_SEXO=="M","1","2") + cQbr + ;					//10- Sexo
					Alltrim((cAliasSRA)->RB_GRAUPAR) + cQbr + ;						//11- Vinculo familiar
					Alltrim((cAliasSRA)->RB_TPDOCPA) + cQbr + ; 						//12- Documento do vinculo
					Alltrim((cAliasSRA)->RB_DOCPAT) + cQbr + ;							//13- Num. documento do vinculo
    				Alltrim((cAliasSRA)->RB_MESCONC) + cQbr + ; 						//14- Mes de concepcao
					Alltrim((cAliasSRA)->RB_LOGRADO) + cQbr + ; 						//15- Tipo via  INICIO ENDERECO1
					Alltrim((cAliasSRA)->RB_ENDEREC) + cQbr + ; 						//16- Nome via
					Alltrim((cAliasSRA)->RB_NUMERO) + cQbr + ;							//17- Numero
					Alltrim(SubStr((cAliasSRA)->RB_CEP,1,2)) + cQbr + ;				//18- Departamento
					Alltrim(SubStr((cAliasSRA)->RB_COMPLEM,1,4)) + cQbr + ;	   		//19- Interior
					Alltrim(SubStr((cAliasSRA)->RB_COMPLEM,5,4)) + cQbr + ;	  		//20- Manzana
					Alltrim(SubStr((cAliasSRA)->RB_COMPLEM,9,4)) + cQbr + ;	   		//21- Lote
					Alltrim(SubStr((cAliasSRA)->RB_COMPLEM,13,4)) + cQbr + ;   		//22- Kilometro
					Alltrim(SubStr((cAliasSRA)->RB_COMPLEM,17,4)) + cQbr + ;   		//23- Bloco
					Alltrim(SubStr((cAliasSRA)->RB_COMPLEM,21,4)) + cQbr + ;			//24- Etapa
					Alltrim((cAliasSRA)->RB_TPZONA) + cQbr + ;							//25- Tipo zona
					Alltrim(fDescRCC("S019",(cAliasSRA)->RB_TPZONA,3,30)) + cQbr + ;	//26- Nome da zona
					Alltrim((cAliasSRA)->RB_REFEREN) + cQbr + ;	   					//27- Referencia
					Alltrim((cAliasSRA)->RB_CEP) + cQbr  + ;		  					//28- UBIGEO
					cQbr + ; 															//29- Tipo via	INICIO ENDERECO1
					cQbr + ; 															//30- Nome via
					cQbr + ;															//31- Numero
					cQbr + ;							  								//32- Departamento
					cQbr + ;						 									//33- Interior
					cQbr + ;						 									//34- Manzana
					cQbr + ;						 									//35- Lote
					cQbr + ;						 									//36- Kilometro
					cQbr + ;						 									//37- Bloco
					cQbr + ;						 									//38- Etapa
					cQbr + ;									 						//39- Tipo zona
					cQbr + ;									  						//40- Nome zona
					cQbr + ;		 							  	   					//41- Referencia
					cQbr + ;										   					//42- UBIGEO
					"1" + cQbr + ;								   	   					//43- Endereco para assist.medica
					Alltrim((cAliasSRA)->RA_CODAREA) + cQbr + ;						//45- Codigo larga distancia nacional
					Alltrim((cAliasSRA)->RA_TELEFON) + cQbr + ;						//45- Telefone
					Alltrim((cAliasSRA)->RA_EMAIL) + cQbr )							//46- Email 
					MntLogError('D',.T.)

		(cAliasSRA)->( DbSkip() )	
		
	EndDo		    		

	(cAliasSRA)->(DbCloseArea())

	If Len(aTxt13) > 0
		GerarArq( cArq13, aTxt13, cDir )
		aTxt13 := Array(0)
	EndIf

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 15 - "Datos de los dias subsidiados del trabajador"					ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "F" $ MV_PAR03

	IncProc(STR0006+STR0027)	//"Processando Estrutura "###"15 (Dias Subsid. Trab...)"

	BeginSql alias cAliasSRA
	
		SELECT SRA.RA_FILIAL, SRA.RA_TPCIC, SRA.RA_CIC, SR8.R8_DATAINI, SR8.R8_DATAFIM, SR8.R8_DURACAO, RCM.RCM_CODSEF
		FROM %table:SRA% SRA

		INNER JOIN %table:SR8% SR8
		ON SRA.RA_FILIAL = SR8.R8_FILIAL 
		AND SRA.RA_MAT = SR8.R8_MAT

		INNER JOIN %table:RCM% RCM
		ON RCM.RCM_TIPO = SR8.R8_TIPOAFA

		WHERE SRA.RA_FILIAL = SR8.R8_FILIAL
		AND SRA.RA_MAT = SR8.R8_MAT
		AND ( ( SR8.R8_DATAINI >= %exp:DToS(dDataIni)% AND SR8.R8_DATAINI <= %exp:DToS(dDataFim)%)  OR 
			  ( SR8.R8_DATAFIM >= %exp:DToS(dDataIni)% AND SR8.R8_DATAFIM <= %exp:DToS(dDataFim)%)  OR 
			  ( SR8.R8_DATAINI <= %exp:DToS(dDataIni)% AND SR8.R8_DATAFIM >= %exp:DToS(dDataIni)%)  OR
			  ( SR8.R8_DATAINI <= %exp:DToS(dDataFim)% AND SR8.R8_DATAFIM = %exp:' '%) )
		AND RCM.RCM_CODSEF <> %exp:' '%
		AND SRA.%notDel% 
		AND SR8.%notDel%
		AND RCM.%notDel%
				
		ORDER BY SRA.RA_FILIAL, SRA.RA_TPCIC, SRA.RA_CIC, RCM.RCM_CODSEF

	EndSql
	
	While (cAliasSRA)->( !Eof() )

		If Empty((cAliasSRA)->R8_DATAFIM) .Or. SToD((cAliasSRA)->R8_DATAFIM) > dDataFim
			If SToD((cAliasSRA)->R8_DATAINI) < dDataIni
				nDias := dDataFim - dDataIni + 1
			Else
				nDias := dDataFim - SToD((cAliasSRA)->R8_DATAINI) + 1
			EndIf
		Else
			If SToD((cAliasSRA)->R8_DATAINI) < dDataIni
				nDias := SToD((cAliasSRA)->R8_DATAFIM) - dDataIni + 1
			Else
				nDias := (cAliasSRA)->R8_DURACAO
			EndIf
		EndIf

		aAdd(aTxt15,;
					Alltrim((cAliasSRA)->RA_TPCIC) + cQbr + ;	//01 - Tipo de Documento
					Alltrim((cAliasSRA)->RA_CIC) + cQbr + ;			//02 - Numero do documento
					Alltrim((cAliasSRA)->RCM_CODSEF) + cQbr + ;	//03 - Tipo de suspensใo da relacao laboral
					AllTrim(Transform(nDias,"@. 99")) + cQbr)		//04 - Numero de dias de suspensao

		(cAliasSRA)->( DbSkip() )	
		
	EndDo		    		

	(cAliasSRA)->(DbCloseArea())	

	If Len(aTxt15) > 0
		GerarArq( cArq15, aTxt15, cDir )
		aTxt15 := Array(0)
	EndIf
	
EndIf
		
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 18 - "Datos del detalle de los ingresos, tributos y descuentos del  ณ
//ณ      trabajador"													ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "I" $ MV_PAR03

	IncProc(STR0006+STR0028)	//"Processando Estrutura "###"18 (Ingr, Trib, Desc Trab...)"

	BeginSql alias cAliasSRA	
		
		SELECT SRA.RA_FILIAL, SRA.RA_TPCIC, SRA.RA_CIC, SRV.RV_CODREMU, SUM(SRD.RD_VALOR) AS RD_VALOR
		FROM %table:SRA% SRA 

		INNER JOIN %table:SRD% SRD
		ON SRA.RA_FILIAL = SRD.RD_FILIAL 
		AND SRA.RA_MAT = SRD.RD_MAT

		INNER JOIN %table:SRV% SRV 
		ON SRD.RD_PD = SRV.RV_COD
				
		WHERE SRA.RA_FILIAL = SRD.RD_FILIAL
		AND SRD.RD_DATARQ = %exp:cAnoMesArq%
		AND SRA.RA_MAT = SRD.RD_MAT
		AND SRD.RD_PD = SRV.RV_COD
		AND SRV.RV_GERAPDT = %exp:'1'%
		AND SRV.RV_CODREMU <> %exp:' '%
		AND SRA.%notDel%
		AND SRD.%notDel%
		AND SRV.%notDel%
				
		GROUP BY SRA.RA_FILIAL, SRA.RA_TPCIC, SRA.RA_CIC, SRV.RV_CODREMU
		ORDER BY SRA.RA_FILIAL, SRA.RA_CIC, SRV.RV_CODREMU
		
	EndSql

	While (cAliasSRA)->( !Eof() )

		aAdd(aTxt18,;
					Alltrim((cAliasSRA)->RA_TPCIC) + cQbr + ;								//01 - Tipo de documento
					Alltrim((cAliasSRA)->RA_CIC) + cQbr + ;										//02 - Numero de documento
					Alltrim((cAliasSRA)->RV_CODREMU) + cQbr + ;								//03 - Codigo da verba
					AllTrim(Transform((cAliasSRA)->RD_VALOR,"@. 9999999999999.99")) + cQbr + ;	//04 - Monto devengado
					AllTrim(Transform((cAliasSRA)->RD_VALOR,"@. 9999999999999.99")) + cQbr )	//05 - Monto pagado/descontado

		(cAliasSRA)->( DbSkip() )	
		
	EndDo		    		

	(cAliasSRA)->(DbCloseArea())

	If Len(aTxt18) > 0
		GerarArq( cArq18, aTxt18, cDir )
		aTxt18 := Array(0)
	EndIf

EndIf
 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 24 - "Importar Datos de derechohabientes - BAIXAS"             		ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "O" $ MV_PAR03

	IncProc(STR0006+STR0029)	//"Processando Estrutura "###"24 (BAJAS - Derechohabientes)"

	BeginSql alias cAliasSRA	
		
		SELECT 	SRA.RA_FILIAL, 	SRA.RA_MAT, 	SRA.RA_NOME, 	SRA.RA_TPCIC,	SRA.RA_CIC, 		SRB.RB_TPCIC, 
				SRB.RB_CIC, 	SRB.RB_PAISPAS,	SRB.RB_DTNASC, 	SRB.RB_NOMEPAT,	SRB.RB_NOMEMAT, SRB.RB_NOME, 
				SRB.RB_GRAUPAR,	SRB.RB_DTBAIXA, SRB.RB_MOTIVOB
		FROM %table:SRA% SRA       
		INNER JOIN %table:SRB% SRB
	    ON SRA.RA_FILIAL = SRB.RB_FILIAL
		AND	SRA.RA_MAT = SRB.RB_MAT
	    
		WHERE SRA.RA_ADMISSA <= %exp:dDataFim%
		AND ( SRA.RA_SITFOLH <> 'D' OR SUBSTRING(RA_DEMISSA,1,6) = %exp:cAnoMesArq% )
		AND SRB.RB_DTBAIXA <> ' '
		AND SRB.%notDel%
		AND SRA.%notDel%
	    ORDER BY SRA.RA_FILIAL, SRA.RA_MAT 
	    
	EndSql

	While (cAliasSRA)->( !Eof() )

		aAdd(aTxt24,;
					AllTrim((cAliasSRA)->RA_TPCIC) + cQbr + ;		//01- Tipo de documento funcionario
					AllTrim((cAliasSRA)->RA_CIC) + cQbr + ;				//02- Numero do documento
					AllTrim((cAliasSRA)->RB_TPCIC) + cQbr + ;			//03- Tipo de documento dependente
					AllTrim((cAliasSRA)->RB_CIC) + cQbr + ;			//04- Numero do documento dependente
					AllTrim((cAliasSRA)->RB_PAISPAS) + cQbr + ;		//05- Pais emissor passaporte
					QrConvData((cAliasSRA)->RB_DTNASC) + cQbr + ;		//06- Data nascimento
					AllTrim((cAliasSRA)->RB_NOMEPAT) + cQbr + ;		//07- Nome paterno
					AllTrim((cAliasSRA)->RB_NOMEMAT) + cQbr + ;		//08- Nome materno
					AllTrim((cAliasSRA)->RB_NOME) + cQbr + ;			//09- Nome dependente
					AllTrim((cAliasSRA)->RB_GRAUPAR) + cQbr + ;		//10- Vinculo familiar
					QrConvData((cAliasSRA)->RB_DTBAIXA,10) + cQbr + ;	//11- Data da baixa
					AllTrim((cAliasSRA)->RB_MOTIVOB) + cQbr )			//12- Motivo da baixa
					MntLogError('O',.T.)

		(cAliasSRA)->( DbSkip() )	
		
	EndDo		    		

	(cAliasSRA)->(DbCloseArea())

	If Len(aTxt24) > 0
		GerarArq( cArq24, aTxt24, cDir )
		aTxt24 := Array(0)
	EndIf

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 26 - "Trabajador - Otras condiciones" .toc                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "Q" $ MV_PAR03

	IncProc(STR0006+STR0030)	//"Processando Estrutura "###"26 (Trabajador - Otras cond...)"
	
	BeginSql alias cAliasSRA	

		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_TPCIC, SRA.RA_CIC, SRA.RA_CODAFP, SRA.RA_SEGUROV, SRA.RA_DOMICIL
		FROM %table:SRA% SRA      
		WHERE SRA.RA_ADMISSA <= %exp:DToS(dDataFim)%
		AND ( SRA.RA_SITFOLH <> 'D' OR SUBSTRING(RA_DEMISSA,1,6) = %exp:cAnoMesArq% )
		
		AND SRA.%notDel%
	    ORDER BY SRA.RA_CIC
	    
	EndSql
	
	While (cAliasSRA)->( !Eof() )

		aAdd(aTxt26,;
				Alltrim((cAliasSRA)->RA_TPCIC) + cQbr + ;				//01- Tipo de documento del trabajador
				Alltrim((cAliasSRA)->RA_CIC) + cQbr + ;						//02- Numero de documento del trabajador
				Iif((cAliasSRA)->RA_CODAFP=="05","1","0") + cQbr +	 ;		//03- Indicador de aporte a Asegura tu Pension
				Iif(!Empty((cAliasSRA)->RA_SEGUROV),"1","0") + cQbr + 	;	//04- Indicador de aporte a Vida Seguro de accidentes
				cQbr + ;													//05- Indicador de aporte al Fondo de Derechos Sociales del Artista (FDSA)
				Iif((cAliasSRA)->RA_DOMICIL=="1","1","2") + cQbr )			//06- Domiciliado

		(cAliasSRA)->( DbSkip() )
		
	EndDo		    		

	(cAliasSRA)->(DbCloseArea())
	
	If Len(aTxt26) > 0
		GerarArq( cArq26, aTxt26, cDir )
		aTxt26 := Array(0)
	EndIf	
		
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 17 - "Establecimientos donde labora el trabajador"					ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "H" $ MV_PAR03

	IncProc(STR0006+STR0031)	//"Processando Estrutura "###"17 (Establec. donde labora ...)"

	BeginSql alias cAliasSRA	

		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_TPCIC, SRA.RA_CIC, SRA.RA_CODPAIS, SRA.RA_EMPTER
		FROM %table:SRA% SRA      
		WHERE SRA.RA_CATPDT <> '4'
		
		AND SRA.%notDel%
	    ORDER BY SRA.RA_FILIAL, SRA.RA_MAT 
	    
	EndSql

	While (cAliasSRA)->( !Eof() )
	
		aAdd(aTxt17,;
					AllTrim((cAliasSRA)->RA_TPCIC) + cQbr + ;      																										//01 - Tipo de documento
					AllTrim((cAliasSRA)->RA_CIC) + cQbr + ;	  		   																										//02 - Num. de Documento
					Iif((cAliasSRA)->RA_TPCIC=="07",AllTrim((cAliasSRA)->RA_CODPAIS),"") + cQbr + ;																		//03 - Pais emissor do Documento
					Iif(Empty((cAliasSRA)->RA_EMPTER),AllTrim(cRuc),AllTrim((cAliasSRA)->RA_EMPTER)) + cQbr + ;															//04 - RUC propio o del empleador a quien destaco o desplazo Personal
					Iif(Empty((cAliasSRA)->RA_EMPTER),AllTrim(cCodEst),AllTrim(fTabela('S045',fPosTab("S045", (cAliasSRA)->RA_EMPTER, "=", 6 ),6,MV_PAR01 ))) + cQbr ) 	//05 - C๓digo de establecimiento

		(cAliasSRA)->( DbSkip() )
		
	EndDo		    		

	(cAliasSRA)->(DbCloseArea())
	
	If Len(aTxt17) > 0
		GerarArq( cArq17, aTxt17, cDir )
		aTxt17 := Array(0)
	EndIf

EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 10 - "Datos del personal de terceros"                        		ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "A" $ MV_PAR03

	IncProc(STR0006+STR0032)	//"Processando Estrutura "###"10 (Personal de terceros...)"

	BeginSql alias cAliasSRA	

		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_TPCIC, SRA.RA_CIC, SRA.RA_CODPAIS, SRA.RA_EMPTER, SRA.RA_SCTRPEN
		FROM %table:SRA% SRA      
		WHERE SRA.RA_CATPDT = '4'
		
		AND SRA.%notDel%
	    ORDER BY SRA.RA_FILIAL, SRA.RA_MAT 
	    
	EndSql

	While (cAliasSRA)->( !Eof() )  

		aAdd(aTxt10,;
					AllTrim((cAliasSRA)->RA_TPCIC) + cQbr + ;      													//01 - Tipo de documento
					AllTrim((cAliasSRA)->RA_CIC) + cQbr + ;	  		   								  					//02 - Num. de Documento
					Iif((cAliasSRA)->RA_TPCIC=="07",AllTrim((cAliasSRA)->RA_CODPAIS),"") + cQbr + ;					//03 - Pais emissor do Documento
					AllTrim((cAliasSRA)->RA_EMPTER) + cQbr + ;															//04 - RUC del empleador que me destaca/desplazo Personal
					Iif(Empty((cAliasSRA)->RA_SCTRPEN),"1",(Iif((cAliasSRA)->RA_SCTRPEN == '04','2','1'))) + cQbr )	//05 - SCTR Pension

		(cAliasSRA)->( DbSkip() )

	EndDo		    		

	(cAliasSRA)->(DbCloseArea())

	If Len(aTxt10) > 0
		GerarArq( cArq10, aTxt10, cDir )
		aTxt10 := Array(0)
	EndIf

EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 9 - "Datos del PERSONAL EN FORMACION -  modalidad formativa laboral y otros"   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "9" $ MV_PAR03

	IncProc(STR0006+STR0033)	//"Processando Estrutura "###"9 (Personal en formacion...)"

	BeginSql alias cAliasSRA	

		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_TPCIC, SRA.RA_CIC, SRA.RA_CODPAIS, SRA.RA_TPFORM, SRA.RA_EMPTER, SRA.RA_SCTRPEN,
				SRA.RA_CODFUNC, SRA.RA_CARGO, SRA.RA_TPDEFFI, SRA.RA_TPCFORM, SRA.RA_TNOTRAB,SRA.RA_GRINRAI
		FROM %table:SRA% SRA      

		WHERE SRA.RA_CATPDT = '5' //ESTAGIARIO
		
		AND SRA.%notDel%
	    ORDER BY SRA.RA_FILIAL, SRA.RA_MAT 
	    
	EndSql

	While (cAliasSRA)->( !Eof() )  

		If SQ3->( dbSeek(xFilial("SQ3",(cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_CARGO,.F.) )
			cOcupac := SQ3->Q3_OCUPRIV
		Else
			cOcupac := ""
		EndIf

		If SRA->RA_SEXO == "M"
			cMadreRes := ""
		Else
		 	If SRB->( dbSeek(xFilial("SRB",(cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_MAT,.F.) )
		 		cMadreRes := "1"
		 	Else
		 		cMadreRes := "0"
		 	EndIf
		EndIf

		aAdd(aTxt09,;
					AllTrim((cAliasSRA)->RA_TPCIC) + cQbr + ;    	  								//01 - Tipo documento do estagiario
					AllTrim((cAliasSRA)->RA_CIC) + cQbr + ;	              								//02 - Num. Doc. estagiario
					Iif((cAliasSRA)->RA_TPCIC=="07",AllTrim((cAliasSRA)->RA_CODPAIS),"") + cQbr + ;	//03 - Pais emissor do documento
					AllTrim((cAliasSRA)->RA_TPFORM) + cQbr + ;	 										//04 - Tipo de modalidad formativa laboral
					"1" + cQbr + ;													   					//05 - Seguro M้dico
					AllTrim((cAliasSRA)->RA_GRINRAI) + cQbr + ;								 		//06 - Nivel educativo
					AllTrim(cOcupac) + cQbr + ;													 		//07 - Ocupacion
					cMadreRes + cQbr + ;														 		//08 - Madre con responsabilidad Familiar
					Iif((cAliasSRA)->RA_TPDEFFI == "0", "0", "1" ) + cQbr +	;						//09 - Discapacidad
					AllTrim((cAliasSRA)->RA_TPCFORM) + cQbr + ;								   		//10 - Tipo de Centro de Formaci๓n Profesional
					Iif(fTrabHnot(),"1","0") + cQbr )  										 		//11 - Sujeto a trabajo en horario nocturno

		(cAliasSRA)->( DbSkip() )

	EndDo		    		

	(cAliasSRA)->(DbCloseArea())

	If Len(aTxt09) > 0
		GerarArq( cArq09, aTxt09, cDir )
		aTxt09 := Array(0)
	EndIf

EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 11 - "Datos de periodos"                                     		ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "B" $ MV_PAR03

	IncProc(STR0006+STR0034)	//"Processando Estrutura "###"11 (Datos de periodos)"

	BeginSql alias cAliasSRA	

		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_TPCIC, SRA.RA_CIC, SRA.RA_CODPAIS, SRA.RA_CATPDT, 
				SRA.RA_ADMISSA, SRA.RA_DEMISSA, SRA.RA_TPFUNC, SRA.RA_SCTRSAL
		FROM %table:SRA% SRA      

		WHERE ( SRA.RA_SITFOLH = 'D' AND SRA.RA_DEMISSA <> ' ' )
		
		AND SRA.%notDel%
	    ORDER BY SRA.RA_FILIAL, SRA.RA_MAT 
	    
	EndSql

	While (cAliasSRA)->( !Eof() )  

		If SRG->( dbSeek(xFilial("SRG",(cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_MAT,.F.) )
			cTipoRes := SRG->RG_TIPORES
		Else
			cTipoRes := ""
		EndIf
	
		aAdd(aTxt11,;
					AllTrim((cAliasSRA)->RA_TPCIC) + cQbr + ;											//01 - Tipo de documento
					AllTrim((cAliasSRA)->RA_CIC) + cQbr + ;													//02 - Num. de Documento
					Iif((cAliasSRA)->RA_TPCIC=="07",AllTrim((cAliasSRA)->RA_CODPAIS),"") + cQbr + ;		//03 - Pais emissor do Documento
					AllTrim((cAliasSRA)->RA_CATPDT) + cQbr + ;												//04 - Categoria
					Iif(Empty(cTipoRes),'2','1') + cQbr + ;												//05 - Tipo de registro - FALTA INFORMACAO
					QrConvData((cAliasSRA)->RA_ADMISSA) + cQbr + ;											//06 - Data de inicio/reinicio
					Iif(Empty((cAliasSRA)->RA_DEMISSA),"",QrConvData((cAliasSRA)->RA_DEMISSA)) +cQbr+ ;	//07 - Data final
					AllTrim(Iif(Empty(cTipoRes),(cAliasSRA)->RA_TPFUNC,cTipoRes)) + cQbr + ;				//08 - Indicador de tipo de registro
					SubStr(AllTrim((cAliasSRA)->RA_SCTRSAL),2) + cQbr )									//09 - EPS/Servicios Propios
	
		(cAliasSRA)->( DbSkip() )

	EndDo		    		

	(cAliasSRA)->(DbCloseArea())

	If Len(aTxt11) > 0
		GerarArq( cArq11, aTxt11, cDir )
		aTxt11 := Array(0)
	EndIf

EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 12 - "Trabajador - Otras Rentas de 5ta. categorํa"            		ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "C" $ MV_PAR03 .and. !Empty(cVer5Cat)

	IncProc(STR0006+STR0035)	//"Processando Estrutura "###"12 (Trabajador Otras Rentas...)"

	BeginSql alias cAliasSRA	

		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_TPCIC, SRA.RA_CIC, RGB.RGB_RUCEMP, RGB.RGB_VALOR
		FROM %table:SRA% SRA      

		INNER JOIN %table:RGB% RGB
	    ON SRA.RA_FILIAL = RGB.RGB_FILIAL
		AND	SRA.RA_MAT = RGB.RGB_MAT

		WHERE SRA.RA_SITFOLH <> 'D'
		AND RGB.RGB_DTREF = %exp:cAnoMesArq%
		AND RGB.RGB_PD = %exp:cVer5Cat%
		AND SRA.%notDel%
		AND RGB.%notDel%
	    ORDER BY SRA.RA_FILIAL, SRA.RA_MAT 
	    
	EndSql

	While (cAliasSRA)->( !Eof() )  
	
		aAdd(aTxt12,;
					AllTrim((cAliasSRA)->RA_TPCIC) + cQbr + ;      									//01 - Tipo de documento
					AllTrim((cAliasSRA)->RA_CIC) + cQbr + ;	  		   									//02 - Num. de Documento
					AllTrim((cAliasSRA)->RGB_RUCEMP) + cQbr + ;										//03 - RUC del otro empleador
					PADL(AllTrim(Transform((cAliasSRA)->RGB_VALOR,"@. 9999999.99")),10," ") + cQbr ) 	//04 - Monto de la renta de quinta percibida en el otro empleador
		MntLogError('C',.T.)

		(cAliasSRA)->( DbSkip() )

	EndDo		    		

	(cAliasSRA)->(DbCloseArea())

	If Len(aTxt12) > 0
		GerarArq( cArq12, aTxt12, cDir )
		aTxt12 := Array(0)
	EndIf

EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 23 - "Lugar de formaci๓n de Personal en Formaci๓n - modalidad		ณ
//ณ formativa laboral y otros y de destaque del Personal de Terceros	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "N" $ MV_PAR03 

	IncProc(STR0006+STR0036)	//"Processando Estrutura "###"23 (Lugar formacion...)"

	BeginSql alias cAliasSRA	

		SELECT RGC.RGC_ESTABL,SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_TPCIC, SRA.RA_CIC, SRA.RA_CATPDT
		FROM %table:SRA% SRA      
		LEFT JOIN %table:RGC%  RGC ON SRA.RA_KEYLOC = RGC.RGC_KEYLOC AND SRA.RA_FILIAL = RGC.RGC_FILIAL
		WHERE SRA.RA_CATPDT BETWEEN %exp:'4'% AND %exp:'5'%
		AND SRA.%notDel% AND RGC.%notDel%
	    ORDER BY SRA.RA_FILIAL, SRA.RA_MAT 
	
	EndSql

	While (cAliasSRA)->( !Eof() )  
	
		aAdd(aTxt23,;
					AllTrim((cAliasSRA)->RA_TPCIC) + cQbr + ;										//01 - Tipo de documento
					AllTrim((cAliasSRA)->RA_CIC) + cQbr + ;				   								//02 - Numero do documento
					Iif((cAliasSRA)->RA_TPCIC=="07",AllTrim((cAliasSRA)->RA_CODPAIS),"") + cQbr + ;	//03 - Pais emissor do Documento
					AllTrim((cAliasSRA)->RA_CATPDT) + cQbr + ;											//04 - Categoria
					AllTrim((cAliasSRA)->RGC_ESTABL)+ cQbr )//AllTrim(cCodEst) + cQbr )															//05 - Codigo do estabelecimento

		(cAliasSRA)->( DbSkip() )

	EndDo		    		

	(cAliasSRA)->(DbCloseArea())

	If Len(aTxt23) > 0
		GerarArq( cArq23, aTxt23, cDir )
		aTxt23 := Array(0)
	EndIf
	
EndIf


Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GerarArq บAutor  ณ Ademar Fernandes   บ Data ณ 16/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Usado na funcao principal                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localizacao Peru                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GerarArq( cNomArq , aTexto , cDir )
Local i
Local nHdlArq	:= 0
Local cArquivo  := cDir+cNomArq
Local cTexto    := ""

If File(cArquivo)
	FErase(cArquivo)
Endif

nHdlArq  := fCreate(cArquivo)

For i=1 to Len(aTexto)
	cTexto := aTexto[i]+CHR(13)+CHR(10)
	fWrite(nHdlArq, cTexto, Len(cTexto))
Next i

FClose(nHdlArq)

lGerou := .T.

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fOpcPDT  บAutor  ณ Ademar Fernandes   บ Data ณ 16/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Usado na funcao principal                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localizacao Peru                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fOpcPDT()
Local cTitulo	:= STR0002	//"Gera็ใo PDT"
Local MvParDef	:= ""
Local MvPar		:= ""
Local aResul	:={}

MvPar	:=	&(Alltrim(ReadVar()))
MvRet	:=	Alltrim(ReadVar())

aResul  := {STR0037,; //"Establecimientos Propios del Empleador"
			STR0038,; //"Empleadores a quienes destaco o desplazo personal"
			STR0039,; //"Empleadores que me destacan o desplazan personal"
			STR0040,; //"Datos personales del trabajador, pensionista, personal en formaci๓n - modalidad formativa laboral y personal de terceros"
			STR0041,; //"Datos del TRABAJADOR"
			STR0042,; //"Datos del PERSONAL EN FORMACIำN -  modalidad formativa laboral y otros"
			STR0043,; //"Datos del PERSONAL DE TERCEROS"
			STR0044,; //"Datos de perํodos"
			STR0045,; //"Trabajador - Otras Rentas de 5ta. categorํa"
			STR0046,; //"Importar Datos de derechohabientes - ALTAS"
			STR0047,; //"Trabajador - Dํas subsidiados y otros no laborados."
			STR0048,; //"Establecimientos donde labora el trabajador"
			STR0049,; //"Trabajador - Detalle de ingresos, tributos y descuentos."
			STR0050,; //"Lugar de formaci๓n de Personal en Formaci๓n - modalidad formativa laboral y otros y de destaque del Personal de Terceros" 
			STR0051,; //"Importar derechohabientes - BAJA"
			STR0052,; //"Trabajador - Otras condiciones"
			STR0053 } //"Datos de estudios concluidos"
			
MvParDef	:=	"123459ABCDFHINOQT"

f_Opcoes(@MvPar,cTitulo,aResul,MvParDef)
&MvRet := mvpar

Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QrConvData บAutor  ณ M. Silveira      บ Data ณ 21/10/2013  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Usado na funcao principal com uso de query                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localizacao Peru                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function QrConvData(dData)
Local cAuxData := Space(10)

If !Empty(dData)

	If ValType(dData) == "D"  
		dData := DTOC(dData)
	EndIf
	cAuxData := Substr(dData,7,2)+"/"+Substr(dData,5,2)+"/"+Substr(dData,1,4)
EndIf

Return(cAuxData)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerBasePDTบAutor  ณ Leandro Drumond    บ Data ณ 27/12/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se todos os campos necessarios foram criados.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerBasePDT()
Local aArea := GetArea()
Local lRet  := .T.

DbSelectArea("SRA")
If !( SRA->( FieldPos( "RA_CODPAIS" ) ) > 0 ) .or. !( SRA->( FieldPos( "RA_TPCFORM" ) ) > 0 ) .or. !( SRA->( FieldPos( "RA_CATPDT" ) ) > 0 ) .or. !( SRA->( FieldPos( "RA_EMPTER" ) ) > 0 )  .or. !( RGB->( FieldPos( "RGB_RUCEMP" ) ) > 0 ) //Verificar se o campo existe, caso nใo exista nใo foi executado o update
	lRet := .F.
EndIf

RestArea(aArea)
		
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfTrabHnot บAutor  ณ Leandro Drumond    บ Data ณ 19/12/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o funcionario trabalha em periodo noturno.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fTrabHnot()
Local aArea		:= GetArea()
Local cFilter	:= ""
Local cIniHNot  := ""
Local cFimHNot	:= ""
Local lRet 		:= .F.
Local lUseSPJ 	:= SuperGetMv("MV_USESPJ",NIL,"0")  == "1"
Local lExInAs400


If SR6->(DbSeek(xFilial('SR6',(cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_TNOTRAB))
	cIniHNot := Alltrim(Str(SR6->R6_INIHNOT))
	cFimHNot := Alltrim(Str(SR6->R6_FIMHNOT))


		lExInAs400 := ExeInAs400()
		If lUseSPJ
			cAliasQuery := GetNextAlias()
					
			cFilter := " PJ_FILIAL = '"+(cAliasSRA)->RA_FILIAL+"'"
			cFilter += " AND PJ_TURNO = '"+(cAliasSRA)->RA_TNOTRAB+"'"
			cFilter += " AND ( ( PJ_ENTRA1 >= '" + cIniHNot + "' OR PJ_ENTRA2 >= '" + cIniHNot + "' OR PJ_ENTRA3 >= '" + cIniHNot + "' OR PJ_ENTRA4 >= '" + cIniHNot + "' "
			cFilter += " OR PJ_SAIDA1 > '" + cIniHNot + "' OR PJ_SAIDA2 > '" + cIniHNot + "' OR PJ_SAIDA3 > '" + cIniHNot + "' OR PJ_SAIDA4 > '" + cIniHNot + "' ) "
			cFilter += " OR PJ_SAIDA1 < PJ_ENTRA1 OR PJ_SAIDA2 < PJ_ENTRA1 OR PJ_SAIDA3 < PJ_ENTRA1 OR PJ_SAIDA4 < PJ_ENTRA1 ) OR "
			cFilter += " ( PJ_ENTRA1 < '" + cFimHNot + "' OR PJ_ENTRA2 <= '" + cFimHNot + "' OR PJ_ENTRA3 <= '" + cFimHNot + "' OR PJ_ENTRA4 <= '" + cFimHNot + "' "
			cFilter += " OR PJ_SAIDA1 < '" + cFimHNot + "' OR PJ_SAIDA2 < '" + cFimHNot + "' OR PJ_SAIDA3 < '" + cFimHNot + "' OR PJ_SAIDA4 < '" + cFimHNot + "' ) "
			cFilter += " OR PJ_SAIDA1 < PJ_ENTRA1 OR PJ_SAIDA2 < PJ_ENTRA1 OR PJ_SAIDA3 < PJ_ENTRA1 OR PJ_SAIDA4 < PJ_ENTRA1 ) ) "
		
			If !lExInAs400
				cFilter    += " AND D_E_L_E_T_ = ' ' "
			Else
				cFilter    += " AND @DELETED@ = ' ' "
			EndIf
			
			cFilter := "%"+cFilter+"%"
		
			BeginSql alias cAliasQuery
				%NoParser%
				SELECT 
					MIN(cAliasQuery.PJ_ENTRA1) MINHRA
				FROM 
					%Table:SPJ% cAliasQuery
				WHERE 
					%Exp:cFilter%
			EndSql
							
			If !Empty((cAliasQuery)->(MINHRA))
				lRet := .T.
			EndIf
			
			(cAliasQuery)->(dbCloseArea())	
		Else
			cAliasQuery := GetNextAlias()
					
			cFilter := " RF7_FILIAL = '"+(cAliasSRA)->RA_FILIAL+"'"
			cFilter += " AND RF7_MAT = '"+(cAliasSRA)->RA_MAT+"'"
			cFilter += " AND ( RF7_ENTRA >= '" + cIniHNot + "' OR RF7_SAIDA >= '" + cIniHNot + "' OR RF7_ENTRA < '" + cFimHNot + "' OR RF7_SAIDA <= '" + cFimHNot + "' OR ( RF7_DATAS > RF7_DATAE ) )"
		
			If !lExInAs400
				cFilter    += " AND D_E_L_E_T_ = ' ' "
			Else
				cFilter    += " AND @DELETED@ = ' ' "
			EndIf
			
			cFilter := "%"+cFilter+"%"
		
			BeginSql alias cAliasQuery
				%NoParser%
				SELECT 
					MIN(cAliasQuery.RF7_ENTRA) MINHRA
				FROM 
					%Table:RF7% cAliasQuery
				WHERE 
					%Exp:cFilter%
			EndSql
							
			If !Empty((cAliasQuery)->(MINHRA))
				lRet := .T.
			EndIf
			
			(cAliasQuery)->(dbCloseArea())	
		EndIf

EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณfCargaPd   บAutor  ณ Leandro Drumond    บ Data ณ 11/01/2012 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega a verba referente ao identificador.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCargaPd(cCodFol)
Local cRet := ''

SRV->(dbSetOrder(2))

If SRV->( dbSeek(xFilial("SRV",SRA->RA_FILIAL)+cCodFol,.F.) )
	cRet := SRV->RV_COD
EndIf

SRV->(dbSetOrder(1))

Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณMntLogErrorบAutor  ณ Leandro Drumond    บ Data ณ 13/01/2012 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica existencia de inconsistencias e monta log.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MntLogErro(cCod,lQuery)

Local aLogClone := aClone(aLogFile)
Local cAliasTab	:= ""

DEFAULT cCod := 'XX'
DEFAULT lQuery := .F.

cAliasTab := If( lQuery, '(cAliasSRA)', 'SRA' )

If !lErro
	aAdd(aLogFile, " ")
	
	If cCod $ "E|6|J|L|M|P|XX"
		aAdd(aLogFile, STR0014 + SRA->RA_MAT + " - " + SRA->RA_NOME )  //Ocorrencias para o funcionแrio: ###
	Else
		aAdd(aLogFile, STR0014 + (cAliasSRA)->RA_MAT + " - " + (cAliasSRA)->RA_NOME )  //Ocorrencias para o funcionแrio: ###
	EndIf
	
	aAdd(aLogFile, " ")
EndIf

If cCod == 'XX'
	If (cAliasTab)->RA_TPCIC == '07' .and. Empty((cAliasTab)->RA_CODPAIS)
		aAdd(aLogFile, STR0011 + "'RA_CODPAIS'" + STR0012 )  //Campo #### deve ser preenchido quando o tipo de coumento ้ passaporte
		lErro := .T.
	EndIf
	If Empty((cAliasTab)->RA_CIC)
		aAdd(aLogFile, STR0011 + "'RA_CIC'" + STR0013 ) //Campo #### deve ser preenchido
		lErro := .T.
	EndIf
	If Empty((cAliasTab)->RA_TPCIC)
		aAdd(aLogFile, STR0011 + "'RA_TPCIC'" + STR0013) //Campo #### deve ser preenchido
		lErro := .T.
	EndIf
	
	If "4" $ MV_PAR03
		If Empty((cAliasTab)->RA_SEXO)
			aAdd(aLogFile, STR0011 + "'RA_SEXO'" + STR0013) //Campo #### deve ser preenchido
			lErro := .T.
		EndIf
	EndIf
	
	If "5" $ MV_PAR03
		If Empty((cAliasTab)->RA_MOTCON)
			aAdd(aLogFile, STR0011 + "'RA_MOTCON'" + STR0013 ) //Campo #### deve ser preenchido
			lErro := .T.
		EndIf
		If Empty((cAliasTab)->RA_TIPOPGT)
			aAdd(aLogFile, STR0011 + "'RA_TIPOPGT'" + STR0013 ) //Campo #### deve ser preenchido
			lErro := .T.
		EndIf
		If Empty((cAliasTab)->RA_SITTRAB)
			aAdd(aLogFile, STR0011 + "'RA_SITTRAB'" + STR0013 ) //Campo #### deve ser preenchido
			lErro := .T.
		EndIf	
	EndIf
	
	If "9" $ MV_PAR03
		If Empty((cAliasTab)->RA_TPFORM)
			aAdd(aLogFile, STR0011 + "'RA_TPFORM'" + STR0013 ) //Campo #### deve ser preenchido
			lErro := .T.
		EndIf
		If Empty((cAliasTab)->RA_GRINRAI)
			aAdd(aLogFile, STR0011 + "'RA_GRINRAI'" + STR0013 ) //Campo #### deve ser preenchido
			lErro := .T.
		EndIf
		If Empty((cAliasTab)->RA_TPCFORM)
			aAdd(aLogFile, STR0011 + "'RA_TPCFORM'" + STR0013 ) //Campo #### deve ser preenchido
			lErro := .T.
		EndIf	
	EndIf
	
	If "A" $ MV_PAR03
		If Empty((cAliasTab)->RA_EMPTER)
			aAdd(aLogFile, STR0011 + "'RA_EMPTER'" + STR0013 ) //Campo #### deve ser preenchido
			lErro := .T.
		EndIf	
	EndIf
	
	If Empty((cAliasTab)->RA_CATPDT) .and. ( "9" $ MV_PAR03 .or. "A" $ MV_PAR03 .or. "B" $ MV_PAR03 .or. "H" $ MV_PAR03 .or. "L" $ MV_PAR03 .or. "M" $ MV_PAR03 .or. "N" $ MV_PAR03 .or. "P" $ MV_PAR03 )
		aAdd(aLogFile, STR0011 + "'RA_CATPDT'" + STR0013 ) //Campo #### deve ser preenchido
		lErro := .T.
	EndIf	
	
EndIf

If cCod == "6"
	If Empty(SRQ->RQ_TPPENS)
		aAdd(aLogFile, STR0011 + "'RQ_TPPENS'" + STR0013 ) //Campo #### deve ser preenchido
		lErro := .T.
	EndIf
	If Empty(SRQ->RQ_REGPENS)
		aAdd(aLogFile, STR0011 + "'RQ_REGPENS'" + STR0013 ) //Campo #### deve ser preenchido
		lErro := .T.
	EndIf
	If SRQ->RQ_TPCIC == '07' .and. Empty(SRQ->RQ_PAISPAS)
		aAdd(aLogFile, STR0011 + "'RQ_PAISPAS'" + STR0012 )  //Campo #### deve ser preenchido quando o tipo de coumento ้ passaporte
		lErro := .T.
	EndIf
	If Empty(SRQ->RQ_RG)
		aAdd(aLogFile, STR0011 + "'RQ_RG'" + STR0013 ) //Campo #### deve ser preenchido
		lErro := .T.
	EndIf
	If Empty(SRQ->RQ_TPCIC)
		aAdd(aLogFile, STR0011 + "'RQ_TPCIC'" + STR0013) //Campo #### deve ser preenchido
		lErro := .T.
	EndIf	
EndIf

If cCod == "C"
	If Empty((cAliasTab)->RGB_RUCEMP)
		aAdd(aLogFile, STR0011 + "'RGB_RUCEMP'" + STR0013 ) //Campo #### deve ser preenchido
		lErro := .T.
	EndIf		
EndIf

If cCod == "D" .or. cCod == "O"
	If (cAliasSRA)->RB_TPCIC == '07' .and. Empty((cAliasSRA)->RB_PAISPAS) .and. !lTpCic
		aAdd(aLogFile, STR0011 + "'RB_PAISPAS'" + STR0012 )  //Campo #### deve ser preenchido quando o tipo de coumento ้ passaporte
		lTpCic := .T.
		lErro  := .T.
	EndIf
	If Empty((cAliasSRA)->RB_CIC) .and. !lCic
		aAdd(aLogFile, STR0011 + "'RB_CIC'" + STR0013 ) //Campo #### deve ser preenchido
		lCic  := .T.
		lErro := .T.
	EndIf			
EndIf

If !lErro
	aLogFile := aClone(aLogClone) //Se nao existiu inconsistencias no funcionario, retorna array original
EndIf

Return Nil
