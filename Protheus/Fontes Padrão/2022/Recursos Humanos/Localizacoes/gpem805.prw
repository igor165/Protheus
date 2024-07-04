#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM805.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GPEM805  บAutor  ณ Cesar Perea             บ Data ณ 01/12/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Geracao de arquivo PLAME                                        บฑฑ
ฑฑบ          ณ                                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localizacao Peru                                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  บฑฑ
ฑฑฬออออออออออออัออออออออัอออออออออออัออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ Data   ณ BOPS/FNC  ณ  Motivo da Alteracao                     บฑฑ
ฑฑฬออออออออออออุออออออออุอออออออออออุออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ            ณ        ณ           ณ                                          ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function GPEM805()

Local aSays     := {}
Local aButtons  := {}
Local cCadastro := STR0001	//"Arquivos PLAME"
Local cDescr    := STR0002	//"Gera็ใo dos Arquivos do PLAME Peru."

Private cPerg	:= "GPM805"
Private lAutomato := isblind()

If !VerBasePDT()
    MsgInfo(OemToAnsi(STR0009))  //"Antes de prosseguir ้ necessแrio executar a atualiza็ao 'Geracao do arquivo PDT layout 12/2011', disponํvel para o m๓dulo SIGAGPE no compatibilizador RHUPDMOD."
    Return(.F.)
EndIf

Pergunte(cPerg,.F.)

AADD(aSays, cDescr )
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.) } } )
AADD(aButtons, { 1,.T.,{|| If( GPM805Ok(), FechaBatch(), ) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
If !lAutomato
	FormBatch( cCadastro, aSays, aButtons )
Else
	GPM805Ok()
EndIf
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GPM805Ok บAutor  ณ Ademar Fernandes   บ Data ณ 16/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Usado na funcao principal                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localizacao Peru                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM805Ok()

Local aTabEmp   := {}
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
MV_PAR01 -Fecha base inicial
MV_PAR02 - Fecha base final
MV_PAR03 - Archivo destino
MV_PAR04 - Generar Archivos
MV_PAR05 - Codigo del formulario
MV_PAR06 - Sucursal
MV_PAR07 - Matricula
MV_PAR08 - Proceso
*/

If Empty(MV_PAR01) .OR. Empty(MV_PAR02) .OR. Empty(MV_PAR03) .OR. Empty(MV_PAR04)
	Alert(STR0003)	//"Preencher os Parametros"
	Return(.F.)
EndIf

Private dDataIni	:= MV_PAR01 //FirstDate(MV_PAR01)
Private dDataFim	:= MV_PAR02 //LastDate(MV_PAR02)
Private cAnoMesArq	:= AnoMes(MV_PAR01)

fRetTab(@aTabEmp,"S002",,,dDataBase)
If Len(aTabEmp) >= 19
	cRuc    := IIF (VALTYPE(aTabEmp[5])=='N', ALLTRIM(STR(aTabEmp[5])),ALLTRIM(aTabEmp[5]))
	cTipEst := aTabEmp[19]
EndIf
nPOS := fPosTab("ST57", cTipEst, "==", 04)
If nPOS > 0
	cDescr := fTabela("ST57",nPOS,05)
EndIf

If !lAutomato
	Processa( {|lEnd| GPM805Proc(cRuc,cCodEst,cTipEst,cRisco,cDescr), STR0001 })	//"Gerando Arquivos... Aguarde!"
	If lGerou
		MsgInfo(STR0005)	//"PLAME Gerado com Sucesso!!"
	Else
		MsgInfo(STR0010) 	//"Nenhum arquivo gerado!"
	EndIf
Else
	GPM805Proc(cRuc,cCodEst,cTipEst,cRisco,cDescr)
	If lGerou
		CONOUT(STR0005)	//"PLAME Gerado com Sucesso!!"
	Else
		CONOUT(STR0010) 	//"Nenhum arquivo gerado!"
	EndIf
EndIf



If Len(aLogFile) > 0
	aAdd(aLogTitle , STR0015 ) //'Se encontraron inconsistencias en la generaci๓n del PLAME'
	
	fMakeLog(	{aLogFile}															,;	//Array que contem os Detalhes de Ocorrencia de Log
				aLogTitle															,;	//Array que contem os Titulos de Acordo com as Ocorrencias
				"GPM805"															,;	//Pergunte a Ser Listado
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
ฑฑบPrograma  ณGPM805ProcบAutor  ณ Ademar Fernandes   บ Data ณ 16/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Usado na funcao principal                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localizacao Peru                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM805Proc(cRuc,cCodEst,cTipEst,cRisco,cDescr)

Local cDir		:= Alltrim(MV_PAR03)
Local cQbr		:= "|"
Local aTexto	:= {}
Local cVer5Cat	:= fCargaPd('1118')
Local nX		:= 0
Local nHorNor	:= 0
Local nHorExt	:= 0
Local nMinExt	:= 0 
Local nMinNor	:= 0 
Local nFatorH	:= 0
Local cFolId := ""
Local i := 0
Local cFiltro   := ""
Local cFilRCH   := "% 1=1 AND %"
Local cFolHorNor:= ""
Local cPicture := ""

Private lDepSf		:= IIf(SRA->(FieldPos("RA_DEPSF"))>0,.T.,.F.) 

PRIVATE cAliasSRA	:= "QSRA"

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

MakeSqlExpr(cPerg)    

	If !Empty(mv_par06)
		cFiltro += If( !Empty(cFiltro), " AND " + MV_PAR06, MV_PAR06 )
	EndIf
	
	If !Empty(mv_par07)
		cFiltro += If( !Empty(cFiltro), " AND " + MV_PAR07, MV_PAR07 )
	EndIf

	If !Empty(mv_par08)
		cFiltro += If( !Empty(cFiltro), " AND " + MV_PAR08, MV_PAR08 )
		cFilRCH		:= strTran(MV_PAR08, "SRA", "RCH")
		cFilRCH		:= strTran(cFilRCH, "RA_", "RCH_") 
		cFilRCH		:=  "%" + cFilRCH + " AND " + "%" 
 
	EndIf
cFiltro := If( !Empty(cFiltro), "% " + cFiltro + " AND %", "%%" )

aTxt14 := {}
cArq14 := AllTrim(MV_PAR05) + AnoMes(MV_PAR01) + cRuc + ".jor"

aTxt15 := {}
cArq15 := AllTrim(MV_PAR05) + AnoMes(MV_PAR01) + cRuc + ".snl"

aTxt18 := {}
cArq18 := AllTrim(MV_PAR05) + AnoMes(MV_PAR01) + cRuc + ".rem"

aTxt19 := {}
cArq19 := AllTrim(MV_PAR05) + AnoMes(MV_PAR01) + cRuc + ".pen"

aTxt21 := {}
cArq21 := AllTrim(MV_PAR05) + AnoMes(MV_PAR01) + cRuc + ".for"

aTxt22 := {}
cArq22 := AllTrim(MV_PAR05) + AnoMes(MV_PAR01) + cRuc + ".pte"

aTxt25 := {}
cArq25 := AllTrim(MV_PAR05) + AnoMes(MV_PAR01) + cRuc + ".tas"

aTxt26 := {}
cArq26 := AllTrim(MV_PAR05) + AnoMes(MV_PAR01) + cRuc + ".toc"

cFlQrEm := "% NOT (SRA.RA_CATFUNC = 'E' AND SRA.RA_CATPDT = '5' AND SRA.RA_TIPOEST = '03') %"


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 26 - "Trabajador - Otras condiciones" .toc                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If "B" $ MV_PAR04

	IncProc(STR0006+STR0016)	//"Processando Estrutura "###"26 (Trabajador - Otras cond...)"
	
	BeginSql alias cAliasSRA	

		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_TPCIC, SRA.RA_CIC, SRA.RA_CODAFP, SRA.RA_SEGUROV, 
		SRA.RA_DOMICIL,SRA.RA_REGESSA
		FROM %table:SRA% SRA      
		WHERE SRA.RA_ADMISSA <= %exp:DToS(dDataFim)%
		AND SRA.RA_TPCIC  IN ('01','04','07','09') 
		AND SRA.RA_TIPOEST = ''
		AND SRA.RA_CATFUNC != 'E'
		AND ( ( SRA.RA_SITFOLH <> 'D')  OR (RA_SITFOLH = 'D' AND (RA_DEMISSA >= %exp:dDataIni% AND RA_DEMISSA <= %exp:dDataFim% ) ) OR (RA_SITFOLH = 'D' AND RA_DEMISSA > %exp:dDataFim%) ) 
		AND %exp:cFiltro% SRA.%notDel%
		AND %exp:cFlQrEm%
	    ORDER BY SRA.RA_CIC
	EndSql
	 
	While (cAliasSRA)->( !Eof())

		aAdd(aTxt26,;
				Alltrim((cAliasSRA)->RA_TPCIC) + cQbr + ;            //iff(Alltrim((cAliasSRA)->RA_TPCIC) $ "01/04/07/09",Alltrim((cAliasSRA)->RA_TPCIC),"  " ) + cQbr + ;				//01- Tipo de documento del trabajador
				Alltrim((cAliasSRA)->RA_CIC) + cQbr + ;						//02- Numero de documento del trabajador
				"0" + cQbr +	 ;														 //Iif((cAliasSRA)->RA_CODAFP=="05","1","0") + cQbr +	 ;		//03- Indicador de aporte a Asegura tu Pension
				Iif(Alltrim((cAliasSRA)->RA_REGESSA) $ "01/02/03/04" ,Iif(!Empty((cAliasSRA)->RA_SEGUROV),"1","0"),"0") + cQbr + 	;	//04- Indicador de aporte a Vida Seguro de accidentes
				"" + cQbr + ;													//05- Indicador de aporte al Fondo de Derechos Sociales del Artista (FDSA)
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
//ณ 12 - "Trabajador - Otras Rentas de 5ta. categorํa"            		ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If "2" $ MV_PAR04 .and. !Empty(cVer5Cat)

	IncProc(STR0006+STR0017)	//"Processando Estrutura "###"12 (Trabajador Otras Rentas...)"
EndIf
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 14 - "Importar Datos de la jornada laboral por trabajador"   		ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "3" $ MV_PAR04

	
	IncProc(STR0006+STR0018)	//"Processando Estrutura "###"14 (Datos de la jornada...)"
	
	cFiltroC :=""
	cFiltroD := ""
	
	cFolId := AllTrim(FDESCRCC("S017","E1405",1,5,6,50))
	cFolHorNor := AllTrim(FDESCRCC("S017","E1403",1,5,6,50))
	
		cFolIds	:= Substring(cFolId,1,Len(cFolId)) +"/"+ Substring(cFolHorNor,1,Len(cFolHorNor))		//Elimino el ultimo /
		cFolIds	:= Strtran(cFolIds,"/","','") 				//Sustitucion de  / por ,  
		     
	
	If !Empty(cFiltro)
	
		cFiltroC	+= Iif(!Empty(cFiltroC)," AND "+cFiltro,cFiltro)
		cFiltroD	+= Iif(!Empty(cFiltroD)," AND "+cFiltro,cFiltro)
		cFiltro		:= Iif(!Empty(cFiltro ),cFiltro,"")
	
	EndIf
	
	If !( TcGetDb() == "INFORMIX" )
			cCoalese := "% AND COALESCE(SQB.D_E_L_E_T_,'') <> '*'"
			cCoalese += "%"
	Else
			cCoalese := "% AND DECODE(SQB.D_E_L_E_T_,NULL,'','') <> '*'"
			cCoalese += "%"
	EndIf
	
	
	cCpoAdicEsp := "%SRA.RA_FILIAL as CpoVisual%" // SE NAO FOR UM DOS PAISES MENCIONADOS ATRIBUI O CAMPO RA_FILIAL COM UM ALIAS PARA NAO FICAR VAZIO
			
	If lDepSf
			cDepenContr	:= "% SRA.RA_DEPIR, SRA.RA_DEPSF %"
	Else
			cDepenContr	:= "% SRA.RA_DEPIR %"
	EndIf
	
			cCpoAdicLan	:= " CTT.CTT_DESC01 "
			cNotDel		:= "% AND CTT.D_E_L_E_T_= ' ' %"
		
			cCpoCcRc		:= " SRA.RA_CC, SRC.RC_CC CCUSTO "
			cCpoCcRd		:= " SRA.RA_CC, SRD.RD_CC CCUSTO "
			
			cCpoCcRc	:= If( !Empty(cCpoCcRc), "% , " + cCpoCcRc + ", ", "% , " ) + cCpoAdicLan + " %"
			cCpoCcRd	:= If( !Empty(cCpoCcRd), "% , " + cCpoCcRd + ", ", "% , " ) + cCpoAdicLan + " %"
	
	
	cJoin := " "   
	
	
	cJoinC		:= "% AND SRA.RA_MAT = SRC.RC_MAT " +;
		         " INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND " + fGR805join("CTT", "SRC") + " AND CTT.CTT_CUSTO = SRC.RC_CC %" 
	
	cJoinD		:= "% AND SRA.RA_MAT = SRD.RD_MAT" +;
		         " INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND " + fGR805join("CTT", "SRD") + " AND CTT.CTT_CUSTO = SRD.RD_CC %" 
	
	
		cJoinC		:= Iif(Empty(cJoinC),cJoin,cJoinC)
		cJoinD		:= Iif(Empty(cJoinD),cJoin,cJoinD) 
		cJoinD		:= strTran(cJoinD, "SRC", "SRD")
		cJoinD		:= strTran(cJoinD, "RC_", "RD_")
		cOrdemFun   := "%RA_FILIAL,RA_MAT%"
			
	
	cJoinSQB := " LEFT JOIN " + RetSqlName("SQB") + " SQB ON SRA.RA_DEPTO = SQB.QB_DEPTO AND " + fGR805join("SRA", "SQB")

	cJoinSRV1 := fGR805join("SRC", "SRV")
	cJoinSRV2 := " LEFT JOIN " + RetSqlName("SRV") + " SRV ON SRD.RD_PD = SRV.RV_COD AND " + fGR805join("SRD", "SRV")
	
	cJoin1 :=  "% " +  cJoin + cJoinSRV1 + "%" 
	cJoin2 :=  "% " +  cJoin + cJoinSRV2 + "%"
	
			BeginSql alias cAliasSRA
	
				SELECT SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME,SRA.RA_CATFUNC, SUM(SRC.RC_HORAS) RCD_HORAS,(SELECT DISTINCT RV_CODFOL From %table:SRV% SRV Where SRC.RC_PD = SRV.RV_COD) as RV_CODFOL,          
					   SRA.RA_HRSMES,SRA.RA_HRSDIA,SRA.RA_TPCIC,SRA.RA_CIC,
					   SRC.RC_FILIAL FILIAL
				FROM %table:SRA% SRA    
	
				LEFT JOIN  %table:SRC% SRC 
				ON 	    SRA.RA_FILIAL = SRC.RC_FILIAL	AND
						SRA.RA_MAT    = SRC.RC_MAT	  AND  
						SRA.RA_PROCES    = SRC.RC_PROCES AND
						SRC.RC_PD IN (SELECT RV_COD FROM %table:SRV% SRV
							WHERE %exp:cJoin1% AND 
							SRV.RV_GERAPDT='1' AND SRV.RV_CODFOL IN (%exp:cFolIds% )  AND SRV.%notDel% )  AND
						SRC.RC_PERIODO IN ( SELECT RCH.RCH_PER FROM %table:RCH% RCH  WHERE RCH.RCH_DTPAGO BETWEEN %exp:DToS(dDataIni)% AND %exp:DToS(dDataFim)%  
						AND %exp:cFilRCH% RCH.%notDel% )
						AND SRC.%notDel%   
				  
				WHERE SRA.RA_TPFUNC NOT IN ('66','71','88','98')
				AND SRA.RA_TIPOEST = ''
				AND SRA.RA_CATFUNC != 'E'
				AND SRA.RA_TPCIC IN ('01','04','07','09') 
				AND (SRA.RA_SITFOLH <> 'D' OR SUBSTRING(RA_DEMISSA,1,6) >= %exp:cAnoMesArq% ) 
				AND %exp:cFiltroC%  SRA.%notDel% 
				AND %exp:cFlQrEm%
				 
				GROUP BY SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME,SRA.RA_CATFUNC,            
					   SRA.RA_HRSMES,SRA.RA_HRSDIA,SRA.RA_TPCIC,SRA.RA_CIC,SRC.RC_PD,
					   SRC.RC_FILIAL
	  		 	UNION
	  		 
	  		 	SELECT SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME,SRA.RA_CATFUNC, SUM(SRD.RD_HORAS) RCD_HORAS,(SELECT DISTINCT RV_CODFOL From %table:SRV% SRV Where SRD.RD_PD = SRV.RV_COD) as RV_CODFOL,      
					   SRA.RA_HRSMES,SRA.RA_HRSDIA,SRA.RA_TPCIC,SRA.RA_CIC,
					   SRD.RD_FILIAL FILIAL
				FROM %table:SRA% SRA    
	
				LEFT JOIN  %table:SRD% SRD 
				ON 	    SRA.RA_FILIAL = SRD.RD_FILIAL	AND
						SRA.RA_MAT    = SRD.RD_MAT	  AND  
						SRA.RA_PROCES    = SRD.RD_PROCES AND
						SRD.RD_PD IN (SELECT RV_COD FROM %table:SRV% SRV
							WHERE %exp:cJoin1% AND 
							SRV.RV_GERAPDT='1' AND SRV.RV_CODFOL IN (%exp:cFolIds% )  AND SRV.%notDel% )  AND
						SRD.RD_PERIODO IN ( SELECT RCH.RCH_PER FROM %table:RCH% RCH  WHERE RCH.RCH_DTPAGO BETWEEN %exp:DToS(dDataIni)% AND %exp:DToS(dDataFim)%  
						AND %exp:cFilRCH% RCH.%notDel% )
						AND SRD.%notDel%   
				  
				WHERE SRA.RA_TPFUNC NOT IN ('66','71','88','98')
				AND SRA.RA_TIPOEST = ''
				AND SRA.RA_CATFUNC != 'E'
				AND SRA.RA_TPCIC IN ('01','04','07','09') 
				AND (SRA.RA_SITFOLH <> 'D' OR SUBSTRING(RA_DEMISSA,1,6) >= %exp:cAnoMesArq% )
				AND %exp:cFiltroD%  SRA.%notDel% 
				AND %exp:cFlQrEm% 
				 
				GROUP BY SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME,SRA.RA_CATFUNC,            
					   SRA.RA_HRSMES,SRA.RA_HRSDIA,SRA.RA_TPCIC,SRA.RA_CIC,SRD.RD_PD,
					   SRD.RD_FILIAL
					   
	  		 
				ORDER BY %exp:cOrdemFun%
	
			EndSql
	  
	  
		While (cAliasSRA)->( !Eof() )  
	
	
				nHorNor	:= 0
				nHorExt	:= 0
				nMinExt	:= 0
				nMinNor := 0
				cMatEmp := (cAliasSRA)->RA_MAT
				cFilMat := (cAliasSRA)->RA_FILIAL
				cTipCic := (cAliasSRA)->RA_TPCIC
				cCodCic := (cAliasSRA)->RA_CIC

					While (cAliasSRA)->( !Eof() ) .and.  (cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT ==  cFilMat+cMatEmp
						nFatorH := If( (cAliasSRA)->RA_CATFUNC $ "H", 1, (cAliasSRA)->RA_HRSMES / 30 )

							If (cAliasSRA) -> RV_CODFOL $ cFolHorNor
								nHorNor += (cAliasSRA)->RCD_HORAS * (cAliasSRA)->RA_HRSDIA
							ElseIf (cAliasSRA) -> RV_CODFOL $ cFolId
								nHorExt += (cAliasSRA)->RCD_HORAS
							EndIf

				(cAliasSRA)->( DbSkip() )
						
					Enddo

					If nHorNor > 0 .Or. nHorExt > 0
						nMinExt := (nHorExt-Int(nHorExt))*60
						nMinNor := (nHorNor-Int(nHorNor))*60
						nHorNor := Iif(nHorNor < 0,0,nHorNor)
						aAdd(aTxt14,;
									Alltrim(cTipCic) + cQbr + ;							//01 - Tipo de documento
									Alltrim(cCodCic) + cQbr + ;							//02 - Numero do documento
									AllTrim(Transform(Int(nHorNor),"@. 999")) + cQbr + ;		//03 - Numero de horas ordinarias trabalhadas
									AllTrim(Transform(nMinNor,"@. 99")) + cQbr + ;											//04 - Numero de minutos ordinarios trabalhados
									AllTrim(Transform(Int(nHorExt),"@. 999")) + cQbr +	;	//05 - Numero de horas extras trabalhadas
									AllTrim(Transform(nMinExt,"@. 99")) + cQbr )			//06 - Numero de minutos extras trabalhados
																	
					EndIf
					
	
		EndDo		    		
	
		(cAliasSRA)->(DbCloseArea())
	
		If Len(aTxt14) > 0
			GerarArq( cArq14, aTxt14, cDir )
		EndIf
	
	
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 15 - "'- Trabajador: Dํas subsidiados y otros no laborados."   		ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If "4" $ MV_PAR04

	
	IncProc(STR0006+STR0019)	//"Processando Estrutura "###"15 (Trabajador - Dํas subsidiados y otros no laborados....)"
	
	cFiltroC :=""
	cFiltroD := ""
	
	If !Empty(cFiltro)
	
		cFiltroC	+= Iif(!Empty(cFiltroC)," AND "+cFiltro,cFiltro)
		cFiltroD	+= Iif(!Empty(cFiltroD)," AND "+cFiltro,cFiltro)
		cFiltro		:= Iif(!Empty(cFiltro ),cFiltro,"")
	
	EndIf
	
		If !( TcGetDb() == "INFORMIX" )
			cCoalese := "% AND COALESCE(SQB.D_E_L_E_T_,'') <> '*'"
			cCoalese += "%"
		Else
			cCoalese := "% AND DECODE(SQB.D_E_L_E_T_,NULL,'','') <> '*'"
			cCoalese += "%"
		EndIf
	
	
			cCpoAdicEsp := "%SRA.RA_FILIAL as CpoVisual%" // SE NAO FOR UM DOS PAISES MENCIONADOS ATRIBUI O CAMPO RA_FILIAL COM UM ALIAS PARA NAO FICAR VAZIO
			
		If lDepSf
			cDepenContr	:= "% SRA.RA_DEPIR, SRA.RA_DEPSF %"
		Else
			cDepenContr	:= "% SRA.RA_DEPIR %"
		EndIf
	
			cCpoAdicLan	:= " CTT.CTT_DESC01 "
			cNotDel		:= "% AND CTT.D_E_L_E_T_= ' ' %"
		
			cCpoCcRc		:= " SRA.RA_CC, SRC.RC_CC CCUSTO "
			cCpoCcRd		:= " SRA.RA_CC, SRD.RD_CC CCUSTO "
			
			cCpoCcRc	:= If( !Empty(cCpoCcRc), "% , " + cCpoCcRc + ", ", "% , " ) + cCpoAdicLan + " %"
			cCpoCcRd	:= If( !Empty(cCpoCcRd), "% , " + cCpoCcRd + ", ", "% , " ) + cCpoAdicLan + " %"
	
	cJoin := " "  
	
	
	cJoinC		:= "% AND SRA.RA_MAT = SRC.RC_MAT " +;
		         " INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND " + fGR805join("CTT", "SRC") + " AND CTT.CTT_CUSTO = SRC.RC_CC %" 
	
	cJoinD		:= "% AND SRA.RA_MAT = SRD.RD_MAT" +;
		         " INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND " + fGR805join("CTT", "SRD") + " AND CTT.CTT_CUSTO = SRD.RD_CC %" 
	
	
		cJoinC		:= Iif(Empty(cJoinC),cJoin,cJoinC)
		cJoinD		:= Iif(Empty(cJoinD),cJoin,cJoinD) 
		cJoinD		:= strTran(cJoinD, "SRC", "SRD")
		cJoinD		:= strTran(cJoinD, "RC_", "RD_")
		cOrdemFun   := "%RA_FILIAL,RA_MAT,RV_CODSEF%"
			
	
	//cJoinRCM   := "  INNER JOIN "  + RetSqlName("RCM") + " RCM ON RCM.RCM_TIPO = SR8.R8_TIPOAFA AND RCM.RCM_PD = SR8.R8_PD AND " + fGR805join("RCM", "SR8")

	  cJoinSR81   := "  INNER JOIN "  + RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRC.RC_PD AND " + fGR805join("SRC", "SRV")
	  
	  cJoinSR82   := "  INNER JOIN "  + RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRD.RD_PD AND " + fGR805join("SRD", "SRV")
	
	//cJoinSR81  := "  INNER JOIN "  + RetSqlName("SR8") + " SR8 ON SRA.RA_MAT = SR8.R8_MAT AND SR8.R8_NUMID = SRC.RC_NUMID AND " + fGR805join("SRC", "SR8")
	//cJoinSR82  := "  INNER JOIN "  + RetSqlName("SR8") + " SR8 ON SRA.RA_MAT = SR8.R8_MAT AND SR8.R8_NUMID = SRD.RD_NUMID AND " + fGR805join("SRD", "SR8")
	
	cJoin1 :=  "% " +  cJoin + cJoinSR81 + "%" 
	cJoin2 :=  "% " +  cJoin + cJoinSR82 + "%"
	
			BeginSql alias cAliasSRA

				SELECT SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_REGESSA,SRV.RV_CODSEF,SRA.RA_CATFUNC,
					   SRA.RA_TPCIC,SRA.RA_CIC,SRC.RC_FILIAL FILIAL,
					   SUM(SRC.RC_HORAS) RCD_HORAS,SUM(SRC.RC_VALOR) RCD_VALOR 
						
				FROM %table:SRA% SRA    
	
				INNER JOIN  %table:SRC% SRC 
				ON 	    SRA.RA_FILIAL = SRC.RC_FILIAL	AND
						SRA.RA_MAT    = SRC.RC_MAT	    
				%exp:cJoin1% 

				WHERE %exp:cFiltroC%  SRC.%notDel% 
				AND SRA.RA_TPFUNC NOT IN ('66','88','98') AND SRV.%notDel%   
				AND SRA.RA_TIPOEST = ''
				AND SRA.RA_CATFUNC != 'E'
				AND SRA.RA_TPCIC IN ('01','04','07','09')
				AND (SRA.RA_SITFOLH <> 'D' OR SUBSTRING(RA_DEMISSA,1,6) >= %exp:cAnoMesArq% )
				AND SRC.RC_PERIODO IN ( SELECT RCH.RCH_PER FROM %table:RCH% RCH  WHERE RCH.RCH_DTPAGO BETWEEN %exp:DToS(dDataIni)% AND %exp:DToS(dDataFim)%  
				AND  %exp:cFilRCH% RCH.%notDel% )
				AND SRV.RV_CODSEF <> %exp:' '% 
				AND SRA.%notDel% 
				AND %exp:cFlQrEm% 

				GROUP BY SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_REGESSA,SRV.RV_CODSEF,SRA.RA_CATFUNC,
					   SRA.RA_TPCIC,SRA.RA_CIC,SRC.RC_FILIAL

	  			UNION
	
	  			SELECT SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_REGESSA,SRV.RV_CODSEF,SRA.RA_CATFUNC,
	  				   SRA.RA_TPCIC,SRA.RA_CIC,SRD.RD_FILIAL FILIAL,
					   SUM(SRD.RD_HORAS) RCD_HORAS,SUM(SRD.RD_VALOR) RCD_VALOR 
					
				FROM %table:SRA% SRA    
	
				INNER JOIN  %table:SRD% SRD
				ON 	    SRA.RA_FILIAL = SRD.RD_FILIAL	AND
						SRA.RA_MAT    = SRD.RD_MAT 		
				%exp:cJoin2% 

				WHERE %exp:cFiltroD%  SRD.%notDel% 
				AND SRA.RA_TPFUNC NOT IN ('66','88','98') AND SRV.%notDel%   
				AND SRA.RA_TIPOEST = ''
				AND SRA.RA_CATFUNC != 'E'
				AND SRA.RA_TPCIC IN ('01','04','07','09')
				AND (SRA.RA_SITFOLH <> 'D' OR SUBSTRING(RA_DEMISSA,1,6) >= %exp:cAnoMesArq% )
				AND	SRD.RD_PERIODO IN ( SELECT RCH.RCH_PER FROM %table:RCH% RCH  WHERE RCH.RCH_DTPAGO BETWEEN %exp:DToS(dDataIni)% AND %exp:DToS(dDataFim)%  
				AND %exp:cFilRCH% RCH.%notDel% )
				AND SRV.RV_CODSEF <> %exp:' '% 
				AND SRA.%notDel%
				AND %exp:cFlQrEm%  
				
				GROUP BY SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_REGESSA,SRV.RV_CODSEF,SRA.RA_CATFUNC,
	  				   SRA.RA_TPCIC,SRA.RA_CIC,SRD.RD_FILIAL

				ORDER BY %exp:cOrdemFun%
	
			EndSql	
	
		While (cAliasSRA)->( !Eof() )  
	

 					cCodSef := (cAliasSRA)->RV_CODSEF//(cAliasSRA)->RCM_CODSEF
					cTipCic := (cAliasSRA)->RA_TPCIC
					cCodCic := (cAliasSRA)->RA_CIC
					cMatEmp := (cAliasSRA)->RA_MAT
					cFilMat := (cAliasSRA)->RA_FILIAL
					nRdcHoras := 0
					cCodRegessa := (cAliasSRA)->RA_REGESSA


					While (cAliasSRA)->( !Eof() ) .and.  (cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT+(cAliasSRA)->RV_CODSEF ==  cFilMat+cMatEmp+cCodSef
																   	
							nRdcHoras += (cAliasSRA)->RCD_HORAS
				
						(cAliasSRA)->( dbSkip() )
						
					Enddo

					If cCodSef $ "21/22"	
							If ! Alltrim(cCodRegessa) $ "00/01/02/03/04"
			
							cCodSef += STR0020 //" NO VALIDO TIPO DE SUSPENSION PARA EL EMPLEADO"
							EndIf
					EndIf


		
		aAdd(aTxt15,;
					Alltrim(cTipCic) + cQbr + ;	//01 - Tipo de Documento
					Alltrim(cCodCic) + cQbr + ;			//02 - Numero do documento
					Alltrim(cCodSef) + cQbr + ;	//03 - Tipo de suspensใo da relacao laboral
					iif(nRdcHoras<= 31,AllTrim(Transform(nRdcHoras,"@. 99")),STR0021) + cQbr)		//04 - Numero de dias de suspensao ### "VALOR MAYOR A 31 DIAS"
	
	
		EndDo		    		
	
		(cAliasSRA)->(DbCloseArea())
	
		If Len(aTxt15) > 0
			GerarArq( cArq15, aTxt15, cDir )
		EndIf
	
	
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 18 - '- Trabajador: Detalle de los ingresos, tributos y descuentos.	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "5" $ MV_PAR04

	
				IncProc(STR0006+STR0022)	//"Processando Estrutura "###"18 (Detalle de ingresos, tributos y descuentos...)"
	
	cFiltroC :=""
	cFiltroD := ""

	
	If !Empty(cFiltro)
	
		cFiltroC	+= Iif(!Empty(cFiltroC)," AND "+cFiltro,cFiltro)
		cFiltroD	+= Iif(!Empty(cFiltroD)," AND "+cFiltro,cFiltro)
		cFiltro		:= Iif(!Empty(cFiltro ),cFiltro,"")
	
	EndIf
	
		If !( TcGetDb() == "INFORMIX" )
			cCoalese := "% AND COALESCE(SQB.D_E_L_E_T_,'') <> '*'"
			cCoalese += "%"
		Else
			cCoalese := "% AND DECODE(SQB.D_E_L_E_T_,NULL,'','') <> '*'"
			cCoalese += "%"
		EndIf
	
	
			cCpoAdicEsp := "%SRA.RA_FILIAL as CpoVisual%" // SE NAO FOR UM DOS PAISES MENCIONADOS ATRIBUI O CAMPO RA_FILIAL COM UM ALIAS PARA NAO FICAR VAZIO
			
		If lDepSf
			cDepenContr	:= "% SRA.RA_DEPIR, SRA.RA_DEPSF %"
		Else
			cDepenContr	:= "% SRA.RA_DEPIR %"
		EndIf
	
			cCpoAdicLan	:= " CTT.CTT_DESC01 "
			cNotDel		:= "% AND CTT.D_E_L_E_T_= ' ' %"
		
			cCpoCcRc		:= " SRA.RA_CC, SRC.RC_CC CCUSTO "
			cCpoCcRd		:= " SRA.RA_CC, SRD.RD_CC CCUSTO "
			
			cCpoCcRc	:= If( !Empty(cCpoCcRc), "% , " + cCpoCcRc + ", ", "% , " ) + cCpoAdicLan + " %"
			cCpoCcRd	:= If( !Empty(cCpoCcRd), "% , " + cCpoCcRd + ", ", "% , " ) + cCpoAdicLan + " %"
	
	
	
	cJoin := " "  
	
	
	cJoinC		:= "% AND SRA.RA_MAT = SRC.RC_MAT " +;
		         " INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND " + fGR805join("CTT", "SRC") + " AND CTT.CTT_CUSTO = SRC.RC_CC %" 
	
	cJoinD		:= "% AND SRA.RA_MAT = SRD.RD_MAT" +;
		         " INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND " + fGR805join("CTT", "SRD") + " AND CTT.CTT_CUSTO = SRD.RD_CC %" 
	
	
		cJoinC		:= Iif(Empty(cJoinC),cJoin,cJoinC)
		cJoinD		:= Iif(Empty(cJoinD),cJoin,cJoinD) 
		cJoinD		:= strTran(cJoinD, "SRC", "SRD")
		cJoinD		:= strTran(cJoinD, "RC_", "RD_")
		cOrdemFun   := "%RA_FILIAL,RA_MAT,RV_CODREMU%"
			
	
	cJoinSQB := " LEFT JOIN " + RetSqlName("SQB") + " SQB ON SRA.RA_DEPTO = SQB.QB_DEPTO AND " + fGR805join("SRA", "SQB")
	cJoinSRV1 := " LEFT JOIN " + RetSqlName("SRV") + " SRV ON SRC.RC_PD = SRV.RV_COD AND " + fGR805join("SRC", "SRV")
	cJoinSRV2 := " LEFT JOIN " + RetSqlName("SRV") + " SRV ON SRD.RD_PD = SRV.RV_COD AND " + fGR805join("SRD", "SRV")
	
	cJoin1 :=  "% " +  cJoin + cJoinSRV1 + "%" 
	cJoin2 :=  "% " +  cJoin + cJoinSRV2 + "%"
	
			BeginSql alias cAliasSRA
	
				SELECT SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME,SRA.RA_CATFUNC,            
					   SRA.RA_TPCIC,SRA.RA_CIC,SRA.RA_TPFUNC,SRA.RA_CODAFP,
					   SRC.RC_FILIAL FILIAL,SUM(SRC.RC_HORAS) RCD_HORAS,SUM(SRC.RC_VALOR) RCD_VALOR,
					   SRV.RV_CODREMU
				FROM %table:SRA% SRA    
	
				INNER JOIN  %table:SRC% SRC 
				ON 	    SRA.RA_FILIAL = SRC.RC_FILIAL	AND
						SRA.RA_MAT    = SRC.RC_MAT	    
				%exp:cJoin1% 
				WHERE SRA.%notDel% AND %exp:cFiltroC%  SRC.%notDel% 
				AND SRV.RV_GERAPDT= %exp:'1'%  AND SRV.RV_CODREMU <> %exp:' '%  
					AND SRV.RV_CODREMU NOT IN ('0100','0200','0300','0400','0500','0600','0603','0604','0607','0610','0612','0616','0800','0802','0804','0806','0808')
					AND SRA.RA_TIPOEST = ''
					AND SRA.RA_CATFUNC != 'E'
					AND SRA.RA_TPCIC IN ('01','04','07','09') AND SRV.%notDel%  
					AND SRC.RC_PERIODO+SRC.RC_ROTEIR+SRC.RC_SEMANA IN ( SELECT RCH.RCH_PER+RCH.RCH_ROTEIR+RCH.RCH_NUMPAG FROM %table:RCH% RCH  WHERE RCH.RCH_DTPAGO BETWEEN %exp:DToS(dDataIni)% AND %exp:DToS(dDataFim)%  
					AND %exp:cFilRCH% RCH.%notDel% )
					AND %exp:cFlQrEm% 
							
				GROUP BY SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME,SRA.RA_CATFUNC,            
					     SRA.RA_TPCIC,SRA.RA_CIC,SRA.RA_TPFUNC,SRA.RA_CODAFP,
					     SRC.RC_FILIAL,SRV.RV_CODREMU
	  			UNION
	
				SELECT SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME,SRA.RA_CATFUNC,   
					   SRA.RA_TPCIC,SRA.RA_CIC,SRA.RA_TPFUNC,SRA.RA_CODAFP,
					   SRD.RD_FILIAL FILIAL,SUM(SRD.RD_HORAS) RCD_HORAS,SUM(SRD.RD_VALOR) RCD_VALOR,
					   SRV.RV_CODREMU					   	
				FROM %table:SRA% SRA    
	
				INNER JOIN  %table:SRD% SRD
				ON 	    SRA.RA_FILIAL = SRD.RD_FILIAL	AND
						SRA.RA_MAT    = SRD.RD_MAT 		
				%exp:cJoin2%
				WHERE SRA.%notDel% AND %exp:cFiltroD%  SRD.%notDel% 
				AND SRV.RV_GERAPDT= %exp:'1'%  AND SRV.RV_CODREMU <> %exp:' '% 
				AND SRV.RV_CODREMU NOT IN ('0100','0200','0300','0400','0500','0600','0603','0604','0607','0610','0612','0616','0800','0802','0804','0806','0808')
				AND SRA.RA_TIPOEST = ''
				AND SRA.RA_CATFUNC != 'E'
				AND SRA.RA_TPCIC IN ('01','04','07','09') AND SRV.%notDel%
				AND	SRD.RD_PERIODO+SRD.RD_ROTEIR+SRD.RD_SEMANA IN ( SELECT RCH.RCH_PER+RCH.RCH_ROTEIR+RCH.RCH_NUMPAG FROM %table:RCH% RCH  WHERE RCH.RCH_DTPAGO BETWEEN %exp:DToS(dDataIni)% AND %exp:DToS(dDataFim)%  
				AND %exp:cFilRCH% RCH.%notDel% )
				AND %exp:cFlQrEm% 

				GROUP BY SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME,SRA.RA_CATFUNC,           
					     SRA.RA_TPCIC,SRA.RA_CIC,SRA.RA_TPFUNC,SRA.RA_CODAFP, 
					     SRD.RD_FILIAL,SRV.RV_CODREMU	  
				ORDER BY %exp:cOrdemFun%
	
			EndSql
	
		While (cAliasSRA)->( !Eof() )  
	
	
					cCodCon := (cAliasSRA)->RV_CODREMU
					cCodAfp := (cAliasSRA)->RA_CODAFP
					cTipCic := (cAliasSRA)->RA_TPCIC
					cCodCic := (cAliasSRA)->RA_CIC
					cMatEmp := (cAliasSRA)->RA_MAT
					cFilMat := (cAliasSRA)->RA_FILIAL
					nRdcValor := 0
					
					While (cAliasSRA)->( !Eof() ) .and.  (cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT+(cAliasSRA)->RV_CODREMU ==  cFilMat+cMatEmp+cCodCon
							nRdcValor += (cAliasSRA)->RCD_VALOR 
				
						(cAliasSRA)->( dbSkip() )
						
					Enddo
	

					If 	Alltrim(CCodCon) $ "0601/0606/0608/0609/0613/0614/0615/0618"
						If Alltrim(CCodCon) $ "0601/0606/0608/0609"
						
							If !(AllTrim(cCodAfp) $ "21/22/23/24/25")
								CCodCon += STR0023 //" NO VALIDO PARA EL REGIMEN PENSIONARIO DE EMPLEADO"
							EndIf
						
						ElseIf Alltrim(CCodCon) $ "0615"
	
							If !(AllTrim(cCodAfp) $ "10/11")
								CCodCon += STR0023 //" NO VALIDO PARA EL REGIMEN PENSIONARIO DE EMPLEADO"
							EndIf
						ElseIF Alltrim(CCodCon) $ "0614"
							If !(AllTrim(cCodAfp) $ "13")
								CCodCon += STR0023 //" NO VALIDO PARA EL REGIMEN PENSIONARIO DE EMPLEADO"
							EndIf
						ElseIF Alltrim(CCodCon) $ "0613"
							If !(AllTrim(cCodAfp) $ "03")
								CCodCon += STR0023 //" NO VALIDO PARA EL REGIMEN PENSIONARIO DE EMPLEADO"
							EndIf
						ElseIF Alltrim(CCodCon) $ "0618"
							
								CCodCon += STR0024 //" NO VALIDO PARA EMPRESAS PUBLICAS"
							
						
						EndIF 
					EndIF
	
	
					
				aAdd(aTxt18,;
					Alltrim(cTipCic) + cQbr + ;								//01 - Tipo de documento
					Alltrim(cCodCic) + cQbr + ;										//02 - Numero de documento
					Alltrim(CCodCon) + cQbr + ;								//03 - Codigo da verba
					AllTrim(Transform(nRdcValor,"@. 9999999.99")) + cQbr + ;	//04 - Monto devengado
					AllTrim(Transform(nRdcValor,"@. 9999999.99")) + cQbr )	//05 - Monto pagado/descontado
					
	
		EndDo		    		
	
		(cAliasSRA)->(DbCloseArea())
	
		If Len(aTxt18) > 0
			GerarArq( cArq18, aTxt18, cDir )
		EndIf
	
	
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 21 - Personal en Formaci๓n - modalidad formativa laboral y otros: Monto pagado.	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If "8" $ MV_PAR04
	
	IncProc(STR0006+STR0025)	//"Processando Estrutura "###"21 - (Modalidad en Formaci๓n - Modalidad formativa laboral y Otros - Monto pagado)"
	
	cFiltroC :=""
	cFiltroD := ""
	
	cFolId := AllTrim(FDESCRCC("S017","E2103",1,5,6,50)) 
	
	cFolIds := ""

	cFolIds	:= Substring(cFolId,1,Len(cFolId))		//Elimino el ultimo /
	cFolIds	:= Strtran(cFolIds,"/","','") 				//Sustitucion de  / por ,  
	
	
	If !Empty(cFiltro)
	
		cFiltroC	+= Iif(!Empty(cFiltroC)," AND "+cFiltro,cFiltro)
		cFiltroD	+= Iif(!Empty(cFiltroD)," AND "+cFiltro,cFiltro)
		cFiltro		:= Iif(!Empty(cFiltro ),cFiltro,"")
	
	EndIf
	
		If !( TcGetDb() == "INFORMIX" )
			cCoalese := "% AND COALESCE(SQB.D_E_L_E_T_,'') <> '*'"
			cCoalese += "%"
		Else
			cCoalese := "% AND DECODE(SQB.D_E_L_E_T_,NULL,'','') <> '*'"
			cCoalese += "%"
		EndIf
	
	
			cCpoAdicEsp := "%SRA.RA_FILIAL as CpoVisual%" // SE NAO FOR UM DOS PAISES MENCIONADOS ATRIBUI O CAMPO RA_FILIAL COM UM ALIAS PARA NAO FICAR VAZIO
			
		If lDepSf
			cDepenContr	:= "% SRA.RA_DEPIR, SRA.RA_DEPSF %"
		Else
			cDepenContr	:= "% SRA.RA_DEPIR %"
		EndIf
	
			cCpoAdicLan	:= " CTT.CTT_DESC01 "
			cNotDel		:= "% AND CTT.D_E_L_E_T_= ' ' %"
		
			cCpoCcRc		:= " SRA.RA_CC, SRC.RC_CC CCUSTO "
			cCpoCcRd		:= " SRA.RA_CC, SRD.RD_CC CCUSTO "
			
			cCpoCcRc	:= If( !Empty(cCpoCcRc), "% , " + cCpoCcRc + ", ", "% , " ) + cCpoAdicLan + " %"
			cCpoCcRd	:= If( !Empty(cCpoCcRd), "% , " + cCpoCcRd + ", ", "% , " ) + cCpoAdicLan + " %"
	
	cJoin := " "  
	
	
	cJoinC		:= "% AND SRA.RA_MAT = SRC.RC_MAT " +;
		         " INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND " + fGR805join("CTT", "SRC") + " AND CTT.CTT_CUSTO = SRC.RC_CC %" 
	
	cJoinD		:= "% AND SRA.RA_MAT = SRD.RD_MAT" +;
		         " INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND " + fGR805join("CTT", "SRD") + " AND CTT.CTT_CUSTO = SRD.RD_CC %" 
	
	
		cJoinC		:= Iif(Empty(cJoinC),cJoin,cJoinC)
		cJoinD		:= Iif(Empty(cJoinD),cJoin,cJoinD) 
		cJoinD		:= strTran(cJoinD, "SRC", "SRD")
		cJoinD		:= strTran(cJoinD, "RC_", "RD_")
		cOrdemFun   := "%RA_FILIAL,RA_MAT%"
			
	
	cJoinSQB := " LEFT JOIN " + RetSqlName("SQB") + " SQB ON SRA.RA_DEPTO = SQB.QB_DEPTO AND " + fGR805join("SRA", "SQB")
	cJoinSRV1 := " LEFT JOIN " + RetSqlName("SRV") + " SRV ON SRC.RC_PD = SRV.RV_COD AND " + fGR805join("SRC", "SRV")
	cJoinSRV2 := " LEFT JOIN " + RetSqlName("SRV") + " SRV ON SRD.RD_PD = SRV.RV_COD AND " + fGR805join("SRD", "SRV")
	
	cJoin1 :=  "% " +  cJoin + cJoinSRV1 + "%" 
	cJoin2 :=  "% " +  cJoin + cJoinSRV2 + "%"
	
			BeginSql alias cAliasSRA
	
				SELECT SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME,SRA.RA_CATFUNC, SUM(SRC.RC_VALOR) RCD_VALOR,            
					   SRA.RA_HRSMES,SRA.RA_TPCIC,SRA.RA_CIC,
					   SRC.RC_FILIAL FILIAL
				FROM %table:SRA% SRA    
	
				INNER JOIN  %table:SRC% SRC 
				ON 	    SRA.RA_FILIAL = SRC.RC_FILIAL	AND
						SRA.RA_MAT    = SRC.RC_MAT	    
				%exp:cJoin1% 
				WHERE SRA.%notDel% AND %exp:cFiltroC%  SRC.%notDel% 
				AND SRV.RV_GERAPDT='1' AND SRV.RV_CODFOL IN (%exp:cFolIds% ) 
				AND SRA.RA_TIPOEST <> %exp:' '% AND SRV.%notDel%  
				AND  SRC.RC_DATA  BETWEEN %exp:DToS(dDataIni)% AND %exp:DToS(dDataFim)% 

				AND	SRC.RC_PERIODO IN ( SELECT RCH.RCH_PER FROM %table:RCH% RCH  WHERE RCH.RCH_DTPAGO BETWEEN %exp:DToS(dDataIni)% AND %exp:DToS(dDataFim)%  
				AND %exp:cFilRCH% RCH.%notDel% )

				GROUP BY SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME,SRA.RA_CATFUNC,            
					   SRA.RA_HRSMES,SRA.RA_TPCIC,SRA.RA_CIC,
					   SRC.RC_FILIAL
	  			UNION
	
				SELECT SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME, SRA.RA_CATFUNC,SUM(SRD.RD_VALOR) RCD_VALOR,           
					   SRA.RA_HRSMES,SRA.RA_TPCIC,SRA.RA_CIC, 
					   SRD.RD_FILIAL FILIAL	
				FROM %table:SRA% SRA    
	
				INNER JOIN  %table:SRD% SRD
				ON 	    SRA.RA_FILIAL = SRD.RD_FILIAL	AND
						SRA.RA_MAT    = SRD.RD_MAT 		
				%exp:cJoin2%
				WHERE SRA.%notDel% AND %exp:cFiltroD%  SRD.%notDel% 
				AND SRV.RV_GERAPDT='1' AND SRV.RV_CODFOL IN (%exp:cFolIds% ) 
				AND SRA.RA_TIPOEST <> %exp:' '% AND SRV.%notDel%
				AND  SRD.RD_DATPGT  BETWEEN %exp:DToS(dDataIni)% AND %exp:DToS(dDataFim)% 
				AND	SRD.RD_PERIODO IN ( SELECT RCH.RCH_PER FROM %table:RCH% RCH  WHERE RCH.RCH_DTPAGO BETWEEN %exp:DToS(dDataIni)% AND %exp:DToS(dDataFim)%  
				AND  %exp:cFilRCH% RCH.%notDel% )

				GROUP BY SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME, SRA.RA_CATFUNC,           
					   SRA.RA_HRSMES,SRA.RA_TPCIC,SRA.RA_CIC, 
					   SRD.RD_FILIAL	  
				ORDER BY %exp:cOrdemFun%
	
			EndSql

		While (cAliasSRA)->( !Eof() )  
		
				nMtoPag	:= 0
				cMatEmp := (cAliasSRA)->RA_MAT
				cFilMat := (cAliasSRA)->RA_FILIAL
				cTipCic := (cAliasSRA)->RA_TPCIC
				cCodCic := (cAliasSRA)->RA_CIC
	
				While (cAliasSRA)->( !Eof() ) .and.  (cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT ==  cFilMat+cMatEmp
				
							
							nMtoPag += (cAliasSRA)->RCD_VALOR 
	
				
						(cAliasSRA)->( dbSkip() )
						
				Enddo

					If nMtoPag > 0 
						cPicture := IIf(nMtoPag % 1 == 0, "@. 9999999", "@. 9999999.99")
							aAdd(aTxt21,;
							Alltrim(cTipCic) + cQbr + ;									//01 - Tipo de documento
							Alltrim(cCodCic) + cQbr + ;				   						//02 - Numero do documento
							Alltrim(PADL(Transform(nMtoPag,cPicture),10," ") + cQbr ))	//03 - Monto pagado				
					EndIf				
		EndDo		    		
		(cAliasSRA)->(DbCloseArea())
	
		If Len(aTxt21) > 0
			GerarArq( cArq21, aTxt21, cDir )
		EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ (*) Executa a geracao dos arquivos necessarios                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aTxt25) > 0
	GerarArq( cArq25, aTxt25, cDir )
EndIf		
If Len(aTxt22) > 0
	GerarArq( cArq22, aTxt22, cDir )
EndIf
If Len(aTxt19) > 0
	GerarArq( cArq19, aTxt19, cDir )
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

For i := 1 to Len(aTexto)
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
ฑฑบPrograma  ณ GetDir   บAutor  ณ Ademar Fernandes   บ Data ณ 16/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Usado na funcao principal                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localizacao Peru                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetDir()
Local cDirPesq
Local cCpo     := readvar()

cDirPesq := cGetFile( STR0007,STR0008,,"C:\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY)	//"Arquivo Texto"###"Gerar no Diretorio"
If Len(cDirPesq) = 0
	cDirPesq := "C:\"
EndIf
&(cCpo) := cDirPesq
Return(.T.)

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
Function fOpcPlame()
Local cTitulo	:= STR0002	//"Gera็ใo PDT"
Local MvParDef	:= ""
Local MvPar		:= ""
Local aResul	:={}

MvPar	:=	&(Alltrim(ReadVar()))
MvRet	:=	Alltrim(ReadVar())

aResul  := {STR0026, ; //"07 - No disponible"																//-07.r nuevo 1
			STR0027, ; //"12 - No Disponible"																//-12.c 2
			STR0028, ; //"14 - Trabajador - Datos de la Jornada Laboral"									//-14.e	3		
			STR0029, ; //"15 - Trabajador - Dํas subsidiados y otros no laborados"							//-15.f 4
			STR0030, ; //"18 - Trabajador - Detalle de ingresos, tributos y descuentos"						//-18.i 5
			STR0031, ; //"19 - No disponible" 																//-19.j 6
			STR0032, ; //"20 - No Disponible"																//-20.s nuevo 7
			STR0033, ; //"21 - Modalidad en Formaci๓n - Modalidad formativa laboral y Otros - Monto pagado"	//-21.l 8
			STR0034, ; //"22 - No Disponible"																//-22.m 9
			STR0035, ; //"25 - no Disponible"																//-25.p A
			STR0036, ; //"26 - Trabajador - Otras Condiciones"												//-26.q B
			STR0037, ; //"27 - No disponible"																//-27.q C
			STR0038}   //"28 - No disponible"																//-28.t nuevo D

MvParDef	:=	"123456789ABCD"

f_Opcoes(@MvPar,cTitulo,aResul,MvParDef)
&MvRet := mvpar

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ConvTxt  บAutor  ณ Ademar Fernandes   บ Data ณ 16/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Usado na funcao principal                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localizacao Peru                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ConvTxt(cNCpo,nTCpo)
Local cAuxTxt := ""

cAuxTxt := AllTrim(cNCpo) + Space(nTCpo - Len(AllTrim(cNCpo)))
If Len(cAuxTxt) > nTCpo
	cAuxTxt := SubStr(cAuxTxt,1,nTCpo)
EndIf

Return(cAuxTxt)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ConvData บAutor  ณ Ademar Fernandes   บ Data ณ 16/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Usado na funcao principal                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Localizacao Peru                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ConvData(dData)
Local cAuxData := Space(10)

If !Empty(dData)
	cAuxData := Substr(DTOC(dData),1,6)+Substr(DTOS(dData),1,4)
EndIf

Return(cAuxData)

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
ฑฑบPrograma  ณfEstAfast บAutor  ณ Ademar Fernandes   บ Data ณ 16/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao indica se o funcionario esta afastado na data infor-บฑฑ
ฑฑบ          ณ mada como parametro                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fEstAfast(cMatr,dData)
Local aArea 	:= GetArea()
Local lRet  	:= .F.

DbSelectArea("SR8")
DbSetOrder(1)

If DbSeek(xFilial("SR8",SRA->RA_FILIAL)+cMatr+AnoMes(dDataIni),.F.)
	
	While !Eof() .And. SR8->R8_FILIAL+SR8->R8_MAT == cMatr
		
		If ( SR8->R8_DATAINI >= dDataIni .And. SR8->R8_DATAINI <= dDataFim ) .Or. ( SR8->R8_DATAFIM >= dDataIni .and. SR8->R8_DATAFIM <= dDataFim )
			lRet := .T.
			Exit
		EndIf
		
		DbSkip()
	EndDo
EndIf

RestArea(aArea)

Return(lRet)
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
If !( SRA->( FieldPos( "RA_CODPAIS" ) ) > 0 ) .or. !( SRA->( FieldPos( "RA_CATPDT" ) ) > 0 ) .or. !( SRA->( FieldPos( "RA_EMPTER" ) ) > 0 )  .or. !( RGB->( FieldPos( "RGB_RUCEMP" ) ) > 0 ) //Verificar se o campo existe, caso nใo exista nใo foi executado o update
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

	#IFDEF TOP
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
	#ENDIF
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณfCargaHorasบAutor  ณ Leandro Drumond    บ Data ณ 22/12/2011 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega o horario trabalhado do funcionario.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCargaHoras(nHorNor,nHorExt)
Local cQuery 	:= ""
Local cAliasAux := ""
Local cPrefixo  := ""
Local cAliasQry := ""
Local nX		:= 0

For nX := 1 to 2
	If nX == 1
		cAliasAux := "SPC"
	Else
		cAliasAux := "SPH"
	EndIf
	
	cPrefixo  := ( PrefixoCpo( cAliasAux ) + "_" )
	
	cAliasQry := GetNextAlias()

	cQuery := " SELECT " 
	cQuery +=			cPrefixo + "PD AS EVENTO, "
	cQuery +=           cPrefixo + "QUANTC AS HORAS, "
	cQuery += "         P9_IDPON AS IDPON "
	cQuery += " FROM " + InitSqlName( cAliasAux ) + " SPC INNER JOIN " + InitSqlName( "SP9" ) + " SP9 "
	cQuery += " ON P9_CODIGO = " + cPrefixo + "PD "
	cQuery += " WHERE " + cPrefixo + "FILIAL = " + SRA->RA_FILIAL + " AND " 
	cQuery +=        	+ cPrefixo + "MAT = " + SRA->RA_MAT + " AND " 
	cQuery +=        	+ cPrefixo + "DATA >= " + DtoS(dDataIni) + " AND "
	cQuery +=        	+ cPrefixo + "DATA <= " + DtoS(dDataFim) + " AND "
	cQuery += "		  SPC.D_E_L_E_T_= ' ' AND SP9.D_E_L_E_T_ = ' ' AND ( " 			
	cQuery += "       P9_IDPON = '001A' OR "
	cQuery += "       P9_IDPON = '003N' OR "
	cQuery += "       P9_IDPON = '004N' OR "
	cQuery += "       P9_IDPON = '026A' OR "
	cQuery += "       P9_IDPON = '029A' OR "
	cQuery += "       P9_IDPON = '028A' OR "
	cQuery += "       P9_IDPON = '027N' ) "
	
	cQuery := ChangeQuery(cQuery)
	
	If Select(cAliasQry) > 0
		(cAliasQry)->(dbCloseArea())	
	EndIf
	
	If ( MsOpenDbf(.T.,"TOPCONN",TcGenQry(NIL,NIL,cQuery),cAliasQry,.F.,.T.) )
		While (cAliasQry)->(!Eof())
			If (cAliasQry)->IDPON $ '001A|003N|004N|026A'
				nHorNor := SomaHoras( nHorNor , (cAliasQry)->HORAS )
			Else
				nHorExt := SomaHoras( nHorExt , (cAliasQry)->HORAS )
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo	

		(cAliasQry)->(dbCloseArea())

	EndIf

Next nX

Return (!Empty(nHorNor) .or. !Empty(nHorExt))

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
Static Function MntLogError(cCod,lQuery)

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
		aAdd(aLogFile, STR0011 + "'RA_TPDOCTO'" + STR0013) //Campo #### deve ser preenchido
		lErro := .T.
	EndIf
	
	If "4" $ MV_PAR04
		If Empty((cAliasTab)->RA_SEXO)
			aAdd(aLogFile, STR0011 + "'RA_SEXO'" + STR0013) //Campo #### deve ser preenchido
			lErro := .T.
		EndIf
	EndIf
	
	If "5" $ MV_PAR04
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
	
	If "9" $ MV_PAR04
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
	
	If "A" $ MV_PAR04
		If Empty((cAliasTab)->RA_EMPTER)
			aAdd(aLogFile, STR0011 + "'RA_EMPTER'" + STR0013 ) //Campo #### deve ser preenchido
			lErro := .T.
		EndIf	
	EndIf
	
	If Empty((cAliasTab)->RA_CATPDT) .and. ( "9" $ MV_PAR04 .or. "A" $ MV_PAR04 .or. "B" $ MV_PAR04 .or. "H" $ MV_PAR04 .or. "L" $ MV_PAR04 .or. "M" $ MV_PAR04 .or. "N" $ MV_PAR04 .or. "P" $ MV_PAR04 )
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
	If SRQ->RQ_TPDOCTO == '07' .and. Empty(SRQ->RQ_PAISPAS)
		aAdd(aLogFile, STR0011 + "'RQ_PAISPAS'" + STR0012 )  //Campo #### deve ser preenchido quando o tipo de coumento ้ passaporte
		lErro := .T.
	EndIf
	If Empty(SRQ->RQ_RG)
		aAdd(aLogFile, STR0011 + "'RQ_CIC'" + STR0013 ) //Campo #### deve ser preenchido
		lErro := .T.
	EndIf
	If Empty(SRQ->RQ_TPDOCTO)
		aAdd(aLogFile, STR0011 + "'RQ_TPDOCTO'" + STR0013) //Campo #### deve ser preenchido
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…cao  ณfGR106join  ณ Autor ณ  Equipe RH           ณ Data ณ 19/09/2012       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrica…o ณO tratamento a seguir deve-se ao problema do embedded SQL nใo      ณฑฑ
ฑฑณ          ณconverter clausula "SUBSTRING" no INNER JOIN, ao usar banco de dados ณฑฑ
ฑฑณ          ณORACLE. E segundo sustenta็ao FRAMEWORK, devemos alterar consulta SQLณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ 
ฑฑณParametro ณExpC1 - Obrigatorio - Variแvel com Primeira tabela do "inner join"   ณฑฑ
ฑฑณ          ณExpC2 - Obrigatorio - Variแvel com Segunda  tabela do "inner join"   ณฑฑ
ฑฑณ          ณExpC3 - Variแvel indica se retorno deverแ conter "%   %". Caso vazio ณฑฑ
ฑฑณ          ณ        o seu valor padrใo serแ "".                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณGPER106                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fGR805join(cTabela1, cTabela2,cEmbedded)
Local cFiltJoin := ""
Default cEmbedded := ""

cFiltJoin := cEmbedded + FWJoinFilial(cTabela1, cTabela2) + cEmbedded	

If ( TCGETDB() $ 'DB2|ORACLE|POSTGRES|INFORMIX' )
	cFiltJoin := STRTRAN(cFiltJoin, "SUBSTRING", "SUBSTR")
EndIf

Return (cFiltJoin)
