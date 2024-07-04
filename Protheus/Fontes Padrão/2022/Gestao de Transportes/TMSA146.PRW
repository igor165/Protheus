#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                               
#INCLUDE "TMSA146.CH"

#DEFINE TYPE_MODEL	1
#DEFINE TYPE_VIEW  	2

//-- Diretivas indicando as colunas para Matriz de Prioridades de Entrega
#DEFINE PE_QTDCOL 5         
#DEFINE PE_CODPRI 1
#DEFINE PE_TIPPRI 2                          
#DEFINE PE_DEPRI  3
#DEFINE PE_ATEPRI 4
#DEFINE PE_CORPRI 5 

//-- Diretivas indicando as colunas dos documentos da viagem
#DEFINE CTSTATUS	 1
#DEFINE CTSTROTA	 2
#DEFINE CTMARCA	 	 3
#DEFINE CTSEQUEN	 4
#DEFINE CTARMAZE	 5
#DEFINE CTLOCALI	 6
#DEFINE CTFILDOC	 7
#DEFINE CTDOCTO		 8
#DEFINE CTSERIE	 	 9
#DEFINE CTREGDES	10                                           
#DEFINE CTDATEMI	11
#DEFINE CTPRZENT	12
#DEFINE CTNOMREM	13
#DEFINE CTNOMDES	14
#DEFINE CTQTDVOL	15
#DEFINE CTVOLORI	16
#DEFINE CTPLIQUI	17
#DEFINE CTPESOM3	18
#DEFINE CTVALMER	19
#DEFINE CTVIAGEM	20
#DEFINE CTSEQDA7	21
#DEFINE CTSOLICI	22			//-- DUE_NOME
#DEFINE CTENDERE	23			//-- DUE_END
#DEFINE CTBAIRRO	24			//-- DUE_BAIRRO
#DEFINE CTMUNICI	25			//-- DUE_MUN
#DEFINE CTDATSOL	26			//-- DT5_DATSOL
#DEFINE CTHORSOL	27			//-- DT5_HORSOL
#DEFINE CTDATPRV	28			//-- DT5_DATPRV
#DEFINE CTHORPRV	29			//-- DT5_HORPRV
#DEFINE CTDOCROT	30			//-- Codigo que identifica a q rota pertence o documento
#DEFINE CTBLQDOC	31			//-- Tipos de bloqueio do documento
#DEFINE CTNUMAGE	32			//-- Numero do Agendamento( Carga Fechada ).
#DEFINE CTITEAGE	33			//-- Item do Agendamento( Carga Fechada ).
#DEFINE CTSERTMS	34			//-- Tipo do Servico.
#DEFINE CTDESSVT	35			//-- Descricao do Servico.
#DEFINE CTESTADO	36
#DEFINE CTDATENT	37
#DEFINE CTUNITIZ	38
#DEFINE CTCODANA	39

#DEFINE NPOSQTDVOL  02
#DEFINE NPOSVALFRE  03
#DEFINE NPOSVALOR   04
#DEFINE NPOSPESO    05
#DEFINE NPOSPESOM3  06
#DEFINE NPOSMETRO3  07
#DEFINE NPOSDOCTOS  08
#DEFINE NPOSQTDRAT  09

//-- TMSA200A - Calculo do Lote
#DEFINE LTMARCA  1 
#DEFINE LTCORBRW 2
#DEFINE LTFILORI 3
#DEFINE LTLOTNFC 4
#DEFINE LTDATLOT 5
#DEFINE LTHORLOT 6
#DEFINE LTQTDLOT 7
#DEFINE LTTIPLOT 8
#DEFINE LTSTALOT 9
#DEFINE LTRATEIO 10
#DEFINE LTBACRAT 11
#DEFINE LTCRIRAT 12
#DEFINE LTPRORAT 13
#DEFINE LTORIRAT 14
#DEFINE LTCALRAT 15
#DEFINE LTTABRAT 16
#DEFINE LTTIPRAT 17
#DEFINE LTTPLOTE 18 
#DEFINE LTNUMNFC 19
#DEFINE LTSERNFC 20
#DEFINE LTCLIREM 21
#DEFINE LTLOJREM 22

#DEFINE NROCPOS  22


//-- Documentos da Programacao, via rotina automatica
#DEFINE PRGFILDOC  1 
#DEFINE PRGDOC     2
#DEFINE PRGSERIE   3
#DEFINE PRGNUMNFC  4
#DEFINE PRGSERNFC  5
#DEFINE PRGFILORI  6
#DEFINE PRGLOTNFC  7
#DEFINE PRGCODCAV  8
#DEFINE PRGMARK    9  //Controle para indicar se o documento foi selecionado na query
#DEFINE PRGRECDTC  10  //Recno DTC
#DEFINE PRGSEQUEN  11  //Sequencia TPR

Static aDadosZona	:= {}                       
Static aDadosSetor	:= {}
Static cNumTmp		:= ''    //Numero da programacao temporaria
Static cSeqPrg		:= ''    //Sequencia da programacao 
Static cSeqEnt		:= ''    //Sequencia de Entrega dos Documentos de Transporte
Static aRegDF8		:= {}
Static aRegVgeInt	:= {}
Static cDbType		:= TCGetDB()
Static lTmsa029		:= FindFunction("TMSA029USE") 
Static aCliRestri	:= {} 	// Recebe os Clientes Restritos
Static lPesqRes		:= .F.
Static cMVTMSRLC	:= SuperGetMV( "MV_TMSRLC",, '0')
Static lMVITMSDMD	:= SuperGetMv("MV_ITMSDMD",.F.,.F.) //Parametro que indica se a Gestão de Demandas está ativa ou não.
Static cPlnDmd		:= " "
Static lRestricao	:= cMVTMSRLC != '0'  //Restricao de Localizacao e Cliente 0= Nao Utiliza
Static dDtPrvIni	:= ''
Static dDtPrvFim	:= ''
Static dDtEmiIni	:= ''
Static dDtEmiFim	:= ''

Static lContVei		:= SuperGetMV( 'MV_CONTVEI', , .T. ) // Verifica se o sistema Controla Motoristas / Veiculos
Static aLoadTot		:= {}
Static nCarretas	:= 0
Static cTpTransp	:= ''
Static lRot146Aut	:= .F. 
Static aDoc146Aut	:= {}
Static lIncAuto		:= .F.  //Tratamento para indicar se é inclusao ou alteração
Static cCodCavAut	:= ""
Static cRota146		:= ""
Static aMsgErrPrg	:= {} //--> Array com mensagem de LOG de Processamento.
Static aDocErr		:= {}
Static lHasViaM3	:= FindFunction("TMSHasMd3") .AND. TMSHasMd3()
Static lIntTPR      := SuperGetMV("MV_ROTAINT",,.F.)  //Integração Rota Inteligente
Static nValPdg      := 0
Static cIdRotTPR    := ""       //Id Roteriza TPR
Static dDatIni	    := cTod('')
Static dDatFim	    := cTod('')
Static cHorIni	    := ""
Static cHorFim	    := ""
Static lAlteraTPR   := .F. //Controle para validar a TPR na alteração da Programação

//Tabelas Temporarias
//T01- Grid Documentos
//T02- Codigo de Barra
//T03- Totalizador

//-------------------------------------------------------------------
/*/ Programacao de Carregamento
@author Katia
@since 30/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMSA146(lRotAuto,aDocAuto,nOpcAuto,cRota,cIdRot,dDtPrgIni,cHrPrgIni,dDtPrgFim,cHrPrgFim)

Local oMBrowse	 := Nil
Local aSetKey	 := {}       
Local oModel146  := Nil
Local lRet       := .T.
Local aDocTmp    := {}
Local nZ         := 0
Local cRoteiri   := ""

Private aRotina := MenuDef()
Private aRotas  := {}
Private cSerAdi := ""

Default lRotAuto := .F.
Default aDocAuto  := {}   //Podera ser enviado ou não os documentos para filtro
Default nOpcAuto := 4
Default cRota    := ""
Default cIdRot   := ""
Default dDtPrgIni := cTod('')
Default cHrPrgIni := ""
Default dDtPrgFim := cTod('')
Default cHrPrgFim := ""

lRot146Aut := lRotAuto //Rotina Automatica
If lRot146Aut 
	aDoc146Aut:= aClone(aDocAuto)
	cRota146 := cRota
	If nOpcAuto == 3  
		lIncAuto:= .T.
		nOpcAuto:= 4   //Programação de Carregamento, sempre com opcao 4
	EndIf
EndIf

Pergunte("TMB144",.F.)
If Type("MV_PAR02") == "C"
	cSerAdi := mv_par02
EndIf

Pergunte('TMSA146',.F.)
dDtPrvIni:= DtoS(mv_par01)
dDtPrvFim:= DtoS(mv_par02)
dDtEmiIni:= DtoS(mv_par03)
dDtEmiFim:= DtoS(mv_par04)
cTpTransp:= mv_par28
nCarretas:= 0
	
If lRestricao
	lPesqRes:= Iif(mv_par32 == 1, .T., .F.)
EndIf	
	                       
If lRestricao  //-- Verifica se possui a funcionalidade de Restricoes
	lPesqRes:= Iif(mv_par32 == 1, .T., .F.)
EndIf	

If lIntTPR .And. FindFunction('TMSROTEIRI')
	If !lHasViaM3   //Habilitado somente com ambiente da viagem modelo3
		lIntTPR:= .F.
	Else
		cRoteiri:= TMSROTEIRI() 
		lIntTPR:= cRoteiri == '2'   //1-Maplink, 2-TPR
		If lIntTPR .And. lRot146Aut .And. !Empty(cIdRot) 
			cIdRotTPR := cIdRot  
			dDatIni   := dDtPrgIni
			dDatFim	  := dDtPrgFim
			cHorIni	  := cHrPrgIni
			cHorFim	  := cHrPrgFim
		EndIf
	EndIf
	lAlteraTPR:= .F.
EndIf

If IsInCallStack("TMSAF76")
	//-- Viagem jah deve estar posicionada
	If "TMSA146MNT" $ Upper(AllTrim(aPanAgeTms[6]))
		TMSA146Mnt( 'DF8', Recno(), )
	Else
		If At("(",aPanAgeTms[6]) == 0
			aPanAgeTms[6] := aPanAgeTms[6] + "()"
		EndIf
		
		&(aPanAgeTms[6])
	EndIf
ElseIf lRot146Aut
	
	//--- Abertura do Arquivo para executar a rotina

	If lIncAuto
		dbSelectArea("DF8")
		DF8->(dbSetOrder(1))
	EndIf	
	
    oModel146 := FWLoadModel('TMSA146')
	oModel146:SetOperation( nOpcAuto )
	oModel146:Activate()
	
	If Len(aMsgErrPrg) > 0
		lRet:= .F.
		If Len(aMsgErrPrg[1]) > 0
			TmsLogMsg("ERROR",aMsgErrPrg[1][1]) 
		EndIF
	ElseIf lIncAuto
		lRet:= 	T146CarVei(.T.)
	EndIf	

	If lRet
		If lIncAuto
			oModel146:LoadByModel(oModel146)
		EndIf	
		//Valida e grava as informações
		If (lRet:= oModel146:VldData())
			lRet:= oModel146:CommitData()
		EndIf
		If !lRet
			VarInfo('',oModel146:GetErrorMessage())
			oModel146:SetErrorMessage(,,,,,oModel146:GetErrorMessage()[6])
			TmsLogMsg("ERROR",oModel146:GetErrorMessage()[6])  
			lRet:= .F.
		EndIf
	EndIf

	If !lRet .And. Len(aMsgErrPrg) > 0
		TmsMsgErr( aMsgErrPrg ) 
	EndIf

	oModel146:Deactivate()
	oModel146:Destroy()

	//----- Verifica os documentos q nao foram carregados
	If lIncAuto 
		Asort(aDoc146Aut,,,{|x,y| x[PRGMARK] < y[PRGMARK] })
		AEval(aDoc146Aut,{|x| Iif(!x[PRGMARK], AAdd(aDocTmp,x),'')  })

		If Len(aDocTmp) > 0
			For nZ:= 1 To Len(aDocTmp) 
				aAdd(aDocErr,{Iif(Empty(aDocTmp[nZ][PRGFILDOC]), '', 'Fil.Docto: ' + aDocTmp[nZ][PRGFILDOC]) +;
				              Iif(Empty(aDocTmp[nZ][PRGDOC])   , '', '- Docto: '   + aDocTmp[nZ][PRGDOC])   + ;
			               	  Iif(Empty(aDocTmp[nZ][PRGSERIE]) , '', '- Serie: '   + aDocTmp[nZ][PRGSERIE]) + ;
							  Iif(Empty(aDocTmp[nZ][PRGFILORI]), '',' - Fil.Ori: ' +aDocTmp[nZ][PRGFILORI])+;
							  Iif(Empty(aDocTmp[nZ][PRGLOTNFC]), '',' - Lote: '    +aDocTmp[nZ][PRGLOTNFC])+;
							  Iif(Empty(aDocTmp[nZ][PRGNUMNFC]), '',' - NumNFC: '  +aDocTmp[nZ][PRGNUMNFC])+;
							  Iif(Empty(aDocTmp[nZ][PRGSERNFC]), '',' - SerNFC: '  +aDocTmp[nZ][PRGSERNFC]) })

				//--- Atualiza Status dos Doctos com falha de processamento
				If lIntTPR .And. !Empty(cIdRotTPR)
					aRet:= T146IdDMS(Nil,aDocTmp[nZ][PRGFILDOC],aDocTmp[nZ][PRGDOC],aDocTmp[nZ][PRGSERIE],aDocTmp[nZ][PRGRECDTC])
					If Len(aRet) > 0
						T146AtuDMS(cIdRotTPR,aRet[1],aRet[2],'4',"Documento não localizado na Programação de Carregamento.")  
					EndIf
				EndIf

			Next nZ
		
			TmsMsgErr( aDocErr,'Documentos não localizados: ' ) 

		EndIf
	EndIf

Else	
	AAdd(aSetKey, { VK_F12 , { || Pergunte("TMSA146C") } } )
	TmsKeyOn(aSetKey)
	//===========================================================================================================
	// Funcao de BROWSE
	//===========================================================================================================
	oMBrowse:= FwMBrowse():New()
	oMBrowse:SetAlias( "DF8" )
	oMBrowse:SetDescription( STR0001 )
	
	oMBrowse:AddLegend( "DF8->DF8_STATUS=='1'", "GREEN"	 , STR0028 	) //-- Em Aberto
	oMBrowse:AddLegend( "DF8->DF8_STATUS=='2'", "BLUE"	 , STR0029 	) //-- Efetivada
	oMBrowse:AddLegend( "DF8->DF8_STATUS=='3'", "RED"	 , STR0030 	) //-- Documentos Não Transmitidos
	oMBrowse:AddLegend( "DF8->DF8_STATUS=='9'", "BLACK"	 , STR0056 	) //-- Cancelada

	If lIntTPR 
		oMBrowse:AddStatusColumns( {||T146LegTPR( DF8->DF8_FILORI, DF8->DF8_NUMPRG, DF8->DF8_SEQPRG )}, {||TMSAC19Leg()} )
	EndIf

	If IsInCallStack('TMSA153')
		oMBrowse:AddFilter(STR0208,TMSA153FPC(.F.),.T.,.T.)
	EndIf

	oMBrowse:SetCacheView( .F. )
	oMBrowse:Activate()
		
	TmsKeyOff(aSetKey)
EndIf

LimpaVar() //--- Limpa Variaveis Static
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Katia
@since 30/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local cDemanda := IIF(DF8->(ColumnPos("DF8_DATINI")) > 0,"DF8_DATINI|DF8_HORINI|DF8_DATFIM|DF8_HORFIM|","")
Local oStruT02  := MdoStruT02()    //Estrutura do Model (Codigo de Barra)
Local oStruT03  := MdoStruT03()    //Estrutura do Model (Totalizador)
Local oStruDDZ  := FWFormStruct(1,'DDZ')
Local oStruDA3  := FWFormStruct(1,'DA3',{|cCampo| AllTrim(cCampo)+"|" $ "DA3_MARK|DA3_BTCAR|DA3_BTDES|DA3_STATUS|DA3_COD|DA3_PLACA|DA3_DESC|DA3_FROVEI|DA3_DESTIP|DA3_CAPACM|DA3_CAPACN|DA3_VOLMAX|DA3_FILATU|DA3_FILBAS|DA3_VEIRAS|DA3_DTPRCH|DA3_HRPRCH|DA3_SERTMS|DA3_DESSVT|DA3_VELOC|"})
Local oStruDA8  := FWFormStruct(1,'DA8',{|cCampo| AllTrim(cCampo)+"|" $ "DA8_MARK|DA8_COD|DA8_DESC|DA8_SERTMS|DA8_DESSVT|"})
Local oStruDA5  := FWFormStruct(1,'DA5',{|cCampo| AllTrim(cCampo)+"|" $ "DA5_MARK|DA5_COD|DA5_DESC|DA5_CDROTA"})
Local oStruDA6  := FWFormStruct(1,'DA6',{|cCampo| AllTrim(cCampo)+"|" $ "DA6_MARK|DA6_ROTA|DA6_REF|DA6_PERCUR|DA6_CDROTA|"})
Local oStruDF8  := FWFormStruct(1,'DF8',{|cCampo| AllTrim(cCampo)+"|" $ "DF8_BTCAR|DF8_BTDES|DF8_BTVIS|DF8_STAPRG|DF8_STAVEI|DF8_RESTRI|DF8_FILORI|DF8_NUMTMP|DF8_NUMPRG|DF8_SEQPRG|DF8_ROTA|DF8_DESSVT|DF8_SERTMS|DF8_DATGER|DF8_HORGER|DF8_FILVGE|DF8_NUMVGE|DF8_CODVEI|"+;
																		"DF8_CAPACM|DF8_CAPACD|DF8_QTDVOL|DF8_QTDDOC|DF8_PESO|DF8_PESOM3|DF8_VALOR|DF8_QTDCOL|DF8_VOLCOL|DF8_PESCOL|DF8_PM3COL|DF8_VLMCOL|DF8_VLFCOL|"+;
																		"DF8_QTDENT|DF8_VOLENT|DF8_PESENT|DF8_PM3ENT|DF8_VLMENT|DF8_VLFENT|DF8_QTDTRA|DF8_VOLTRA|DF8_PESTRA|DF8_PM3TRA|DF8_VLMTRA|DF8_VLFTRA|DF8_VIAGEM|DF8_CODCAV|DF8_MODCAV|DF8_QTDRAT|DF8_TIPTRA|"+cDemanda})

Local aCamposDTC:= {"DTC_FILIAL","DTC_FILDOC","DTC_DOC","DTC_SERIE","DTC_NUMNFC","DTC_SERNFC","DTC_EMINFC","DTC_FILCFS","DTC_NUMSOL","DTC_CLIREM","DTC_LOJREM",;
					"REM.A1_NREDUZ","DTC_CLIDES","DTC_LOJDES","DES.A1_NREDUZ","DTC_SQEDES","DES.A1_END","DES.A1_EST","DES.A1_MUN","DES.A1_BAIRRO","DES.A1_CEP","DES.A1_CGC",;
					"DTC_QTDVOL","DTC_PESO"  ,"DTC_PESOM3","DTC_METRO3","DTC_VALOR","DT6_VALFRE","DTC_CDRORI" ,"DTC_CDRDES" ,"DTC_CDRCAL","DTC_PRVENT","DTC_CODPRO",;
					"DTC_CODEMB","DTC_CLIDEV","DTC_LOJDEV","DEV.A1_NREDUZ","DTC_LOTNFC" , "DTP_RATEIO", "DTP_CRIRAT","DTC_TIPFRE","DTC_SERTMS","DTC_DESSVT","DTC_TIPTRA","DTC_SERVIC","DTC_DESSER", "DTC_FILORI","DT6_CHVCTE", "DTC_NFEID", ;
					"DT6_BLQDOC","DT6_FILDES","DYD_NUMAGD","DYD_DATAGD","DYD_PRDAGD","DYD_INIAGD","DYD_FIMAGD","DYD_TIPAGD","DT6_STATUS"}
Local oStruDTC  := T146Struct(TYPE_MODEL, aCamposDTC)
Local lProcDF8  := !IsInCallStack('TMSA146MNT') .And. !lIncAuto
Local lHasDLS   := AliasInDic("DLS")
Local oStruDLS  := Iif(lHasDLS, FwFormStruct(1,"DLS"),Nil)  //| Campos relacionados ao motorista - trocar DUP pela nova tabela

TMSA146Mod(TYPE_MODEL, @oStruDA3, @oStruDA8, @oStruDA6, @oStruDA5, @oStruDF8)

Pergunte('TMSA146',.F.)

oModel := MPFormModel():New('TMSA146', /*bPreValidacao*/, { |oMdl| T146PosVld( oMdl ) } /*bPosValid*/, { |oMdl| TMSA146Grv( oMdl ) } /*bCommit*/, /*bCancel*/ )

oModel:AddFields('MdFieldCOD',,oStruT02,,,{||})
If lHasDLS 
	oStruDLS:AddField('Titulo', '', 'DLS_ALTERA', 'L' , 1 , 0, NIL , NIL , NIL, .F., {|oModel|T146INIT(oModel)}, .F., .F. , .T.) //--Marca
EndIf
oModel:AddGrid('MdGridRot','MdFieldCOD', oStruDA8,  /* bLinePre */, /* nLinePost */ ,/*bPre*/, /*bPos*/,{|oMdlRot| TM146LdRot(oMdlRot) } /*BLoad*/ )
oModel:AddGrid('MdGridDoc','MdFieldCOD', oStruDTC, /* bLinePre */, /* nLinePost */ ,/*bPre*/, /*bPos*/, {|oMdlDoc| TM146LdDoc(oMdlDoc) } /*BLoad*/ )

oModel:AddGrid('MdGridDA3','MdFieldCOD', oStruDA3, /* bLinePre */, /* nLinePost */ ,/*bPre*/, /*bPos*/, {|oMdlVei| TM146LdDA3(oMdlVei) } /*BLoad*/ )
oModel:AddGrid('MdGridZon','MdGridRot' , oStruDA5) //Ambos estao relacionados com a GridRota porque os dados sao carregados por variavel 
oModel:AddGrid('MdGridSet','MdGridRot' , oStruDA6) //Ambos estao relacionados com a GridRota porque os dados sao carregados por variavel
oModel:AddGrid('MdGridDF8','MdGridDA3' , oStruDF8 , /* bLinePre */, /* nLinePost */ ,/*bPre*/, /*bPos*/, {|oMdl| If(lProcDF8,TM146LdDF8(oMdl,DF8->DF8_FILORI,DF8->DF8_NUMPRG,DF8->DF8_SEQPRG),{}) } /*BLoad*/ ) 
oModel:AddGrid('MdGridDDZ','MdGridDF8' , oStruDDZ , /* bLinePre */, /* nLinePost */ ,/*bPre*/, /*bPos*/,  /*BLoad*/ ) 
oModel:SetRelation( 'MdGridDDZ'    , { { 'DDZ_FILIAL', 'xFilial("DDZ")' }, { 'DDZ_FILORI', 'DF8_FILORI' }, { 'DDZ_NUMPRG', 'DF8_NUMPRG' }, { 'DDZ_SEQPRG', 'DF8_SEQPRG' } }, DDZ->( IndexKey(1) ))

//| Implementação nova tabela Motoristas da Prog. Carregamento
If lHasDLS
	oModel:AddGrid('MdGridDLS','MdGridDF8' , oStruDLS , {|oMdl,nLine,cAction,cFieldId,xValueOld,xValueNew| TM146VLDLS(oMdl,nLine,cAction,cFieldId,xValueNew,xValueOld) },/*bDLSPre*/,,,) //| Estrutura dos Dados do Motorista.
	oModel:SetRelation( 'MdGridDLS'    , { { 'DLS_FILIAL', 'xFilial("DLS")' }, { 'DLS_FILORI', 'DF8_FILORI' }, { 'DLS_NUMPRG', 'DF8_NUMPRG' }, { 'DLS_ITEDF8', 'DF8_SEQPRG' } }, DLS->( IndexKey(1) ))
EndIf

oModel:AddFields('MdTotal','MdFieldCOD',oStruT03,,,{|oMdl| TM146LdTot(oMdl) })
 
oModel:GetModel('MdGridDA3'):SetDescription(STR0027)   //Veiculos
oModel:GetModel('MdGridDF8'):SetDescription(STR0059)  //Programações do Veiculo
oModel:GetModel('MdTotal'):SetDescription('Totalizador') 

oModel:SetDescription(STR0023)  //Documentos

oModel:GetModel('MdFieldCOD'):SetDescription(STR0061) //Codigo de Barras
oModel:GetModel('MdGridDoc'):SetDescription(STR0023)  //Documentos

oModel:GetModel('MdGridRot'):SetDescription(STR0062)   //Rota
oModel:GetModel('MdGridZon'):SetDescription(STR0063)   //Zona
oModel:GetModel('MdGridSet'):SetDescription(STR0064)   //Setor

oModel:SetDescription(STR0001)   //Programacao de Carregamento

oModel:GetModel( 'MdGridDA3' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridDA3' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'MdGridDoc' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridDoc' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'MdGridDF8' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridDF8' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'MdGridRot' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridRot' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'MdGridZon' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridZon' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'MdGridSet' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridSet' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'MdGridDDZ' ):SetNoInsertLine( .T. )
//oModel:GetModel( 'MdGridDLS' ):SetNoDeleteLine( .T. )

oModel:GetModel( 'MdGridDA3' ):SetOptional(.T.)
oModel:GetModel( 'MdGridDoc' ):SetOptional(.T.)
oModel:GetModel( 'MdGridRot' ):SetOptional(.T.)
oModel:GetModel( 'MdGridZon' ):SetOptional(.T.)
oModel:GetModel( 'MdGridSet' ):SetOptional(.T.)
oModel:GetModel( 'MdGridDF8' ):SetOptional(.T.)
oModel:GetModel( 'MdGridDDZ' ):SetOptional(.T.)

oModel:GetModel('MdGridDF8'):SetOnlyQuery (.T.)
oModel:GetModel('MdGridDDZ'):SetOnlyQuery (.T.)

oModel:GetModel('MdGridDA3'):SetOnlyQuery(.T.)
oModel:GetModel('MdGridDoc'):SetOnlyQuery(.T.)
oModel:GetModel('MdGridRot'):SetOnlyQuery(.T.)
oModel:GetModel('MdGridZon'):SetOnlyQuery(.T.)
oModel:GetModel('MdGridSet'):SetOnlyQuery(.T.)
oModel:GetModel('MdTotal'):SetOnlyQuery(.T.)

If lHasDLS
	oModel:GetModel( 'MdGridDLS' ):SetOptional(.T.)
	oModel:GetModel('MdGridDLS'):SetOnlyQuery(.T.)
	// Unique line
	oModel:GetModel("MdGridDLS"):SetUniqueLine({'DLS_CODVEI','DLS_CODMOT'})
	oStruDLS:AddTrigger('DLS_CODMOT','DLS_NOMMOT',,{||Posicione("DA4",1,xFilial("DA4")+oModel:GetModel("MdGridDLS"):GetValue("DLS_CODMOT"),"DA4_NOME")})
	oStruDLS:AddTrigger('DLS_CODMOT','DLS_TIPMOT',,{||Posicione("DA4",1,xFilial("DA4")+oModel:GetModel("MdGridDLS"):GetValue("DLS_CODMOT"),"DA4_TIPMOT")})
EndIf

oStruDF8:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

// Se for rota Automatica - Remove a obrigatoriedade do campo Rota
If IsInCallStack("TMSAF76") 
	oStruDA6:SetProperty("DA6_ROTA",MODEL_FIELD_OBRIGAT,.F.)
	oStruDA8:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
EndIf

oModel:SetVldActivate( { |oModel| VldActMdl( oModel ) } )

oModel:SetActivate({ |oModel|ActiveMdl(oModel) })

Return oModel

//-----------------------------------------------------------------
/*/{Protheus.doc} T146Struct
Estrutura dos campos 
@author Katia
@since 30/07/2014
/*/
//-----------------------------------------------------------------

Static Function T146Struct(nType,aCampos)

Local oStruct   := Nil
Local nX        := 0
Local aDadosCpo := {}
Local cCampo    := ""
Local aAux      := {}

Default nType   := 1        //  1=Tipo Model / 2= Tipo View
DefauLt aCampos := {}

If nType == 1
	oStruct := FWFormModelStruct():New()

	//----------Estrutura do campo tipo Model----------------------------		
	// [01] C Titulo do campo
	// [02] C ToolTip do campo
	// [03] C identificador (ID) do Field
	// [04] C Tipo do campo
	// [05] N Tamanho do campo
	// [06] N Decimal do campo
	// [07] B Code-block de validação do campo
	// [08] B Code-block de validação When do campo
	// [09] A Lista de valores permitido do campo
	// [10] L Indica se o campo tem preenchimento obrigatório
	// [11] B Code-block de inicializacao do campo
	// [12] L Indica se trata de um campo chave
	// [13] L Indica se o campo pode receber valor em uma operação de update.
	// [14] L Indica se o campo é virtual
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campo filial da tabela fake. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oStruct:AddField(STR0086,STR0087,"T01_FILIAL","C",FwSizeFilial(),0)	//"Filial"//"Filial do Sistema"
		
	For nX := 1 To Len(aCampos)
		If SubStr(aCampos[nX],1,3) $ 'DEV|REM|DES' 
			aDadosCpo:= TMSX3Cpo(Substr(aCampos[nX],5,Len(aCampos[nX])))   
			If !aCampos[nX] $ "DES.A1_END|DES.A1_EST|DES.A1_MUN|DES.A1_BAIRRO|DES.A1_CEP|DES.A1_CGC"                                                                                  
				oStruct:AddField(aDadosCpo[1],aDadosCpo[2],"T01_NOM"+SubStr(aCampos[nX],1,3),aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])
			Else
				cCampo:= StrTran( aCampos[nX], 'DES.A1_', '')	  //Remove o caracter
				oStruct:AddField(aDadosCpo[1],aDadosCpo[2],"T01_"+cCampo,aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])
			EndIf	
		Else
			aDadosCpo := TMSX3Cpo(aCampos[nX])
			oStruct:AddField(aDadosCpo[1],aDadosCpo[2],"T01_"+SubStr(aCampos[nX],5,Len(aCampos[nX])),aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])
		EndIf	
	Next nX
	//-- Campos Virtuais
	oStruct:AddField(STR0088, STR0089, 'T01_MARK'  , 'L'  , 1 , 0, {|| T146MrkDoc() } , {|| TMA146VDoc(FwFldGet('T01_SERTMS'),'D',FwFldGet('T01_MARK')) }  , NIL, NIL, NIL, NIL, NIL, .T.)  //Marca Docto
	oStruct:AddField('L'    , STR0009, 'T01_LEGEN' , 'BT' , 1 , 0, {|| TMSA146Leg("L")} , NIL , NIL, NIL, NIL, NIL, .F., .T.)  //Legenda
	
	oStruct:AddField('A'                             , AllTrim(RetTitle('DYK_CORPRI')), 'T01_LEGPAG' , 'BT' , 1 , 0, {|| TMSA146Leg("A")} , NIL , NIL, NIL, NIL, NIL, .F., .T.)  //Legenda Prioridade Agendamento
	oStruct:AddField('DT'                            , AllTrim(RetTitle('DT6_STATUS')), 'T01_LEGDOC' , 'BT' , 1 , 0, {|| TMSA146Leg("DT6")} , NIL , NIL, NIL, NIL, NIL, .F., .T.)  //Legenda Documentos de Transporte
	oStruct:AddField(AllTrim(RetTitle('DYD_TIPAGD')) , AllTrim(RetTitle('DYD_TIPAGD')), 'T01_DETPAG', 'C' , 20    , 0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.) //Tp.Agendamento
	oStruct:AddField(AllTrim(RetTitle('DYD_PRDAGD')) , AllTrim(RetTitle('DYD_PRDAGD')), 'T01_DEPRAG', 'C' , 20    , 0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.) //Prioridade Agendamento
	
	oStruct:AddField(STR0090, STR0090, 'T01_NUMPRG', 'C' , TamSX3('DF8_NUMPRG')[1] , 0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.) //Num.Prg.
	oStruct:AddField(STR0091, STR0091, 'T01_NUMTMP', 'C' , TamSX3('DF8_NUMPRG')[1] , 0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.) //Prg.Temp
	oStruct:AddField(STR0092, STR0092, 'T01_SEQPRG', 'C' , TamSX3('DF8_SEQPRG')[1] , 0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.) //Seq.Prg
	oStruct:AddField(STR0093, STR0093, 'T01_CODVEI', 'C' , TamSX3('DA3_COD')[1]    , 0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.) //Cod.Vei
	oStruct:AddField(STR0094, STR0094, 'T01_SEQENT', 'C' , TamSX3('DUD_SEQENT')[1] , 0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.) //Seq.Ent
	oStruct:AddField(STR0062, STR0062, 'T01_CDROTA', 'C' , TamSX3('DA8_COD')[1]    , 0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.) //Rota
	oStruct:AddField(STR0154, STR0154, 'T01_RECREM', 'C' , 1 , 0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.) //Restricao Cliente Remetente
	oStruct:AddField(STR0155, STR0155, 'T01_RECDES', 'C' , 1 , 0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.) //Restricao Cliente Destinatario
	oStruct:AddField(AllTrim(RetTitle('DTC_TIPFRE')), AllTrim(RetTitle('DTC_TIPFRE')), 'T01_DETPFR', 'C' , 3 , 0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.) //Restricao Cliente Destinatario
	
	aAux := FwStruTrigger(;
	"T01_MARK", ;                                                      // [01] Id do campo de origem
	"T01_SEQENT" , ;                                                   // [02] Id do campo de destino
	"TMA146Seq()")
			
	oStruct:AddTrigger( ;
	aAux[1], ;                                                      // [01] Id do campo de origem
	aAux[2], ;                                                      // [02] Id do campo de destino
	aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
	aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho
		
Else	
	//----------------Estrutura para criação do campo-----------------------------
	// [01] C Nome do Campo
	// [02] C Ordem
	// [03] C Titulo do campo
	// [04] C Descrição do campo
	// [05] A Array com Help
	// [06] C Tipo do campo
	// [07] C Picture
	// [08] B Bloco de Picture Var
	// [09] C Consulta F3
	// [10] L Indica se o campo é evitável
	// [11] C Pasta do campo
	// [12] C Agrupamento do campo
	// [13] A Lista de valores permitido do campo (Combo)
	// [14] N Tamanho Maximo da maior opção do combo
	// [15] C Inicializador de Browse
	// [16] L Indica se o campo é virtual
	// [17] C Picture Variável
	
	oStruct := FWFormViewStruct():New()

	For nX := 1 To Len(aCampos)
		If SubStr(aCampos[nX],1,3) $ 'DEV|REM|DES' 
			If !aCampos[nX] $ "DES.A1_END|DES.A1_EST|DES.A1_MUN|DES.A1_BAIRRO|DES.A1_CEP|DES.A1_CGC"
				aDadosCpo:= TMSX3Cpo(Substr(aCampos[nX],5,Len(aCampos[nX])))
				oStruct:AddField("T01_NOM"+SubStr(aCampos[nX],1,3),StrZero(nX,2),aDadosCpo[1],aDadosCpo[2],{""},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil)                                                                                     
			Else                                       
				aDadosCpo:= TMSX3Cpo(Substr(aCampos[nX],5,Len(aCampos[nX])))
				cCampo:= StrTran( aCampos[nX], 'DES.A1_', '')	  //Remove o caracter
				oStruct:AddField("T01_"+cCampo,StrZero(nX,2),aDadosCpo[1],aDadosCpo[2],{""},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil)
			EndIf                                                                                  
		Else
			aDadosCpo := TMSX3Cpo(aCampos[nX])
			oStruct:AddField("T01_"+SubStr(aCampos[nX],5,Len(aCampos[nX])),StrZero(nX,2),aDadosCpo[1],aDadosCpo[2],{""},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil)   
		EndIf	
	Next nX	
	
	oStruct:AddField( "T01_MARK"   ,'00' , STR0088 , STR0089 , {} , 'L'  ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL,	NIL, NIL, .T. )	
	oStruct:AddField( "T01_LEGEN"  ,'01' , "L"     , STR0009 , {} , 'BT' ,'@BMP', NIL, NIL, TM146Edit(), NIL, NIL, NIL,	NIL, NIL, .T. )
	
	oStruct:AddField( "T01_LEGPAG" ,'02' , "A"                            , AllTrim(RetTitle('DYK_CORPRI')), {} , 'BT' ,'@BMP', NIL, NIL, TM146Edit(), NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruct:AddField( "T01_LEGDOC" ,'03' , "DT"                           , AllTrim(RetTitle('DT6_STATUS')), {} , 'BT' ,'@BMP', NIL, NIL, TM146Edit(), NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruct:AddField( "T01_DETPAG" ,'80' , AllTrim(RetTitle('DYD_TIPAGD')), AllTrim(RetTitle('DYD_TIPAGD')) , {} , 'G' ,'@!'  , NIL, NIL, .F., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruct:AddField( "T01_DEPRAG" ,'81' , AllTrim(RetTitle('DYD_PRDAGD')), AllTrim(RetTitle('DYD_PRDAGD')) , {} , 'G' ,'@!'  , NIL, NIL, .F., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruct:AddField( "T01_NUMPRG" ,'82' , STR0090 , STR0090 , {} , 'G' ,'@!'  , NIL, NIL,	.F., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruct:AddField( "T01_NUMTMP" ,'83' , STR0091 , STR0091 , {} , 'G' ,'@!'  , NIL, NIL,	.F., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruct:AddField( "T01_SEQPRG" ,'84' , STR0092 , STR0092 , {} , 'G' ,'@!'  , NIL, NIL,	.F., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruct:AddField( "T01_CODVEI" ,'85' , STR0093 , STR0093 , {} , 'G' ,'@!'  , NIL, NIL,	.F., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruct:AddField( "T01_SEQENT" ,'86' , STR0094 , STR0095 , {} , 'G' ,'@!'  , NIL, NIL,	.F., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruct:AddField( "T01_CDROTA" ,'87' , STR0062 , STR0062 , {} , 'G' ,'@!'  , NIL, NIL,	.F., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruct:AddField( "T01_RECREM" ,'88' , STR0154 , STR0154 , {} , 'G' ,'@!'  , NIL, NIL,	.F., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruct:AddField( "T01_RECDES" ,'89' , STR0155 , STR0155 , {} , 'G' ,'@!'  , NIL, NIL,	.F., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruct:AddField( "T01_DETPFR" ,'90' , AllTrim(RetTitle('DTC_TIPFRE')) , AllTrim(RetTitle('DTC_TIPFRE')) , {} , 'G' ,'@!'  , NIL, NIL,	.F., NIL, NIL, NIL,	NIL, NIL, .T. )
		
EndIf

Return(oStruct)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Katia
@since 30/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel := Nil
Local cDemanda := IIF(DF8->(ColumnPos("DF8_DATINI")) > 0,"DF8_DATINI|DF8_HORINI|DF8_DATFIM|DF8_HORFIM|","")
                                                                                                                                                                                                                    
Local oStruDDZ := FWFormStruct(2,'DDZ')
Local oStruDA3 := FWFormStruct(2,'DA3',{|cCampo| AllTrim(cCampo)+"|" $ "DA3_MARK|DA3_BTCAR|DA3_BTDES|DA3_STATUS|DA3_COD|DA3_PLACA|DA3_DESC|DA3_FROVEI|DA3_DESTIP|DA3_CAPACM|DA3_CAPACN|DA3_VOLMAX|DA3_FILATU|DA3_FILBAS|DA3_VEIRAS|DA3_DTPRCH|DA3_HRPRCH|DA3_SERTMS|DA3_DESSVT|DA3_VELOC|"})
Local oStruDF8  := FWFormStruct(2,'DF8',{|cCampo| AllTrim(cCampo)+"|" $ "DF8_BTCAR|DF8_BTDES|DF8_BTVIS|DF8_STAPRG|DF8_STAVEI|DF8_RESTRI|DF8_FILORI|DF8_NUMTMP|DF8_NUMPRG|DF8_SEQPRG|DF8_ROTA|DF8_DESSVT|DF8_SERTMS|DF8_DATGER|DF8_HORGER|DF8_FILVGE|DF8_NUMVGE|DF8_CODVEI|"+;
"DF8_CAPACM|DF8_CAPACD|DF8_QTDVOL|DF8_QTDDOC|DF8_PESO|DF8_PESOM3|DF8_VALOR|DF8_QTDCOL|DF8_VOLCOL|DF8_PESCOL|DF8_PM3COL|DF8_VLMCOL|DF8_VLFCOL|"+;
"DF8_QTDENT|DF8_VOLENT|DF8_PESENT|DF8_PM3ENT|DF8_VLMENT|DF8_VLFENT|DF8_QTDTRA|DF8_VOLTRA|DF8_PESTRA|DF8_PM3TRA|DF8_VLMTRA|DF8_VLFTRA|DF8_VIAGEM|DF8_CODCAV|DF8_MODCAV|DF8_QTDRAT|DF8_TIPTRA|"+cDemanda})

Local aCamposDTC:= {"DTC_FILIAL","DTC_FILDOC","DTC_DOC","DTC_SERIE","DTC_NUMNFC","DTC_SERNFC","DTC_EMINFC","DTC_FILCFS","DTC_NUMSOL","DTC_CLIREM","DTC_LOJREM",;
"REM.A1_NREDUZ","DTC_CLIDES","DTC_LOJDES","DES.A1_NREDUZ","DTC_SQEDES","DES.A1_END","DES.A1_EST","DES.A1_MUN","DES.A1_BAIRRO","DES.A1_CEP","DES.A1_CGC",;
"DTC_QTDVOL","DTC_PESO"  ,"DTC_PESOM3","DTC_METRO3","DTC_VALOR","DT6_VALFRE","DTC_CDRORI" ,"DTC_CDRDES" ,"DTC_CDRCAL","DTC_PRVENT","DTC_CODPRO",;
"DTC_CODEMB","DTC_CLIDEV","DTC_LOJDEV","DEV.A1_NREDUZ","DTC_LOTNFC" ,"DTP_RATEIO", "DTP_CRIRAT","DTC_TIPFRE","DTC_SERTMS","DTC_DESSVT", "DTC_TIPTRA","DTC_SERVIC","DTC_DESSER", "DTC_FILORI","DT6_CHVCTE", "DTC_NFEID", ;
"DT6_BLQDOC","DT6_FILDES","DYD_NUMAGD","DYD_DATAGD","DYD_PRDAGD","DYD_INIAGD","DYD_FIMAGD","DYD_TIPAGD","DT6_STATUS"}

Local oStruT02:= VwoStruT02()   //Estrutura do Model - Codigo de Barra
Local oStruT03:= VwoStruT03()   //Estrutura do Model - Totalizador
Local oStruDA8:= FWFormStruct(2, 'DA8', {|cCampo| AllTrim(cCampo)+"|" $ "DA8_MARK|DA8_COD|DA8_DESC|DA8_SERTMS|DA8_DESSVT|"})
Local oStruDA5:= FWFormStruct(2, 'DA5', {|cCampo| AllTrim(cCampo)+"|" $ "DA5_MARK|DA5_COD|DA5_DESC|DA5_CDROTA|"})
Local oStruDA6:= FWFormStruct(2, 'DA6', {|cCampo| AllTrim(cCampo)+"|" $ "DA6_MARK|DA6_ROTA|DA6_REF|DA6_PERCUR|DA6_CDROTA|"})
Local oStruDTC:= T146Struct(TYPE_VIEW,aCamposDTC)
Local lHasDLS := AliasInDic("DLS") //| Tabela disponivel na release 12.1.25
Local oStruDLS:= NIL 

If lHasDLS
	oStruDLS := FwFormStruct(2,"DLS" ,{ |cCampo| !(AllTrim(CCampo) $ "DLS_FILORI|DLS_NUMPRG|DLS_CODVEI|DLS_ITEDF8|DLS_IDOPE") }) //| Trocar pelo alias da nova tabela - "Motorista da Programacao de Carregamento"
EndIf

oModel   := FwLoadModel("TMSA146")

TMSA146Mod(TYPE_VIEW, @oStruDA3, @oStruDA8, @oStruDA6, @oStruDA5, @oStruDF8)
oStruDTC:RemoveField("T01_FILIAL")
oStruDTC:RemoveField("T01_TIPAGD")
oStruDTC:RemoveField("T01_PRDAGD")
oStruDTC:RemoveField("T01_TIPTRA")
oStruDTC:RemoveField("T01_STATUS")
oStruDTC:RemoveField("T01_TIPFRE")
oStruDTC:RemoveField("T01_SERTMS")
oStruDTC:RemoveField("T01_BLQDOC")
oStruDF8:RemoveField("DF8_VGEINT")
oStruDF8:RemoveField("DF8_CODVEI")
oStruDF8:RemoveField("DF8_CODVEI")
oStruDF8:RemoveField("DF8_QTDRAT")  //Campo para controle de lote de Rateio
oStruT03:RemoveField("T03_QTDRAT")  //Campo para controle de lote de Rateio

oStruDA8:SetProperty( "DA8_DESC"  , MVC_VIEW_CANCHANGE ,.F.)
oStruDA5:SetProperty( "DA5_COD"  ,  MVC_VIEW_CANCHANGE ,.F.)
oStruDA5:SetProperty( "DA5_DESC"  , MVC_VIEW_CANCHANGE ,.F.)
oStruDA5:SetProperty( "DA5_CDROTA", MVC_VIEW_CANCHANGE ,.F.)
oStruDA6:SetProperty( "DA6_REF"   , MVC_VIEW_CANCHANGE ,.F.)
oStruDA3:SetProperty( "DA3_PLACA" , MVC_VIEW_CANCHANGE ,.F.)
oStruDA3:SetProperty( "DA3_DESC"  , MVC_VIEW_CANCHANGE ,.F.)
oStruDA3:SetProperty( "DA3_VOLMAX", MVC_VIEW_CANCHANGE ,.F.)
oStruDA3:SetProperty( "DA3_VEIRAS", MVC_VIEW_CANCHANGE ,.F.)
oStruDA3:SetProperty( "DA3_FROVEI", MVC_VIEW_CANCHANGE ,.F.)
oStruDA3:SetProperty( "DA3_CAPACM", MVC_VIEW_CANCHANGE ,.F.)
oStruDA3:SetProperty( "DA3_CAPACN", MVC_VIEW_CANCHANGE ,.F.)
oStruDA3:SetProperty( "DA3_DESTIP", MVC_VIEW_CANCHANGE ,.F.)
oStruDA3:SetProperty( "DA3_SERTMS", MVC_VIEW_CANCHANGE ,.F.)
If lIntTPR .And. DA3->(ColumnPos("DA3_VELOC")) > 0
	oStruDA3:SetProperty( "DA3_VELOC", MVC_VIEW_CANCHANGE ,.F.)
EndIf	

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VwFieldCod', oStruT02 ,'MdFieldCOD' )

oView:AddGrid('VwGridDA3' , oStruDA3 ,'MdGridDA3' )
oView:AddGrid('VwGridDoc' , oStruDTC ,'MdGridDoc' )
oView:AddGrid('VwGridRot' , oStruDA8 ,'MdGridRot' )
oView:AddGrid('VwGridZon' , oStruDA5 ,'MdGridZon' )
oView:AddGrid('VwGridSet' , oStruDA6 ,'MdGridSet' )

oView:AddGrid('VwGridDF8' , oStruDF8 ,'MdGridDF8' )
oView:AddGrid('VwGridDDZ' , oStruDDZ ,'MdGridDDZ' )
If lHasDLS
	oView:AddGrid('VwGridDLS' , oStruDLS ,'MdGridDLS' ) //|Tabela - "Motoristas da Programação de Carregamento."
EndIf

oView:AddField('VwTotal'   , oStruT03 ,'MdTotal' )
	
TMSA146Ord(@oStruDTC, @oStruDA3, @oStruDF8, @oStruDA5, @oStruDA6, @oStruDDZ)

oView:CreateHorizontalBox( 'BCodBar', 10)
oView:CreateHorizontalBox( 'BTela'  , 83)
oView:CreateHorizontalBox( 'BTotal' , 7)

oView:CreateVerticalBox( 'BColuna1', 70, 'BTela') 
oView:CreateVerticalBox( 'BColuna2', 30, 'BTela') 

oView:CreateHorizontalBox( 'BVeiculo', 60, 'BColuna2') 
oView:CreateHorizontalBox( 'BProgram', 40, 'BColuna2') 

oView:CreateHorizontalBox( 'BDocto', 100, 'BColuna1')  

oView:CreateVerticalBox( 'BoxVeiculo', 100, 'BVeiculo')

oView:SetOwnerView('VwGridDA3','BoxVeiculo')

oView:CreateFolder( 'IdFldIni', 'BDocto')

oView:CreateFolder( 'IdFldPrg', 'BProgram')   
oView:AddSheet('IdFldPrg','ShtDF8',STR0059)		  //Folder/Sheet
oView:AddSheet('IdFldPrg','ShtDDZ',STR0027)       //Folder/Sheet

//| Folder Motoristas da Programacao de Carregamento
If lHasDLS
	oView:AddSheet('IdFldPrg','ShtDLS',STR0239)
	oView:CreateHorizontalBox('BoxGridDLS',100,,,'IdFldPrg','ShtDLS')
	oView:SetOwnerView('VwGridDLS','BoxGridDLS')
EndIf

oView:CreateHorizontalBox( 'BoxGridDF8', 100, /*owner*/, /*lUsePixel*/, 'IdFldPrg', 'ShtDF8')
oView:SetOwnerView('VwGridDF8','BoxGridDF8')

oView:CreateHorizontalBox( 'BoxGridDDZ', 100, /*owner*/, /*lUsePixel*/, 'IdFldPrg', 'ShtDDZ')
oView:SetOwnerView('VwGridDDZ','BoxGridDDZ')


oView:AddSheet('IdFldIni','ShtDoct', STR0023)  //Documentos  (Folder/Sheet)
oView:AddSheet('IdFldIni','ShtRota', STR0062)  //Rota		 (Folder/Sheet)

oView:CreateHorizontalBox( 'BRota' , 36, /*owner*/, /*lPixel*/, 'IdFldIni', 'ShtRota')
oView:CreateHorizontalBox( 'BZona' , 33, /*owner*/, /*lPixel*/, 'IdFldIni', 'ShtRota')
oView:CreateHorizontalBox( 'BSetor', 31, /*owner*/, /*lPixel*/, 'IdFldIni', 'ShtRota')

oView:CreateHorizontalBox( 'BoxGridDoc', 100, /*owner*/, /*lUsePixel*/, 'IdFldIni', 'ShtDoct')

oView:CreateVerticalBox( 'BoxCodBarra', 100, 'BCodBar')
oView:CreateVerticalBox( 'BoxTotal'   , 100, 'BTotal')

oView:CreateVerticalBox( 'BoxRota' , 100, 'BRota' , /*lUsePixel*/, 'IdFldIni', 'ShtRota')
oView:CreateVerticalBox( 'BoxZona' , 100, 'BZona' , /*lUsePixel*/, 'IdFldIni', 'ShtRota')
oView:CreateVerticalBox( 'BoxSetor', 100, 'BSetor', /*lUsePixel*/, 'IdFldIni', 'ShtRota')

oView:SetOwnerView('VwGridSet'  ,'BoxSetor')
oView:SetOwnerView('VwGridZon'  ,'BoxZona')
oView:SetOwnerView('VwGridRot'  ,'BoxRota')
oView:SetOwnerView('MdTotal'    ,'BoxTotal')
oView:SetOwnerView('VwFieldCod' ,'BoxCodBarra')	
oView:SetOwnerView('VwGridDoc'  ,'BoxGridDoc')

oView:AddUserButton(STR0147,'',{|| TM146Cons('D',FwFldGet('T01_FILDOC'),FwFldGet('T01_DOC'),FwFldGet('T01_SERIE'),FwFldGet('T01_NUMNFC'),FwFldGet('T01_SERNFC'),FwFldGet('T01_CLIREM'),FwFldGet('T01_LOJREM')) })   
oView:AddUserButton(STR0148,'',{|| TM146Cons('V') })   

If lIntTPR 
	oView:AddUserButton(STR0246,'',{|| TMS146ATPR() })    //Enviar Planej.Rotas (TPR)
EndIf

oView:EnableTitleView( 'VwGridDA3' , STR0027)
                                              
//--- Inclusao de Filtro na Grid, necessario habilitar somente para a versao 11.
oView:SetViewProperty("VwGridDA3", "ENABLENEWGRID")
oView:SetViewProperty("VwGridDA3", "GRIDFILTER", {.T.}) 
oView:SetViewProperty("VwGridDA3", "GRIDSEEK", {.T.})

oView:SetViewProperty("VwGridDoc", "ENABLENEWGRID")
oView:SetViewProperty("VwGridDoc", "GRIDFILTER", {.T.}) 
oView:SetViewProperty("VwGridDoc", "GRIDSEEK", {.T.})  

oView:SetViewProperty("VwGridDF8", "ENABLENEWGRID")
oView:SetViewProperty("VwGridDF8", "GRIDFILTER", {.T.}) 
oView:SetViewProperty("VwGridDF8", "GRIDSEEK", {.T.})

oView:SetViewProperty("VwGridDDZ", "ENABLENEWGRID")

//| Campos com auto incremento
If lHasDLS
	oView:addIncrementField("VwGridDLS", "DLS_ITEM")
EndIf

oView:SetCloseOnOk({|| .T. })

If oModel:GetOperation() == MODEL_OPERATION_VIEW
	//-- Não Permite Abertura Da Tela De "Salvar Dados Do Formulário"
	oView:SetViewAction("ASKONCANCELSHOW",{||.F.})
EndIf

oView:bAfterViewActivate := { |oView| TMA146Act(oView)}

Return oView

//-------------------------------------------------------------------
/*/ {Protheus.doc} MdoStruT02()
Retorna estrutura do Model - Codigo de Barra
@author Katia
@since 30/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MdoStruT02()

Local oStruT02 := FWFormModelStruct():New()
Local aIndex   := {1, "1", "DT6_CHVCTE", "Chv.Cte"}

oStruT02:AddTable('T02',{'T02_CODBAR'},STR0096)   //Codigo de Barras

oStruT02:AddIndex( ;
		aIndex[1]  , ;       // [01] Ordem do indice
		aIndex[2]  , ;       // [02] ID
		aIndex[3]  , ;       // [03] Chave do indice
		aIndex[4]  , ;       // [04] Descrição do indice
		''         , ;       // [05] Expressão de lookUp dos campos de indice
		''         , ;   		// [06] Nickname do indice
		.T.)                	// [07] Indica se o indice pode ser utilizado pela interface   
			
oStruT02:AddField(STR0096, STR0096,'T02_CODBAR', 'C',TamSX3('DT6_CHVCTE')[1], 0,{|| TM146CdBar()} , , {}, .F., , .F., .F., .T., , )
oStruT02:AddField(STR0096, STR0096,'T02_CODBAR', 'C',TamSX3('DT6_CHVCTE')[1], 0, Nil , , , .F., , .F., .F., .T., , )
oStruT02:AddField(STR0097, STR0098,'T02_TODOS' , 'L',1 ,0 ,{|| TM146MrkTd()},Nil,Nil,Nil,Nil,Nil,Nil,.T.)   //Todos Documentos

return oStruT02

//-------------------------------------------------------------------
/*/ {Protheus.doc} MdoStruT03()
Retorna estrutura do Model - Totalizador
@author Katia
@since 12/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MdoStruT03()

Local oStruT03 := FWFormModelStruct():New()

oStruT03:AddTable('T03',{'T03_QTDDT'},STR0143)  //Campos Calculados
		
oStruT03:AddField(STR0065,STR0065,'T03_QTDDT','N',10,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0066,STR0066,'T03_QTDDC','N',10,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)

oStruT03:AddField(STR0067,STR0067,'T03_QTDDTC','N',8,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0084,STR0084,'T03_QTDDTE','N',8,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0121,STR0121,'T03_QTDDTT','N',8,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)

oStruT03:AddField(STR0068,STR0068,'T03_QTDDCC','N',8,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0085,STR0085,'T03_QTDDCE','N',8,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0122,STR0122,'T03_QTDDCT','N',8,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)

oStruT03:AddField(STR0069,STR0069,'T03_VOLUME','N',10,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0070,STR0070,'T03_PESO','N',14,4, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0071,STR0071,'T03_PESOM3','N',14,4, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0072,STR0072,'T03_VALOR','N',16,2, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0073,STR0073,'T03_VALFRE','N',16,2, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)

oStruT03:AddField(STR0074,STR0074,'T03_VOLDTC','N',8,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0075,STR0075,'T03_PESDTC','N',11,4, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0076,STR0076,'T03_PM3DTC','N',11,4, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0077,STR0077,'T03_VLMDTC','N',14,2, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0078,STR0078,'T03_VLFDTC','N',14,2, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)

oStruT03:AddField(STR0079,STR0079,'T03_VOLDTE','N',8,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0080,STR0080,'T03_PESDTE','N',11,4, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0081,STR0081,'T03_PM3DTE','N',11,4, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0082,STR0082,'T03_VLMDTE','N',14,2, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0083,STR0083,'T03_VLFDTE','N',14,2, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)

oStruT03:AddField(STR0123,STR0123,'T03_VOLDTT','N',8,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0124,STR0124,'T03_PESDTT','N',11,4, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0125,STR0125,'T03_PM3DTT','N',11,4, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0126,STR0126,'T03_VLMDTT','N',14,2, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0127,STR0127,'T03_VLFDTT','N',14,2, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)

oStruT03:AddField(STR0128,STR0128,'T03_VOLDCC','N',8,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0129,STR0129,'T03_PESDCC','N',11,4, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0130,STR0130,'T03_PM3DCC','N',11,4, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0131,STR0131,'T03_VLMDCC','N',14,2, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0132,STR0132,'T03_VLFDCC','N',14,2, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)

oStruT03:AddField(STR0133,STR0133,'T03_VOLDCE','N',8,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0134,STR0134,'T03_PESDCE','N',11,4, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0135,STR0135,'T03_PM3DCE','N',11,4, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0136,STR0136,'T03_VLMDCE','N',14,2, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0137,STR0137,'T03_VLFDCE','N',14,2, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)

oStruT03:AddField(STR0138,STR0138,'T03_VOLDCT','N',8,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0139,STR0139,'T03_PESDCT','N',11,4, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0140,STR0140,'T03_PM3DCT','N',11,4, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0141,STR0141,'T03_VLMDCT','N',14,2, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
oStruT03:AddField(STR0142,STR0142,'T03_VLFDCT','N',14,2, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)

oStruT03:AddField(STR0142,STR0142,'T03_QTDRAT','N',8,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)
return oStruT03

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewoStruT02()
Retorna estrutura do Model - (Codigo de Barra)
@author Katia
@since 31/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VwoStruT02()

Local oStruT02 := FWFormViewStruct():New()

oStruT02:AddField( 'T02_TODOS' ,'01', STR0097, STR0098, {STR0098},'L',Nil,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)
oStruT02:AddField( 'T02_CODBAR','02', STR0096, STR0096,          ,'G',Nil,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)

return oStruT02

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewoStruT03()
Retorna estrutura do Model - (Totalizador)
@author Katia
@since 31/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VwoStruT03()

Local oStruT03 := FWFormViewStruct():New()

oStruT03:AddField('T03_QTDDT','01',STR0065,STR0065,, 'G' ,'9999999999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_QTDDC','02',STR0066,STR0066,, 'G' ,'9999999999',,,.F.,,,,,,.T.,, )

oStruT03:AddField('T03_QTDDTC','03',STR0067,STR0067,, 'G' ,'99999999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_QTDDTE','04',STR0084,STR0084,, 'G' ,'99999999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_QTDDTT','05',STR0121,STR0121,, 'G' ,'99999999',,,.F.,,,,,,.T.,, )

oStruT03:AddField('T03_QTDDCC','06',STR0068,STR0068,, 'G' ,'99999999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_QTDDCE','07',STR0085,STR0085,, 'G' ,'99999999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_QTDDCT','08',STR0122,STR0122,, 'G' ,'99999999',,,.F.,,,,,,.T.,, )

oStruT03:AddField('T03_VOLUME','09',STR0069,STR0069,, 'G' ,'99999999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_PESO'  ,'10',STR0070,STR0070,, 'G' ,'@E 99,999,999,999.99',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_PESOM3','11',STR0071,STR0071,, 'G' ,'@E 99,999,999,999.99',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_VALOR' ,'12',STR0072,STR0072,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_VALFRE','13',STR0073,STR0073,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )

oStruT03:AddField('T03_VOLDTC','14',STR0074,STR0074,, 'G' ,'99999999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_PESDTC','15',STR0075,STR0075,, 'G' ,'@E 99,999,999,999.99',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_PM3DTC','16',STR0076,STR0076,, 'G' ,'@E 99,999,999,999.99',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_VLMDTC','17',STR0077,STR0077,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_VLFDTC','18',STR0078,STR0078,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )

oStruT03:AddField('T03_VOLDTE','19',STR0079,STR0079,, 'G' ,'99999999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_PESDTE','20',STR0080,STR0080,, 'G' ,'@E 99,999,999,999.99',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_PM3DTE','21',STR0081,STR0081,, 'G' ,'@E 99,999,999,999.99',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_VLMDTE','22',STR0082,STR0082,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_VLFDTE','23',STR0083,STR0083,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )

oStruT03:AddField('T03_VOLDTT','24',STR0123,STR0123,, 'G' ,'99999999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_PESDTT','25',STR0124,STR0124,, 'G' ,'@E 99,999,999,999.99',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_PM3DTT','26',STR0125,STR0125,, 'G' ,'@E 99,999,999,999.99',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_VLMDTT','27',STR0126,STR0126,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_VLFDTT','28',STR0127,STR0127,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )

oStruT03:AddField('T03_VOLDCC','29',STR0128,STR0128,, 'G' ,'99999999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_PESDCC','30',STR0129,STR0129,, 'G' ,'@E 99,999,999,999.99',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_PM3DCC','31',STR0130,STR0130,, 'G' ,'@E 99,999,999,999.99',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_VLMDCC','32',STR0131,STR0131,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_VLFDCC','33',STR0132,STR0132,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )

oStruT03:AddField('T03_VOLDCE','34',STR0133,STR0133,, 'G' ,'99999999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_PESDCE','35',STR0134,STR0134,, 'G' ,'@E 99,999,999,999.99',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_PM3DCE','36',STR0135,STR0135,, 'G' ,'@E 99,999,999,999.99',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_VLMDCE','37',STR0136,STR0136,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_VLFDCE','38',STR0137,STR0137,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )

oStruT03:AddField('T03_VOLDCT','39',STR0138,STR0138,, 'G' ,'99999999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_PESDCT','40',STR0139,STR0139,, 'G' ,'@E 99,999,999,999.99',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_PM3DCT','41',STR0140,STR0140,, 'G' ,'@E 99,999,999,999.99',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_VLMDCT','42',STR0141,STR0141,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )
oStruT03:AddField('T03_VLFDCT','43',STR0142,STR0142,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )

oStruT03:AddField('T03_QTDRAT','44',STR0142,STR0142,, 'G' ,'@E 999,999,999,999.9999',,,.F.,,,,,,.T.,, )
Return oStruT03

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna as operacoes disponiveis
@author Katia
@since 31/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function MenuDef()

Local aEfetivar:= {	{ STR0007, "TMSA146EFT()"  ,0 ,6, 0 },; //"Efetivar"
					{ STR0196, "TMSA146EST()"  ,0 ,7, 0 } } //"Estornar"

Local aRotina	:= {} 

Local aTPRMenu	:= {	{ STR0247, "T146PnlTPR"  ,0 ,6, 0 },;  //"Painel de Integração"
						{ STR0249, "TMSAC24Map"  ,0 ,7, 0 } }  //"Visualizar Mapa"     

aRotina :=    { { STR0002, "AxPesqui"             , 0, 1, 0 },; //-- "Pesquisar"
				{ STR0003, "VIEWDEF.TMSA146"      , 0, 2, 0 },; //-- "Visualizar"
				{ STR0004, "TMSA146Mnt"           , 0, 3, 0 },; //-- "Incluir"
				{ STR0005, "TMSA146ALT" 	      , 0, 4, 0 },; //-- "Alterar"
				{ STR0006, "VIEWDEF.TMSA146"      , 0, 5, 0 },; //-- "Excluir"
				{ STR0007, aEfetivar              , 0, 6, 0 },; //-- "Efetivar"
				{ STR0008, "TMSA146CTe"           , 0, 8, 0 }} //-- "Monitor CTe"

If IsInCallStack("TMSAF76") //Painel de Agendamento
	AAdd( aRotina, {STR0009,"TMSA146Leg('P')", 0, 9,0,Nil } ) //"Legenda"
EndIf
	
If lIntTPR
	AAdd( aRotina, {STR0250,aTPRMenu, 0, 9,0,Nil } ) //"Planejamento Rotas (TPR)
EndIf

If FindFunction("T146AltVei")
	AAdd( aRotina, {STR0254,"T146AltVei" , 0, 9,0,Nil } ) 
EndIf
						 
Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA146Mod
Retorna a Estrutura do modelo de dados (ModelDef ou ViewDef)
@author Katia
@since 31/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMSA146Mod(nType, oStruDA3, oStruDA8, oStruDA6, oStruDA5, oStruDF8)

Default nType    := 1
Default oStruDA3 := Nil
Default oStruDA8 := Nil
Default oStruDA6 := Nil
Default oStruDA5 := Nil
Default oStruDF8 := Nil
                      
If nType == 1
	//------ Ord. Tipo Desc.
	// [01]  C   Titulo do campo
	// [02]  C   ToolTip do campo
	// [03]  C   Id do Field
	// [04]  C   Tipo do campo
	// [05]  N   Tamanho do campo
	// [06]  N   Decimal do campo
	// [07]  B   Code-block de validação do campo
	// [08]  B   Code-block de validação When do campo
	// [09]  A   Lista de valores permitido do campo
	// [10]  L   Indica se o campo tem preenchimento obrigatório
	// [11]  B   Code-block de inicializacao do campo
	// [12]  L   Indica se trata-se de um campo chave
	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	// [14]  L   Indica se o campo é virtual
	oStruDA3:AddField(STR0105  ,STR0105  , 'DA3_MARK'  , 'L'  , 1 , 0, {|| T146MrkVei() }   , , {}, .F., , .F., .F., .T.)
	oStruDA3:AddField(STR0099  ,STR0099  , 'DA3_BTCAR' , 'BT' , 1 , 0, {|| T146CarVei(.T.)} , , {},.F., , .F., .F., .T. )	
	oStruDA3:AddField(STR0100  ,STR0100  , 'DA3_BTDES' , 'BT' , 1 , 0, {|| T146CarVei(.F.)} , , {},.F., , .F., .F., .T. )
	oStruDA3:AddField(STR0102  ,STR0102  , 'DA3_DTPRCH', 'D'  , 8 , 0,                      , , {},.F., , .F., .F., .T. )   //Dt Previsao Chegada
	oStruDA3:AddField(STR0103  ,STR0103  , 'DA3_HRPRCH', 'C'  , 4 , 0,                      , , {},.F., , .F., .F., .T. )   //Hr Previsao Chegada
	
	oStruDA8:AddField(STR0088, STR0105, 'DA8_MARK'  , 'L'  , 1 , 0, {|| TM146Marca('R')}, {|| TM146ChkR()}, {}, .F., , .F., .F., .T.)

	oStruDA5:AddField(STR0088, STR0106, 'DA5_MARK'  , 'L'  , 1  , 0, {|| TM146Marca('Z')}, , {}, .F., , .F., .F., .T. )
	oStruDA5:AddField(STR0062, STR0062, 'DA5_CDROTA', 'C'  , TamSX3('DA8_COD')[1] , 0,                     , , {}, .F., , .F., .F., .T., , )

	oStruDA6:AddField(STR0088, STR0144, 'DA6_MARK'   , 'L'  , 1  , 0, {|| TM146Marca('S')}, , {}, .F., , .F., .F., .T. )
	oStruDA6:AddField(STR0062, STR0062, 'DA6_CDROTA' , 'C'  , TamSX3('DA8_COD')[1] , 0, , , {}, .F., , .F., .F., .T. )
	
	oStruDF8:AddField(STR0099 , STR0099, 'DF8_BTCAR'  , 'BT' , 1                      , 0, {|| T146CarPrg(.T.)} , , {}, .F., , .F., .F., .T. )
	oStruDF8:AddField(STR0100 , STR0100, 'DF8_BTDES'  , 'BT' , 1                      , 0, {|| T146CarPrg(.F.)} , , {}, .F., , .F., .F., .T. )
	oStruDF8:AddField(STR0003 , STR0003, 'DF8_BTVIS'  , 'BT' , 1                      , 0, {|| T146Visual()}    , , {}, .F., , .F., .F., .T. )
	oStruDF8:AddField(STR0091 , STR0091, 'DF8_NUMTMP' , 'C'  , TamSX3('DF8_NUMPRG')[1], 0, {|| TMSA146Vld('DF8_NUMTMP')}, , {}, .F., , .F., .F., .T. )
	oStruDF8:AddField(STR0110 , STR0110, 'DF8_CAPACM' , 'N'  , TamSX3('DA3_CAPACM')[1], 0, , , {}, .F., , .F., .F., .T. )	
	oStruDF8:AddField(STR0111 , STR0111, 'DF8_CAPACD' , 'N'  , TamSX3('DA3_CAPACM')[1], 0, , , {}, .F., , .F., .F., .T. )
	oStruDF8:AddField(STR0112 , STR0112, 'DF8_STAPRG' , 'BT' , 1                      , 0, {|| TMSA146Leg("P")}, , {}, .F.,  , .F., .F., .T. )		
	oStruDF8:AddField(STR0113 , STR0113, 'DF8_STAVEI' , 'BT'  , 1                      , 0, {|| TMSA146Leg("CV")}, , {}, .F.,  , .F., .F., .T. )	
	oStruDF8:AddField(STR0146 , STR0146, 'DF8_RESTRI' , 'BT'  , 1                      , 0, {|| TMSA146Leg("R")} , , {}, .F.,  , .F., .F., .T. )  //Restricao Veiculo 
	oStruDF8:AddField(STR0114 , STR0114, 'DF8_VGEINT' , 'L'   , 1                      , 0, , , {}, .F.,  , .F., .F., .T. )  //Viagem Coligada		
	oStruDF8:AddField(AllTrim(RetTitle('DA8_DESSVT')) , AllTrim(RetTitle('DA8_DESSVT')), 'DF8_DESSVT' , 'C'   , 15                     , 0, , , {}, .F.,  , .F., .F., .T. )
	
	oStruDF8:AddField(STR0202 , STR0202, 'DF8_QTDRAT' ,'N',8,0, NIL , NIL , NIL, .F., NIL, .F., .F., .T.)  		//--'Qt.Doc.Rat'
Else 
	//------ Ord. Tipo Desc.
	// [01] Campo
	// [02] Ordem
	// [03] Titulo
	// [04] Descricao
	// [05] Help
	// [06] Tipo do campo   COMBO, Get ou CHECK
	// [07] Picture
	// [08] PictVar
	// [09] F3
	// [10] Editavel
	// [11] Folder
	// [12] Group
	// [13] Lista Combo
	// [14] Tam Max Combo
	// [15] Inic. Browse
	// [16] Virtual

	oStruDA3:AddField( "DA3_MARK"  ,'01' , "M "     , STR0105 , NIL , 'L', '@BMP'     , NIL, NIL,.T., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruDA3:AddField( "DA3_BTCAR" ,'02' , "C "    , STR0099 , NIL , 'BT', '@BMP'     , NIL, NIL,.T. /*TM146Edit()*/, NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruDA3:AddField( "DA3_BTDES" ,'03' , "D "    , STR0100 , NIL , 'BT', '@BMP'     , NIL, NIL,.T. /*TM146Edit()*/, NIL, NIL, NIL,	NIL, NIL, .T. )	
	oStruDA3:AddField( "DA3_DTPRCH",'04' , STR0102 , STR0102 , NIL , 'G' , ''         , NIL, NIL,.F., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruDA3:AddField( "DA3_HRPRCH",'05' , STR0103 , STR0103 , NIL , 'G' , '@r 99:99' , NIL, NIL,.F., NIL, NIL, NIL,	NIL, NIL, .T. )            
						
	oStruDA8:AddField( "DA8_MARK"  ,'01' , STR0088, STR0105 , NIL , 'BT', '@BMP'    , NIL, NIL,.T., NIL, NIL, NIL,	NIL, NIL, .T. )
	
	oStruDA6:AddField( "DA6_MARK"  ,'01' , STR0088, STR0144 , NIL , 'L' , '@BMP'    , NIL, NIL,.T., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruDA6:AddField( "DA6_CDROTA",'01' , STR0062, STR0062 , NIL , 'G' , ''        , NIL, NIL,.F., NIL, NIL, NIL,	NIL, NIL, .T. )
	
	oStruDA5:AddField( "DA5_CDROTA" ,'01', STR0062, STR0062 , NIL , 'G' , ''        , NIL, NIL,.F., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruDA5:AddField( "DA5_MARK"  ,'02' , STR0088, STR0106 , NIL , 'L' , '@BMP'    , NIL, NIL,.T., NIL, NIL, NIL,	NIL, NIL, .T. )
		
	oStruDF8:AddField('DF8_BTCAR'  ,'70' ,'C '     , STR0099 , NIL , 'BT', '@BMP'    , NIL, NIL,.T. /*TM146Edit()*/, NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruDF8:AddField('DF8_BTDES'  ,'71' ,'D '     , STR0100 , NIL , 'BT', '@BMP'    , NIL, NIL,.T. /*TM146Edit()*/, NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruDF8:AddField('DF8_BTVIS'  ,'72' ,'V '     , STR0003 , NIL , 'BT', '@BMP'    , NIL, NIL,.T. /*TM146Edit()*/, NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruDF8:AddField('DF8_NUMTMP' ,'73' ,STR0091 , STR0091 , NIL , 'G' , ''        , NIL, NIL,.T., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruDF8:AddField('DF8_CAPACM' ,'77' ,STR0110 , STR0110 , NIL , 'G' , ''        , NIL, NIL,.F., NIL, NIL, NIL,	NIL, NIL, .T. )	
	oStruDF8:AddField('DF8_CAPACD' ,'78' ,STR0111 , STR0111 , NIL , 'G' , ''        , NIL, NIL,.F., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruDF8:AddField('DF8_STAPRG' ,'79' ,'P'     , STR0112 , NIL , 'BT', '@BMP'    , NIL, NIL,.T., NIL, NIL, NIL,	NIL, NIL, .T. )	
	oStruDF8:AddField('DF8_STAVEI' ,'80' ,'CV'    , STR0113 , NIL , 'BT', '@BMP'    , NIL, NIL,.T., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruDF8:AddField('DF8_RESTRI' ,'81' ,'R'     , STR0146 , NIL , 'BT', '@BMP'    , NIL, NIL,.T., NIL, NIL, NIL,	NIL, NIL, .T. )
	oStruDF8:AddField('DF8_VGEINT' ,'82' ,'VGI'   , STR0114 , NIL , 'L' , ''        , NIL, NIL,.F., NIL, NIL, NIL,	NIL, NIL, .T. )	
	oStruDF8:AddField('DF8_DESSVT' ,'83' ,AllTrim(RetTitle('DA8_DESSVT')) , AllTrim(RetTitle('DA8_DESSVT')) , NIL , 'C' , ''        , NIL, NIL,.F., NIL, NIL, NIL,	NIL, NIL, .T. )	

	oStruDF8:AddField('DF8_QTDRAT','84','Qt.Doc.Rat','Qt.Doc.Rat',, 'G' ,'99999999',,,.F.,,,,,,.T.,, )
EndIf	 

Return (oStruDA3, oStruDA8, oStruDA6, oStruDA5, oStruDF8)


//-------------------------------------------------------------------
//Retorna a ordem da exibicao dos campos na Grid
//@author Katia
//@since 31/07/2014
//@version 1.0
//-------------------------------------------------------------------
Static Function TMSA146Ord(oStruDTC, oStruDA3, oStruDF8, oStruDA5, oStruDA6, oStruDDZ)

Default oStruDTC:= Nil
Default oStruDA3:= Nil
Default oStruDF8:= Nil
Default oStruDA5:= Nil
Default oStruDA6:= Nil
Default oStruDDZ:= Nil

oStruDTC:SetProperty( 'T01_MARK'  , MVC_VIEW_ORDEM, '01')
oStruDTC:SetProperty( 'T01_LEGEN' , MVC_VIEW_ORDEM, '02')
oStruDTC:SetProperty( 'T01_LEGPAG', MVC_VIEW_ORDEM, '03')
oStruDTC:SetProperty( 'T01_LEGDOC', MVC_VIEW_ORDEM, '04')
oStruDTC:SetProperty( 'T01_FILDOC', MVC_VIEW_ORDEM, '05')
oStruDTC:SetProperty( 'T01_DOC',    MVC_VIEW_ORDEM, '06')
oStruDTC:SetProperty( 'T01_SERIE',  MVC_VIEW_ORDEM, '07')
oStruDTC:SetProperty( 'T01_NUMNFC', MVC_VIEW_ORDEM, '08')
oStruDTC:SetProperty( 'T01_SERNFC', MVC_VIEW_ORDEM, '09')
oStruDTC:SetProperty( 'T01_EMINFC', MVC_VIEW_ORDEM, '10')
oStruDTC:SetProperty( 'T01_FILCFS', MVC_VIEW_ORDEM, '11')
oStruDTC:SetProperty( 'T01_NUMSOL', MVC_VIEW_ORDEM, '12')
oStruDTC:SetProperty( 'T01_NUMPRG', MVC_VIEW_ORDEM, '13')
oStruDTC:SetProperty( 'T01_NUMTMP', MVC_VIEW_ORDEM, '14')
oStruDTC:SetProperty( 'T01_SEQPRG', MVC_VIEW_ORDEM, '15')
oStruDTC:SetProperty( 'T01_CODVEI', MVC_VIEW_ORDEM, '16')
	
oStruDTC:SetProperty( 'T01_CLIREM', MVC_VIEW_ORDEM, '17')
oStruDTC:SetProperty( 'T01_LOJREM', MVC_VIEW_ORDEM, '18')
oStruDTC:SetProperty( 'T01_NOMREM', MVC_VIEW_ORDEM, '19')
oStruDTC:SetProperty( 'T01_RECREM', MVC_VIEW_ORDEM, '20')
oStruDTC:SetProperty( 'T01_CLIDES', MVC_VIEW_ORDEM, '21')
oStruDTC:SetProperty( 'T01_LOJDES', MVC_VIEW_ORDEM, '22')
oStruDTC:SetProperty( 'T01_NOMDES', MVC_VIEW_ORDEM, '23')
oStruDTC:SetProperty( 'T01_RECDES', MVC_VIEW_ORDEM, '24')
oStruDTC:SetProperty( 'T01_SQEDES', MVC_VIEW_ORDEM, '25')
oStruDTC:SetProperty( 'T01_END'   , MVC_VIEW_ORDEM, '26')
oStruDTC:SetProperty( 'T01_MUN'   , MVC_VIEW_ORDEM, '27')
oStruDTC:SetProperty( 'T01_BAIRRO', MVC_VIEW_ORDEM, '28')
oStruDTC:SetProperty( 'T01_CEP'   , MVC_VIEW_ORDEM, '29')
oStruDTC:SetProperty( 'T01_EST'   , MVC_VIEW_ORDEM, '30')
oStruDTC:SetProperty( 'T01_CGC'   , MVC_VIEW_ORDEM, '31')
oStruDTC:SetProperty( 'T01_CLIDEV', MVC_VIEW_ORDEM, '32')
oStruDTC:SetProperty( 'T01_LOJDEV', MVC_VIEW_ORDEM, '33')
oStruDTC:SetProperty( 'T01_NOMDEV', MVC_VIEW_ORDEM, '34')
oStruDTC:SetProperty( 'T01_CDRORI', MVC_VIEW_ORDEM, '35')
oStruDTC:SetProperty( 'T01_CDRDES', MVC_VIEW_ORDEM, '36')
oStruDTC:SetProperty( 'T01_CDRCAL', MVC_VIEW_ORDEM, '37')
oStruDTC:SetProperty( 'T01_QTDVOL', MVC_VIEW_ORDEM, '38')
oStruDTC:SetProperty( 'T01_PESO'  , MVC_VIEW_ORDEM, '39')
oStruDTC:SetProperty( 'T01_PESOM3', MVC_VIEW_ORDEM, '40')
oStruDTC:SetProperty( 'T01_METRO3', MVC_VIEW_ORDEM, '41')
oStruDTC:SetProperty( 'T01_VALOR' , MVC_VIEW_ORDEM, '42')
oStruDTC:SetProperty( 'T01_VALFRE', MVC_VIEW_ORDEM, '43')
oStruDTC:SetProperty( 'T01_SERVIC', MVC_VIEW_ORDEM, '44')
oStruDTC:SetProperty( 'T01_DESSER', MVC_VIEW_ORDEM, '45')
oStruDTC:SetProperty( 'T01_DETPFR', MVC_VIEW_ORDEM, '46') 
oStruDTC:SetProperty( 'T01_PRVENT', MVC_VIEW_ORDEM, '47')
oStruDTC:SetProperty( 'T01_CODPRO', MVC_VIEW_ORDEM, '48')
oStruDTC:SetProperty( 'T01_CODEMB', MVC_VIEW_ORDEM, '49')
oStruDTC:SetProperty( 'T01_LOTNFC', MVC_VIEW_ORDEM, '50')
oStruDTC:SetProperty( 'T01_RATEIO', MVC_VIEW_ORDEM, '51')

oStruDA3:SetProperty('DA3_MARK'   , MVC_VIEW_ORDEM, '01')
oStruDA3:SetProperty('DA3_BTCAR'  , MVC_VIEW_ORDEM, '02')
oStruDA3:SetProperty('DA3_BTDES'  , MVC_VIEW_ORDEM, '03')
oStruDA3:SetProperty('DA3_STATUS' , MVC_VIEW_ORDEM, '04')
oStruDA3:SetProperty('DA3_COD'    , MVC_VIEW_ORDEM, '05')
oStruDA3:SetProperty('DA3_PLACA'  , MVC_VIEW_ORDEM, '06')
oStruDA3:SetProperty('DA3_DESC'   , MVC_VIEW_ORDEM, '07')
oStruDA3:SetProperty('DA3_FROVEI' , MVC_VIEW_ORDEM, '08')
oStruDA3:SetProperty('DA3_DESTIP' , MVC_VIEW_ORDEM, '09')
oStruDA3:SetProperty('DA3_CAPACM' , MVC_VIEW_ORDEM, '10')
oStruDA3:SetProperty('DA3_CAPACN' , MVC_VIEW_ORDEM, '11')
oStruDA3:SetProperty('DA3_FILATU' , MVC_VIEW_ORDEM, '12')
oStruDA3:SetProperty('DA3_FILBAS' , MVC_VIEW_ORDEM, '13')
oStruDA3:SetProperty('DA3_VEIRAS' , MVC_VIEW_ORDEM, '14')
oStruDA3:SetProperty('DA3_DTPRCH' , MVC_VIEW_ORDEM, '15')
oStruDA3:SetProperty('DA3_HRPRCH' , MVC_VIEW_ORDEM, '16')
oStruDA3:SetProperty('DA3_SERTMS' , MVC_VIEW_ORDEM, '17')
oStruDA3:SetProperty('DA3_DESSVT' , MVC_VIEW_ORDEM, '18')
If lIntTPR .And. DA3->(ColumnPos("DA3_VELOC")) > 0
	oStruDA3:SetProperty('DA3_VELOC'  , MVC_VIEW_ORDEM, '19')
EndIf

oStruDF8:SetProperty('DF8_BTCAR'  , MVC_VIEW_ORDEM, '01')
oStruDF8:SetProperty('DF8_BTDES'  , MVC_VIEW_ORDEM, '02')
oStruDF8:SetProperty('DF8_BTVIS'  , MVC_VIEW_ORDEM, '03')
oStruDF8:SetProperty('DF8_STAPRG' , MVC_VIEW_ORDEM, '04')
oStruDF8:SetProperty('DF8_STAVEI' , MVC_VIEW_ORDEM, '05')
oStruDF8:SetProperty('DF8_RESTRI' , MVC_VIEW_ORDEM, '06')
oStruDF8:SetProperty('DF8_FILORI' , MVC_VIEW_ORDEM, '08')
oStruDF8:SetProperty('DF8_NUMTMP' , MVC_VIEW_ORDEM, '09')
oStruDF8:SetProperty('DF8_NUMPRG' , MVC_VIEW_ORDEM, '10')
oStruDF8:SetProperty('DF8_SEQPRG' , MVC_VIEW_ORDEM, '11')

oStruDF8:SetProperty('DF8_ROTA'   , MVC_VIEW_ORDEM, '12')

oStruDF8:SetProperty('DF8_DESSVT' , MVC_VIEW_ORDEM, '13')
oStruDF8:SetProperty('DF8_SERTMS' , MVC_VIEW_ORDEM, '14')
oStruDF8:SetProperty('DF8_TIPTRA' , MVC_VIEW_ORDEM, '15')
oStruDF8:SetProperty('DF8_DATGER' , MVC_VIEW_ORDEM, '16')
oStruDF8:SetProperty('DF8_HORGER' , MVC_VIEW_ORDEM, '17')
oStruDF8:SetProperty('DF8_VIAGEM' , MVC_VIEW_ORDEM, '18')
oStruDF8:SetProperty('DF8_CAPACM' , MVC_VIEW_ORDEM, '22')
oStruDF8:SetProperty('DF8_CAPACD' , MVC_VIEW_ORDEM, '23')
oStruDF8:SetProperty('DF8_FILVGE' , MVC_VIEW_ORDEM, '24')
oStruDF8:SetProperty('DF8_NUMVGE' , MVC_VIEW_ORDEM, '25')
oStruDF8:SetProperty('DF8_QTDVOL' , MVC_VIEW_ORDEM, '26')
oStruDF8:SetProperty('DF8_QTDDOC' , MVC_VIEW_ORDEM, '27')
oStruDF8:SetProperty('DF8_PESO'   , MVC_VIEW_ORDEM, '28')
oStruDF8:SetProperty('DF8_PESOM3' , MVC_VIEW_ORDEM, '30')
oStruDF8:SetProperty('DF8_VALOR'  , MVC_VIEW_ORDEM, '31')
oStruDF8:SetProperty('DF8_CODCAV' , MVC_VIEW_ORDEM, '32')
oStruDF8:SetProperty('DF8_MODCAV' , MVC_VIEW_ORDEM, '33')
oStruDF8:SetProperty('DF8_QTDCOL' , MVC_VIEW_ORDEM, '34')
oStruDF8:SetProperty('DF8_VOLCOL' , MVC_VIEW_ORDEM, '35')
oStruDF8:SetProperty('DF8_PESCOL' , MVC_VIEW_ORDEM, '36')
oStruDF8:SetProperty('DF8_PM3COL' , MVC_VIEW_ORDEM, '37')
oStruDF8:SetProperty('DF8_VLMCOL' , MVC_VIEW_ORDEM, '38')
oStruDF8:SetProperty('DF8_VLFCOL' , MVC_VIEW_ORDEM, '39')
oStruDF8:SetProperty('DF8_QTDENT' , MVC_VIEW_ORDEM, '40')
oStruDF8:SetProperty('DF8_VOLENT' , MVC_VIEW_ORDEM, '41')
oStruDF8:SetProperty('DF8_PESENT' , MVC_VIEW_ORDEM, '42')
oStruDF8:SetProperty('DF8_PM3ENT' , MVC_VIEW_ORDEM, '43')
oStruDF8:SetProperty('DF8_VLMENT' , MVC_VIEW_ORDEM, '44')
oStruDF8:SetProperty('DF8_VLFENT' , MVC_VIEW_ORDEM, '45')
oStruDF8:SetProperty('DF8_QTDTRA' , MVC_VIEW_ORDEM, '46')
oStruDF8:SetProperty('DF8_VOLTRA' , MVC_VIEW_ORDEM, '47')
oStruDF8:SetProperty('DF8_PESTRA' , MVC_VIEW_ORDEM, '48')
oStruDF8:SetProperty('DF8_PM3TRA' , MVC_VIEW_ORDEM, '49')
oStruDF8:SetProperty('DF8_VLMTRA' , MVC_VIEW_ORDEM, '50')
oStruDF8:SetProperty('DF8_VLFTRA' , MVC_VIEW_ORDEM, '51')
If DF8->(ColumnPos("DF8_DATINI")) .AND. AliasInDic('DL9')
	oStruDF8:SetProperty('DF8_DATINI' , MVC_VIEW_ORDEM, '52')
	oStruDF8:SetProperty('DF8_HORINI' , MVC_VIEW_ORDEM, '53')
	oStruDF8:SetProperty('DF8_DATFIM' , MVC_VIEW_ORDEM, '54')
	oStruDF8:SetProperty('DF8_HORFIM' , MVC_VIEW_ORDEM, '55')
EndIf

oStruDA5:SetProperty( 'DA5_MARK'  , MVC_VIEW_ORDEM, '01')
oStruDA5:SetProperty( 'DA5_COD'   , MVC_VIEW_ORDEM, '02')
oStruDA5:SetProperty( 'DA5_DESC'  , MVC_VIEW_ORDEM, '03')
oStruDA5:SetProperty( 'DA5_CDROTA', MVC_VIEW_ORDEM, '04')
    
oStruDA6:SetProperty( 'DA6_MARK'   , MVC_VIEW_ORDEM, '01')
oStruDA6:SetProperty( 'DA6_ROTA'   , MVC_VIEW_ORDEM, '02')
oStruDA6:SetProperty( 'DA6_REF'    , MVC_VIEW_ORDEM, '03')
oStruDA6:SetProperty( 'DA6_CDROTA' , MVC_VIEW_ORDEM, '04')

oStruDDZ:SetProperty( 'DDZ_CODVEI' , MVC_VIEW_ORDEM, '01')
oStruDDZ:SetProperty( 'DDZ_MODVEI' , MVC_VIEW_ORDEM, '02')
oStruDDZ:SetProperty( 'DDZ_PLACA'  , MVC_VIEW_ORDEM, '03')
oStruDDZ:SetProperty( 'DDZ_DESTIP' , MVC_VIEW_ORDEM, '04')
oStruDDZ:SetProperty( 'DDZ_CAPACM'  , MVC_VIEW_ORDEM, '05')
oStruDDZ:SetProperty( 'DDZ_CODRB1'  , MVC_VIEW_ORDEM, '06')
oStruDDZ:SetProperty( 'DDZ_MODRB1'  , MVC_VIEW_ORDEM, '07')
oStruDDZ:SetProperty( 'DDZ_CAPRB1'  , MVC_VIEW_ORDEM, '08')
oStruDDZ:SetProperty( 'DDZ_CODRB2'  , MVC_VIEW_ORDEM, '09')
oStruDDZ:SetProperty( 'DDZ_MODRB2'   , MVC_VIEW_ORDEM, '10')
oStruDDZ:SetProperty( 'DDZ_CAPRB2'   , MVC_VIEW_ORDEM, '11')
oStruDDZ:SetProperty( 'DDZ_FILORI'   , MVC_VIEW_ORDEM, '12')
oStruDDZ:SetProperty( 'DDZ_NUMPRG'   , MVC_VIEW_ORDEM, '13')
oStruDDZ:SetProperty( 'DDZ_SEQPRG'   , MVC_VIEW_ORDEM, '14')
oStruDDZ:SetProperty( 'DDZ_VIAGEM'   , MVC_VIEW_ORDEM, '15')
                                                         
Return(oStruDTC,oStruDA3,oStruDF8,oStruDA5,oStruDA6)

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA146MNT
Manutencao da Programacao de Carregamento
@author Katia
@since 11/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMSA146MNT( cAliasTab, nReg, nOpcx)

Local oModel    := Nil	

Default cAliasTab	:= ""
Default nReg 		:= 0

If !Empty(cAliasTab) .AND. !Empty(nReg)
	(cAliasTab)->(dbGoto(nReg))
EndIf

aDadosZona	:= {}
aDadosSetor	:= {}
aRotas		:= {}
aRegDF8		:= {}
aRegVgeInt	:= {}
cNumTmp		:= ''
cSeqPrg		:= ''
cSeqEnt		:= ''
nCarretas	:= 0
lAlteraTPR  := .F.

If Pergunte('TMSA146',.T.)
	dDtPrvIni := DtoS(mv_par01)
	dDtPrvFim := DtoS(mv_par02)
	dDtEmiIni := DtoS(mv_par03)
	dDtEmiFim := DtoS(mv_par04)
	cTpTransp := mv_par28
	
	If lRestricao
		lPesqRes:= If( mv_par32 == 1, .T., .F. )
	EndIf
	
	If IsInCallStack("TMSAF76")
		// Verifica Serviço adicional
		A146SrAdPn()
	EndIf
	// Executa a View para o Carregamento
	//        ([cTitulo],<cPrograma >, [ nOperation ], [ oDlg ], [ bCloseOnOK ], [ bOk ], [ nPercReducao ], [ aEnableButtons ], [ bCancel ], [ cOperatId ], [ cToolBar ], [ oModelAct ])-> nValor
	FWExecView( STR0001, 'TMSA146', MODEL_OPERATION_UPDATE, , { || .T. }, { || .T.  }, , , { |oModel| EVCancel(oModel) } )  //Programacao de Carregamento
EndIf  

Return 

/*/{Protheus.doc} EVCancel
	(Disparado ao clicar no botão fechar/cancelar da ExecView. Faz o destravamento dos registros marcados com lockbyname)
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return .T.
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function  EVCancel(oModel)
Local oCMdlDoc  := oModel:GetModel("MdGridDoc")
Local i        	:= 1
Local cLockByDoc:= ""
		For i:= 1 To oCMdlDoc:getQtdLine()
			oCMdlDoc:GoLine(i)
			cLockByDoc := "PRGCARR" + oCMdlDoc:GetValue("T01_FILDOC") + oCMdlDoc:GetValue("T01_DOC") + oCMdlDoc:GetValue("T01_SERIE")
			UnLockByName(cLockByDoc,.T.,.F.)
		Next i
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA146ALT
Manutencao da Programacao de Carregamento
@author Paulo Henrique	
@since 23/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMSA146ALT( cAliasTab, nReg, nOpcx)
Local lRet   := .T.

Default cAliasTab	:= ""
Default nReg 		:= 0

If !Empty(cAliasTab) .AND. !Empty(nReg)
	(cAliasTab)->(dbGoto(nReg))
EndIf

aDadosZona := {}
aDadosSetor:= {}
aRotas     := {}

cNumTmp    := '' 
cSeqPrg    := ''
cSeqEnt    := ''   
aRegDF8    := {}
aRegVgeInt := {}
lAlteraTPR := .F.

If lIntTPR
	//--- Verifica se existem Doctos da Programação pendente para Roteirização
	cIdRot:= T146VldTPR('DF8',DF8->DF8_FILORI,DF8->DF8_NUMPRG,DF8->DF8_SEQPRG,"1")  //1-Pendente,2-Rejeitado,3-Processado
	If !Empty(cIdRot)
		Help('',1,'TMSA14651',, STR0248 + ' ' + cIdRot,5,11) //Não é permitido a alteração da Programação de Carregamento com Roteirização (TPR) pendente.
		lRet:= .F.
	EndIf
EndIf

If lRet .And. Pergunte('TMSA146',.T.)
	dDtPrvIni:= DtoS(mv_par01)
	dDtPrvFim:= DtoS(mv_par02)
	dDtEmiIni:= DtoS(mv_par03)
	dDtEmiFim:= DtoS(mv_par04)
	cTpTransp:= mv_par28
	
	If lRestricao
		lPesqRes:= Iif(mv_par32 == 1, .T., .F.)
	EndIf	 
  	// Executa a View para o Carregamento	 
	FWExecView(STR0001,'TMSA146',MODEL_OPERATION_UPDATE,, { || .T. },{ || .T.  },,,{ |oModel| EVCancel(oModel) })  //Programacao de Carregamento
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} TM146LdDoc
Relacao dos Documentos - Query dos Documentos DT6 e DTC
@author Katia
@since 11/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TM146LdDoc(oMdlDTC,cRota,aZonas,aSetores)
Local aLoad:= {}
	FWMsgRun(,{|| aLoad := StsRunDoc(oMdlDTC,cRota,aZonas,aSetores)})
Return aLoad

Static Function StsRunDoc(oMdlDTC,cRota,aZonas,aSetores)

Local oStructDTC := oMdlDTC:GetStruct()
Local aCamposDTC := aClone(oStructDTC:GetFields())
Local AareaAtu   := GetArea()
Local aLoadDTC   := {}
Local nLinha     := 0
Local nX         := 0
Local nY         := 0
Local aEndereco  := {}
Local cAliasQry := ''
Local cAliasPri := GetNextAlias()
Local cQuery    := ''
Local nI        := 0
Local aRetPrior := {}
Local cCorPri   := ''
Local lAaddDocs := .T. 
Local lAgdEntr  := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)  //-- Agendamento de Entrega.
Local cQuery1	  := ''
Local cDesSvt   := ""
Local lNotas    := mv_par21 == 1
Local lDoctos   := mv_par21 == 2  //e ou Coleta
Local lTodos    := mv_par21 == 3
Local aFilDest  := Iif(!Empty(mv_par20),Str2Arr(Upper(mv_par20), ";"),{})
Local cFilDest  := ""
Local cFilDe    := ""
Local cFilAte   := ""       
Local nOperation:= oMdlDTC:GetOperation()
Local aRetPrd   := RetSx3Box( Posicione('SX3', 2, 'DYD_PRDAGD', 'X3CBox()' ),,, Len(DYD->DYD_PRDAGD))
Local aRetTipo  := RetSx3Box( Posicione('SX3', 2, 'DYD_TIPAGD', 'X3CBox()' ),,, Len(DYD->DYD_TIPAGD))
Local aRetCor   := RetSx3Box( Posicione('SX3', 2, 'DYK_CORPRI', 'X3CBox()' ),,, Len(DYK->DYK_CORPRI))
Local aCliLoj   := {}
Local lRestri   := .F.
Local nLoad     := 1
Local cAliasTb  := ""
Local lServEnt  := DT5->(ColumnPos("DT5_SRVENT")) > 0
Local lTelMark  := IsInCallStack("A146SrAdPn")
Local cTpFrete  := ""
Local cSeqTPR   := ""

Private cVSerTms  := ""
Private INCLUI    := .F.   //Nao retirar MVC

Default cRota   := ""
Default aZonas  := {}
Default aSetores:= {}

If Len(aFilDest) > 0
	nPos:= At("-",aFilDest[1])
	If nPos > 0
		cFilDe := SubStr(aFilDest[1],1,(nPos-1))
		cFilAte:= SubStr(aFilDest[1],nPos+1)			   			
	Else
		For nX := 1 To Len(aFilDest)
		    If At("'", aFilDest[nx]) == 0
			    aFilDest[nx] := "'" + AllTrim(aFilDest[nx]) + "'"
			EndIf
			cFilDest+=  aFilDest[nx] + Iif(nX == Len(aFilDest),"", ",")
		Next nX
	EndIf	
Else
	cFilDe	:= Space(Len(DTC->DTC_FILIAL))
	cFilAte := Replicate('Z',Len(DTC->DTC_FILIAL))
EndIf	

If lAgdEntr
	cQuery1 := " SELECT DYK_CODPRI, "
	cQuery1 += "        DYK_TIPPRI, "
	cQuery1 += "        DYK_DEPRI,  "
	cQuery1 += "        DYK_ATEPRI, "
	cQuery1 += "        DYK_CORPRI "
	
	cQuery1 += " FROM " +  RetSqlName("DYK") + " DYK "
	cQuery1 += " WHERE DYK_FILIAL  = '"+xFilial('DYK')+"'"
	cQuery1 += "   	   AND DYK_CODPRI >= '" + mv_par24 + "'"
	cQuery1 += "   	   AND DYK_CODPRI <= '" + mv_par25 + "'"
	cQuery1 += "       AND D_E_L_E_T_  = ' '"
	
	cQuery1 += "    ORDER BY DYK_TIPPRI,    "
	cQuery1 += "       		 DYK_DEPRI,     "
	cQuery1 += "       		 DYK_ATEPRI DESC"
	
	If !cDbType $ "MSSQL|MSSQL7|ORACLE"
		cQuery1 := ChangeQuery(cQuery1)
	EndIf	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery1),cAliasPri,.T.,.T.)
	While (cAliasPri)->(!Eof())
		AAdd(aRetPrior,Array(PE_QTDCOL))

		nI := Len(aRetPrior)
		aRetPrior[nI,PE_CODPRI] := (cAliasPri)->DYK_CODPRI
		aRetPrior[nI,PE_TIPPRI] := (cAliasPri)->DYK_TIPPRI
		aRetPrior[nI,PE_DEPRI ] := (cAliasPri)->DYK_DEPRI
		aRetPrior[nI,PE_ATEPRI] := (cAliasPri)->DYK_ATEPRI
		aRetPrior[nI,PE_CORPRI] := (cAliasPri)->DYK_CORPRI
		(cAliasPri)->(dbSkip())
	EndDo
	(cAliasPri)->(dbCloseArea())
EndIf
nRegPrior:= Len(aRetPrior)

cQuery := ""	

// Limpa aLoadTot
aLoadTot := {}

//--- Quando a opção Alteração é necessário executar query distintas, pois é necessario exibir os dados
//--- da programacao alterada mais os documentos em aberto.
//--- Foi necessario quebrar as querys devido ao erro do tamanho da query.
For nLoad:= 1 To 2
	cQuery := ""	
	cAliasQry := GetNextAlias()
	If nOperation == 4 .And. !IsInCallStack('TMSA146MNT') .And. !lIncAuto .And. nLoad == 1
		cQuery:= T146QryVis(lAgdEntr)
	
	ElseIf nOperation == 1 .Or. nOperation == 5 //Visualizar,Excluir
  		cQuery:= T146QryVis(lAgdEntr)                                                          
  		
	Else
		cQuery := "SELECT * FROM ("	
	     		                                                      
		If lTodos .Or. lNotas
			cQuery += " SELECT DISTINCT DTC.DTC_FILIAL T01_FILIAL, DTC.DTC_FILDOC T01_FILDOC, DTC.DTC_DOC    T01_DOC   , DTC.DTC_SERIE  T01_SERIE , DTC.DTC_NUMNFC T01_NUMNFC, DTC.DTC_SERNFC T01_SERNFC, "
			cQuery += "        DTC.DTC_EMINFC T01_EMINFC, DTC.DTC_FILCFS T01_FILCFS, DTC.DTC_NUMSOL T01_NUMSOL, DTC.DTC_CLIREM T01_CLIREM, DTC.DTC_LOJREM T01_LOJREM, REM.A1_NREDUZ  T01_NOMREM, " 
			cQuery += "        DTC.DTC_CLIDES T01_CLIDES, DTC.DTC_LOJDES T01_LOJDES, DES.A1_NREDUZ  T01_NOMDES, DTC_SQEDES     T01_SQEDES,  " 
			cQuery += "        CASE WHEN DTC_SQEDES = ' ' THEN DES.A1_END     WHEN DUL_CODRED = ' ' THEN DUL_END    ELSE RED.A1_END    END AS T01_END, "         
			cQuery += "        CASE WHEN DTC_SQEDES = ' ' THEN DES.A1_EST     WHEN DUL_CODRED = ' ' THEN DUL_EST    ELSE RED.A1_EST    END AS T01_EST, " 
			cQuery += "        CASE WHEN DTC_SQEDES = ' ' THEN DES.A1_MUN     WHEN DUL_CODRED = ' ' THEN DUL_MUN    ELSE RED.A1_MUN    END AS T01_MUN, " 
			cQuery += "        CASE WHEN DTC_SQEDES = ' ' THEN DES.A1_BAIRRO  WHEN DUL_CODRED = ' ' THEN DUL_BAIRRO ELSE RED.A1_BAIRRO END AS T01_BAIRRO, "
			cQuery += "        CASE WHEN DTC_SQEDES = ' ' THEN DES.A1_CEP     WHEN DUL_CODRED = ' ' THEN DUL_CEP    ELSE RED.A1_CEP    END AS T01_CEP, DES.A1_CGC     T01_CGC, "
			cQuery += "        DTC.DTC_QTDVOL T01_QTDVOL, DTC.DTC_PESO   T01_PESO  , DTC.DTC_PESOM3 T01_PESOM3, DTC.DTC_METRO3 T01_METRO3, "
			cQuery += "        DTC.DTC_VALOR  T01_VALOR , 0              T01_VALFRE, DTC.DTC_CDRORI T01_CDRORI, DTC.DTC_CDRDES T01_CDRDES,  "
			cQuery += "        DTC.DTC_CDRCAL T01_CDRCAL, DTC.DTC_PRVENT T01_PRVENT,  "
			cQuery += "        DTC.DTC_CODPRO T01_CODPRO, DTC.DTC_CODEMB T01_CODEMB, DTC.DTC_CLIDEV T01_CLIDEV, DTC.DTC_LOJDEV T01_LOJDEV, DTC.DTC_CLICAL T01_CLICAL, DTC.DTC_LOJCAL T01_LOJCAL, DEV.A1_NREDUZ T01_NOMDEV, "
			cQuery += "        DTC.DTC_LOTNFC T01_LOTNFC, DTP.DTP_RATEIO T01_RATEIO, DTP.DTP_CRIRAT T01_CRIRAT, DTC.DTC_TIPFRE T01_TIPFRE, DTC.DTC_SERTMS T01_SERTMS, DTC.DTC_TIPTRA T01_TIPTRA, "
			cQuery += "        DTC.DTC_SERVIC T01_SERVIC, DTC.DTC_FILORI T01_FILORI, ''             T01_CHVCTE, DTC.DTC_NFEID T01_NFEID, ''  T01_BLQDOC, '' T01_FILDES, "
			cQuery += "        ' '            T01_NUMPRG, ' '            T01_SEQPRG, ' '            T01_CODVEI, ' ' T01_SEQENT, ' ' T01_STATUS, X5_DESCRI T01_DESSER, 'N' T01_RECREM,  'N' T01_RECDES, " 
			cQuery += "        ' '            T01_CDROTA, ' ' T01_NUMTMP"
			
			If IsInCallStack("TMSAF76")
				cQuery += "		  ,CASE WHEN DF1.DF1_MRKPAN = '"+ cNumThread +"' THEN '.T.'  ELSE '.F.' END   T01_MARK"
			ElseIf lIncAuto
				cQuery += "		  ,'.T.' T01_MARK "
			Else		
		    	cQuery += "		  ,'.F.' T01_MARK "
			EndIf
			
			cQuery += ", 'PMSEDT3' T01_LEGPAG, " 
			
			If lAgdEntr 
				If Len(aRetPrd)> 0 //.And. cSerTMS == "3"
					cQuery += "     DYD.DYD_NUMAGD T01_NUMAGD, DYD.DYD_DATAGD T01_DATAGD, DYD.DYD_PRDAGD T01_PRDAGD, DYD.DYD_INIAGD T01_INIAGD, "
					cQuery += "     DYD.DYD_FIMAGD T01_FIMAGD, DYD.DYD_TIPAGD T01_TIPAGD, "
					cQuery += "     CASE WHEN DYD.DYD_PRDAGD = '1'  THEN  '" + aRetPrd[1][3] + "' "
					cQuery += "          WHEN DYD.DYD_PRDAGD = '2'  THEN  '" + aRetPrd[2][3] + "' " 
					cQuery += "          WHEN DYD.DYD_PRDAGD = '3'  THEN  '" + aRetPrd[3][3] + "' "   
					cQuery += "          WHEN DYD.DYD_PRDAGD = '4'  THEN  '" + aRetPrd[4][3] + "' "
					cQuery += "          ELSE ' ' END AS T01_DETPAG, "
				EndIf
				
				If Len(aRetTipo)> 0 	
					cQuery += "     CASE WHEN DYD.DYD_TIPAGD = '0'  THEN  '" + aRetTipo[1][3] + "' "
					cQuery += "          WHEN DYD.DYD_TIPAGD = '1'  THEN  '" + aRetTipo[2][3] + "' " 
					cQuery += "          WHEN DYD.DYD_TIPAGD = '2'  THEN  '" + aRetTipo[3][3] + "' "   
					cQuery += "          WHEN DYD.DYD_TIPAGD = '3'  THEN  '" + aRetTipo[4][3] + "' "
					cQuery += "          WHEN DYD.DYD_TIPAGD = '4'  THEN  '" + aRetTipo[5][3] + "' "
					cQuery += "          ELSE ' ' END AS T01_DEPRAG "
				EndIf	
			Else
				cQuery += "     ''             T01_NUMAGD, ''             T01_DATAGD, ''             T01_PRDAGD, ''             T01_INIAGD, "
				cQuery += "     ''             T01_FIMAGD, ''             T01_TIPAGD, '' T01_DETPAG, ' ' T01_DEPRAG "
			EndIf
				
			cQuery += " FROM  "
			cQuery += RetSqlName("DTC") + " DTC "
			
			//--- CLAUSULA WHERE DO DTC
			cQuery += T146SelDTC('D',cFilDest,cFilDe,cFilAte)		
		EndIf
		
		If lTodos
			cQuery += "  UNION ALL "
		EndIf
	
		If lTodos .Or. lDoctos  
			cQuery += " SELECT DISTINCT DT6.DT6_FILIAL T01_FILIAL, DT6.DT6_FILDOC T01_FILDOC, DT6.DT6_DOC    T01_DOC   , DT6.DT6_SERIE  T01_SERIE , ''             T01_NUMNFC, ''             T01_SERNFC, "
			cQuery += "        DT6.DT6_DATEMI T01_EMINFC, ''             T01_FILCFS, ''             T01_NUMSOL, "
			cQuery += "			CASE    "
			cQuery += "				WHEN DT6.DT6_SERIE = 'COL'    "
			cQuery += "					THEN     "
			cQuery += "						CASE      "
			cQuery += "							WHEN DT6.DT6_CLIREM <> ' '      "
			cQuery += "								THEN DT6.DT6_CLIREM    "
			cQuery += "							ELSE DUE.DUE_CODCLI    "
			cQuery += "						END     "
			cQuery += "				WHEN  DT6.DT6_SERIE <> 'COL'    "
			cQuery += "					THEN DT6.DT6_CLIREM    "
			cQuery += "			END AS T01_CLIREM,    "
		
			cQuery += "          CASE    "
			cQuery += "          	WHEN DT6.DT6_SERIE = 'COL'    "
			cQuery += "          		THEN     "
			cQuery += "          			CASE      "
			cQuery += "          				WHEN DT6.DT6_LOJREM <> ' '     " 
			cQuery += "          					THEN DT6.DT6_LOJREM    "
			cQuery += "          				ELSE DUE.DUE_LOJCLI    "
			cQuery += "          			END     "
			cQuery += "          	WHEN  DT6.DT6_SERIE <> 'COL'    "
			cQuery += "          		THEN DT6.DT6_LOJREM    "
			cQuery += "          END AS T01_LOJREM,    "
			
			cQuery += "        CASE WHEN DT6_SERIE = 'COL' AND DT6.DT6_CLIREM = ' '  THEN DUE_NOME ELSE  REM.A1_NREDUZ END T01_NOMREM, " 
			cQuery += "        DT6.DT6_CLIDES T01_CLIDES, DT6.DT6_LOJDES T01_LOJDES, DES.A1_NREDUZ  T01_NOMDES, ''             T01_SQEDES, DES.A1_END     T01_END   , DES.A1_EST     T01_EST,"
			cQuery += "        DES.A1_MUN     T01_MUN   , DES.A1_BAIRRO  T01_BAIRRO, DES.A1_CEP     T01_CEP   , DES.A1_CGC     T01_CGC, "
			cQuery += "        DT6.DT6_QTDVOL T01_QTDVOL, DT6.DT6_PESO   T01_PESO  , DT6.DT6_PESOM3 T01_PESOM3, DT6.DT6_METRO3 T01_METRO3, "
			cQuery += "        DT6.DT6_VALMER T01_VALOR , DT6.DT6_VALFRE T01_VALFRE, DT6.DT6_CDRORI T01_CDRORI, DT6.DT6_CDRDES T01_CDRDES,  "
			cQuery += "        DT6.DT6_CDRCAL T01_CDRCAL, DT6.DT6_PRZENT T01_PRVENT,  "
			cQuery += "        ''       T01_CODPRO, ''  T01_CODEMB, DT6.DT6_CLIDEV T01_CLIDEV, DT6.DT6_LOJDEV T01_LOJDEV, DT6.DT6_CLICAL T01_CLICAL, DT6.DT6_LOJCAL T01_LOJCAL, DEV.A1_NREDUZ  T01_NOMDEV, "
			cQuery += "        ''             T01_LOTNFC, '' T01_RATEIO,  '' T01_CRIRAT, DT6.DT6_TIPFRE T01_TIPFRE, "
			
			cQuery += "         CASE WHEN DUD.DUD_SERTMS  = '2'  AND DUD.DUD_FILDCA = '" + cFilAnt + "'  AND DT6.DT6_FILDES = '" + cFilAnt + "'  THEN  '3' "
			cQuery += "              ELSE DUD.DUD_SERTMS  END AS T01_SERTMS, "         	   
			cQuery += "         DT6.DT6_TIPTRA T01_TIPTRA, "
			
			cQuery += "        DT6.DT6_SERVIC T01_SERVIC, ''             T01_FILORI, DT6.DT6_CHVCTE T01_CHVCTE, ' ' T01_NFEID, DT6.DT6_BLQDOC T01_BLQDOC, DT6.DT6_FILDES T01_FILDES, " 
			cQuery += "        ' '            T01_NUMPRG, ' '            T01_SEQPRG, ' '            T01_CODVEI, ' ' T01_SEQENT, DT6.DT6_STATUS T01_STATUS, X5_DESCRI T01_DESSER, 'N' T01_RECREM,  'N' T01_RECDES,"
			cQuery += "        ' '            T01_CDROTA, ' ' T01_NUMTMP" 
			
			If IsInCallStack("TMSAF76")
				cQuery += "		  ,CASE WHEN DF1.DF1_MRKPAN = '"+ cNumThread +"' THEN '.T.'  ELSE '.F.' END   T01_MARK"
			ElseIf lIncAuto
				cQuery += "		  ,'.T.' T01_MARK "
			Else
		    	cQuery += "		  ,'.F.' T01_MARK "
			EndIf
			cQuery += ", 'PMSEDT3' T01_LEGPAG,"	
			If lAgdEntr  //.And. cSerTMS == "3"
				If Len(aRetPrd)> 0 //.And. cSerTMS == "3"
					cQuery += "     DYD.DYD_NUMAGD T01_NUMAGD, DYD.DYD_DATAGD T01_DATAGD, DYD.DYD_PRDAGD T01_PRDAGD, DYD.DYD_INIAGD T01_INIAGD, "
					cQuery += "     DYD.DYD_FIMAGD T01_FIMAGD, DYD.DYD_TIPAGD T01_TIPAGD, "
					cQuery += "     CASE WHEN DYD.DYD_PRDAGD = '1'  THEN  '" + aRetPrd[1][3] + "' "
					cQuery += "          WHEN DYD.DYD_PRDAGD = '2'  THEN  '" + aRetPrd[2][3] + "' " 
					cQuery += "          WHEN DYD.DYD_PRDAGD = '3'  THEN  '" + aRetPrd[3][3] + "' "   
					cQuery += "          WHEN DYD.DYD_PRDAGD = '4'  THEN  '" + aRetPrd[4][3] + "' "
					cQuery += "          ELSE ' ' END  T01_DETPAG, "
				EndIf
				
				If Len(aRetTipo)> 0 	
					cQuery += "     CASE WHEN DYD.DYD_TIPAGD = '0'  THEN  '" + aRetTipo[1][3] + "' "
					cQuery += "          WHEN DYD.DYD_TIPAGD = '1'  THEN  '" + aRetTipo[2][3] + "' " 
					cQuery += "          WHEN DYD.DYD_TIPAGD = '2'  THEN  '" + aRetTipo[3][3] + "' "   
					cQuery += "          WHEN DYD.DYD_TIPAGD = '3'  THEN  '" + aRetTipo[4][3] + "' "
					cQuery += "          WHEN DYD.DYD_TIPAGD = '4'  THEN  '" + aRetTipo[5][3] + "' "
					cQuery += "          ELSE ' ' END  T01_DEPRAG "
				EndIf	
			Else
				cQuery += "     ''             T01_NUMAGD, ''             T01_DATAGD, ''             T01_PRDAGD, ''             T01_INIAGD, "
				cQuery += "     ''             T01_FIMAGD, ''             T01_TIPAGD, '' T01_DETPAG, ' ' T01_DEPRAG  "
			EndIf
			cQuery += "  FROM  " 
			cQuery += RetSqlName("DUD") + " DUD "
			
			cQuery+= " LEFT JOIN " + RetSqlname('DT6') + " DT6 " 
			cQuery+= "   ON DT6_FILIAL = '" + xFilial('DT6') + "' "
			
			//--- CLAUSULA WHERE DO DT6
			cQuery += T146SelDT6( 'D', cFilDest, cFilDe, cFilAte )
			
		EndIf
		cQuery += " ) TABTMP "  //Tabela Temporaria
		//--- Criterio para selecao do Codigo do Cliente. Por considerar o codigo do cliente do Solicitante, foi necessario implementar esta regra.
		
		If mv_par11 == 1 //-- Cliente Remetente
			cQuery += "   WHERE  TABTMP.T01_CLIREM   >= '" +  Iif(!lTelMark, mv_par07 ,Replicate( "" ,TamSx3("DT6_CLIREM")[1] )) + "'"
			cQuery += "   AND  TABTMP.T01_LOJREM   >= '" +  Iif(!lTelMark, mv_par08 ,Replicate( "" ,TamSx3("DT6_LOJREM")[1] ))+ "'"
			cQuery += "   AND  TABTMP.T01_CLIREM   <= '" +  Iif(!lTelMark, mv_par09 ,Replicate( "Z" ,TamSx3("DT6_CLIREM")[1] ))+ "'"
			cQuery += "   AND  TABTMP.T01_LOJREM   <= '" +  Iif(!lTelMark, mv_par10 ,Replicate( "Z" ,TamSx3("DT6_LOJREM")[1] ))+ "'"
		ElseIf mv_par11 == 2 //-- Cliente Destinatário
			cQuery += "   WHERE  TABTMP.T01_CLIDES   >= '" + Iif(!lTelMark,mv_par07 ,Replicate( "" ,TamSx3("DT6_CLIDES")[1] ))+ "'"
			cQuery += "   AND  TABTMP.T01_LOJDES   >= '" + Iif(!lTelMark,mv_par08 ,Replicate( "" ,TamSx3("DT6_LOJDES")[1] ))+ "'"
			cQuery += "   AND  TABTMP.T01_CLIDES   <= '" + Iif(!lTelMark,mv_par09 ,Replicate( "Z" ,TamSx3("DT6_CLIDES")[1] ))+ "'"
			cQuery += "   AND  TABTMP.T01_LOJDES   <= '" + Iif(!lTelMark,mv_par10 ,Replicate( "Z" ,TamSx3("DT6_LOJDES")[1] ))+ "'"
		ElseIf mv_par11 == 3 //-- Cliente Devedor
			cQuery += "   WHERE  TABTMP.T01_CLIDEV   >= '" + Iif(!lTelMark,mv_par07 ,Replicate( "" ,TamSx3("DT6_CLIDEV")[1] ))+ "'"
			cQuery += "   AND  TABTMP.T01_LOJDEV   >= '" + Iif(!lTelMark,mv_par08 ,Replicate( "" ,TamSx3("DT6_LOJDEV")[1] ))+ "'"
			cQuery += "   AND  TABTMP.T01_CLIDEV   <= '" + Iif(!lTelMark,mv_par09 ,Replicate( "Z" ,TamSx3("DT6_CLIDEV")[1] ))+ "'"
			cQuery += "   AND  TABTMP.T01_LOJDEV   <= '" + Iif(!lTelMark,mv_par10 ,Replicate( "Z" ,TamSx3("DT6_LOJDEV")[1] ))+ "'"
		ElseIf mv_par11 == 4 //-- Cliente de Cálculo
			cQuery += "   WHERE  TABTMP.T01_CLICAL   >= '" + Iif(!lTelMark,mv_par07 ,Replicate( "" ,TamSx3("DT6_CLICAL")[1] ))+ "'"
			cQuery += "   AND  TABTMP.T01_LOJCAL   >= '" + Iif(!lTelMark,mv_par08 ,Replicate( "" ,TamSx3("DT6_LOJCAL")[1] ))+ "'"
			cQuery += "   AND  TABTMP.T01_CLICAL   <= '" + Iif(!lTelMark,mv_par09 ,Replicate( "Z" ,TamSx3("DT6_CLICAL")[1] ))+ "'"
			cQuery += "   AND  TABTMP.T01_LOJCAL   <= '" + Iif(!lTelMark,mv_par10 ,Replicate( "Z" ,TamSx3("DT6_LOJCAL")[1] ))+ "'"
		EndIf		
		
		cQuery += " ORDER BY T01_MARK DESC "
	
	EndIf
	
	If !cDbType $ "MSSQL|MSSQL7|ORACLE"
		cQuery := ChangeQuery( cQuery )
	EndIf	
	
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .T., .T. )
	TcSetField(cAliasQry,"T01_EMINFC","D",8,0) 
	TcSetField(cAliasQry,"T01_PRVENT","D",8,0) 
	TcSetField(cAliasQry,"T01_DATAGD","D",8,0)
	
	aItensPC := {}
	
	While (cAliasQry)->(!Eof())
			
		cVSerTms:= (cAliasQry)->T01_SERTMS
		cDesSvt:= TMSValField('cVSerTms',.F.)
		lAaddDocs:= .T.
		If lAgdEntr .And. (cAliasQry)->T01_SERTMS == "3" .And. !Empty((cAliasQry)->T01_TIPAGD)
			lAaddDocs := .F.
			If Val((cAliasQry)->T01_TIPAGD) >= MV_PAR22 .And. Val((cAliasQry)->T01_TIPAGD) <= MV_PAR23
	
				cCorPri := TMSA146PAE(aRetPrior,(cAliasQry)->T01_DATAGD)
				If !Empty(cCorPri)
					lAaddDocs := .T.
	   			EndIf
	   		EndIf	
		EndIf
		
		If lAaddDocs
			If lRot146Aut .And. lIncAuto .And. Len(aDoc146Aut) > 0 //Filtra os documentos enviados por rotina automatica
				lAaddDocs:= .F.
				nPos:= Ascan(aDoc146Aut, {|x| AllTrim(x[PRGFILDOC])+AllTrim(x[PRGDOC])+AllTrim(x[PRGSERIE])+AllTrim(x[PRGNUMNFC])+AllTrim(x[PRGSERNFC])+AllTrim(x[PRGFILORI])+AllTrim(x[PRGLOTNFC]) == ;
					   AllTrim((cAliasQry)->T01_FILDOC) + AllTrim((cAliasQry)->T01_DOC) + AllTrim((cAliasQry)->T01_SERIE) + AllTrim((cAliasQry)->T01_NUMNFC) + AllTrim((cAliasQry)->T01_SERNFC) + AllTrim((cAliasQry)->T01_FILORI) + AllTrim((cAliasQry)->T01_LOTNFC) } ) 

				If nPos > 0
					cCodCavAut  := aDoc146Aut[nPos][PRGCODCAV]
					aDoc146Aut[nPos][PRGMARK]:= .T.
					lAaddDocs:= .T.
					cSeqTPR  := aDoc146Aut[nPos][PRGSEQUEN]
				EndIf

			EndIf
		EndIf
		
		If lAaddDocs
			nLinha++
						
			//-- Busca a Sequencia de Endereco
			aEndereco:={}
			If (cAliasQry)->T01_SERIE == "COL" //!Empty((cAliasQry)->T01_SQEDES) .Or. (cAliasQry)->T01_SERIE == "COL"
				aEndereco:= TM146SeqEnd((cAliasQry)->T01_CLIREM,(cAliasQry)->T01_LOJREM,(cAliasQry)->T01_CLIDES,(cAliasQry)->T01_LOJDES,(cAliasQry)->T01_SQEDES,(cAliasQry)->T01_FILDOC,(cAliasQry)->T01_DOC,(cAliasQry)->T01_SERIE)
			EndIf	
			
			aAdd(aLoadDTC,{nLinha,Array(Len(aCamposDTC))})
			
			For nY := 1 To Len(aCamposDTC)
				If !aCamposDTC[nY][MODEL_FIELD_VIRTUAL]
					If aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "T01_DESSVT" 
						aLoadDTC[nLinha][2][nY]	:= cDesSvt											
					Else
						aLoadDTC[nLinha][2][nY]	:= (cAliasQry)->&(aCamposDTC[nY][MODEL_FIELD_IDFIELD])
					EndIf
					
					If Len(aEndereco)>0						
						If aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "T01_END" .And. Len(aEndereco)>0
							aLoadDTC[nLinha][2][nY]	:= aEndereco[1]
						ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "T01_EST" .And. Len(aEndereco)>0
							aLoadDTC[nLinha][2][nY]	:= aEndereco[2]
						ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "T01_MUN" .And. Len(aEndereco)>0
							aLoadDTC[nLinha][2][nY]	:= aEndereco[3]					
						ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "T01_BAIRRO" .And. Len(aEndereco)>0
							aLoadDTC[nLinha][2][nY]	:= aEndereco[4]
						ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "T01_CEP" .And. Len(aEndereco)>0
							aLoadDTC[nLinha][2][nY]	:= aEndereco[5]
						EndIf	
					EndIf		
					
					
					// Acerta o Serviço de Transporte para as coletas já efetuadas
					If aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "T01_SERTMS"
					   	If IsInCallStack("TMSAF76") 
					   	
							dbSelectArea("DT5")
							DT5->(dbSetOrder(1))					   	
					   		If DT5->( dbSeek(FwxFilial("DT5") + (cAliasQry)->T01_FILDOC + (cAliasQry)->T01_DOC ))
						     
						     	If DT5->DT5_STATUS $ "1|2" // Em Aberto ou Indicado para Coleta
						     	
						     		aLoadDTC[nLinha][2][nY]	:= (cAliasQry)->T01_SERTMS 
						     		
						      	ElseIf DT5->DT5_STATUS $ "4" // Encerrada
						      		
						      		If lServEnt .AND. !Empty(DT5->DT5_SRVENT)
						      			
						      			dbSelectArea("DC5")
						      			DC5->(dbSetOrder(1))
						      			DC5->( dbSeek(FwxFilial("DC5")+ DT5->DT5_SRVENT ) ) 
						      			aLoadDTC[nLinha][2][nY]	:= DC5->DC5_SERTMS
						      		Else
						      			aLoadDTC[nLinha][2][nY]	:= "3"
						      		EndIf
						      		
						      	EndIf
						      	
					      	EndIf
						EndIf
					     
					EndIf                             										
				Else    
					If aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "T01_MARK"
				       aLoadDTC[nLinha][2][nY]	:= &((cAliasQry)->T01_MARK )
				       If !Empty((cAliasQry)->T01_NUMPRG) .OR. &((cAliasQry)->T01_MARK )
				       	If  !Empty((cAliasQry)->T01_DOC )
								cAliasTb:= 'DT6' 
							Else
								cAliasTb:= 'DTC'
							EndIf
							
							aAdd(aLoadTot,{cAliasTb,(cAliasQry)->T01_SERTMS,(cAliasQry)->T01_QTDVOL,(cAliasQry)->T01_PESO,(cAliasQry)->T01_PESOM3,(cAliasQry)->T01_VALOR,;
								(cAliasQry)->T01_VALFRE, 1, Iif((cAliasQry)->T01_CRIRAT == 'A', 1, 0) } )							
				       EndIf
				                                          
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "T01_LEGPAG" .And. !Empty(cCorPri) 
						aLoadDTC[nLinha][2][nY]	:= Upper( "BR_" + StrTran(AllTrim(aRetCor[Ascan(aRetCor, {|x| AllTrim(x[2])==AllTrim(cCorPri)}), 3]),"Rosa","Pink"))

					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == ("T01_LEGEN")
						aLoadDTC[nLinha][2][nY]	:= TM146Cor('D',(cAliasQry)->T01_DOC,(cAliasQry)->T01_BLQDOC,,(cAliasQry)->T01_NUMPRG,,(cAliasQry)->T01_FILDOC,(cAliasQry)->T01_SERIE) 
					
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == ("T01_LEGDOC") 
						If !Empty((cAliasQry)->T01_DOC)
							aLoadDTC[nLinha][2][nY]	:= TM146Cor('DT6',(cAliasQry)->T01_DOC,(cAliasQry)->T01_BLQDOC,,(cAliasQry)->T01_NUMPRG,,(cAliasQry)->T01_FILDOC,(cAliasQry)->T01_SERIE,(cAliasQry)->T01_STATUS)
						Else
							aLoadDTC[nLinha][2][nY]	:= "BR_VERDE" //Em Aberto
						EndIf							
					ElseIf lRestri
						If aCamposDTC[nY][MODEL_FIELD_IDFIELD] == ("T01_RECREM")   //Retricao Cliente Remetente
							If (cAliasQry)->T01_SERIE <> 'COL'
								aAdd(aCliLoj,{ (cAliasQry)->T01_CLIREM, (cAliasQry)->T01_LOJREM })
							Else
								TMSA146Sol((cAliasQry)->T01_FILDOC,(cAliasQry)->T01_DOC,(cAliasQry)->T01_SERIE,,@aCliLoj)
							EndIf                            
							lRestri:= Iif(lPesqRes,TMSA146Res("C",aCliLoj),.F.)
								
							aLoadDTC[nLinha][2][nY]	:= Iif(lRestri,'S','N') 
							
						ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] $ ("T01_RECDES")   //Restricao Cliente Destinatario
							aCliLoj   := {}
							If (cAliasQry)->T01_SERIE <> 'COL'
								DUL->(dbSetOrder(2))
								If DUL->(DbSeek(xFilial('DUL')+(cAliasQry)->T01_CLIDES + (cAliasQry)->T01_LOJDES + (cAliasQry)->T01_SQEDES ))
									If !Empty(DUL->DUL_CODRED)
										aAdd(aCliLoj,{ DUL->DUL_CODRED, DUL->DUL_LOJRED })
									EndIf
								EndIf
							
								If Empty(aCliLoj)
									aAdd(aCliLoj,{ (cAliasQry)->T01_CLIDES, (cAliasQry)->T01_LOJDES })
								EndIf
									
								lRestri:= 	Iif(lPesqRes,TMSA146Res("C",aCliLoj),.F.)
								aLoadDTC[nLinha][2][nY]	:= Iif(lRestri,'S','N')
							Else
								aLoadDTC[nLinha][2][nY]	:= ''
							EndIf
						EndIf
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == ("T01_DETPFR")  //Tipo Frete
						If (cAliasQry)->T01_SERIE <> 'COL'
							aLoadDTC[nLinha][2][nY]:= Iif( (cAliasQry)->T01_TIPFRE == StrZero( 1, Len( DTC->DTC_TIPFRE ) ), "CIF", "FOB" )
						Else
							TMSA146Sol((cAliasQry)->T01_FILDOC,(cAliasQry)->T01_DOC,(cAliasQry)->T01_SERIE,,,@cTpFrete)
							aLoadDTC[nLinha][2][nY]:= Iif( cTpFrete == StrZero( 1, Len( DTC->DTC_TIPFRE ) ), "CIF", "FOB" )
						EndIf
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == ("T01_CDROTA") .And. !Empty(cRota146)
						aLoadDTC[nLinha][2][nY]:= cRota146
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == ("T01_SEQENT") .And. !Empty(cSeqTPR)
						aLoadDTC[nLinha][2][nY]:= cSeqTPR
					Else
						aLoadDTC[nLinha][2][nY]	:= (cAliasQry)->&(aCamposDTC[nY][MODEL_FIELD_IDFIELD])
					EndIf	
				EndIf
			Next nY
		EndIf
	
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	If (nOperation == 4 .And. IsInCallStack('TMSA146MNT') ) .Or. nOperation <> 4 .Or. lIncAuto
		Exit
	EndIf
Next nLoad	

aCamposDTC:= aSize(aCamposDTC,0)

If nLinha == 0 
	If lRot146Aut
		TM146MsgAd(STR0209,"TM146LdDoc" )
		If !Empty(cPlnDmd)
			aDoc146Aut:= aSize(aDoc146Aut,0)
		EndIf
	Else
		Help('',1,'TMSA14602') // "Não foram encontrados Documentos para o critério de seleção"
	EndIf	
EndIf

RestArea(aAreaAtu)
Return( aLoadDTC )

//-------------------------------------------------------------------
/*/{Protheus.doc} ActiveMdl
Ativacao do Model
@author paulo.henrique
@since 19/04/2016
/*/
//-------------------------------------------------------------------
Static Function ActiveMdl(oModel)
Local aGetArea	:= GetArea()
Local nOperation:= oModel:GetOperation()

If Len(aLoadTot) > 0 .And. nOperation <> 5 
	AEval( aLoadTot, { |x| TM146Total(x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],@oModel,x[9]) } )
EndIf

RestArea( aGetArea )
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldActMdl
Validacao da ativacao do Model
@author Katia
@since 11/08/2014
/*/
//-------------------------------------------------------------------
Static Function VldActMdl(oModel)
Local aGetArea	:= GetArea()
Local lRet 		:= .T.                  
Local nOperation:= oModel:GetOperation()

If (nOperation == 4  .And. !IsInCallStack('TMSA146MNT') .And. !lIncAuto) .Or. nOperation == 5
	If cFilAnt <> DF8->DF8_FILORI
		Help('',1,'TMSA14631') // "Manutenção permitida somente na filial da Programação.
		lRet:= .F.
	EndIf
	
	If lRet
		If nOperation == 4 
			If !IsInCallStack('TMSA146MNT') .And. !lIncAuto .And. DF8->DF8_STATUS $ ('2|9')   
				Help('',1,'TMSA14627') // "Manutenções permitidas apenas para programação com status - Em aberto"
				lRet:= .F.
			EndIf	
		ElseIf nOperation == 5
			If DF8->DF8_STATUS == StrZero(1,Len(DF8->DF8_STATUS))
				lRet:= T146VldVge()
			Else
				Help('',1,'TMSA14644') // "A Exclusão somente é permitido para programação com status - Em aberto"
				lRet:= .F.
			EndIf	
		EndIf
	EndIf	
EndIf            

RestArea( aGetArea )
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TM146LdDA3
Relacao dos Veiculos
@author Katia
@since 11/08/2014
/*/
//-------------------------------------------------------------------
Static Function TM146LdDA3(oMdlDA3)
Local aLoad:= {}
	FWMsgRun(,{|| aLoad := StsRunDA3(oMdlDA3)})
Return aLoad

Static Function StsRunDA3(oMdlDA3)
Local oStructDA3 := oMdlDA3:GetStruct()
Local aCamposDA3 := aClone(oStructDA3:GetFields())
Local aLoadDA3   := {}
Local nLinha	 := 0
Local nY		 := 0
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local aVeiRes    := {}
Local cVeiDDZ    := ""                      
Local cFuncNull  := ""
Local aPlacas    := Iif(!Empty(mv_par29),Str2Arr(Upper(mv_par29), ";"),{})
Local cPlacas    := ""
Local cPlacaDe   := ""
Local cPlacaAte  := ""
Local aTipVei    := Iif(!Empty(mv_par30),Str2Arr(Upper(mv_par30), ";"),{})
Local cTipVei    := ""
Local cTipVeiDe  := ""
Local cTipVeiAte := ""
Local nX         := 0
Local nPos       := 0
Local lCmpDA3    := DA3->(ColumnPos("DA3_VELOC")) > 0

Private INCLUI	:= .F.
Private cDSerTms:= ''

Do Case
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case cDbType $ "ORACLE/INFORMIX"  
  		cFuncNull	:= "NVL"
 	Otherwise
 		cFuncNull	:= "ISNULL"
EndCase     

//---- Tratamento de Placas
If Len(aPlacas) > 0
    nPos:= At("-",aPlacas[1])
	If nPos > 0
		If At("'",aPlacas[1]) == 0
			cPlacaDe := "'" + SubStr(aPlacas[1],1,(nPos-1)) + "'"
			cPlacaAte:= "'" + SubStr(aPlacas[1],nPos+1)	 + "'"
		Else
			cPlacaDe := SubStr(aPlacas[1],1,(nPos-1)) 
			cPlacaAte:= SubStr(aPlacas[1],nPos+1)	
		EndIf
	Else
        For nX := 1 To Len(aPlacas)
			If At("'",aPlacas[1]) == 0
            	cPlacas+=  "'" + aPlacas[nx] + Iif(nX == Len(aPlacas),"'", "',")
			Else
				cPlacas+= aPlacas[nx] + Iif(nX == Len(aPlacas),"", ",")
			EndIf
        Next nX
    EndIf
EndIf

//---- Tratamento Tipo de Veiculos	     
If Len(aTipVei) > 0
    nPos:= At("-",aTipVei[1])
	If nPos > 0
		cTipVeiDe := "' " + SubStr(aTipVei[1],1,(nPos-1)) + "' "
		cTipVeiAte:= "' " + SubStr(aTipVei[1],nPos+1) + "' "			   			
	Else
        For nX := 1 To Len(aTipVei)
            cTipVei+= aTipVei[nx] + Iif(nX == Len(aTipVei),"", ",")
        Next nX
    EndIf
EndIf             

If !IsInCallStack('TMSA146MNT') .And. !lIncAuto

	cQuery := " SELECT DDZ_CODVEI, DDZ_CODRB1, DDZ_CODRB2, DDZ_CODRB3 FROM "
	cQuery +=  RetSqlName("DDZ") + " DDZ "
	cQuery += " WHERE DDZ.DDZ_FILIAL = '" + xFilial("DDZ") + "' "
	cQuery += " AND DDZ.DDZ_FILORI = '" + DF8->DF8_FILORI + "' "
	cQuery += " AND DDZ.DDZ_NUMPRG = '" + DF8->DF8_NUMPRG + "' "
	cQuery += " AND DDZ.DDZ_SEQPRG = '" + DF8->DF8_SEQPRG + "' "
	cQuery += " AND DDZ.D_E_L_E_T_ = ' '"
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
	While (cAliasQry)->(!Eof())
		If !Empty(cVeiDDZ)
			cVeiDDZ:= cVeiDDZ + ", " + "'" + (cAliasQry)->DDZ_CODVEI + "'"
		Else
			cVeiDDZ:= "'" + (cAliasQry)->DDZ_CODVEI + "'" 
		EndIf	
		If !Empty((cAliasQry)->DDZ_CODRB1)
			cVeiDDZ:= cVeiDDZ + ", " + "'" + (cAliasQry)->DDZ_CODRB1 + "'"
		EndIf	
		If !Empty((cAliasQry)->DDZ_CODRB2)
			cVeiDDZ:= cVeiDDZ + ", " + "'" + (cAliasQry)->DDZ_CODRB2 + "'"
		EndIf
		If !Empty((cAliasQry)->DDZ_CODRB3)
			cVeiDDZ:= cVeiDDZ + ", " + "'" + (cAliasQry)->DDZ_CODRB3 + "'"
		EndIf
		
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	
	If !Empty(cVeiDDZ)
		cAliasQry  := GetNextAlias()
		cQuery := " SELECT DA3_STATUS, DA3_COD, DA3_PLACA, DA3_DESC, DA3_FROVEI, DUT_DESCRI, DA3_CAPACM, DA3_CAPACN, DA3_VOLMAX, DA3_FILATU, DA3_FILBAS, DA3_VEIRAS, ' ' DTW_DATPRE,' ' DTW_HORPRE, "
		cQuery +=  cFuncNull + "(DA3.DA3_SERTMS, '') DA3_SERTMS    "
		If lCmpDA3
			cQuery +=  ", DA3_VELOC "
		EndIf
		cQuery +=  "FROM " + RetSqlName("DA3") + " DA3 "
		cQuery += " LEFT JOIN " + RetSqlName("DUT") + " DUT "
		cQuery += " ON DUT.DUT_FILIAL = '" + xFilial("DUT") + "' "
		cQuery += " AND DUT.DUT_TIPVEI = DA3.DA3_TIPVEI  AND DUT.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE DA3.DA3_FILIAL = '" + xFilial("DA3") + "' "
		cQuery += " AND DA3.DA3_COD IN (" + cVeiDDZ + ") "
		cQuery += " AND DA3.D_E_L_E_T_ = ' ' "
	 EndIf             

ElseIf IsInCallStack('T146GERPRG') .And. !Empty(cIdRotTPR) //TPR

	cQuery := " SELECT DA3_STATUS, DA3_COD, DA3_PLACA, DA3_DESC, DA3_FROVEI, DUT_DESCRI, "
	cQuery += " DA3_CAPACM, DA3_CAPACN, DA3_VOLMAX, DA3_FILATU, DA3_FILBAS, DA3_VEIRAS, "
	cQuery += " ' ' DTW_DATPRE,' ' DTW_HORPRE, "
	cQuery += cFuncNull + "(DA3.DA3_SERTMS, '') DA3_SERTMS "
	If lCmpDA3
		cQuery +=  ", DA3_VELOC "
	EndIf
	cQuery += " FROM " + RetSqlName("DA3") + " DA3 "

	cQuery += " LEFT JOIN " + RetSqlName("DUT") + " DUT "
	cQuery += " ON DUT.DUT_FILIAL = '" + xFilial("DUT") + "' "
	cQuery += " AND DUT.DUT_TIPVEI = DA3.DA3_TIPVEI  AND DUT.D_E_L_E_T_ = ' ' "
	
	cQuery += " WHERE DA3.DA3_FILIAL = '" + xFilial("DA3") + "' "
	cQuery += " AND DA3.DA3_ATIVO = '1' "
	cQuery += " AND DA3.DA3_PLACA  = " + cPlacas 
	cQuery += " AND DUT.DUT_CATVEI <> '2' "
	cQuery += " AND DA3.D_E_L_E_T_ = ' ' "

Else
	cQuery := " SELECT DA3_STATUS, "
	cQuery += 			" DA3_COD, DA3_PLACA, DA3_DESC, DA3_FROVEI, DUT_DESCRI, "
	cQuery +=			" DA3_CAPACM, DA3_CAPACN, DA3_VOLMAX, DA3_FILATU, DA3_FILBAS, DA3_VEIRAS, "
	cQuery += 			" ' ' DTW_DATPRE,' ' DTW_HORPRE, "
	cQuery +=			cFuncNull + "(DA3.DA3_SERTMS, '') DA3_SERTMS "
	If lCmpDA3
		cQuery +=  ", DA3_VELOC "
	EndIf
	cQuery += " FROM " + RetSqlName("DA3") + " DA3 "
	
	cQuery +=			" LEFT JOIN " + RetSqlName("DUT") + " DUT "
	cQuery +=			" ON DUT.DUT_FILIAL = '" + xFilial("DUT") + "' "
	cQuery +=			" AND DUT.DUT_TIPVEI = DA3.DA3_TIPVEI  AND DUT.D_E_L_E_T_ = ' ' "
	
	cQuery += " WHERE DA3.DA3_FILIAL = '" + xFilial("DA3") + "' "
	cQuery +=		" AND DA3.DA3_ATIVO = '1' "
	If mv_par16 == 1 //Em Filial  
		cQuery +=	" AND DA3.DA3_FILATU = '" + cFilAnt + "' "
	ElseIf mv_par16 == 2 //Da Filial Base
		cQuery +=	" AND DA3.DA3_FILBAS = '" + cFilAnt + "' "
	EndIf
	cQuery +=		" AND DA3.DA3_STATUS <> '3' "
	
	If !Empty(cPlacas) 
		If Len(aPlacas) > 1 
			cQuery += " AND DA3.DA3_PLACA  IN (" + cPlacas + ")"
		Else
			cQuery += " AND DA3.DA3_PLACA  = " + cPlacas 
		EndIf
    ElseIf !Empty(cPlacaDe) .AND. !Empty(cPlacaAte)
        cQuery +=	" AND DA3.DA3_PLACA >= " + cPlacaDe + " AND DA3.DA3_PLACA <= " + cPlacaAte
	EndIf
	
	If !Empty(cTipVei)
		If Len(aTipVei) > 1 
			cQuery += " AND DA3.DA3_TIPVEI  IN (" + cTipVei + ")"
		Else
			cQuery += " AND DA3.DA3_TIPVEI  =  " + cTipVei 
		EndIf
    ElseIf !Empty(cTipVeiDe) .AND. !Empty(cTipVeiAte)
        cQuery +=	" AND DA3.DA3_TIPVEI >= " + cTipVeiDe + " AND DA3.DA3_TIPVEI <= " + cTipVeiAte
	EndIf
	
	If mv_par31 <> 4 //Tipo Frota
		cQuery +=	" AND DA3.DA3_FROVEI = '" + Str(MV_PAR31,1) + "' "
	EndIf

	cQuery +=		" AND DA3.D_E_L_E_T_ = ' ' "
	cQuery +=		" AND DUT.DUT_CATVEI <> '2' "

	If lContVei
		cQuery +=	"AND EXISTS ( SELECT 1 FROM "+RetSqlName('DTU')+" DTU "
		cQuery += 				" WHERE DTU.DTU_FILIAL  = '"+xFilial('DTU')+"' "
		cQuery += 						" AND DTU.DTU_CODVEI  = DA3.DA3_COD     "
		cQuery += 						" AND DTU.DTU_STATUS IN ( '1', '2' )"
		cQuery += 						" AND DTU.D_E_L_E_T_  = ' ' )       "
	EndIf
	
	cQuery += " UNION ALL "   
	
	cQuery +=  " SELECT DA3_STATUS, "
	cQuery += 			" DA3_COD, DA3_PLACA, DA3_DESC, DA3_FROVEI, DUT_DESCRI, "
	cQuery += 			" DA3_CAPACM, DA3_CAPACN, DA3_VOLMAX, DA3_FILATU, DA3_FILBAS, DA3_VEIRAS,"
	cQuery += 			" MAX(DTW_DATPRE) DTW_DATPRE, MAX(DTW_HORPRE) DTW_HORPRE, "
	cQuery += 			cFuncNull + "(DA3.DA3_SERTMS, '') DA3_SERTMS  "
	If lCmpDA3
		cQuery +=  ", DA3_VELOC "
	EndIf
	cQuery +=  " FROM " + RetSqlName("DA3") + " DA3 "
	
	cQuery += 			" LEFT JOIN " + RetSqlName("DUT") + " DUT "
	cQuery += 						" ON DUT.DUT_FILIAL = '" + xFilial("DUT") + "' "
	cQuery +=						" AND DUT.DUT_TIPVEI = DA3.DA3_TIPVEI "
	cQuery +=						" AND DUT.D_E_L_E_T_ = ' ' "

	cQuery +=			" INNER JOIN " + RetSqlName("DTR") + " DTR "
	cQuery +=						" ON DTR.DTR_FILIAL = '" + xFilial("DTR") + "' "
	cQuery +=						" AND DTR.DTR_CODVEI = DA3.DA3_COD AND DTR.D_E_L_E_T_ = ' ' "
	
	cQuery +=			" INNER JOIN " + RetSqlName("DTQ") + " DTQ "
	cQuery +=						" ON DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "' "
	cQuery +=						" AND DTQ.DTQ_FILORI = DTR.DTR_FILORI AND DTQ.DTQ_VIAGEM = DTR.DTR_VIAGEM AND DTQ.DTQ_STATUS IN ('2', '4' )  "
	cQuery +=						" AND DTQ.D_E_L_E_T_ = ' ' "
	
	cQuery +=			" INNER JOIN " + RetSqlName("DTW") + " DTW "
	cQuery += 						" ON DTW.DTW_FILIAL = '" + xFilial("DTW") + "' " 
	cQuery += 						" AND DTW.DTW_FILORI = DTQ.DTQ_FILORI AND DTW.DTW_VIAGEM = DTQ.DTQ_VIAGEM " 
	cQuery += 						" AND DTW.DTW_ATIVID = '050' " 
	cQuery += 						" AND DTW.DTW_FILATI = '" + cFilAnt + "' " 
	cQuery += 						" AND DTW.DTW_STATUS = '1' "
	
	cQuery +=  " WHERE DA3.DA3_FILIAL = '" + xFilial("DA3") + "' "
	cQuery +=		" AND DA3.DA3_STATUS = '3' "
	cQuery += 		" AND DA3.DA3_ATIVO = '1' "
	cQuery += 		" AND DA3.D_E_L_E_T_ = ' ' "
	cQuery += 		" AND DUT.DUT_CATVEI <> '2' "
	
	If !Empty(cPlacas) 
		If Len(aPlacas) > 1 
			cQuery += "   AND  DA3.DA3_PLACA  IN (" + cPlacas + ")"
		Else
			cQuery += "   AND  DA3.DA3_PLACA  = " + cPlacas 
		EndIf
    ElseIf !Empty(cPlacaDe) .AND. !Empty(cPlacaAte)
        cQuery += " AND DA3.DA3_PLACA >= " + cPlacaDe + " AND DA3.DA3_PLACA <= " + cPlacaAte
	EndIf				
	
	If !Empty(cTipVei)
		If Len(aTipVei) > 1 
			cQuery += "   AND  DA3.DA3_TIPVEI  IN (" + cTipVei + ")"
		Else
			cQuery += "   AND  DA3.DA3_TIPVEI  =  " + cTipVei 
		EndIf
    ElseIf !Empty(cTipVeiDe) .AND. !Empty(cTipVeiAte)
        cQuery += " AND DA3.DA3_TIPVEI >= " + cTipVeiDe + " AND DA3.DA3_TIPVEI <= " + cTipVeiAte
	EndIf
	
	If mv_par31 <> 4 //Tipo Frota
		cQuery += " AND DA3.DA3_FROVEI = '" + Str(MV_PAR31,1) + "' "
	EndIf
	cQuery += " GROUP BY DA3_STATUS, DA3_COD, DA3_PLACA, DA3_DESC, DA3_FROVEI, DUT_DESCRI, DA3_CAPACM, DA3_CAPACN, DA3_VOLMAX, DA3_FILATU, DA3_FILBAS, DA3_VEIRAS, DA3_SERTMS "
	If lCmpDA3
		cQuery += " , DA3_VELOC "
	EndIf
	cQuery += " ORDER BY DA3_STATUS, DA3_COD, DA3_PLACA "
EndIf
If !cDbType $ "MSSQL|MSSQL7|ORACLE"
	cQuery := ChangeQuery( cQuery )
EndIf	

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

While (cAliasQry)->(!Eof())
	nLinha++
	aAdd(aLoadDA3,{nLinha,Array(Len(aCamposDA3))})
	For nY := 1 To Len(aCamposDA3)
		aVeiRes:= {}
		If !aCamposDA3[nY][MODEL_FIELD_VIRTUAL]
			aLoadDA3[nLinha][2][nY]	:= (cAliasQry)->&(aCamposDA3[nY][MODEL_FIELD_IDFIELD])			
		Else
			If (aCamposDA3[nY][MODEL_FIELD_IDFIELD] $ ("DA3_BTCAR"))
				aLoadDA3[nLinha][2][nY]	:= 'CARGANEW' //"TMSIMG16" //"CARGANEW" 
			EndIf
			If (aCamposDA3[nY][MODEL_FIELD_IDFIELD] $ ("DA3_BTDES"))
				aLoadDA3[nLinha][2][nY]	:= 'CARGA' //"NOCHECKED_15" //"CARGA"
			EndIf
			If (aCamposDA3[nY][MODEL_FIELD_IDFIELD] $ ("DA3_DESTIP"))
				aLoadDA3[nLinha][2][nY]	:= (cAliasQry)->DUT_DESCRI
			EndIf			
			If (aCamposDA3[nY][MODEL_FIELD_IDFIELD] $ ("DA3_MARK"))
				If lIncAuto
					aLoadDA3[nLinha][2][nY]	:= .T.
			    Else
			    	aLoadDA3[nLinha][2][nY]	:= .F.
				Endif 
			EndIf
			If (aCamposDA3[nY][MODEL_FIELD_IDFIELD] $ ("DA3_DTPRCH"))
				aLoadDA3[nLinha][2][nY]	:= (cAliasQry)->DTW_DATPRE
			EndIf
			If (aCamposDA3[nY][MODEL_FIELD_IDFIELD] $ ("DA3_HRPRCH"))
				aLoadDA3[nLinha][2][nY]	:= (cAliasQry)->DTW_HORPRE
			EndIf
			If (aCamposDA3[nY][MODEL_FIELD_IDFIELD] $ ("DA3_DESSVT"))
				cDSerTms:= (cAliasQry)->DA3_SERTMS
				aLoadDA3[nLinha][2][nY]	:= TMSValField('cDSerTms',.F.) 
			EndIf
		EndIf
	Next nY
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())

If nLinha == 0
	If lRot146Aut
		TM146MsgAd(STR0210,"TM146LdDA3" )
	Else	
		Help('',1,'TMSA14645') // "Não foram encontrados Veiculos para o critério de seleção"
	EndIf	
EndIf

aCamposDA3 := aSize(aCamposDA3,0)

Return( aLoadDA3 )

//-------------------------------------------------------------------
/*/{Protheus.doc} TM146LdRot
Relacao dos Veiculos
@author Katia
@since 11/08/2014
/*/
//-------------------------------------------------------------------
Static Function TM146LdRot(oMdlDA8,oMdlGridDoc,cRota,aZonas,aSetores,lMrkDoc)
Local aLoad
	FWMsgRun(,{|| aLoad := StsRun(oMdlDA8,oMdlGridDoc,cRota,aZonas,aSetores,lMrkDoc)})
Return aLoad

//-------------------------------------------------------------------
/*/{Protheus.doc} StsRun
Relacao dos Veiculos
@author Katia
@since 11/08/2014
/*/
//-------------------------------------------------------------------

Static Function StsRun(oMdlDA8,oMdlGridDoc,cRota,aZonas,aSetores,lMrkDoc)
Local oStructDA8  := Nil
Local aCamposDA8  := {}
Local aLoadDA8    := {}
Local nLinha      := 0 
Local nX          := 0
Local nY          := 0
Local cAliasDTC   := GetNextAlias()
Local cAliasQryR  := ""
Local cQuery      := ""   
Local nPos        := 0
Local cCdrOri     := Padr(GetMv("MV_CDRORI",,""),Len(DA8->DA8_CDRORI))     
Local cRotaDe     := mv_par17
Local cRotaAte    := mv_par18
Local aFilDest    := Iif(!Empty(mv_par20),Str2Arr(Upper(mv_par20), ";"),{})
Local cFilDest    := ""
Local cFilDe      := ""
Local cFilAte     := ""
Local cZonas      := ""
Local cSetores    := ""
Local nOperation  := oMdlDA8:GetOperation()
Local oView       := Nil
Local lAllRota    := .F.
Local lRotaCol    := .F.
Local lRotaEnt    := .F.
Local lRotaTra    := .F.

Private INCLUI		:= .F.

Default oMdlDA8     := Nil
Default oMdlGridDoc := Nil
Default cRota       := ""
Default aZonas      := {}
Default aSetores    := {}
Default lMrkDoc     := .F.

If Type("aRotas") == "U"
	aRotas := {}
EndIf

If ValType(oMdlDA8) == "O"
	oStructDA8  := oMdlDA8:GetStruct()
	aCamposDA8  := aClone(oStructDA8:GetFields())
EndIf

Pergunte("TMSA146C",.F.)
If (mv_par01 == 1 .And. !lRot146Aut) .Or. (nOperation == 2 .Or. nOperation == 5)   //Documentos, Visualizar ou Excluir nao carrega a Grid Rotas
	Pergunte("TMSA146",.F.)
	aAdd(aLoadDA8,{1,Array(Len(aCamposDA8))})
	Return( aLoadDA8 )
EndIf
Pergunte("TMSA146",.F.)

If Len(aFilDest) > 0                        
	nPos:= At("-",aFilDest[1])
	If nPos > 0
		cFilDe := SubStr(aFilDest[1],1,(nPos-1))
		cFilAte:= SubStr(aFilDest[1],nPos+1)			   			
	Else
		For nX:= 1 To Len(aFilDest)   
             If At("'", aFilDest[nx]) == 0
			    aFilDest[nx] := "'" + AllTrim(aFilDest[nx]) + "'"
			EndIf
			cFilDest+=  aFilDest[nx] + Iif(nX == Len(aFilDest),"", ",")
		Next nX
	EndIf	
Else
	cFilDe	:= Space(Len(DTC->DTC_FILIAL))
	cFilAte := Replicate('Z',Len(DTC->DTC_FILIAL))
EndIf
	
If !Empty(cRota)
	cRotaDe := cRota
	cRotaAte:= cRota
	
	For nX:=1 To Len(aZonas)
		cZonas+=  "'" + aZonas[nx] + Iif(nX == Len(aZonas),"'", "',")
	Next nX
	
	For nX:=1 To Len(aSetores)
		cSetores+=  "'" + aSetores[nx] + Iif(nX == Len(aSetores),"'", "',")
	Next nX
EndIf

//--- Servico da Rota
lRotaCol:= mv_par26 == '1' .Or. mv_par27 == '1' 
lRotaTra:= mv_par26 == '2' .Or. mv_par27 == '2'
lRotaEnt:= mv_par26 == '3' .Or. mv_par27 == '3'
lAllRota:= mv_par26 == '1' .And. mv_par27 == '3'  

// Limpa aLoadTot
aLoadTot := {}

//-- Coleta e Entrega - DT6
cQuery:= ""
cAliasQryR:= GetNextAlias()
If lAllRota .Or. lRotaCol .Or. lRotaEnt	
	cQuery:= "SELECT DA8_COD,"
	cQuery+= 		" DA8_DESC,"
	cQuery+= 		" DA8_TIPROT,"
	cQuery+= 		" DA8_SERTMS,"
	cQuery+= 		" DA5_COD DA5COD,"
	cQuery+= 		" DA5_DESC DA5DESC,"
	cQuery+= 		" DA6_ROTA DA6ROTA,"
	cQuery+= 		" DA6_REF DA6REF,"
	cQuery+= 		" DA6_PERCUR DA6PERCUR,"
	cQuery+= 		" DT6.DT6_FILDOC,"
	cQuery+= 		" DT6.DT6_DOC,"
	cQuery+= 		" DT6.DT6_SERIE,"
	cQuery+= 		" ' ' DTCNUMNFC,"
	cQuery+= 		" ' ' DTCSERNFC,"		
	cQuery+= 		" DT6_QTDVOL,"
	cQuery+= 		" DT6_PESO,"
	cQuery+= 		" DT6_PESOM3,"
	cQuery+= 		" DT6_VALMER,"
	cQuery+= 		" DT6_VALFRE,"
	cQuery+= 		" DT6_SERTMS,"
	cQuery+= 		" DT6_BLQDOC"	
	cQuery+= " FROM " + RetSqlName('DUD') + " DUD "
	
	cQuery+= " INNER JOIN " + RetSqlname('DA7') + " DA7 "
	cQuery+= 				" ON DA7_FILIAL = '" + xFilial('DA7') + "' "
	cQuery+= 				" AND DUD_CEPENT BETWEEN DA7_CEPDE AND DA7_CEPATE "
	If !Empty(cZonas) 
		cQuery+= 			" AND DA7_PERCUR IN (" + cZonas +")  "
		cQuery+= 			" AND DA7_ROTA IN (" + cSetores +")  "		
	EndIf
	cQuery+=				" AND DA7.D_E_L_E_T_ = ' ' "
	
	cQuery+= " INNER JOIN " + RetSqlname('DA6') + " DA6 "
	cQuery+= 				" ON DA6_FILIAL = '" + xFilial('DA6') + "' "
	cQuery+= 				" AND DA6_PERCUR = DA7_PERCUR 		"
	cQuery+= 				" AND DA6_ROTA = DA7_ROTA 			"
	cQuery+=				" AND DA6.D_E_L_E_T_ = ' ' 		 	" 
	
	cQuery+= " INNER JOIN " + RetSqlname('DA5') + " DA5 "
	cQuery+= 				" ON  DA5_FILIAL = '" + xFilial('DA5') + "' "
	cQuery+= 				" AND DA5_COD = DA6_PERCUR "
	cQuery+= 				" AND DA5.D_E_L_E_T_ = ' '  "
	
	cQuery+= " INNER JOIN " + RetSqlname('DA9') + " DA9 "
	cQuery+= 				" ON DA9_FILIAL = '" + xFilial('DA9') + "' "
	cQuery+= 				" AND DA9_PERCUR = DA7_PERCUR 
	cQuery+= 				" AND DA9_ROTA = DA7_ROTA "
	cQuery+= 				" AND DA9.D_E_L_E_T_ = ' ' " 
	
	cQuery+= " INNER JOIN " + RetSqlname('DA8') + " DA8 "
	cQuery+= 				" ON DA8_FILIAL = '" + xFilial('DA8') + "' "
	cQuery+= 				" AND DA8_COD >= '" + cRotaDe + "' "
	cQuery+= 				" AND DA8_COD <= '" + cRotaAte + "' "
	cQuery+= 				" AND DA8_COD = DA9_ROTEIR "

	If lAllRota .Or. (lRotaCol .OR. lRotaEnt)
		If lHasViaM3
			cQuery+= 			" AND DA8_SERTMS IN ('3')  "
		Else
			If lRotaCol .AND. lRotaEnt
				cQuery+= 			" AND DA8_SERTMS IN ('1','3')  "
			ElseIf lRotaCol
				cQuery+= 			" AND DA8_SERTMS = '1'  "				
			ElseIf lRotaEnt
				cQuery+= 			" AND DA8_SERTMS = '3'  "
			EndIf
		EndIf
	EndIf
	
	cQuery+= 				" AND DA8_TIPTRA = '" + cTpTransp + "' "
	cQuery+= 				" AND DA8_ATIVO = '1' "
	cQuery+= 				" AND DA8.D_E_L_E_T_ = ' ' "
	
	cQuery+= " LEFT JOIN " + RetSqlname('DT6') + " DT6 " 
	cQuery+= 				" ON DT6_FILIAL = '" + xFilial('DT6') + "' "
	 
	cQuery += T146SelDT6( 'R', cFilDest, cFilDe, cFilAte )
EndIf
	
//--- Todas as Rotas Ou Rota Transferencia mais a de Rota de Coleta ou Rota de Entrega
If lAllRota .Or. (lRotaTra .And. (lRotaCol .Or. lRotaEnt))		
	cQuery+= " UNION "
EndIf	
	
If lAllRota .Or. lRotaTra
	//-- Transferencia
	cQuery+= " SELECT DA8_COD,"
	cQuery+= " DA8_DESC,"
	cQuery+= " DA8_TIPROT,"
	cQuery+= " DA8_SERTMS,"
	cQuery+= " '' DA5COD,"
	cQuery+= " '' DA5DESC,"
	cQuery+= " '' DA6ROTA,"
	cQuery+= " '' DA6REF, "
	cQuery+= " '' DA6PERCUR,"
	cQuery+= " DT6.DT6_FILDOC,"
	cQuery+= " DT6.DT6_DOC,"
	cQuery+= " DT6.DT6_SERIE,"
	cQuery+= " ' ' DTCNUMNFC,"
	cQuery+= " ' ' DTCSERNFC,"
	cQuery+= "  DT6_QTDVOL,"
	cQuery+= " DT6_PESO,"
	cQuery+= " DT6_PESOM3,"
	cQuery+= " DT6_VALMER,"
	cQuery+= " DT6_VALFRE,"	 
	cQuery+= " DT6_SERTMS,"
	cQuery+= " DT6_BLQDOC "
	cQuery+= " FROM " + RetSqlName('DUD') + " DUD "
	
	cQuery+= " INNER JOIN " + RetSqlName('DA8') + " DA8 "
	cQuery+= 				" ON DA8_FILIAL = '" + xFilial('DA8') + "' "
	cQuery+= 				" AND DA8_COD >= '" + cRotaDe + "' "
	cQuery+= 				" AND DA8_COD <='" + cRotaAte + "' "
	cQuery+= 				" AND DA8_TIPTRA = '" + cTpTransp + "' "
	cQuery+= 				" AND DA8_SERTMS = '2'  "
	cQuery+= 				" AND DA8_CDRORI =  '" + cCdrOri + "' "
	cQuery+= 				" AND DA8_ATIVO = '1' "
	cQuery+= 				" AND DA8.D_E_L_E_T_ = ' ' "
	
	cQuery+= " INNER JOIN " + RetSqlName('DVM') + " DVM "
	cQuery+= 				" ON DVM_FILIAL = '" + xFilial('DVM') + "' " 
	cQuery+= 				" AND DVM_ROTEIR = DA8_COD  "
	cQuery+= 				" AND DVM_CDRDES = DUD_CDRCAL " 
	cQuery+= 				" AND DVM.D_E_L_E_T_ = ' ' "
	
	cQuery+= " LEFT JOIN " + RetSqlname('DT6') + " DT6 "
	cQuery+= 				" ON DT6_FILIAL = '" + xFilial('DT6') + "' "
	
	cQuery += T146SelDT6( 'R', cFilDest, cFilDe, cFilAte )
	
	cQuery+= " ORDER BY  DA8_COD,"
	cQuery+= " DA8_DESC,"
	cQuery+= " DA8_TIPROT,"
	cQuery+= " DA8_SERTMS"
EndIf
	
If !Empty(cQuery)	
	If !cDbType $ "MSSQL|MSSQL7|ORACLE"
		cQuery := ChangeQuery( cQuery )
	EndIf	
		
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQryR, .T., .T. )     
	
	While (cAliasQryR)->(!Eof())
	 	//Carrega Grid Rotas,Zonas e Setores	
		If Empty(cRota)
			nPos:= Ascan(aRotas, (cAliasQryR)->DA8_COD) 
			If nPos == 0
				aAdd(aRotas, (cAliasQryR)->DA8_COD)	
	
				nLinha++						
				aAdd(aLoadDA8,{nLinha,Array(Len(aCamposDA8))})
				For nY := 1 To Len(aCamposDA8)
					If !aCamposDA8[nY][MODEL_FIELD_VIRTUAL]
						aLoadDA8[nLinha][2][nY]	:= (cAliasQryR)->&(aCamposDA8[nY][MODEL_FIELD_IDFIELD])
					Else
						If !(aCamposDA8[nY][MODEL_FIELD_IDFIELD] $ ("DA8_MARK"))
							If (aCamposDA8[nY][MODEL_FIELD_IDFIELD] $ ("DA8_DESSVT"))						
								aLoadDA8[nLinha][2][nY]	:= TMSValField(cAliasQryR+"->DA8_SERTMS",.F.)
							Else                                                                           
								aLoadDA8[nLinha][2][nY]	:= CriaVar(aCamposDA8[nY][MODEL_FIELD_IDFIELD],.T.)
							EndIf	
						EndIf	
					EndIf
				Next nY  
			EndIf	
			
			nPos:= Ascan(aDadosZona, {|x| x[4]+x[1] == (cAliasQryR)->DA8_COD+(cAliasQryR)->DA5COD} )
			If nPos == 0
				aAdd(aDadosZona, {(cAliasQryR)->DA5COD,(cAliasQryR)->DA5DESC,,(cAliasQryR)->DA8_COD} )
			EndIf	
				
			nPos:= Ascan(aDadosSetor, {|x| x[5]+x[2]+x[1] == (cAliasQryR)->DA8_COD+(cAliasQryR)->DA6ROTA+(cAliasQryR)->DA6PERCUR} )
			If nPos == 0
				aAdd(aDadosSetor, {(cAliasQryR)->DA6PERCUR,(cAliasQryR)->DA6ROTA,(cAliasQryR)->DA6REF,,(cAliasQryR)->DA8_COD } )
			EndIf
		Else
			If (cAliasQryR)->DT6_BLQDOC == '2'  //Nao
				If oMdlGridDoc:SeekLine( {{ "T01_FILDOC", (cAliasQryR)->DT6_FILDOC},{ "T01_DOC", (cAliasQryR)->DT6_DOC},{ "T01_SERIE", (cAliasQryR)->DT6_SERIE} , { "T01_MARK", .F.}} )
					oMdlGridDoc:LoadValue("T01_MARK",.T.)        //Nao utilizar setvalue - performance
					oMdlGridDoc:LoadValue("T01_CDROTA", cRota)
					
					aAdd(aLoadTot,{'DT6',oMdlGridDoc:GetValue('T01_SERTMS'),oMdlGridDoc:GetValue('T01_QTDVOL'),oMdlGridDoc:GetValue('T01_PESO'),oMdlGridDoc:GetValue('T01_PESOM3'),oMdlGridDoc:GetValue('T01_VALOR'),;
						0,1,Iif(oMdlGridDoc:GetValue('T01_CRIRAT') == 'A', 1, 0)} )
				EndIf	
			EndIf
		EndIf
		
		(cAliasQryR)->(dbSkip())
	EndDo
	(cAliasQryR)->(dbCloseArea())
EndIf
	
//-- Notas - DTC 
	cQuery:= ""
If lAllRota .Or. lRotaTra	
	
	// Busca Valores para Servico de Tranp = 2 Transporte
	cQuery+= " SELECT DTC.DTC_NUMNFC, 	"
	cQuery+= " 		  DTC.DTC_SERNFC, 	"
	cQuery+= " 		  DTC.DTC_CLIREM, 	"
	cQuery+= " 		  DTC.DTC_LOJREM, 	"
	cQuery+= " 		  DTC.DTC_SQEDES, 	"
	cQuery+= " 		  DTC.DTC_SERTMS, 	"
	cQuery+= " 		  DES.A1_CEP, 		"
	cQuery+= " 		  DUL.DUL_CEP, 		"
	cQuery+= " 		  DTC.DTC_CDRCAL, 	"
	cQuery+= " 		  DA8_COD,  		"
	cQuery+= " 		  DA8_DESC, 		"
	cQuery+= " 		  DA8_TIPROT,		" 
	cQuery+= " 		  DA8_SERTMS, 		"
	cQuery+= " 		  '' DA5COD, 		"
	cQuery+= " 		  '' DA5DESC ,		" 
	cQuery+= " 		  '' DA6ROTA, 		"
	cQuery+= " 		  '' DA6REF , 		"
	cQuery+= " 		  '' DA6PERCUR "
	cQuery+= " FROM " + RetSqlName('DTC') + " DTC "
		 
	cQuery += T146SelDTC('D',cFilDest,cFilDe,cFilAte,"2","","")
	
	cQuery += "AND DA8_COD >= '" + cRotaDe + "'  	"
    cQuery += "AND DA8_COD <= '" + cRotaAte + "' 	"
    cQuery += "AND DA8_SERTMS = '2'				 	"
    cQuery += "AND DA8_TIPTRA = '" + cTpTransp + "' 	"
    cQuery += "AND DA8_ATIVO = '1' 					"
    cQuery += "AND DA8.D_E_L_E_T_ = ' '				"
	
	cQuery += "GROUP BY DTC.DTC_NUMNFC, "
	cQuery += "			DTC.DTC_SERNFC, "
	cQuery += "			DTC.DTC_CLIREM, "
	cQuery += "			DTC.DTC_LOJREM, "
	cQuery += "			DTC.DTC_SQEDES, "
	cQuery += "			DTC.DTC_SERTMS, "
	cQuery += "			DES.A1_CEP,		"
	cQuery += "			DUL.DUL_CEP, 	"
	cQuery += "			DTC.DTC_CDRCAL,	"
	cQuery += " 		DA8_COD,  		"
	cQuery += " 		DA8_DESC, 		"
	cQuery += " 		DA8_TIPROT,		" 
	cQuery += " 		DA8_SERTMS	 	"
EndIf
	
If lAllRota .Or. (lRotaTra .And. lRotaEnt)
	cQuery += "	UNION ALL	"
EndIf
	
If lAllRota .Or. lRotaEnt
	// Busca Valores para Servico de Tranp = 3 Transporte
	cQuery+= " SELECT DTC.DTC_NUMNFC, 		"
	cQuery+= " 		  DTC.DTC_SERNFC, 		"
	cQuery+= " 		  DTC.DTC_CLIREM, 		"
	cQuery+= " 		  DTC.DTC_LOJREM, 		"
	cQuery+= " 		  DTC.DTC_SQEDES, 		"
	cQuery+= " 		  DTC.DTC_SERTMS, 		"
	cQuery+= " 		  DES.A1_CEP, 			"
	cQuery+= " 		  DUL.DUL_CEP, 			"
	cQuery+= " 		  DTC.DTC_CDRCAL, 		"
	cQuery+= " 		  DA8_COD,  			"
	cQuery+= " 		  DA8_DESC, 			"
	cQuery+= " 		  DA8_TIPROT,			"	 
	cQuery+= " 		  DA8_SERTMS, 			"
	cQuery+= " 		  DA5_COD  DA5COD,		"
	cQuery+= " 		  DA5_DESC DA5DESC, 	"	 
	cQuery+= " 		  DA6_ROTA DA6ROTA,		"
	cQuery+= " 		  DA6_REF   DA6REF,	 	"
	cQuery+= " 		  DA6_PERCUR DA6PERCUR 	"
	cQuery+= " FROM " + RetSqlName('DTC') + " DTC "
		
	cQuery += T146SelDTC('D',cFilDest,cFilDe,cFilAte,"3",cZonas,cSetores)
	
	cQuery += "AND DA8_COD >= '" + cRotaDe + "' 	"
	cQuery += "AND DA8_COD <= '" + cRotaAte + "' 	"
	cQuery += "AND DA8_SERTMS = '3'					"
	cQuery += "AND DA8_TIPTRA = '" + cTpTransp + "' 	"
	cQuery += "AND DA8_ATIVO = '1'	"
	cQuery += "AND DA8.D_E_L_E_T_ = ' ' "
	
	cQuery += "GROUP BY DTC.DTC_NUMNFC, "
	cQuery += "			DTC.DTC_SERNFC, "
	cQuery += "			DTC.DTC_CLIREM, "
	cQuery += "			DTC.DTC_LOJREM, "
	cQuery += "			DTC.DTC_SQEDES, "
	cQuery += "			DTC.DTC_SERTMS, "
	cQuery += "			DES.A1_CEP,		"
	cQuery += "			DUL.DUL_CEP, 	"
	cQuery += "			DTC.DTC_CDRCAL,	"
	cQuery += " 		DA8_COD,  		"
	cQuery += " 		DA8_DESC, 		"
	cQuery += " 		DA8_TIPROT,		" 
	cQuery += " 		DA8_SERTMS,	 	"
	cQuery += " 		DA5_COD ,		"
	cQuery += " 		DA5_DESC , 		"	 
	cQuery += " 		DA6_ROTA ,		"
	cQuery += " 		DA6_REF   ,	 	"
	cQuery += " 		DA6_PERCUR  	"
	
	cQuery += " ORDER BY  DTC_NUMNFC, " 
	cQuery += " DTC_SERNFC, 		  "
	cQuery += " DTC_CLIREM, 		  " 
	cQuery += " DTC_LOJREM, 		  " 
	cQuery += " DTC_SQEDES, 		  " 
	cQuery += " DTC_SERTMS,  		  "
	cQuery += " A1_CEP,  		 	  "
	cQuery += " DUL_CEP,  		 	  "
	cQuery += " DTC_CDRCAL,			  "
	cQuery += " DA8_COD,  			  	  "
	cQuery += " DA8_DESC,  			      "
	cQuery += " DA8_TIPROT,  			  "
	cQuery += " DA8_SERTMS,  			  "
	cQuery += " DA5COD,  			      "
	cQuery += " DA5DESC ,  			  	  "
	cQuery += " DA6ROTA,  			  	  "
	cQuery += " DA6REF ,  			  	  "
	cQuery += " DA6PERCUR  			 	  "
EndIf
	
If !Empty(cQuery)	
	If !cDbType $ "MSSQL|MSSQL7|ORACLE"
		cQuery := ChangeQuery( cQuery )
	EndIf	
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasDTC, .T., .T. )     

	While (cAliasDTC)->(!Eof())	
		
		//Carrega Grid Rotas,Zonas e Setores	
		If Empty(cRota)  
			nPos:= Ascan(aRotas, (cAliasDTC)->DA8_COD) 
			If nPos == 0
				aAdd(aRotas, (cAliasDTC)->DA8_COD)	
	
				nLinha++						
				aAdd(aLoadDA8,{nLinha,Array(Len(aCamposDA8))})
				For nY := 1 To Len(aCamposDA8)
					If !aCamposDA8[nY][MODEL_FIELD_VIRTUAL]
						aLoadDA8[nLinha][2][nY]	:= (cAliasDTC)->&(aCamposDA8[nY][MODEL_FIELD_IDFIELD])
					Else
						If !(aCamposDA8[nY][MODEL_FIELD_IDFIELD] $ ("DA8_MARK"))
							If (aCamposDA8[nY][MODEL_FIELD_IDFIELD] $ ("DA8_DESSVT"))						
								aLoadDA8[nLinha][2][nY]	:= TMSValField(cAliasDTC+"->DA8_SERTMS",.F.)
							Else                                                                           
								aLoadDA8[nLinha][2][nY]	:= CriaVar(aCamposDA8[nY][MODEL_FIELD_IDFIELD],.T.)
							EndIf	
						EndIf	
					EndIf
				Next nY  
			EndIf	
			
			nPos:= Ascan(aDadosZona, {|x| x[4]+x[1] == (cAliasDTC)->DA8_COD+(cAliasDTC)->DA5COD} )
			If nPos == 0
				aAdd(aDadosZona, {(cAliasDTC)->DA5COD,(cAliasDTC)->DA5DESC,,(cAliasDTC)->DA8_COD} )
			EndIf	
				
			nPos:= Ascan(aDadosSetor, {|x| x[5]+x[2]+x[1] == (cAliasDTC)->DA8_COD+(cAliasDTC)->DA6ROTA+(cAliasDTC)->DA6PERCUR} )
			If nPos == 0
				aAdd(aDadosSetor, {(cAliasDTC)->DA6PERCUR,(cAliasDTC)->DA6ROTA,(cAliasDTC)->DA6REF,,(cAliasDTC)->DA8_COD } )
			EndIf
		Else
			If oMdlGridDoc:SeekLine( {{ "T01_NUMNFC", (cAliasDTC)->DTC_NUMNFC},{ "T01_SERNFC", (cAliasDTC)->DTC_SERNFC },{ "T01_CLIREM", (cAliasDTC)->DTC_CLIREM}, { "T01_LOJREM", (cAliasDTC)->DTC_LOJREM}, { "T01_MARK", .F.} } )
				oMdlGridDoc:LoadValue("T01_MARK",.T.)        //Nao alterar para SetValue - performance
				oMdlGridDoc:LoadValue("T01_CDROTA", cRota)

				aAdd(aLoadTot,{'DTC',oMdlGridDoc:GetValue('T01_SERTMS'),oMdlGridDoc:GetValue('T01_QTDVOL'),oMdlGridDoc:GetValue('T01_PESO'),oMdlGridDoc:GetValue('T01_PESOM3'),;
					oMdlGridDoc:GetValue('T01_VALOR'),0,1,Iif(oMdlGridDoc:GetValue('T01_CRIRAT')== 'A', 1, 0)} )
			EndIf
		EndIf
		
		(cAliasDTC)->(dbSkip())
	EndDo
	(cAliasDTC)->(dbCloseArea())
EndIf
	
oView := FWViewActive()
If oView != Nil
	If oMdlGridDoc != Nil	
		oView:Refresh('VwTotal')				
		oView:Refresh('VwGridDoc')  
	EndIf
EndIf
//--- Atualiza o Totalizador (Rodape) ---
If Len(aLoadTot) > 0
	AEval( aLoadTot, { |x| TM146Total(x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],,x[9]) } )
EndIf

aCamposD8:= aSize(aCamposDA8,0)
Return( aLoadDA8 ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} TM146Cor
Cor da Legenda 
@author Katia
@since 11/08/2014
/*/
//-------------------------------------------------------------------

Function TM146Cor(cItem,cDoc,cBlqDoc,cNumTmp,cNumPrg,cStaPrg,cFilDoc,cSerie,cStatus)
Local cRetorno := ""
Local lRet     := .T.

Default cItem  := 'D'  //D-Documento,V-Veiculos,P-Programacao
Default cDoc   := ""    
Default cStaPrg:= ""          
               
If cItem == 'D'   //Grid Documentos
	cRetorno:= "BR_AMARELO" //Sem Documento
	If !Empty(cDoc)                       
		cRetorno := "BR_AZUL" //Com Documento
	EndIf	
	If cBlqDoc == '1' //Bloqueado
		cRetorno := "BR_PRETO" //Com Documento
	EndIf
	If !Empty(cNumTmp) .Or. !Empty(cNumPrg)
		cRetorno := "BR_VERMELHO" //Com Programacao
	EndIf
                                               
ElseIf cItem == "S" 
	If cBlqDoc == '1' //Bloqueado
		cRetorno := "BR_PRETO" //Com Documento
	EndIf
	If !Empty(cNumTmp) .Or. !Empty(cNumPrg)
		cRetorno := "BR_VERMELHO" //Com Programacao
	EndIf
ElseIf cItem == 'V'  //Grid Veiculos
	If cBlqDoc == 'S'  //Bloqueado
		cRetorno := "BR_VERMELHO"  //Com Restricao
	Else	 
		cRetorno := "BR_VERDE"     //Sem Restricao
	EndIf
		
ElseIf cItem == 'P'  //Programacao de Veiculo
	If cStaPrg == '1'         //Em Aberto
		cRetorno:= "BR_VERDE"    
	ElseIf cStaPrg == "2"     //Efetivada
		cRetorno:= "BR_AZUL"
	ElseIf cStaPrg == "3"     //Documentos Nao transmitidos
		cRetorno:= "BR_VERMELHO"	  
	ElseIf cStaPrg == "9"     //Cancelada
		cRetorno:= "BR_PRETO"	  
	EndIf
ElseIf cItem='DT6'
	If cStatus == '1' .Or. TMSStatCol(cFilDoc,cDoc,cSerie,'1') 
		cRetorno:= "BR_VERDE"     //-- Em aberto
	ElseIf cStatus == '2' .Or. TMSStatCol(cFilDoc,cDoc,cSerie,'2')
		cRetorno:= "BR_VERMELHO"  //-- Carregado ### Indicado para Coleta
	ElseIf cStatus == '3' .Or. TMSStatCol(cFilDoc,cDoc,cSerie,'3')
		cRetorno:= "BR_AMARELO"   //-- Em transito
	ElseIf (cStatus == '4' .And. cSerie <> 'COL' ) .Or. TMSStatCol(cFilDoc,cDoc,cSerie,'5')
		cRetorno:= "BR_LARANJA"  //-- Chegada parcial ### Documento Informado
	ElseIf (cStatus == '5' .And. cSerie <> 'COL' ) .Or. TMSStatCol(cFilDoc,cDoc,cSerie,'4')
		cRetorno:= "BR_AZUL"   //-- Chegada final   ### Encerrada
	ElseIf cStatus == '6'
		cRetorno:= "BR_CINZA"	//-- Indicado p/ entrega
	ElseIf cStatus == '7'
		cRetorno:= "BR_MARRON"	//-- Entregue
	ElseIf	TMSStatCol(cFilDoc,cDoc,cSerie,'9')
		cRetorno:= "BR_PRETO"		//-- Ordem de Coleta Cancelada
	ElseIf cStatus == '8'
		cRetorno:= "BR_PINK"			//Entrega Parcial
	ElseIf cStatus == '9'
		cRetorno:= "BR_CANCEL"		//Anulado
	ElseIf cStatus == 'A'
		cRetorno:= "BR_BRANCO"		//Retorno Total
	ElseIf cStatus == 'B'
		cRetorno:= "PMSEDT4"		//Cancelamento SEFAZ Aguardando
	ElseIf cStatus == "C"
		cRetorno:= "PMSEDT3"		//Cancelamento SEFAZ Autorizado
	ElseIf cStatus == 'D'
		cRetorno:= "PMSEDT1"		//Cancelamento SEFAZ Nao Autorizado
	EndIf	
	If !IsInCallStack('TMSA146MNT') .And. !Empty(cDoc)  .And. DF8->DF8_STATUS <> StrZero(1,Len(DF8->DF8_STATUS ) ) .And. !lIncAuto //Em Aberto 
		lRet:= T146VerVge(cFilDoc,cDoc,cSerie)
		If !lRet
			cRetorno:= 'BR_VIOLETA'  //Docto excluido da viagem
		EndIf
	EndIf		
EndIf	
Return ( cRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TM146CdBar
Funcao do Codigo de Barras  
@author Katia
@since 11/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TM146CdBar()
Local oModel      := FwModelActive()
Local oView       := FWViewActive()
Local oMdlGridDoc := oModel:GetModel("MdGridDoc")
Local cCodBarra   := AllTrim(oModel:GetModel("MdFieldCOD"):GETVALUE('T02_CODBAR'))
Local lRet		  := .T.
Local nLinha      := 0    
FwClearHLP()

cCodBarra := PadR( cCodBarra, TamSx3("DT6_CHVCTE")[1] )

If !Empty(cCodBarra) .And. Substr(cCodBarra, 21, 2) == '55' .And. oMdlGridDoc:SeekLine( {{ "T01_NFEID", cCodBarra}} )
	nLinha := oMdlGridDoc:GetLine()	
ElseIf !Empty(cCodBarra) .And. oMdlGridDoc:SeekLine( {{ "T01_CHVCTE", cCodBarra}} )
	nLinha := oMdlGridDoc:GetLine()	
EndIf

If nLinha > 0
	oMdlGridDoc:GoLine(nLinha)
	oMdlGridDoc:SetValue("T01_MARK",.T.)
ElseIf nLinha == 0
	If !Empty(cCodBarra)
		oModel:GetModel():SetErrorMessage(,,,,,STR0160) //"Não foram encontrados Documentos com esta Chave de CTE"
	EndIf
	lRet:= .F.	
Else
	oView:Refresh('VwGridDoc') 
EndIf

oModel:GetModel("MdFieldCOD"):LoadValue("T02_CODBAR",Space(TamSx3("DT6_CHVCTE")[1]))
oView:Refresh('VwFieldCod') 
oView:GetViewObj("VwFieldCod")[3]:getFWEditCtrl("T02_CODBAR"):oCtrl:SetFocus() 

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} TM146SeqEnd
Endereco de Entrega Solicitante/Sequencia de Endereco 
@author Katia
@since 11/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TM146SeqEnd(cCliRem,cLojRem,cCliDes,cLojDes,cSqeDes,cFilDoc,cDoc,cSerie)
Local cQuery    := ""
Local cAliasDT5 := ""
Local cAliasCol := ""
Local cSeekDUL  := ""
Local aEnd      := {}

Default cCliRem := ""
Default cLojRem := ""
Default cCliDes := ""
Default cLojDes := ""
Default cSqeDes := ""
Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""

If cSerie <> "COL"
	cSeekDUL := xFilial('DUL')+cCliDes + cLojDes + cSqeDes
	
	DUL->(DbSetOrder(2))
	If	DUL->(dBSeek(cSeekDUL))
		If Empty(DUL->DUL_CODRED + DUL->DUL_LOJRED)
			Aadd( aEnd, DUL->DUL_END )
			Aadd( aEnd, DUL->DUL_EST )
			Aadd( aEnd, DUL->DUL_MUN )
			Aadd( aEnd, DUL->DUL_BAIRRO )
			Aadd( aEnd, DUL->DUL_CEP )
		Else
			cAliasCol:= GetNextAlias()									                  
			cQuery := " SELECT "
			cQuery += "	A1_COD, A1_LOJA, A1_CGC, A1_PESSOA,A1_NOME, A1_END, A1_BAIRRO, A1_MUN, A1_EST," 
			cQuery += "   A1_COD_MUN, A1_INSCR, A1_PAIS, A1_DDD, A1_TEL, A1_CEP  "
			cQuery += "  FROM "  
			cQuery += RetSqlName("SA1") + " SA1 "
			cQuery += "  WHERE SA1.A1_FILIAL = '" + xFilial('SA1') + "'"
			cQuery += "	 AND A1_COD = '" + DUL->DUL_CODRED + "'"
			cQuery += "     AND A1_LOJA = '" + DUL->DUL_LOJRED + "'"
			cQuery += "     AND SA1.D_E_L_E_T_ = ' ' "
			If !cDbType $ "MSSQL|MSSQL7|ORACLE"
				cQuery := ChangeQuery(cQuery)
			EndIf	
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasCol,.T.,.T.)
			If !(cAliasCol)->(Eof())
				Aadd( aEnd, (cAliasCol)->A1_END )
				Aadd( aEnd, (cAliasCol)->A1_EST )
				Aadd( aEnd, (cAliasCol)->A1_MUN )
				Aadd( aEnd, (cAliasCol)->A1_BAIRRO )
				Aadd( aEnd, (cAliasCol)->A1_CEP )
			EndIf
			(cAliasCol)->(DbCloseArea())
		EndIf		
	EndIf	
Else   //Solicitacao de Coleta
	cAliasDT5:= GetNextAlias()
	cQuery := " SELECT  "
	cQuery += "   DUE_CODCLI, DUE_LOJCLI, DUE_NREDUZ, DUE_END, DUE_BAIRRO, DUE_CODMUN,DUE_MUN, DUE_EST, DUE_CEP,"
	cQuery += "   DUL_CODRED, DUL_LOJRED, DUL_CODCLI, DUL_LOJCLI, DUL_END, DUL_BAIRRO, DUL_CODMUN, DUL_MUN, DUL_EST, DUL_CEP, "
	cQuery += "   A1_COD, A1_LOJA, A1_CGC, A1_PESSOA,A1_NOME, A1_END, A1_BAIRRO, A1_MUN, A1_EST," 
	cQuery += "   A1_COD_MUN, A1_INSCR, A1_PAIS, A1_DDD, A1_TEL, A1_CEP  "
	cQuery += "	FROM " + RetSQLName("DT5") + " DT5 "
	
	cQuery += "  INNER JOIN " + RetSQLName("DUE") + " DUE "
	cQuery += "   ON DUE_FILIAL = '" + xFilial('DUE') + "'" 
	cQuery += "    AND DUE_CODSOL = DT5_CODSOL "
	cQuery += "    AND DUE.D_E_L_E_T_ = ' ' "
	
	cQuery += "  LEFT JOIN " + RetSqlName("DUL") + " DUL "
	cQuery += "   ON DUL_FILIAL = '" + xFilial('DUL') + "'"
	cQuery += "	   AND DUL_CODSOL = DT5_CODSOL "
	cQuery += "	   AND DUL_SEQEND = DT5_SEQEND "
	cQuery += "	   AND DUL.D_E_L_E_T_ = ' ' "
	
	cQuery += "	 LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += "	 	ON SA1.A1_FILIAL = '" + xFilial('SA1') + "'"
	cQuery += "	 	   AND A1_COD  = DUL.DUL_CODRED "
	cQuery += "        AND A1_LOJA = DUL.DUL_LOJRED "
	cQuery += "        AND SA1.D_E_L_E_T_ = ' ' 	"
	
	cQuery += "  WHERE DT5_FILIAL	= '" + xFilial("DT5") + "' "
	cQuery += "    AND DT5_FILDOC  = '" + cFilDoc + "' "
	cQuery += "    AND DT5_DOC  = '" + cDoc + "' "
	cQuery += "    AND DT5_SERIE  = '" + cSerie + "' "
	cQuery += "    AND DT5.D_E_L_E_T_ = ' ' "
	
	If !cDbType $ "MSSQL|MSSQL7|ORACLE"
		cQuery := ChangeQuery(cQuery)
	EndIf	
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDT5,.T.,.T.)
					
	If !(cAliasDT5)->(Eof())
		If (Empty(Alltrim((cAliasDT5)->DUL_CODRED)) .And. Empty(Alltrim((cAliasDT5)->DUL_LOJRED)))
			If Empty((cAliasDT5)->(DUL_END))
				Aadd( aEnd, (cAliasDT5)->DUE_END )
				Aadd( aEnd, (cAliasDT5)->DUE_EST )
				Aadd( aEnd, (cAliasDT5)->DUE_MUN )							
				Aadd( aEnd, (cAliasDT5)->DUE_BAIRRO )
				Aadd( aEnd, (cAliasDT5)->DUE_CEP )
			Else
				Aadd( aEnd, (cAliasDT5)->DUL_END )
				Aadd( aEnd, (cAliasDT5)->DUL_EST )
				Aadd( aEnd, (cAliasDT5)->DUL_MUN )							
				Aadd( aEnd, (cAliasDT5)->DUL_BAIRRO )
				Aadd( aEnd, (cAliasDT5)->DUL_CEP )
			EndIf	
		Else
			Aadd( aEnd, (cAliasDT5)->A1_END )
			Aadd( aEnd, (cAliasDT5)->A1_EST )
			Aadd( aEnd, (cAliasDT5)->A1_MUN )
			Aadd( aEnd, (cAliasDT5)->A1_BAIRRO )
			Aadd( aEnd, (cAliasDT5)->A1_CEP )
		EndIf
					
	EndIf
	(cAliasDT5)->(DbCloseArea())
	
EndIf

Return aEnd

//-------------------------------------------------------------------
/*/{Protheus.doc} T146MrkDoc
Marca um Documento  
@author Katia
@since 26/08/2014
/*/
//-------------------------------------------------------------------
Static Function T146MrkDoc()
Local oView      := FWViewActive()
Local oModel     := FwModelActive()
Local oMdlGridDoc:= oModel:GetModel("MdGridDoc")
Local cFilDoc    := FwFldGet("T01_FILDOC")
Local cDoc       := FwFldGet("T01_DOC")
Local cSerie     := FwFldGet("T01_SERIE")
Local cNumNfc    := FwFldGet("T01_NUMNFC")
Local cSerNfc    := FwFldGet("T01_SERNFC")
Local cCliRem    := FwFldGet("T01_CLIREM")
Local cLojRem    := FwFldGet("T01_LOJREM")
Local lMark      := FwFldGet("T01_MARK")
Local lRateio    := Iif(!IsInCallStack("T146CarVei") .And. !IsInCallStack("T146CarPrg") .And. FwFldGet("T01_RATEIO") == '1' ,.T.,.F.)  //Sim
Local cFilOri    := FwFldGet("T01_FILORI")
Local cLotNfc    := FwFldGet("T01_LOTNFC")
Local aArea      := GetArea()
Local nLinha     := 0
Local lRet		 := .T.
Local aSaveLine  := FWSaveRows()
Local cNumTmp    := ""
Local cSeqTmp    := ""
Local lAtuGrid   := Iif(!Empty(FwFldGet("T01_NUMPRG")),.F., .T. ) //!IsInCallStack('T146CarVei') .And. !IsInCallStack('T146CarPrg')
Local cAlias     := ""
Local cServTms   := ""
Local nQtdVol    := 0
Local nPeso      := 0 
Local nPesoM3    := 0
Local nValMer    := 0
Local nValFre    := 0
Local nDoc       := 0
Local lContinua  := .T.
Local cTipReg	   := ""
Local lDesmrkDF1 := .T.
Local aMrkDoc    := {}
Local nLinAtu    := oMdlGridDoc:GetLine()
Local nPos       := 0
Local aNfsLot    := {}
Local nDocRat    := 0
Local lDocRat    := Iif(oMdlGridDoc:GetValue('T01_RATEIO') == StrZero(1,Len(DTP->DTP_RATEIO)),.T.,.F.)
Local cLockByDoc := "PRGCARR" + cFilDoc + cDoc + cSerie

If !lMark  //Desmarcou o Docto, desmarcar todos os documentos relacionados
	lMark:= .T.   //Procura todos os documentos marcados e desmarca
	UnLockByName(cLockByDoc,.T.,.F.)
Else
	lMark:= .F.	
	If !LockByName(cLockByDoc,.T.,.F.)
		FWRestRows( aSaveLine )
		RestArea(aArea)
		//Help('',1,"T146MrkDoc1",, STR0205, 3, 0)  //-- Documento já selecionado por outro usuário.
		oModel:GetModel():SetErrorMessage(,,,,,STR0205)
		Return .F.
	EndIf
	//-- Busca a ultima sequencia de entrega
EndIf

If lMark 
    cTipReg := "1" //Usado 
Else
    cTipReg := "2" // Não Usado
EndIf
	
If lRet
	If lAtuGrid
		cServTms:= oMdlGridDoc:GetValue('T01_SERTMS')
		If lRateio .AND. !IsInCallStack("TMSAF76") 
			aAdd(aNfsLot, {oMdlGridDoc:GetValue('T01_FILORI'),oMdlGridDoc:GetValue('T01_NUMNFC'),oMdlGridDoc:GetValue('T01_SERNFC'),;
					     oMdlGridDoc:GetValue('T01_CLIREM'),oMdlGridDoc:GetValue('T01_LOJREM')} )
		EndIf
		nDoc    := 1
		nQtdVol := oMdlGridDoc:GetValue('T01_QTDVOL')
		nPeso   := oMdlGridDoc:GetValue('T01_PESO')
		nPesoM3 := oMdlGridDoc:GetValue('T01_PESOM3')
		nValMer := oMdlGridDoc:GetValue('T01_VALOR')
		nValFre := oMdlGridDoc:GetValue('T01_VALFRE')
		If oMdlGridDoc:GetValue('T01_CRIRAT') == 'A'  //Lote de Rateio com Criterio  
			nDocRat:= 1
		EndIf
		
		If  !Empty(oMdlGridDoc:GetValue('T01_DOC'))
			cAlias:= 'DT6'
			If IsInCallStack("T146CarVei") .OR. IsInCallStack("T146CarPrg") 
				lDesmrkDF1 := .F.
			EndIf
			lContinua := TMSAVerAge("3",,,,,,,,,oMdlGridDoc:GetValue('T01_FILDOC'),oMdlGridDoc:GetValue('T01_DOC'),,cTipReg,lDesmrkDF1,.T.,,,)
		Else
			cAlias:= 'DTC'
			lContinua := TMSAVerAge("2",,,,oMdlGridDoc:GetValue('T01_CLIREM'),oMdlGridDoc:GetValue('T01_LOJREM'),oMdlGridDoc:GetValue('T01_NUMNFC'),oMdlGridDoc:GetValue('T01_SERNFC'),,,,,cTipReg,lDesmrkDF1,.T.,,,)
		EndIf

		If lContinua
			If lRateio .AND. !IsInCallStack("TMSAF76") 
				aMrkDoc :=  { {"T01_FILORI", cFilOri}, {"T01_LOTNFC", cLotNfc}, {"T01_MARK", lMark } }  //Doctos Rateio                
			Else
				aMrkDoc :=  { {"T01_FILDOC", cFilDoc}, {"T01_DOC", cDoc}, {"T01_SERIE", cSerie}, {"T01_FILORI", cFilOri}, {"T01_NUMNFC", cNumNfc},{"T01_SERNFC", cSerNfc},;
				                           {"T01_CLIREM", cCliRem}, {"T01_LOJREM", cLojRem}, {"T01_MARK", lMark } }  //Entrega                
			EndIf
			
			While oMdlGridDoc:SeekLine( aMrkDoc ) 
			
				nLinha := oMdlGridDoc:GetLine()
				oMdlGridDoc:GoLine(nLinha)
				
				If lMark                                
					oMdlGridDoc:LoadValue("T01_MARK",.F.)
					oMdlGridDoc:LoadValue("T01_SEQENT", '')
					oMdlGridDoc:LoadValue("T01_CDROTA", '')
				Else
					oMdlGridDoc:LoadValue("T01_MARK",.T.)
					If Empty(oMdlGridDoc:GetValue('T01_NUMTMP'))   //Quando marca um Documento para desmarcar
						oMdlGridDoc:LoadValue("T01_NUMTMP",cNumTmp)
						oMdlGridDoc:LoadValue("T01_SEQPRG",cSeqTmp)
					EndIf	
				EndIf	
				
				nQtdVol += oMdlGridDoc:GetValue('T01_QTDVOL')
				nPeso   += oMdlGridDoc:GetValue('T01_PESO')
				nPesoM3 += oMdlGridDoc:GetValue('T01_PESOM3')
				nValMer += oMdlGridDoc:GetValue('T01_VALOR')
				nValFre += oMdlGridDoc:GetValue('T01_VALFRE')
				
				If lRateio .AND. !IsInCallStack("TMSAF76") 
					nPos:= Ascan(aNfsLot, { |x| x[1]+x[2]+x[3]+x[4]+x[5] == oMdlGridDoc:GetValue('T01_FILORI') + oMdlGridDoc:GetValue('T01_NUMNFC');
						                                               + oMdlGridDoc:GetValue('T01_SERNFC') + oMdlGridDoc:GetValue('T01_CLIREM')+;
						                                                oMdlGridDoc:GetValue('T01_LOJREM') })
					If nPos == 0
						aAdd(aNfsLot, {oMdlGridDoc:GetValue('T01_FILORI'),oMdlGridDoc:GetValue('T01_NUMNFC'),oMdlGridDoc:GetValue('T01_SERNFC'),;
					                  oMdlGridDoc:GetValue('T01_CLIREM'),oMdlGridDoc:GetValue('T01_LOJREM')} )
						nDoc++
					EndIf
					
					If oMdlGridDoc:GetValue('T01_CRIRAT') == 'A'
						nDocRat:= nDoc
					EndIf		
				EndIf
				
			EndDo
			If lMark
				nDoc:= nDoc * (-1)
				nDocRat:= nDocRat * (-1)
				
				nQtdVol := nQtdVol * (-1)
				nPeso   := nPeso   * (-1)
				nPesoM3 := nPesoM3 * (-1)
				nValMer := nValMer * (-1) 
				nValFre := nValFre * (-1)
				
				If oMdlGridDoc:GetValue('T01_CRIRAT') == 'A'
					nDocRat:= nDoc
				EndIf
			EndIf
			If !IsInCallStack("T146CarPrg") .Or. (IsInCallStack("T146CarPrg") .And. lMark)
				TM146Total(cAlias,cServTms,nQtdVol,nPeso,nPesoM3,nValMer,nValFre,nDoc,,nDocRat)
			EndIf	
		EndIf
	ElseIf lDocRat  .AND. !IsInCallStack("TMSAF76") 
		aMrkDoc :=  { {"T01_FILORI", cFilOri}, {"T01_LOTNFC", cLotNfc}, {"T01_MARK", lMark } }  //Doctos Rateio                
		While oMdlGridDoc:SeekLine( aMrkDoc ) 
			nLinha := oMdlGridDoc:GetLine()
			oMdlGridDoc:GoLine(nLinha)
			oMdlGridDoc:LoadValue("T01_MARK", Iif(!lMark,.T.,.F.))
		EndDo	
	EndIf
EndIf
If lContinua
	oMdlGridDoc:GoLine(nLinAtu)	 
	oView:Refresh('VwGridDoc')	
EndIf

FWRestRows( aSaveLine )

//Nega o Valor da campo Mark caso o processamento tenha falhado
If !lContinua
	FwFldPut("T01_MARK",!FwFldGet("T01_MARK"),,,,.T.) 
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TM146MrkTd
Marca e Desmarca Todos Documentos  
@author Katia
@since 26/08/2014
/*/
//-------------------------------------------------------------------
Static Function TM146MrkTd()
Local oModel       := FwModelActive()
Local oMdlGridDoc  := oModel:GetModel('MdGridDoc')
Local lFlagTodos   := FwFldGet("T02_TODOS")
Local aSaveLine    := FWSaveRows()
Local lRetorno     := .T.
Local cTabela      := 'DT6'
Local lRet         := .T.
Local oView        := FWViewActive()
Local oFormGrid    := oView:GetSubView('VwGridDoc')
Local aLines       := oFormGrid:GetFilLines()
Local nX           := 0
Local lContinua    := .T.
Local cTipReg	     := ""
Local oMdlTotal    := oModel:GetModel('MdTotal')
Local oStructTot   := oMdlTotal:GetStruct()
Local aCamposTot   := aClone(oStructTot:GetFields())
Local cLockByDoc   := ""

//Zerar totdas as variáveis do total antes de marcar os documentos
If lFlagTodos
	T146LimTot(aCamposTot,oMdlTotal)   
EndIf

If lFlagTodos 
    cTipReg := "2" // Não Usado 
Else
    cTipReg := "1" //Usado 
EndIf

If oMdlGridDoc:IsEmpty()
	Help("",1,"HELP","MarkConta",'Linha em Branco',1)//"Linha em branco"
	lRetorno := .F.
Else
 	For nX := 1 To Len(aLines)
		oMdlGridDoc:GoLine(aLines[nX])
		
		//-- Monta chave para travar o registro para uso por outros usuários.
		cLockByDoc := "PRGCARR" + FwFldGet("T01_FILDOC") + FwFldGet("T01_DOC") + FwFldGet("T01_SERIE")

		If lFlagTodos
			lRet:= TMA146VDoc(oMdlGridDoc:GetValue('T01_SERTMS'),'D')
			If !lRet
				Exit
			EndIf
		EndIf
		
		If Empty(oMdlGridDoc:GetValue('T01_DOC'))
			cTabela:= 'DTC'
			lContinua := TMSAVerAge("2",,,,oMdlGridDoc:GetValue('T01_CLIREM'),oMdlGridDoc:GetValue('T01_LOJREM'),oMdlGridDoc:GetValue('T01_NUMNFC'),oMdlGridDoc:GetValue('T01_SERNFC'),,,,,cTipReg,.T.,.F.,,,)
		Else
			cTabela:= 'DT6'
			lContinua := TMSAVerAge("3",,,,,,,,,oMdlGridDoc:GetValue('T01_FILDOC'),oMdlGridDoc:GetValue('T01_DOC'),,cTipReg,.T.,.F.,,,)
		EndIf
		If lContinua
			If	lFlagTodos
				//-- Trava o documento para uso por outro usuário e realiza a marcação.
				If LockByName(cLockByDoc,.T.,.F.)
					If lRet .And. Empty(oMdlGridDoc:GetValue('T01_NUMTMP'))     
						oMdlGridDoc:LoadValue("T01_MARK", .T.)  //Nao mudar para SetValue - Performance
						TM146Total(cTabela,oMdlGridDoc:GetValue('T01_SERTMS'),oMdlGridDoc:GetValue('T01_QTDVOL'),oMdlGridDoc:GetValue('T01_PESO'),oMdlGridDoc:GetValue('T01_PESOM3'),oMdlGridDoc:GetValue('T01_VALOR'),;
						oMdlGridDoc:GetValue('T01_VALFRE'),1,,Iif(oMdlGridDoc:GetValue('T01_CRIRAT') == 'A', 1, 0))
					EndIf	
				EndIf
			Else
				If oMdlGridDoc:GetValue("T01_MARK")
					oMdlGridDoc:LoadValue("T01_MARK", .F.)      //Nao mudar para SetValue - Performance
					TM146Total(cTabela,oMdlGridDoc:GetValue('T01_SERTMS'),oMdlGridDoc:GetValue('T01_QTDVOL')*(-1),oMdlGridDoc:GetValue('T01_PESO')*(-1),oMdlGridDoc:GetValue('T01_PESOM3')*(-1),;
					oMdlGridDoc:GetValue('T01_VALOR')*(-1),oMdlGridDoc:GetValue('T01_VALFRE')*(-1),-1,,Iif(oMdlGridDoc:GetValue('T01_CRIRAT') == 'A', -1, 0))
					
					//--Destrava o documento para uso por outro usuário
					UnLockByName(cLockByDoc,.T.,.F.)
				EndIf	
			EndIf
		EndIf
	Next nX	
EndIf	               

FWRestRows( aSaveLine )
oView:Refresh('VwGridDoc')	
Return( lRetorno )


//-------------------------------------------------------------------
/*/{Protheus.doc} TM146Marca
Marca os registro de Rota/Zona e Setor
@author Katia
@since 26/08/2014
/*/
//-------------------------------------------------------------------
Static Function TM146Marca(cTipo)
Local oView        := FWViewActive()     
Local oMdlGridZon  := oView:GetModel('MdGridZon')  
Local oMdlGridRot  := oView:GetModel('MdGridRot')  
Local oMdlGridSet  := oView:GetModel('MdGridSet')  
Local oMdlGridDoc  := oView:GetModel('MdGridDoc')
Local oMdlGridDF8  := oView:GetModel('MdGridDF8')
Local cRota        := oMdlGridRot:GetValue( "DA8_COD")
Local lMarkRota    := oMdlGridRot:GetValue( "DA8_MARK")
Local lMark        := .F.
Local aSaveLine    := {}
Local lRetorno     := .T.
Local nI           := 0
Local nCountI      := 1
Local nII          := 0
Local nCountII     := 1
Local aZonas       := {}
Local aSetores     := {}
Local nLinha       := 0
Local cCodDA5      := ""
Local cCodDA6      := ""

If Empty(cTipo)
	Return .F.
EndIf

If cTipo == "R"   //Rota
	lMark:= oMdlGridRot:GetValue( "DA8_MARK")       
	aSaveLine:= FWSaveRows()
	
	If IsInCallStack("TMSA146ALT") .AND. lMark
		If oMdlGridRot:GetValue( "DA8_COD")  != oMdlGridDF8:GetValue("DF8_ROTA")
			oMdlGridRot:LoadValue( "DA8_MARK", .F.)
			oView:Refresh('VwGridRot')
			Help('',1,'TMSA14643')  //"Só poderá ser marcada a rota já utilizada na Programação"
			Return .T.
		EndIf
	EndIf
ElseIf cTipo == "Z"  //Zona
	lMark:= oMdlGridZon:GetValue( "DA5_MARK")
	cCodDA5:= oMdlGridZon:GetValue('DA5_COD')
Else                                           
	lMark  := oMdlGridSet:GetValue( "DA6_MARK")
	cCodDA6:= oMdlGridSet:GetValue('DA6_PERCUR')
EndIf                     

If lMark 
	If !lMarkRota
		oMdlGridRot:SetValue("DA8_MARK" ,.T.)
	EndIf
	
	If cTipo == "R"
				
		//-- Carrega Grid Zona
		oMdlGridZon:SetNoInsertLine( .F. )
		If Empty(oMdlGridZon:GetValue('DA5_COD',1))	
			For nI:= 1  To Len(aDadosZona)
				If aDadosZona[nI][4] == cRota .And. !Empty(aDadosZona[nI][2]) //Condicacao, pois rotas de Transferencia nao tem Zona
					If nCountI > 1 
						oMdlGridZon:Addline()
					EndIf
					oMdlGridZon:GoLine(nCountI)
				   	oMdlGridZon:LoadValue("DA5_COD"   ,aDadosZona[nI][1])
					oMdlGridZon:SetValue("DA5_DESC"   ,aDadosZona[nI][2])
					oMdlGridZon:SetValue("DA5_CDROTA" ,aDadosZona[nI][4])
					oMdlGridZon:LoadValue("DA5_MARK"  ,.T.)
					nCountI++                            
					aAdd(aZonas,(aDadosZona[nI][1]))
				EndIf
			Next nI 
		Else
			For nI:= 1 To oMdlGridZon:Length()		
				oMdlGridZon:GoLine(nI)
				oMdlGridZon:LoadValue("DA5_MARK"  ,.T.)
				aAdd(aZonas,(FwFldGet("DA5_COD")))
			Next nI	
		EndIf
		oMdlGridZon:SetNoInsertLine( .T. )      	    
		oMdlGridZon:GoLine(1)
		
		//-- Carrega Grid Setor
    	oMdlGridSet:SetNoInsertLine( .F. )
        If Empty(oMdlGridSet:GetValue('DA6_ROTA',1)) 
			For nI:= 1  To oMdlGridZon:Length()
				If oMdlGridZon:GetValue('DA5_MARK') == .T. 
					For nII:= 1  To Len(aDadosSetor)
						If !Empty(aDadosSetor[nII][2]) //Condicao, pois rotas de Transferencia nao tem Zona
							If aDadosSetor[nII][5] == cRota .And. aDadosSetor[nII][1] == FwFldGet('DA5_COD',nI) 
								If nCountII > 1 
									oMdlGridSet:Addline()
								EndIf
								oMdlGridSet:GoLine(nCountII)
								oMdlGridSet:LoadValue("DA6_ROTA"   ,aDadosSetor[nII][2])
								oMdlGridSet:SetValue("DA6_REF"     ,aDadosSetor[nII][3])
							   	oMdlGridSet:SetValue("DA6_PERCUR"  ,aDadosSetor[nII][1])
								oMdlGridSet:SetValue("DA6_CDROTA"  ,aDadosSetor[nII][5])			
								oMdlGridSet:LoadValue("DA6_MARK"    ,.T.)
								nCountII++
					
								aAdd(aSetores,(aDadosSetor[nII][2]))						
							EndIf
						EndIf
					Next nII
				EndIf	
   			Next nI
   		Else
   			For nI:= 1 To oMdlGridSet:Length()		
				oMdlGridSet:GoLine(nI)
				oMdlGridSet:LoadValue("DA6_MARK"  ,.T.)
				aAdd(aSetores,(FwFldGet("DA6_ROTA")))
			Next nI	
   		EndIf	 
	   	oMdlGridSet:SetNoInsertLine( .T. )
		oMdlGridSet:GoLine(1)	
	Else
		For nI:= 1  To oMdlGridSet:Length()
			oMdlGridSet:GoLine(nI)
			If FwFldGet('DA6_MARK')
				aAdd(aSetores,(FwFldGet('DA6_ROTA')))
			Else
				If  cTipo == "Z"  //Zona, marca os Setores
					If FwFldGet('DA6_PERCUR')  == cCodDA5 
						oMdlGridSet:LoadValue("DA6_MARK"    ,.T.)
						aAdd(aSetores,(FwFldGet('DA6_ROTA')))
					EndIf
				EndIf
			EndIf	
		Next nI
		oMdlGridSet:GoLine(1)
		
		For nI:= 1  To oMdlGridZon:Length()
			oMdlGridZon:GoLine(nI)
			If FwFldGet('DA5_MARK')
				aAdd(aZonas,(FwFldGet('DA5_COD')))
			Else
				If cTipo == "S"  //Setor, marca as Zonas
					If FwFldGet('DA5_COD')  == cCodDA6 
						oMdlGridZon:LoadValue("DA5_MARK"    ,.T.)
						aAdd(aZonas,(FwFldGet('DA5_COD')))
					EndIf	
				EndIf	
			EndIf	
		Next nI
		oMdlGridZon:GoLine(1)
		
	EndIf

Else     
	//Ao desmarcar uma Zona deverá desmarcar os Setores
	If cTipo <> "R"
		For nI:= 1  To oMdlGridSet:Length()
			If oMdlGridSet:GetValue('DA6_MARK',nI)
				If cTipo == "Z" 
					If oMdlGridSet:GetValue('DA6_PERCUR',nI)  == cCodDA5
						oMdlGridSet:GoLine(nI) 
						oMdlGridSet:LoadValue("DA6_MARK" , .F.)
					Else
						aAdd(aSetores,(oMdlGridSet:GetValue('DA6_ROTA',nI)))	
					EndIf	
				Else
					aAdd(aSetores,(oMdlGridSet:GetValue('DA6_ROTA',nI)))	
				EndIf					
			EndIf
		Next nI
		oMdlGridSet:GoLine(1)
			    
		For nI:= 1  To oMdlGridZon:Length()
			If oMdlGridZon:GetValue('DA5_MARK',nI)
				If cTipo == "S" 
					If oMdlGridZon:GetValue('DA5_COD',nI)  == cCodDA6
						oMdlGridZon:GoLine(nI) 
						oMdlGridZon:LoadValue("DA5_MARK" , .F.)
					Else	
						aAdd(aZonas,(oMdlGridZon:GetValue('DA5_COD',nI)))
					EndIf
				Else	
					aAdd(aZonas,(oMdlGridZon:GetValue('DA5_COD',nI)))
				EndIf
			EndIf	
		Next nI 
		oMdlGridZon:GoLine(1)
	Else
	
		While oMdlGridSet:SeekLine( {{ "DA6_MARK", .T.},{ "DA6_CDROTA", cRota }} )
			nLinha := oMdlGridSet:GetLine()
			oMdlGridSet:GoLine(nLinha)
			oMdlGridSet:LoadValue("DA6_MARK",.F.)
		EndDo
					  
		While oMdlGridZon:SeekLine( {{ "DA5_MARK", .T.},{ "DA5_CDROTA", cRota }} )
			nLinha := oMdlGridZon:GetLine()
			oMdlGridZon:GoLine(nLinha)
			oMdlGridZon:LoadValue("DA5_MARK",.F.)
		EndDo
	EndIf
	
	While oMdlGridDoc:SeekLine( {{ "T01_MARK", .T.} , { "T01_CDROTA", cRota } } )
		oMdlGridDoc:SetValue("T01_MARK",.F.)
		oMdlGridDoc:SetValue("T01_CDROTA", '') 
	EndDo
	oView:Refresh('VwGridDoc') 
EndIf
    
If lMarkRota .And. !Empty(cRota)  
	TM146LdRot(oMdlGridRot,oMdlGridDoc,cRota,aZonas,aSetores,.T.)
EndIf	
If cTipo == "R"
	FWRestRows( aSaveLine )
EndIf

oView:Refresh('VwGridSet')
oView:Refresh('VwGridZon')
oView:Refresh('VwGridRot')

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TM146ChkR
Desmarca o registro de Rota  
@author Katia
@since 26/08/2014
/*/
//-------------------------------------------------------------------
Static Function TM146ChkR()    

Local oModel      := FwModelActive()       
Local oMdlGridRot  := oModel:GetModel('MdGridRot')
Local cRota        := FwFldGet('DA8_COD')
Local cServTms     := FwFldGet('DA8_SERTMS')
Local lMark        := FwFldGet('DA8_MARK')
Local aSaveLine    := FWSaveRows()
Local lRetorno     := .T.    
Local cSerPesq     := "" 
FwClearHLP()
If lMark                                             
	If oMdlGridRot:SeekLine( {{ "DA8_MARK", .T.}, { "DA8_SERTMS", cServTms}} )  
		If oMdlGridRot:GetValue( "DA8_COD" ) <> cRota   //nao permite selecionar rotas do mesmo servico
			oModel:GetModel():SetErrorMessage(,,,,,STR0158) //"Nao é permitido selecionar mais de uma rota com o mesmo Servico de Transporte"
			lRetorno:= .F.
		EndIf  
	EndIf 
	
	//-- Nao permite selecionar rota de Coleta x Transferencia (mv_par02) 
	If cServTms == '1'   //Servico de Coleta
		cSerPesq:= '2'   //Servico de Transferencia
	ElseIf cServTms == '2'
		cSerPesq:= '1'
	EndIf
	
	If cServTms $ '1|2'   
		If oMdlGridRot:SeekLine( {{ "DA8_MARK", .T.}, { "DA8_SERTMS", cSerPesq }} )
			//Se o Servico Adicional estiver habilitado, e a Rota de Transferencia já estiver sido marcada, somente permitirá marcar a Rota de Coleta;
			//se a Rota de Entrega já estiver sido marcada.                                                                
			If cSerAdi == '0' //.Or. (cSerAdi == '1' .And. !oMdlGridRot:SeekLine( {{ "DA8_MARK", .T.}, { "DA8_SERTMS", '3' }} ) )
				oModel:GetModel():SetErrorMessage(,,,,,STR0162) //"Nao é permitido selecionar Documentos com Servico de Coleta e Transferencia ! "
				lRetorno:= .F.
			EndIf	
		EndIf
	EndIf	
EndIf

FWRestRows( aSaveLine )
Return( lRetorno )


//-------------------------------------------------------------------
/*/{Protheus.doc} T146SelDT6
Seleciona os registros da DT6 - Documento de Transporte
@author Katia
@since 11/09/2014
/*/
//-------------------------------------------------------------------
Static Function T146SelDT6( cTpSel, cFilDest, cFilDe, cFilAte )

Local cQuery     := ""    
Local lBloqueado := mv_par19 == 1                        
Local lAgdEntr   := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)   //-- Agendamento de Entrega.
Local lColeta    := .F.
Local lTelMark  := IsInCallStack("A146SrAdPn")

Local lTMSDCol := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.

Default cTpSel  := D    //D- Documentos ou R-Rota
Default cFilDest:= ""
Default cFilDe  := ""
Default cFilAte := ""

If mv_par26 == '1' .Or. Empty(mv_par26)   //Selecionou servico coleta, nao deve verificar o DT6_FILDES
	lColeta:= .T.
EndIf   

If !lTelMark	
	cQuery += "   AND   ( DT6.DT6_DATEMI BETWEEN '" + dDtEmiIni + "' AND '" + dDtEmiFim + "' ) "   
EndIf

If cDbType == "POSTGRES"
	cQuery += "   AND CASE WHEN DT6.DT6_SERIE = 'COL' THEN DT6.DT6_PRZENT BETWEEN '" + Space(8) + "' AND '99999999' "
	cQuery += "                              ELSE DT6.DT6_PRZENT BETWEEN '" + dDtPrvIni + "' AND '" + dDtPrvFim + "' END "
Else
	cQuery += "   AND   ( DT6.DT6_PRZENT BETWEEN (CASE WHEN DT6.DT6_SERIE = 'COL' THEN '" + Space(8) + "' ELSE '" + dDtPrvIni + "' END) " 
	cQuery += "                              AND (CASE WHEN DT6.DT6_SERIE = 'COL' THEN '99999999' ELSE '" + dDtPrvFim + "' END) )"
EndIf

cQuery += "   AND  DT6_CDRORI    >= '" + Iif(!lTelMark,mv_par12  ,Replicate( "" ,TamSx3("DT6_CDRORI")[1] ))+ "'"
cQuery += "   AND  DT6_CDRORI    <= '" + Iif(!lTelMark,mv_par13  ,Replicate( "Z" ,TamSx3("DT6_CDRORI")[1] ))+ "'"

If !Empty(cFilDest) 
	If lColeta
		cQuery += " AND  (DT6_FILDES = ' '  OR  DT6_FILDES IN (" + cFilDest + "))"
	Else
		cQuery += "   AND  DT6_FILDES IN (" + cFilDest + ")"
	EndIf	
Else
	If lColeta .And. cFilDe <> ' '
		cQuery += " AND  (DT6_FILDES = ' ' "
		cQuery += " OR   (DT6_FILDES >= " + Iif(!lTelMark, cFilDe, "'" + Replicate( "", TamSx3("DT6_FILDES")[1]) + "'")
		cQuery += " AND  DT6_FILDES <= " + Iif(!lTelMark, cFilAte, "'" + Replicate( "Z", TamSx3("DT6_FILDES")[1] ) + "'") + "))"
	Else
		cQuery += " AND  DT6_FILDES >= '" + Iif(!lTelMark, cFilDe, Replicate( "", TamSx3("DT6_FILDES")[1])) + "'"
		cQuery += " AND  DT6_FILDES <= '" + Iif(!lTelMark, cFilAte, Replicate( "Z", TamSx3("DT6_FILDES")[1] )) + "'"
	EndIf				
EndIf

If lBloqueado
		cQuery+= "  AND DT6_BLQDOC = '1' "  
EndIf
cQuery += "   AND  DT6.DT6_STATUS NOT IN ('7','9') AND DT6.D_E_L_E_T_ = ' ' "

// Painel de Agendamento
If IsInCallStack("TMSAF76") .AND. cTpSel == 'D'  
	cQuery += "  INNER JOIN " + RetSqlName("DF1") + " DF1  "
	cQuery += 				" ON DF1.DF1_FILIAL = '"+ FwxFilial("DF1") +"'"
	cQuery += 				" AND DF1.DF1_FILDOC = DT6.DT6_FILDOC "
	cQuery += 				" AND DF1.DF1_DOC = DT6.DT6_DOC  "
	cQuery += 				" AND DF1.DF1_SERIE = DT6.DT6_SERIE "
	cQuery += 				" AND DF1.D_E_L_E_T_ = ' ' "
EndIf

If lAgdEntr //.And. cSerTMS == "3"
	cQuery += " LEFT JOIN  " + RetSqlName("DYD") + " DYD"
	cQuery += 				" ON  DYD.DYD_FILIAL  =  '"+xFilial('DYD')+"'"
	cQuery += 				" AND  DYD.DYD_NUMAGD  =  DT6.DT6_NUMAGD"
	cQuery += 				" AND  DYD.DYD_TIPAGD  >= '" + cValToChar(MV_PAR22)  + "'"
	cQuery += 				" AND  DYD.DYD_TIPAGD  <= '" + cValToChar(MV_PAR23)  + "'"			
	cQuery += 				" AND  DYD.D_E_L_E_T_  =  ' '"
EndIf
If cTpSel <> 'R'  
	cQuery += " LEFT JOIN " + RetSqlName("SA1") + " REM "      
	cQuery += 				" ON  REM.A1_FILIAL  = '"+xFilial('SA1')+"'"
	cQuery += 				" AND  REM.A1_COD     = DT6_CLIREM"
	cQuery += 				" AND  REM.A1_LOJA    = DT6_LOJREM"
	cQuery += 				" AND  REM.D_E_L_E_T_ = ' '"          
	cQuery += " LEFT JOIN " + RetSqlName("SA1") + " DES "
	cQuery += 				" ON  DES.A1_FILIAL  = '"+xFilial('SA1')+"'"
	cQuery += 				" AND  DES.A1_COD     = DT6_CLIDES"
	cQuery += 				" AND  DES.A1_LOJA    = DT6_LOJDES"
	cQuery += 				" AND  DES.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN " + RetSqlName("SA1") + " DEV "
	cQuery += 				" ON  DEV.A1_FILIAL  = '"+xFilial('SA1')+"'"
	cQuery += 				" AND  DEV.A1_COD     = DT6_CLIDEV"
	cQuery += 				" AND  DEV.A1_LOJA    = DT6_LOJDEV"
	cQuery += 				" AND  DEV.D_E_L_E_T_ = ' '"
EndIf

cQuery += " LEFT JOIN " + RetSqlName("SX5") + " SX5 "
cQuery += 				" ON SX5.X5_FILIAL ='"  + xFilial("SX5") + "'"
cQuery += 				" AND SX5.X5_TABELA ='L4'"
cQuery += 				" AND SX5.X5_CHAVE  = DT6_SERVIC  " 
cQuery += 				" AND SX5.D_E_L_E_T_ = ' '" 

cQuery += " LEFT JOIN " + RetSqlName("DT5") + " DT5 " 
cQuery += 				" ON  DT5.DT5_FILIAL  = '"+xFilial('DT5')+"'"   
cQuery += 				" AND DT5.DT5_FILDOC = DT6_FILDOC AND DT5.DT5_DOC = DT6_DOC AND DT5.DT5_SERIE = DT6_SERIE AND DT5.D_E_L_E_T_= ' ' "
cQuery += " LEFT JOIN " + RetSqlName("DUE") + " DUE "   
cQuery += 				" ON  DUE.DUE_FILIAL =  '"+xFilial('DUE')+"'" 
cQuery += 				" AND DUE.DUE_CODSOL  = DT5.DT5_CODSOL "
cQuery += 				" AND DUE.D_E_L_E_T_ = ' ' "


cQuery += " WHERE DUD_FILIAL = '" + xFilial('DUD') + "' " 
cQuery += 			" AND  DUD.DUD_FILDOC = DT6_FILDOC"
cQuery += 			" AND  DUD.DUD_DOC    = DT6_DOC   " 
cQuery += 			" AND  DUD.DUD_SERIE  = DT6_SERIE " 
//-- Documentos em Aberto sem Viagem 
cQuery += 			" AND ("

If !IsInCallStack("A146SrAdPn") 
	If !lTMSDCol
		cQuery += 	" ( ((DUD.DUD_FILORI = DT6_FILORI AND DUD.DUD_STATUS = '" + StrZero(1,Len(DUD->DUD_STATUS)) + "' "
	Else
		cQuery += 	" ( ((DUD.DUD_STATUS = '" + StrZero(1,Len(DUD->DUD_STATUS)) + "' "
	EndIf

	If cTpSel == "D"  
		cQuery += 	" AND  DUD_VIAGEM = '" + Space(Len(DUD->DUD_VIAGEM)) + "' ) OR "
	Else
		cQuery += 	" AND  DUD_VIAGEM = '" + Space(Len(DUD->DUD_VIAGEM)) + "' AND DUD.DUD_SERTMS = DA8.DA8_SERTMS ) OR "
	EndIf

	//-- Documentos em Transito com destino a Filial logada
	cQuery += 		" (DUD.DUD_STATUS = '" + StrZero(2,Len(DUD->DUD_STATUS)) + "' " 
	cQuery += 		" AND DUD_VIAGEM <> '" + Space(Len(DUD->DUD_VIAGEM)) + "' AND DUD.DUD_SERTMS='2' AND DUD.DUD_FILDCA = '" + cFilAnt + "' ) )"
	
	If cTpSel == "R"
		cQuery += 	" AND  DUD.DUD_TIPTRA = DA8.DA8_TIPTRA  "
	Else
		cQuery += 	" AND DUD.DUD_SERTMS >= '"+ mv_par26 +"'"
		cQuery += 	" AND DUD.DUD_SERTMS <= '"+ mv_par27 +"'"
		cQuery += 	" AND DUD.DUD_TIPTRA = '"+ mv_par28 +"'"
	EndIf
		
	cQuery += 		" AND  DUD.DUD_NUMRED = ' ' )"
	
	If IsInCallStack("TMSAF76") .AND. cTpSel == 'D' 
		cQuery += 	" OR "
	EndIf
	
EndIf

// Painel de Agendamento
If IsInCallStack("TMSAF76") .AND. cTpSel == 'D'  	
	cQuery += " DF1.DF1_MRKPAN = '"+ cNumThread +"' "
	cQuery += " AND DF1.DF1_STACOL NOT IN('5','9') "
EndIf

cQuery += " ) AND (DT5.DT5_STATUS IN( '1','4','6') OR DT5.DT5_STATUS IS NULL) "
cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
		
cQuery += " AND  NOT EXISTS ( SELECT 1 FROM " + RetSqlName("DD9") + " DD9 "
cQuery += 							" JOIN " + RetSqlName("DF8") + " DF8 "
cQuery += 									" ON DF8.DF8_FILIAL = '"+xFilial('DF8')+"'"
cQuery += 									" AND DF8.DF8_FILORI = DD9.DD9_FILORI"
cQuery += 									" AND DF8.DF8_NUMPRG = DD9.DD9_NUMPRG"
cQuery += 									" AND DF8.DF8_STATUS = '" +  StrZero( 1, Len( DF8->DF8_STATUS ) ) + "' "
cQuery += 									" AND DF8.D_E_L_E_T_ = ' '"
cQuery += " WHERE DD9.DD9_FILIAL = '"+xFilial('DD9')+"'"
cQuery += 		"  AND DD9.DD9_FILDOC = DT6.DT6_FILDOC"
cQuery += 		"  AND DD9.DD9_DOC    = DT6.DT6_DOC"
cQuery += 		"  AND DD9.DD9_SERIE  = DT6.DT6_SERIE"
cQuery += 		"  AND DD9.D_E_L_E_T_ = ' ' )"

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} T146SelDTC
Seleciona os registros da DTC - Documento de Entrada
@author Katia
/*/
//-------------------------------------------------------------------
Static Function T146SelDTC(cTpSel,cFilDest,cFilDe,cFilAte,cSerTMS,cZonas,cSetores)
Local cQuery    := ""    
Local lAgdEntr  := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)   //-- Agendamento de Entrega.
Local cCdrOri     := Padr(GetMv("MV_CDRORI",,""),Len(DA8->DA8_CDRORI)) 

Default cTpSel  := D    //D- Documentos ou R-Rota
Default cFilDest:= ""
Default cFilDe  := ""
Default cFilAte := ""
Default cSerTMS := "" 
Default cZonas := "" 
Default cSetores := "" 

	// Painel de Agendamento
	If IsInCallStack("TMSAF76") .AND.  cTpSel  == 'D' 
		cQuery += " INNER JOIN " + RetSqlName("DF1") +" DF1 "
		cQuery += 				" ON DF1.DF1_FILIAL = '"+ FwxFilial("DF1") +"' "
		cQuery += 				" AND DF1.DF1_DOC = DTC.DTC_NUMSOL "
		cQuery += 				" AND DF1.DF1_FILDOC =  CASE WHEN DTC.DTC_FILCFS = ' ' THEN DTC.DTC_FILORI ELSE DTC.DTC_FILCFS END "
		cQuery += 				" AND DTC.D_E_L_E_T_ = ' ' "
	EndIf
	
	cQuery += " INNER JOIN  " 
	cQuery += RetSqlName("SA1") + " REM" 
	cQuery += " ON  REM.A1_FILIAL   = '"+xFilial('SA1')+"'"
	cQuery += " AND  REM.A1_COD      = DTC_CLIREM"
	cQuery += " AND  REM.A1_LOJA     = DTC_LOJREM"
	cQuery += " AND  REM.D_E_L_E_T_  = ' '"
	cQuery += " INNER JOIN  " 
	cQuery += RetSqlName("SA1") + " DES" 
	cQuery += " ON  DES.A1_FILIAL   = '"+xFilial('SA1')+"'"
	cQuery += " AND  DES.A1_COD      = DTC_CLIDES"
	cQuery += " AND  DES.A1_LOJA     = DTC_LOJDES"
	cQuery += " AND  DES.D_E_L_E_T_  = ' '"
	cQuery += " INNER JOIN " 
	cQuery += RetSqlName("SA1") + " DEV" 
	cQuery += " ON  DEV.A1_FILIAL   = '"+xFilial('SA1')+"'"
	cQuery += " AND  DEV.A1_COD      = DTC_CLIDEV"
	cQuery += " AND  DEV.A1_LOJA     = DTC_LOJDEV"
	cQuery += " AND  DEV.D_E_L_E_T_  = ' '"
	cQuery += " INNER JOIN " 
	cQuery += RetSqlName("SA1") + " CAL" 
	cQuery += " ON  CAL.A1_FILIAL   = '"+xFilial('SA1')+"'"
	cQuery += " AND  CAL.A1_COD      = DTC_CLICAL"
	cQuery += " AND  CAL.A1_LOJA     = DTC_LOJCAL"
	cQuery += " AND  CAL.A1_PRIOR   >= '" + mv_par05 + "'"
	cQuery += " AND  CAL.A1_PRIOR   <= '" + mv_par06 + "'"
	cQuery += " AND  CAL.D_E_L_E_T_  = ' '"
	cQuery += " INNER JOIN " 
	cQuery += RetSqlName("DTP") + " DTP" 
	cQuery += " ON  DTP.DTP_FILIAL   = '"+xFilial('DTP')+"'"
	cQuery += " AND  DTP.DTP_FILORI   = DTC_FILORI"
	cQuery += " AND  DTP.DTP_LOTNFC   = DTC_LOTNFC"

	If !IsInCallStack("TMSAF76") 
		cQuery += " AND  DTP.DTP_STATUS   = '" + StrZero(2, Len(DTP->DTP_STATUS)) + "' "  //Digitado
	EndIf
	
	cQuery += " AND  DTP.D_E_L_E_T_  = ' '"
	
	If lAgdEntr //.And. cSerTMS == "3"
		cQuery += " LEFT JOIN  "
		cQuery += RetSqlName("DYD") + " DYD"
		cQuery += " ON  DYD.DYD_FILIAL  =  '"+xFilial('DYD')+"'"
		cQuery += " AND  DYD.DYD_NUMAGD  =  DTC.DTC_NUMAGD"
		cQuery += " AND  DYD.DYD_TIPAGD  >= '" + cValToChar(MV_PAR22) + "'"
		cQuery += " AND  DYD.DYD_TIPAGD  <= '" + cValToChar(MV_PAR23) + "'"
		cQuery += " AND  DYD.D_E_L_E_T_  =  ' '"
	EndIf                 
	
	If cTpSel == 'D' //Query Documentos 
		cQuery += " LEFT JOIN " + RetSqlName("SX5") + " SX5 "
		cQuery += 				" ON SX5.X5_FILIAL ='"  + xFilial("SX5") + "'"
		cQuery += 				" AND SX5.X5_TABELA ='L4'"
		cQuery += 				" AND SX5.X5_CHAVE  = DTC_SERVIC "
		cQuery += 				" AND SX5.D_E_L_E_T_ = ' '"
		                       
		//-- Sequencia de Endereco
		cQuery += " LEFT JOIN " + RetSqlName("DUL") + " DUL "
		cQuery += 				" ON DUL.DUL_FILIAL ='"  + xFilial("DUL") + "'"
		cQuery += 				" AND DUL_CODCLI = DTC_CLIDES "
		cQuery += 				" AND DUL_LOJCLI = DTC_LOJDES "
		cQuery += 				" AND DUL_SEQEND = DTC_SQEDES "
		cQuery += 				" AND DUL.D_E_L_E_T_ = ' '"


		cQuery += " LEFT JOIN " + RetSqlName("SA1") + " RED" 
		cQuery +=  				" ON  RED.A1_FILIAL   = '"+xFilial('SA1')+"'"
		cQuery +=  				" AND  RED.A1_COD      = DUL_CODRED "
		cQuery +=  				" AND  RED.A1_LOJA     = DUL_LOJRED "
		cQuery += 				" AND  RED.D_E_L_E_T_  = ' '"		
		
		If cSerTMS == "2"
			cQuery+= " INNER JOIN " + RetSqlName('DVM') + " DVM " 
			cQuery+= 				" ON  DVM_FILIAL = '" + xFilial("DVM") + "' "
			cQuery+= 				" AND DVM_CDRDES = DTC.DTC_CDRCAL "
			cQuery+= 				" AND DVM.D_E_L_E_T_ = ' ' "
							
			cQuery+= " INNER JOIN " + RetSqlName('DA8') + " DA8 "
			cQuery+= 				" ON DA8_COD = DVM_ROTEIR "
			cQuery+= 				" AND DA8_SERTMS = '2' "
			cQuery+= 				" AND DA8_CDRORI =  '" + cCdrOri + "' "
			
		ElseIf cSerTMS == "3"
		
			cQuery+= " INNER JOIN " + RetSqlName('DA7') + " DA7 	"
			cQuery+= 				" ON DA7_FILIAL = '" + xFilial("DA7") + "' "
			cQuery+= 				" AND CASE  WHEN DTC_SQEDES <> ' ' THEN DUL.DUL_CEP ELSE DES.A1_CEP  END "
			cQuery+= 				" BETWEEN DA7.DA7_CEPDE AND DA7.DA7_CEPATE
		
			If !Empty(cZonas) 
				cQuery+= 			" AND DA7.DA7_PERCUR IN (" + cZonas +") "
				cQuery+= 			" AND DA7.DA7_ROTA IN (" + cSetores +") "		
			EndIf
			cQuery+= " AND DA7.D_E_L_E_T_ = ' ' "
			
			cQuery+= " INNER JOIN " + RetSqlName('DA6') + " DA6 "
			cQuery+= 				" ON DA6_FILIAL = '" + xFilial("DA6") + "'" 
			cQuery+= 				" AND DA6_PERCUR = DA7_PERCUR "
			cQuery+= 				" AND DA6_ROTA = DA7_ROTA "
			cQuery+= 				" AND DA6.D_E_L_E_T_ = ' ' "
						
			cQuery+= " INNER JOIN " + RetSqlName('DA5') + " DA5 "
			cQuery+= 				" ON DA5_FILIAL = '" + xFilial("DA5") + "'" 
			cQuery+= 				" AND DA5_COD = DA6_PERCUR "
			cQuery+= 				" AND DA5.D_E_L_E_T_ = ' ' "
						 
			cQuery+= " INNER JOIN " + RetSqlName('DA9') + " DA9 "
			cQuery+= 				" ON DA9_FILIAL = '" + xFilial("DA9") + "'" 
			cQuery+= 				" AND DA9_PERCUR = DA7_PERCUR "
			cQuery+= 				" AND DA9_ROTA = DA7_ROTA "
			cQuery+= 				" AND DA9.D_E_L_E_T_ = ' ' "
			
			cQuery+= " INNER JOIN " + RetSqlName('DA8') + " DA8 "
			cQuery+= 				" ON DA8_FILIAL = '" + xFilial("DA8") + "'"
			cQuery+= 				" AND DA8_COD = DA9_ROTEIR "
		
		EndIf
		
	EndIf	
	
	cQuery += " WHERE DTC.DTC_FILIAL  = '" + xFilial('DTC') + "'"
		
	cQuery += 			" AND ( "

	If !IsInCallStack("A146SrAdPn") 
		cQuery += " (( DTC.DTC_EMINFC >= '" + dDtEmiIni + "'"
		cQuery += " AND DTC.DTC_EMINFC <= '" + dDtEmiFim + "' ) "
		cQuery += " AND DTC.DTC_PRVENT >= '" + dDtPrvIni + "'"
		cQuery += " AND DTC.DTC_PRVENT <= '" + dDtPrvFim + "'"
		
		If mv_par11 == 1 //-- Cliente Remetente
			cQuery += " AND DTC_CLIREM >= '" + mv_par07 + "'"
			cQuery += " AND DTC_LOJREM >= '" + mv_par08 + "'"
			cQuery += " AND DTC_CLIREM <= '" + mv_par09 + "'"
			cQuery += " AND DTC_LOJREM <= '" + mv_par10 + "'"
		ElseIf mv_par11 == 2 //-- Cliente Destinatário
			cQuery += " AND DTC_CLIDES >= '" + mv_par07 + "'"
			cQuery += " AND DTC_LOJDES >= '" + mv_par08 + "'"
			cQuery += " AND DTC_CLIDES <= '" + mv_par09 + "'"
			cQuery += " AND DTC_LOJDES <= '" + mv_par10 + "'"
		ElseIf mv_par11 == 3 //-- Cliente Devedor
			cQuery += " AND DTC_CLIDEV >= '" + mv_par07 + "'"
			cQuery += " AND DTC_LOJDEV >= '" + mv_par08 + "'"
			cQuery += " AND DTC_CLIDEV <= '" + mv_par09 + "'"
			cQuery += " AND DTC_LOJDEV <= '" + mv_par10 + "'"
		ElseIf mv_par11 == 4 //-- Cliente de Cálculo
			cQuery += " AND DTC_CLICAL >= '" + mv_par07 + "'"
			cQuery += " AND DTC_LOJCAL >= '" + mv_par08 + "'"
			cQuery += " AND DTC_CLICAL <= '" + mv_par09 + "'"
			cQuery += " AND DTC_LOJCAL <= '" + mv_par10 + "'"
		EndIf
		cQuery += " AND DTC_CDRORI >= '" + mv_par12 + "'"
		cQuery += " AND DTC_CDRORI <= '" + mv_par13 + "'"
		cQuery += " AND DTC_CDRDES >= '" + mv_par14 + "'"
		cQuery += " AND DTC_CDRDES <= '" + mv_par15 + "'"
		cQuery += " AND DTC.DTC_FILORI = '" + cFilAnt + "'"
		cQuery += " AND DTC.DTC_DOC = ' '"
		If Empty(cSerTMS)
			cQuery += " AND DTC.DTC_SERTMS >= '"+ mv_par26 +"'"
			cQuery += " AND DTC.DTC_SERTMS <= '"+ mv_par27 +"'"
		Else
			cQuery += " AND DTC.DTC_SERTMS = '"+ cSerTMS +"'"
		EndIf	
		cQuery += " AND DTC.DTC_TIPTRA = '"+ mv_par28 +"' )"
		
		If IsInCallStack("TMSAF76") .AND. cTpSel == 'D'
			cQuery += " OR "
		EndIf
	EndIf
	
	If IsInCallStack("TMSAF76") .AND. cTpSel == 'D'  	
		cQuery += " DF1.DF1_MRKPAN = '"+ cNumThread +"' "
	EndIf		
	
	cQuery += " ) AND DTC.D_E_L_E_T_ = ' '"
	cQuery += " AND NOT EXISTS ( SELECT 1 "
	cQuery += 					" FROM "+RetSqlName("DD9")+" DD9 "
	cQuery += 						" JOIN " + RetSqlName("DF8") + " DF8"
	cQuery += 								" ON DF8.DF8_FILIAL = '"+xFilial('DF8')+"'"
	cQuery += 								" AND DF8.DF8_FILORI = DD9.DD9_FILORI"
	cQuery += 								" AND DF8.DF8_NUMPRG = DD9.DD9_NUMPRG"
	cQuery += 								" AND DF8.DF8_STATUS = '" +  StrZero( 1, Len( DF8->DF8_STATUS ) ) + "' "
	cQuery += 								" AND DF8.D_E_L_E_T_ = ' '"
	cQuery += 					" WHERE DD9.DD9_FILIAL = '"+xFilial('DD9')+"'"
	cQuery +=						" AND DD9.DD9_CLIREM = DTC.DTC_CLIREM"
	cQuery +=						" AND DD9.DD9_LOJREM = DTC.DTC_LOJREM"
	cQuery +=						" AND DD9.DD9_NUMNFC = DTC.DTC_NUMNFC"
	cQuery +=						" AND DD9.DD9_SERNFC = DTC.DTC_SERNFC"
	cQuery +=						" AND DD9.D_E_L_E_T_ = ' ') "
		
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} T146CarVei
Acao do Botao Carregar e Descarregar de Veiculos
@author Katia
@since 11/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function T146CarVei(lCarrega)
Local oModel     := FwModelActive()
Local oView      := FWViewActive()
Local oMdlGridDA3:= oModel:GetModel('MdGridDA3')
Local oMdlGridDF8:= oModel:GetModel('MdGridDF8')
Local oMdlTotal  := oModel:GetModel('MdTotal')
Local oMdlGridDoc:= oModel:GetModel('MdGridDoc')
Local oMdlGridRot:= oModel:GetModel('MdGridRot')
Local oMdlGridDDZ:= oModel:GetModel('MdGridDDZ')
Local oMdlGridDLS := oModel:GetModel("MdGridDLS")
Local oStructTot := oMdlTotal:GetStruct()  
Local aCamposTot := aClone(oStructTot:GetFields())
Local nLine      := oMdlGridDoc:GetLine()
Local aArea      := GetArea()
Local nLinha     := 0
Local lRet       := .T.
Local lAtualiza  := .F.
Local nQtdVolTot := 0
Local nPesoTot   := 0
Local nPesoM3Tot := 0
Local nValorTot  := 0
Local nValFreTot := 0
Local nQtdVolCol := 0
Local nPesoCol   := 0
Local nPesoM3Col := 0
Local nValorCol  := 0
Local nValFreCol := 0
Local nQtdVolTra := 0
Local nPesoTra   := 0
Local nPesoM3Tra := 0
Local nValorTra  := 0
Local nValFreTra := 0
Local nQtdVolEnt := 0
Local nPesoEnt   := 0
Local nPesoM3Ent := 0
Local nValorEnt  := 0
Local nValFreEnt := 0
Local lFirst     := .T.
Local nQtdEnt    := 0
Local nQtdTra    := 0

Local cVeiDDZ    := ""
Local nQtdCol    := 0
Local nQtdDoc    := 0
Local nOperation:= oModel:GetOperation()
Local nTotDocEnt := 0 
Local nTotDocTra := 0
Local lColigada  := .F.
Local aPesqDoc     := {}
Local nContador    := 1
Local nX           := 0 
Local cRotaDF8     := ""
Local aVeiculos    := {}  
Local nVei         := 0           
Local nLinVei      := 0
Local aVeiRes      := {}
Local aCliLoj      := {}
Local aCliRet      := {}
Local cSerTMSCOL   := "" 
Local cRotaCOL     := ""
Local nXX          := 0
Local nCapacM      := 0
Local cAliasVEI    := ""
Local nCont        := 0        
Local nQtdVei      := 0
Local nXXX         := 0
Local cVeiDF8      := ""
Local aVeiDDZ      := {}
Local nRegDDZ      := 0
Local cCatVei      := 0
Local aSaveAnt     := {}
Local nCarreta     := 0
Local nOutros      := 0
Local aCepCli 	   := {}
Local nLinAtu      := 0
Local lDescarVei   := .F.
Local nQtdRat      := 0

Private cSerTMSDF8   := ""

Default lCarrega := .T.

If nOperation == 4 .And. !IsInCallStack('TMSA146MNT') .And. !lIncAuto
	Help('',1,'TMSA14623') //Na Alteração, não é permitido efetuar o carregamento/descarregamento do veiculo. 
	lRet:= .F.
EndIf

If lCarrega .And. lRet
	If !oMdlGridDoc:SeekLine( { { "T01_MARK", .T.} } )
		If lRot146Aut
			TM146MsgAd(STR0211,"T146CarVei" )
		Else
			Help('',1,'TMSA14614') //Não há documentos selecionados para efetuar o carregamento
		EndIf
		lRet:= .F.
	EndIf

	If lRet
		lRet:= TMA146VDoc(,'V')
	EndIf
EndIf

If lRet
	nLinAtu := oMdlGridDoc:GetLine()
	//-- A programacao sera a mesma para todos os veiculos marcados e também para o veiculo da posicao do botao 'Carregar' que foi clicado
	//-- (mesmo nao o veiculo nao estando marcado)
	nLinVei := oMdlGridDA3:GetLine()
	nCapacM := oMdlGridDA3:GetValue('DA3_CAPACM')

	While oMdlGridDA3:SeekLine( { { "DA3_MARK", .T.} } )

			If Ascan(aVeiculos, oMdlGridDA3:GetValue('DA3_COD') ) == 0
				aAdd(aVeiculos,oMdlGridDA3:GetValue('DA3_COD'))
			EndIf	 
			nCapacM+= oMdlGridDA3:GetValue('DA3_CAPACM')
						
			DA3->(dbSetOrder(1))
			If DA3->(MsSeek(xFilial('DA3')+oMdlGridDA3:GetValue('DA3_COD')))  
				cCatVei:= Posicione('DUT',1,xFilial('DUT')+DA3->DA3_TIPVEI,'DUT_CATVEI')
				If cCatVei == StrZero(3, Len(DUT->DUT_CATVEI)) //Carreta
					nCarreta += 1
				Else
					nOutros += 1
				EndIf
			EndIf

		oMdlGridDA3:SetValue("DA3_MARK"  ,.F.)			
	EndDo
	
	oMdlGridDA3:GoLine(nLinVei)
	If Empty(aVeiculos)
		aAdd(aVeiculos,oMdlGridDA3:GetValue('DA3_COD'))  
		DA3->(dbSetOrder(1))
		If DA3->(MsSeek(xFilial('DA3')+oMdlGridDA3:GetValue('DA3_COD')))            
			cCatVei:= Posicione('DUT',1,xFilial('DUT')+DA3->DA3_TIPVEI,'DUT_CATVEI')
			nCapacM+= oMdlGridDA3:GetValue('DA3_CAPACM')
		EndIf
	EndIf
	
	If lRet
		If cCatVei == StrZero(2, Len(DUT->DUT_CATVEI)) //Cavalo
			If lRot146Aut
				TM146MsgAd(STR0212,"T146CarVei" )
			Else	
				Help('',1,'TMSA14625') // Nao é permitido carregar em veiculo da categoria 'Cavalo'. Selecione outro veiculo.                                        
			EndIf	
			lRet:= .F.
		Else
			If nCarreta > 0 .And. nOutros > 0
				If lRot146Aut
					TM146MsgAd(STR0213,"T146CarVei" )
				Else	
					Help('',1,'TMSA14630') //Não é permitido selecionar veiculos com categorias diferentes."      
				EndIf	
				lRet:= .F.
			EndIf
		EndIf
	EndIf
	 
	If lCarrega 
		If lRet
			aPesqDoc:=  { { 'T01_MARK', .T. } }
			
			//-- Verifica se existe doctos de Entrega e Transferencia para viagens coligadas
			nTotDocEnt:= oMdlTotal:GetValue('T03_QTDDTE') + oMdlTotal:GetValue('T03_QTDDCE') 
			nTotDocTra:= oMdlTotal:GetValue('T03_QTDDTT') + oMdlTotal:GetValue('T03_QTDDCT')
			
			If nTotDocEnt > 0 .And. nTotDocTra > 0
				If !IsInCallStack("TMSAC21PRC")
					lColigada:= MsgYesNo(STR0116)  //'Deseja gerar a programação como Viagem Coligada de Entrega e Transferencia ?'
				Else
					lColigada:= .T.
				EndIf
				nContador:= 2
			EndIf
			
			//-- Viagem Comboio, mais de um veiculo
			If Len(aVeiculos) > 1
				lColigada:= .T.
			EndIf
					
			nQtdCol := oModel:GetModel('MdTotal'):GetValue('T03_QTDDCC') + oModel:GetModel('MdTotal'):GetValue('T03_QTDDTC')
			nQtdEnt := oModel:GetModel('MdTotal'):GetValue('T03_QTDDCE') + oModel:GetModel('MdTotal'):GetValue('T03_QTDDTE')
			nQtdTra := oModel:GetModel('MdTotal'):GetValue('T03_QTDDCT') + oModel:GetModel('MdTotal'):GetValue('T03_QTDDTT')
			nQtdDoc := oModel:GetModel('MdTotal'):GetValue('T03_QTDDT') + oModel:GetModel('MdTotal'):GetValue('T03_QTDDC')
			nQtdRat := oModel:GetModel('MdTotal'):GetValue('T03_QTDRAT')
			For nX:= 1 To nContador
				If nTotDocEnt > 0 .And. nTotDocTra > 0
					If nX == 1
						aPesqDoc :=  { { 'T01_MARK', .T. }, { 'T01_SERTMS', '2' } }   //Transferencia
					Else
						If nQtdCol > 0
							aPesqDoc :=  { { 'T01_MARK', .T. }}   //Coleta e Entrega
						Else
							aPesqDoc :=  { { 'T01_MARK', .T. }, { 'T01_SERTMS', '3' } }   //Entrega
							nQtdEnt := 0
						EndIf	
						If !lColigada
							lFirst:= .T.   //Gera outro numero de programacao
						EndIf
						nQtdVolTot:= 0
						nPesoTot  := 0
						nPesoM3Tot:= 0
						nValorTot := 0
						nValFreTot:= 0
						nQtdVolCol:= 0
						nPesoCol  := 0
						nPesoM3Col:= 0
						nValorCol := 0
						nValFreCol:= 0
						nQtdVolTra:= 0
						nPesoTra  := 0
						nPesoM3Tra:= 0
						nValorTra := 0
						nValFreTra:= 0
						nQtdVolEnt:= 0
						nPesoEnt  := 0
						nPesoM3Ent:= 0
						nValorEnt := 0
						nValFreEnt:= 0
						nQtdCol   := 0
						nQtdTra   := 0
						cSerTMSCOL:= "" 
						cRotaCOL  := ""
					EndIf	
				EndIf
				aCliLoj:= {}
				
				While oMdlGridDoc:SeekLine( aPesqDoc ) 
					nLinha := oMdlGridDoc:GetLine()
								
					If Empty(oMdlGridDoc:GetValue('T01_NUMTMP'))
						If lFirst
							If Empty(cNumTmp)
								cNumTmp:= Space(TamSx3("DF8_NUMPRG")[1])
								cSeqPrg:= Space(TamSx3("DF8_SEQPRG")[1])
							EndIf
							cNumTmp:= Soma1(cNumTmp)
							cSeqPrg:= StrZero(1,Len(DF8->DF8_SEQPRG))
						Else
							If lColigada   //Mesma numero de programacao com sequencias diferentes
								If nX == 2 .And. cSeqPrg == StrZero(1,Len(DF8->DF8_SEQPRG))
									cSeqPrg:= Soma1(cSeqPrg)
								EndIf
							EndIf
						EndIf
									
						lFirst:= .F.
				    
					    //-- Atualiza Grid Documentos
						oMdlGridDoc:GoLine(nLinha)
						oMdlGridDoc:LoadValue('T01_NUMTMP', cNumTmp)
						oMdlGridDoc:LoadValue('T01_SEQPRG', cSeqPrg)
						oMdlGridDoc:LoadValue('T01_CODVEI', Iif(Len(aVeiculos)>1, '', oMdlGridDA3:GetValue('DA3_COD')))
						oMdlGridDoc:LoadValue('T01_MARK',.F.)   //Nao passar pela rotina de MRKDOC 14/09/16   
						oMdlGridDoc:LoadValue('T01_LEGEN',TM146Cor('D',FwFldGet("T01_DOC"),FwFldGet("T01_BLQDOC"),cNumTmp,,,FwFldGet("T01_FILDOC"),FwFldGet("T01_SERIE") ))  
		
						nQtdVolTot+= FwFldGet('T01_QTDVOL')
						nPesoTot  += FwFldGet('T01_PESO')
						nPesoM3Tot+= FwFldGet('T01_PESOM3')
						nValorTot += FwFldGet('T01_VALOR')
						nValFreTot+= FwFldGet('T01_VALFRE')
						If !Empty(FwFldGet('T01_DOC'))
							nQtdDoc+= 1
						EndIf
						
						If FwFldGet('T01_SERTMS') == StrZero( 1, Len(DTC->DTC_SERTMS))  //Coleta
							nQtdVolCol += FwFldGet('T01_QTDVOL')
							nPesoCol   += FwFldGet('T01_PESO')
							nPesoM3Col += FwFldGet('T01_PESOM3')
							nValorCol  += FwFldGet('T01_VALOR')
							nValFreCol += FwFldGet('T01_VALFRE')
							If !Empty(FwFldGet('T01_DOC'))
								nQtdCol+= 1
							EndIf	
							cSerTMSCOL:= If( lHasViaM3 .AND. FwFldGet('T01_SERTMS') == '1', '3', FwFldGet('T01_SERTMS') )
							cRotaCOL  := FwFldGet('T01_CDROTA')

						ElseIf FwFldGet('T01_SERTMS') == StrZero( 2, Len(DTC->DTC_SERTMS))  //Transferencia
							nQtdVolTra += FwFldGet('T01_QTDVOL')
							nPesoTra   += FwFldGet('T01_PESO')
							nPesoM3Tra += FwFldGet('T01_PESOM3')
							nValorTra  += FwFldGet('T01_VALOR')
							nValFreTra += FwFldGet('T01_VALFRE')
							If !Empty(FwFldGet('T01_DOC'))
								nQtdTra+= 1
							EndIf	
							cSerTMSDF8:= FwFldGet('T01_SERTMS')
							cRotaDF8  := FwFldGet('T01_CDROTA')
						ElseIf FwFldGet('T01_SERTMS') == StrZero( 3, Len(DTC->DTC_SERTMS))  //Entrega
							nQtdVolEnt += FwFldGet('T01_QTDVOL')
							nPesoEnt   += FwFldGet('T01_PESO')
							nPesoM3Ent += FwFldGet('T01_PESOM3')
							nValorEnt  += FwFldGet('T01_VALOR')
							nValFreEnt += FwFldGet('T01_VALFRE')
							If !Empty(FwFldGet('T01_DOC'))
								nQtdEnt+= 1
							EndIf
							cSerTMSDF8:= FwFldGet('T01_SERTMS')
							cRotaDF8  := FwFldGet('T01_CDROTA')
						EndIf
																			
						lAtualiza:= .T.
					Else
						oMdlGridDoc:LoadValue("T01_MARK",.F.)   //Nao passar pela rotina de MRKDOC 14/09/16
					EndIf				
					
					aCliRet:= TM146ReCli(FwFldGet('T01_FILDOC'),FwFldGet('T01_DOC'),FwFldGet('T01_SERIE'),FwFldGet('T01_CLIDES'),FwFldGet('T01_LOJDES'),FwFldGet('T01_SQEDES'))
					If Len(aCliRet) > 0
						If aScan(aCliLoj,{|x| x[1]+x[2] == aCliRet[1][1] + aCliRet[1][2] }) == 0
							aAdd(aCliLoj,{ aCliRet[1][1], aCliRet[1][2] })     
						EndIf
					EndIf		
				EndDo
				oMdlGridDoc:GoLine(nLine)
				If nQtdEnt == 0 .And. nQtdTra == 0 .And. nQtdCol > 0 
					cSerTMSDF8:= cSerTMSCOL
					cRotaDF8  := cRotaCOL
				EndIf				
				
				//--- Atualiza Grid Programacao
				If lAtualiza
					For nVei:= 1 To Len(aVeiculos)
					
						If !oMdlGridDF8:IsEmpty()
							oModel:GetModel( 'MdGridDF8' ):SetNoInsertLine( .F. )
							oMdlGridDF8:Addline()
							oModel:GetModel( 'MdGridDF8' ):SetNoInsertLine( .T. )
						EndIf				
						oMdlGridDF8:LoadValue("DF8_BTCAR", 'CARGANEW') 
						oMdlGridDF8:LoadValue("DF8_BTDES", 'CARGA')
						oMdlGridDF8:LoadValue("DF8_BTVIS", 'PESQUISA')  
						oMdlGridDF8:LoadValue("DF8_STAPRG",'BR_VERDE') 

						DA3->(dbSetOrder(1))
						DA3->(MsSeek(xFilial('DA3')+aVeiculos[nVei] ))  
						
						If nCapacM == nPesoTot
							oMdlGridDF8:LoadValue("DF8_STAVEI",'BR_AMARELO')  
						ElseIf  nCapacM < nPesoTot .Or.  (nPesoTot < 0 .And. nCapacM == 0)
							oMdlGridDF8:LoadValue("DF8_STAVEI",'BR_VERMELHO')  
						Else
							oMdlGridDF8:LoadValue("DF8_STAVEI",'BR_VERDE')  
						EndIf
			
						oMdlGridDF8:SetValue("DF8_FILORI", cFilAnt)
						oMdlGridDF8:SetValue("DF8_NUMTMP", cNumTmp)
						oMdlGridDF8:LoadValue("DF8_NUMPRG", '')
						
						oMdlGridDF8:SetValue("DF8_SEQPRG", cSeqPrg)
						If !oMdlGridRot:IsEmpty() .And. (oMdlGridRot:GetValue("DA8_MARK") .Or. (lRot146Aut .And. !Empty(cRotaDF8)) )
							oMdlGridDF8:LoadValue("DF8_ROTA", cRotaDF8 )
							DA8->(DbSetOrder(1))
							If DA8->(MsSeek(xFilial("DA8")+cRotaDF8))
								cSerTMSDF8:= DA8->DA8_SERTMS
							EndIf	
						EndIf
						
						oMdlGridDF8:SetValue("DF8_DATGER", dDataBase )
						oMdlGridDF8:SetValue("DF8_HORGER", StrTran( Left( Time(), 5 ), ":", "" ) )
	
						aAdd(aVeiRes,DA3->DA3_COD)
						If  oMdlGridDF8:GetValue("DF8_RESTRI") <> 'BR_VERMELHO'
							aCepCli := {}
							T146Visual( .F., @aCliLoj, @aCepCli )
							lRestri:= If( lPesqRes, TMSA146Res( "T", aCliLoj, aVeiRes, cRotaDF8, , , , aCepCli ), .F. )
							oMdlGridDF8:LoadValue("DF8_RESTRI", Iif(lRestri,"BR_VERMELHO","BR_VERDE"))
						EndIf
									
						oMdlGridDF8:SetValue("DF8_CODVEI", DA3->DA3_COD	)
						oMdlGridDF8:SetValue("DF8_CAPACM", nCapacM /*DA3->DA3_CAPACM*/ )
						oMdlGridDF8:SetValue("DF8_CAPACD", nCapacM - nPesoTot /*DA3->DA3_CAPACM - nPesoTot*/)
						oMdlGridDF8:SetValue("DF8_QTDVOL", nQtdVolTot	)
						oMdlGridDF8:SetValue("DF8_QTDDOC", nQtdDoc		)
						oMdlGridDF8:SetValue("DF8_PESO"  , nPesoTot		)
						oMdlGridDF8:SetValue("DF8_PESOM3", nPesoM3Tot	)
						oMdlGridDF8:SetValue("DF8_VALOR" , nValorTot	)
						oMdlGridDF8:LoadValue("DF8_DESSVT", TMSValField( 'cSerTMSDF8', .F. ) )
						oMdlGridDF8:SetValue("DF8_SERTMS", cSerTMSDF8	)
						oMdlGridDF8:SetValue("DF8_QTDCOL", nQtdCol		)
						oMdlGridDF8:SetValue("DF8_VOLCOL", nQtdVolCol	)
						oMdlGridDF8:SetValue("DF8_PESCOL", nPesoCol		)
						oMdlGridDF8:SetValue("DF8_PM3COL", nPesoM3Col	)
						oMdlGridDF8:SetValue("DF8_VLMCOL", nValorCol	)
						oMdlGridDF8:SetValue("DF8_VLFCOL", nValFreCol	)
						oMdlGridDF8:SetValue("DF8_QTDENT", nQtdEnt		)
						oMdlGridDF8:SetValue("DF8_VOLENT", nQtdVolEnt	)
						oMdlGridDF8:SetValue("DF8_PESENT", nPesoEnt		)
						oMdlGridDF8:SetValue("DF8_PM3ENT", nPesoM3Ent	)
						oMdlGridDF8:SetValue("DF8_VLMENT", nValorEnt	)
						oMdlGridDF8:SetValue("DF8_VLFENT", nValFreEnt	)
						oMdlGridDF8:SetValue("DF8_QTDTRA", nQtdTra		)
						oMdlGridDF8:SetValue("DF8_VOLTRA", nQtdVolTra	)
						oMdlGridDF8:SetValue("DF8_PESTRA", nPesoTra		)
						oMdlGridDF8:SetValue("DF8_PM3TRA", nPesoM3Tra	)
						oMdlGridDF8:SetValue("DF8_VLMTRA", nValorTra	)
						oMdlGridDF8:SetValue("DF8_VLFTRA", nValFreTra	)
						oMdlGridDF8:SetValue("DF8_VGEINT", If( lColigada, .T., .F. ) )
						oMdlGridDF8:SetValue("DF8_QTDRAT", nQtdRat		)
						oMdlGridDF8:LoadValue("DF8_TIPTRA", cTpTransp	)

						If lIncAuto .And. !Empty(cCodCavAut)
							oMdlGridDF8:LoadValue("DF8_CODCAV", cCodCavAut	)
						EndIf
						
						//--- Atualiza a Grid DDZ com todos os veiculos da programação
						nCont	:= 0
						nQtdVei	:= Len(aVeiculos)
						
						If nQtdVei > 1
							For nCont:= 1 To nQtdVei
								If !Empty(cVeiDDZ)
									cVeiDDZ:= cVeiDDZ + ", " + "'" + aVeiculos[nCont] + "'"
								Else
							   		cVeiDDZ:= "'" + aVeiculos[nCont] + "'"
							   	EndIf
							Next nCont
						EndIf
						
						cAliasVEI := GetNextAlias()

						cQuery := " SELECT DA3_COD, DA3_CAPACM, DA3_PLACA, DA3_DESC, DA3_TIPVEI, DUT_DESCRI "
						cQuery += " FROM " + RetSqlName("DA3") + " DA3 "
						cQuery += 		" INNER JOIN " + RetSqlName("DUT") + " DUT "
						cQuery += 					" ON DUT_FILIAL = '" + xFilial('DUT') + "'"
						cQuery += 					" AND DUT_TIPVEI = DA3_TIPVEI " 
						cQuery += 					" AND DUT.D_E_L_E_T_ = ' ' "
						cQuery += " WHERE DA3.DA3_FILIAL = '" + xFilial('DA3') + "'"

						If nQtdVei == 1
							cQuery +=	" AND DA3_COD = '" + aVeiculos[1] + "'"
						Else                                                        
							cQuery += 	" AND DA3_COD IN ( " + cVeiDDZ + ") "
						EndIf

						cQuery += 		" AND DA3.D_E_L_E_T_ = ' ' "

						If !cDbType $ "MSSQL|MSSQL7|ORACLE"
							cQuery := ChangeQuery(cQuery)
						EndIf

						DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasVEI, .T., .T. )

						While (cAliasVEI)->(!Eof())

							oMdlGridDDZ:SetNoInsertLine( .F. )

							If oMdlGridDDZ:SeekLine( {{ "DDZ_FILORI", cFilAnt},{ "DDZ_NUMPRG", cNumTmp},{ "DDZ_SEQPRG", cSeqPrg} } )
								oMdlGridDDZ:Addline()
							EndIf

							oMdlGridDDZ:LoadValue( "DDZ_FILORI", cFilAnt					)
							oMdlGridDDZ:LoadValue( "DDZ_CODVEI", (cAliasVEI)->DA3_COD		)
							oMdlGridDDZ:LoadValue( "DDZ_NUMPRG", cNumTmp					)
							oMdlGridDDZ:LoadValue( "DDZ_SEQPRG", cSeqPrg					)
							oMdlGridDDZ:LoadValue( "DDZ_CAPACM", (cAliasVEI)->DA3_CAPACM	)
							oMdlGridDDZ:LoadValue( "DDZ_MODVEI", (cAliasVEI)->DA3_DESC		)
							oMdlGridDDZ:LoadValue( "DDZ_PLACA" , (cAliasVEI)->DA3_PLACA		)
							oMdlGridDDZ:LoadValue( "DDZ_DESTIP", (cAliasVEI)->DUT_DESCRI	)
							
							If lIncAuto .And. !Empty(cCodCavAut)
								oMdlGridDDZ:SetValue( "DDZ_CODCAV", cCodCavAut				)
							EndIf

							oMdlGridDDZ:SetNoInsertLine( .T. )                        

							(cAliasVEI)->(DbSkip())

						EndDo
						(cAliasVEI)->(DbCloseArea())

                        If !Empty(DA3->DA3_MOTORI) .AND. TableInDic("DLS")

                            DA4->(dbSetOrder(1)) //DA4_FILIAL+DA4_COD
                            DA4->(MsSeek(xFilial('DA4')+DA3->DA3_MOTORI))

                            If DA4->(!Eof())
                                oMdlGridDLS:SetNoInsertLine( .F. )

                                If !oMdlGridDLS:IsEmpty()
                                    oMdlGridDLS:Addline()
                                EndIf

                                oMdlGridDLS:LoadValue( "DLS_CODMOT", DA4->DA4_COD		)
                                oMdlGridDLS:LoadValue( "DLS_NOMMOT", DA4->DA4_NOME		)
                                oMdlGridDLS:LoadValue( "DLS_TIPMOT", DA4->DA4_TIPMOT	)
								oMdlGridDLS:LoadValue( "DLS_CONDUT", '1'            	)
                                oMdlGridDLS:SetNoInsertLine( .T. )
                            EndIf
                        EndIf

	                Next nVei
				EndIf
			Next nX

			oMdlGridDA3:GoLine(nLinVei)
		EndIf
	Else	
		//-- Marcou algum documento, indica que será descarregado o documento
		lDescarVei:= .F.
		aAdd(aVeiRes,DA3->DA3_COD)
		If oMdlGridDoc:SeekLine( { { "T01_MARK", .T.} } )
			While oMdlGridDoc:SeekLine( { { "T01_MARK", .T.} } )
			   //DLOGTMS01-2975 - Validar se algum documento possui relacionamento com Demanda. Se possuir, não permitir o descarregamento.
			   lRet := A146VldCol(FwFldGet('T01_SERTMS'), oMdlGridDoc:GetValue("T01_DOC"))

			   If lRet
				   //-- Atualiza Grid Programacao  
					If !Empty(FwFldGet("T01_NUMPRG") ) .Or. !Empty(FwFldGet("T01_NUMTMP") )
						If oMdlGridDF8:SeekLine( {  { "T01_NUMPRG", Iif(!Empty(FwFldGet("T01_NUMPRG")),FwFldGet("T01_NUMPRG"),' ') },{ "T01_NUMTMP", FwFldGet("T01_NUMTMP") }, { "T01_SEQPRG", FwFldGet('T01_SEQPRG') } })
							
							oMdlGridDF8:SetValue("DF8_CAPACD", (oMdlGridDF8:GetValue("DF8_CAPACD") + FwFldGet("T01_PESO")))
							
							If FwFldGet('DA3_CAPACM') == oMdlGridDF8:GetValue("DF8_PESO") - FwFldGet("T01_PESO")
								oMdlGridDF8:LoadValue("DF8_STAVEI",'BR_AMARELO')  
							ElseIf  FwFldGet('DA3_CAPACM') < oMdlGridDF8:GetValue("DF8_PESO") - FwFldGet("T01_PESO")
								oMdlGridDF8:LoadValue("DF8_STAVEI",'BR_VERMELHO')  
							Else
								oMdlGridDF8:LoadValue("DF8_STAVEI",'BR_VERDE')  
							EndIf
							
							If !Empty(oMdlGridDoc:GetValue("T01_DOC"))
								oMdlGridDF8:SetValue("DF8_QTDDOC", oMdlGridDF8:GetValue("DF8_QTDDOC") - 1)
							EndIf

							oMdlGridDF8:SetValue("DF8_QTDVOL", oMdlGridDF8:GetValue("DF8_QTDVOL") - FwFldGet("T01_QTDVOL"))	
				    		oMdlGridDF8:SetValue("DF8_PESO"  , oMdlGridDF8:GetValue("DF8_PESO") - FwFldGet("T01_PESO"))
				    		oMdlGridDF8:SetValue("DF8_PESOM3", oMdlGridDF8:GetValue("DF8_PESOM3") - FwFldGet("T01_PESOM3"))
				    		oMdlGridDF8:SetValue("DF8_VALOR" , oMdlGridDF8:GetValue("DF8_VALOR") - FwFldGet("T01_VALOR"))
				    		
				    		If FwFldGet('T01_SERTMS') == StrZero( 1, Len(DTC->DTC_SERTMS))  //Coleta 
								If !Empty(oMdlGridDoc:GetValue("T01_DOC"))
				    				oMdlGridDF8:SetValue("DF8_QTDCOL",oMdlGridDF8:GetValue("DF8_QTDCOL") - 1)
				    			EndIf

				    			oMdlGridDF8:SetValue("DF8_VOLCOL",oMdlGridDF8:GetValue("DF8_VOLCOL") - FwFldGet("T01_QTDVOL"))
				    			oMdlGridDF8:SetValue("DF8_PESCOL",oMdlGridDF8:GetValue("DF8_PESCOL") - FwFldGet("T01_PESO"))
				    			oMdlGridDF8:SetValue("DF8_PM3COL",oMdlGridDF8:GetValue("DF8_PM3COL") - FwFldGet("T01_PESOM3"))
				    			oMdlGridDF8:SetValue("DF8_VLMCOL",oMdlGridDF8:GetValue("DF8_VLMCOL") - FwFldGet("T01_VALOR"))
				    			oMdlGridDF8:SetValue("DF8_VLFCOL",oMdlGridDF8:GetValue("DF8_VLFCOL") - FwFldGet("T01_VALFRE"))

				    		ElseIf FwFldGet('T01_SERTMS') == StrZero( 3, Len(DTC->DTC_SERTMS))  //Entrega
								If !Empty(oMdlGridDoc:GetValue("T01_DOC"))
				    				oMdlGridDF8:SetValue("DF8_QTDENT",oMdlGridDF8:GetValue("DF8_QTDENT") - 1)
				    			EndIf

								oMdlGridDF8:SetValue("DF8_VOLENT",oMdlGridDF8:GetValue("DF8_VOLENT") - FwFldGet("T01_QTDVOL"))
				    			oMdlGridDF8:SetValue("DF8_PESENT",oMdlGridDF8:GetValue("DF8_PESENT") - FwFldGet("T01_PESO"))
				    			oMdlGridDF8:SetValue("DF8_PM3ENT",oMdlGridDF8:GetValue("DF8_PM3ENT") - FwFldGet("T01_PESOM3"))
				    			oMdlGridDF8:SetValue("DF8_VLMENT",oMdlGridDF8:GetValue("DF8_VLMENT") - FwFldGet("T01_VALOR"))
				    			oMdlGridDF8:SetValue("DF8_VLFENT",oMdlGridDF8:GetValue("DF8_VLFENT") - FwFldGet("T01_VALFRE"))

				    		ElseIf FwFldGet('T01_SERTMS') == StrZero( 2, Len(DTC->DTC_SERTMS))  //Transferencia
								If !Empty(oMdlGridDoc:GetValue("T01_DOC"))
				    				oMdlGridDF8:SetValue("DF8_QTDTRA",oMdlGridDF8:GetValue("DF8_QTDTRA") - 1)
				    			EndIf

				    			oMdlGridDF8:SetValue("DF8_VOLTRA",oMdlGridDF8:GetValue("DF8_VOLTRA") - FwFldGet("T01_QTDVOL"))
				    			oMdlGridDF8:SetValue("DF8_PESTRA",oMdlGridDF8:GetValue("DF8_PESTRA") - FwFldGet("T01_PESO"))
				    			oMdlGridDF8:SetValue("DF8_PM3TRA",oMdlGridDF8:GetValue("DF8_PM3TRA") - FwFldGet("T01_PESOM3"))
				    			oMdlGridDF8:SetValue("DF8_VLMTRA",oMdlGridDF8:GetValue("DF8_VLMTRA") - FwFldGet("T01_VALOR"))
				    			oMdlGridDF8:SetValue("DF8_VLFTRA",oMdlGridDF8:GetValue("DF8_VLFTRA") - FwFldGet("T01_VALFRE"))

				    		EndIf

				    		oMdlGridDF8:SetValue("DF8_VGEINT", .F.)
				    		
							If oMdlGridDF8:GetValue("DF8_QTDVOL")  == 0  //Nao sobrou nenhum documento, exclui a programação 
								//-- Verifica se tem mais de um veiculo na programacao, se nao tiver, exclui a programacao
								If oMdlGridDDZ:Length() > 1                                                                                     
									If oMdlGridDDZ:SeekLine( {{ "DDZ_FILORI",oMdlGridDF8:GetValue("DF8_FILORI") }, { "DDZ_NUMPRG",oMdlGridDF8:GetValue("DF8_NUMTMP") },;
									                          { "DDZ_SEQPRG",oMdlGridDF8:GetValue("DF8_SEQPRG") }, { "DDZ_CODVEI", DA3->DA3_COD} } )
		      							oMdlGridDDZ:SetNoDeleteLine( .F. )  //Exclui veiculos da programacao
										If !oMdlGridDDZ:IsDeleted() 
						  					oMdlGridDDZ:DeleteLine() 
					 					EndIf 
			 							oMdlGridDDZ:SetNoDeleteLine( .T. )
									EndIf											
							    Else
									oMdlGridDDZ:SetNoDeleteLine( .F. )  //Exclui veiculos da programacao
									If !oMdlGridDDZ:IsDeleted() 
					  					oMdlGridDDZ:DeleteLine() 
				 					EndIf 
			 						oMdlGridDDZ:SetNoDeleteLine( .T. )
		
									oMdlGridDF8:SetNoDeleteLine( .F. )
									If !oMdlGridDF8:IsDeleted() 
					  					oMdlGridDF8:DeleteLine() 
				 					EndIf 
			 						oMdlGridDF8:SetNoDeleteLine( .T. )	 						
			 					EndIf	
			 				EndIf
			 							 				
							oMdlGridDoc:SetValue('T01_NUMTMP', '')
							oMdlGridDoc:SetValue('T01_SEQPRG', '')
							oMdlGridDoc:SetValue('T01_SEQENT', '')	
							oMdlGridDoc:LoadValue("T01_LEGEN", TM146Cor('D',FwFldGet("T01_DOC"),FwFldGet("T01_BLQDOC"),'','',,FwFldGet("T01_FILDOC"),FwFldGet("T01_SERIE") ))		
						EndIf	
						lDescarVei:= .T.
					EndIf
					oMdlGridDoc:LoadValue("T01_MARK",.F.)
				Else
					oMdlGridDoc:LoadValue("T01_MARK",.F.)
				EndIf							
				
			EndDo
			
			//-- Busca todos os clientes dos documentos da programação para verificar novamente a restrição
			If lDescarVei .And. !oMdlGridDF8:IsDeleted() 
				aCepCli := {}
				T146Visual( .F., @aCliLoj, @aCepCli )

				If Len(aCliLoj) > 0
					lRestri:= Iif(lPesqRes,TMSA146Res("T",aCliLoj,aVeiRes,FwFldGet('DF8_ROTA'),,,,aCepCli),.F.)   //Restricao Cliente com Veiculo              
					oMdlGridDF8:LoadValue("DF8_RESTRI", Iif(lRestri,"BR_VERMELHO","BR_VERDE"))                 
				EndIf 
			EndIf	
			
			oMdlGridDoc:GoLine(nLine)
		Else  

			If lRet
				//Descarrega todos os doctos e programacoes do veiculo
				For nXX:= 1 To Len(aVeiculos)			
					
					cVeiDF8:= aVeiculos[nxx]        
					nRegDDZ:= oMdlGridDDZ:Length() 
					
					If nRegDDZ >= 1 //Procura todos as programações do veiculo na DDZ 
						For nXXX:= 1 To oMdlGridDDZ:Length()
							If !oMdlGridDDZ:IsDeleted(nXXX) 	 
								oMdlGridDDZ:GoLine(nXXX)																			
								aAdd(aVeiDDZ,oMdlGridDDZ:GetValue('DDZ_CODVEI'))
							EndIf
						Next nXXX
					EndIf    
					
					aSaveAnt := FWSaveRows()

					For nXXX:= 1 To Len(aVeiDDZ)		//Procura todas as programações do veiculo para efetuar o descarregamento
						If oMdlGridDA3:SeekLine( { { "DA3_COD", aVeiDDZ[nXXX] }  } )
							For nCont:= 1 To oMdlGridDF8:Length()
								If !oMdlGridDF8:IsDeleted(nCont) 	 
									
									oMdlGridDF8:GoLine(nCont)																			
									lAtualiza := .F.

									If oMdlGridDDZ:SeekLine( { { "DDZ_FILORI", FwFldGet("DF8_FILORI") }, { "DDZ_NUMPRG",  FwFldGet("DF8_NUMTMP") } , { "DDZ_SEQPRG", FwFldGet('DF8_SEQPRG') }, ;
									                           { "DDZ_CODVEI", cVeiDF8 } } )
										oMdlGridDDZ:SetNoDeleteLine( .F. )
										If !oMdlGridDDZ:IsDeleted() 
						  					oMdlGridDDZ:DeleteLine() 
						 				EndIf 
											oMdlGridDDZ:SetNoDeleteLine( .T. )
									EndIf

									If oMdlGridDDZ:Length() > 0 //Tem veiculos
										If oMdlGridDF8:GetValue("DF8_CODVEI") == cVeiDF8
											While oMdlGridDoc:SeekLine( { { "T01_NUMTMP", FwFldGet("DF8_NUMTMP") }, { "T01_SEQPRG", FwFldGet('DF8_SEQPRG') } } ) 
												oMdlGridDoc:SetValue('T01_NUMTMP', '')
												oMdlGridDoc:SetValue('T01_SEQPRG', '')
												oMdlGridDoc:SetValue('T01_CODVEI', '')
												oMdlGridDoc:SetValue('T01_SEQENT', '')
												oMdlGridDoc:LoadValue("T01_LEGEN", TM146Cor('D',FwFldGet("T01_DOC"),FwFldGet("T01_BLQDOC"),'','',,FwFldGet("T01_FILDOC"),FwFldGet("T01_SERIE")))
											EndDo
										EndIf	
									EndIf	
									
									If oMdlGridDF8:GetValue("DF8_CODVEI") == cVeiDF8
										oMdlGridDF8:SetNoDeleteLine( .F. )
										If !oMdlGridDF8:IsDeleted() 
						  					oMdlGridDF8:DeleteLine() 
						 				EndIf 
					 					oMdlGridDF8:SetNoDeleteLine( .T. )
					 				EndIf	
					 			EndIf	
				 			Next nCont
				 		EndIf	
			 		Next nXXX
			 		FWRestRows( aSaveAnt )	
		 		Next nXX		
		 	EndIf
		EndIf	
	EndIf
	
	If lRet	
		oMdlGridDoc:GoLine(nLinAtu)
		If Type('oView') <> 'U'
			oView:Refresh('VwGridDoc')		          
			oView:Refresh('VwGridDF8')         
			oView:Refresh('VwGridDDZ')
            oView:Refresh('VwGridDLS')
		EndIf	
	EndIf	
	cSeqEnt:= ""  //zera variavel sequencia de entrega
EndIf
nCarretas:= 0

//Zerar totdas as variáveis do total
If lRet
   T146LimTot(aCamposTot,oMdlTotal)
EndIf

RestArea( aArea )
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} T146CarPrg
Acao do Botao Carregar e Descarregar da Programacao
@author Katia
@since 11/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function T146CarPrg(lCarrega)
Local oModel     := FwModelActive()
Local oView      := FwViewActive()
Local aSaveLine  := FWSaveRows()
Local oMdlGridDF8:= oModel:GetModel('MdGridDF8')
Local oMdlGridDoc:= oModel:GetModel('MdGridDoc')
Local oMdlTotal  := oModel:GetModel('MdTotal')
Local oStructTot := oMdlTotal:GetStruct()
Local aCamposTot := aClone(oStructTot:GetFields())
Local cNumTmp    := Iif(!Empty(oMdlGridDF8:GetValue('DF8_NUMTMP')),oMdlGridDF8:GetValue('DF8_NUMTMP'),Space(TamSx3("DF8_NUMPRG")[1]))
Local cNumPrg    := Iif(!Empty(oMdlGridDF8:GetValue('DF8_NUMPRG')),oMdlGridDF8:GetValue('DF8_NUMPRG'),Space(TamSx3("DF8_NUMPRG")[1]))
Local cSeqPrg    := oMdlGridDF8:GetValue('DF8_SEQPRG')
Local cVeiculo   := oMdlGridDF8:GetValue('DF8_CODVEI')
Local nLinha     := 0
Local lRet       := .T.
Local lAtualiza  := .F.
Local nQtdVolTot := 0
Local nPesoTot   := 0
Local nPesoM3Tot := 0
Local nValorTot  := 0
Local nValFreTot := 0
Local nQtdVolCol := 0
Local nPesoCol   := 0
Local nPesoM3Col := 0
Local nValorCol  := 0
Local nValFreCol := 0
Local nQtdVolTra := 0
Local nPesoTra   := 0
Local nPesoM3Tra := 0
Local nValorTra  := 0
Local nValFreTra := 0
Local nQtdVolEnt := 0
Local nPesoEnt   := 0
Local nPesoM3Ent := 0
Local nValorEnt  := 0
Local nValFreEnt := 0
Local nQtdDoc    := 0
Local nQtdCol    := 0
Local nQtdEnt    := 0
Local nQtdTra    := 0
Local nSeqAtu    := 0
Local aCliRet    := {}
Local aCliLoj    := {}
Local lRestri    := .F.   
Local aVeiRes    := {}
Local aCepCli	 := {}
Local nLinAtu    := 0
Local lAltPrg    := IsInCallStack("TMSA146ALT")
Local nQtdRat    := 0

Default lCarrega := .T.

aLoadTot:= {}

If lCarrega
	If !oMdlGridDoc:SeekLine( { { "T01_MARK", .T.} } )
		If lRot146Aut
			TM146MsgAd(STR0214,"T146CarPrg" )
		Else	
			Help('',1,'TMSA14614') //Não há documentos selecionados para efetuar o carregamento 
		EndIf	
		lRet:= .F.
	EndIf
	
	If lRet
		lRet:= TMA146VDoc(,'P')
	EndIf
EndIf

If lRet
	
	nLinAtu := oMdlGridDoc:GetLine()
	nQtdCol:= oModel:GetModel('MdTotal'):GetValue('T03_QTDDCC')+ oModel:GetModel('MdTotal'):GetValue('T03_QTDDTC')
	nQtdEnt:= oModel:GetModel('MdTotal'):GetValue('T03_QTDDCE')+ oModel:GetModel('MdTotal'):GetValue('T03_QTDDTE')
	nQtdTra:= oModel:GetModel('MdTotal'):GetValue('T03_QTDDCT')+ oModel:GetModel('MdTotal'):GetValue('T03_QTDDTT')
	nQtdDoc:= oModel:GetModel('MdTotal'):GetValue('T03_QTDDT')+ oModel:GetModel('MdTotal'):GetValue('T03_QTDDC')
	nQtdRat:= oModel:GetModel('MdTotal'):GetValue('T03_QTDRAT')+ oModel:GetModel('MdTotal'):GetValue('T03_QTDRAT')
	
	If lCarrega

		While oMdlGridDoc:SeekLine( { { "T01_MARK", .T.} } ) 
			nLinha := oMdlGridDoc:GetLine()
				
			If Empty(oMdlGridDoc:GetValue('T01_NUMTMP'))
			    //-- Atualiza Grid Documentos
				oMdlGridDoc:GoLine(nLinha)
				If !(lRet := TMA146VDoc(,"DP"))

					Exit
				EndIf
				
				oMdlGridDoc:LoadValue('T01_NUMTMP', cNumTmp)
				oMdlGridDoc:LoadValue('T01_NUMPRG', cNumPrg)
				oMdlGridDoc:LoadValue('T01_SEQPRG', cSeqPrg)
				oMdlGridDoc:LoadValue('T01_CODVEI', cVeiculo)

				If IsInCallStack('TMSA146MNT')
					If cSeqEnt <> StrZero( 1, Len(DUD->DUD_SEQENT))   //Encontrou documento na programacao, a sequencia sera alterada, considerando o ultima sequencia do docto
						nSeqAtu:= (Val(FwFldGet('T01_SEQENT')) + Val(cSeqEnt) )	
						oMdlGridDoc:SetValue("T01_SEQENT", StrZero(nSeqAtu,Len(DUD->DUD_SEQENT)) )
					EndIf
				EndIf
				
				oMdlGridDoc:LoadValue("T01_MARK",.F.)
				oMdlGridDoc:LoadValue("T01_LEGEN",TM146Cor('D',FwFldGet("T01_DOC"),FwFldGet("T01_BLQDOC"),cNumTmp,cNumPrg,,FwFldGet("T01_FILDOC"),FwFldGet("T01_SERIE") ) )  //Com Programacao
				
				nQtdVolTot+= FwFldGet('T01_QTDVOL')
				nPesoTot  += FwFldGet('T01_PESO')
				nPesoM3Tot+= FwFldGet('T01_PESOM3')
				nValorTot += FwFldGet('T01_VALOR')
				nValFreTot+= FwFldGet('T01_VALFRE')
				
				If FwFldGet('T01_SERTMS') == StrZero( 1, Len(DTC->DTC_SERTMS))  //Coleta
					nQtdVolCol += FwFldGet('T01_QTDVOL')
					nPesoCol   += FwFldGet('T01_PESO')
					nPesoM3Col += FwFldGet('T01_PESOM3')
					nValorCol  += FwFldGet('T01_VALOR')
					nValFreCol += FwFldGet('T01_VALFRE')
				ElseIf FwFldGet('T01_SERTMS') == StrZero( 2, Len(DTC->DTC_SERTMS))  //Transferencia
					nQtdVolTra += FwFldGet('T01_QTDVOL')
					nPesoTra   += FwFldGet('T01_PESO')
					nPesoM3Tra += FwFldGet('T01_PESOM3')
					nValorTra  += FwFldGet('T01_VALOR')
					nValFreTra += FwFldGet('T01_VALFRE')
				ElseIf FwFldGet('T01_SERTMS') == StrZero( 3, Len(DTC->DTC_SERTMS))  //Entrega
					nQtdVolEnt += FwFldGet('T01_QTDVOL')
					nPesoEnt   += FwFldGet('T01_PESO')
					nPesoM3Ent += FwFldGet('T01_PESOM3')
					nValorEnt  += FwFldGet('T01_VALOR')
					nValFreEnt += FwFldGet('T01_VALFRE')
				EndIf
				
				lAtualiza:= .T.
			Else
				oMdlGridDoc:LoadValue("T01_MARK",.F.)
			EndIf
			
			aCliRet:= TM146ReCli(FwFldGet('T01_FILDOC'),FwFldGet('T01_DOC'),FwFldGet('T01_SERIE'),FwFldGet('T01_CLIDES'),FwFldGet('T01_LOJDES'),FwFldGet('T01_SQEDES'))
			If Len(aCliRet) > 0
				If aScan(aCliLoj,{|x| x[1]+x[2] == aCliRet[1][1] + aCliRet[1][2] }) == 0
					aAdd(aCliLoj,{ aCliRet[1][1], aCliRet[1][2] })     
				EndIf
			EndIf				
		EndDo
		
		//--- Atualiza Grid Programacao
		If lRet .And. lAtualiza
			DA3->(dbSetOrder(1))
			DA3->(MsSeek(xFilial('DA3')+FwFldGet("DF8_CODVEI"))) 
		
			If DA3->DA3_CAPACM == (FwFldGet("DF8_CAPACD") - nPesoTot )
				oMdlGridDF8:LoadValue("DF8_STAVEI",'BR_AMARELO')  
			ElseIf  DA3->DA3_CAPACM < (FwFldGet("DF8_CAPACD") - nPesoTot )  .Or. ( (FwFldGet("DF8_CAPACD") - nPesoTot) < 0 .And. DA3->DA3_CAPACM == 0)
				oMdlGridDF8:LoadValue("DF8_STAVEI",'BR_VERMELHO')  
			Else
				oMdlGridDF8:LoadValue("DF8_STAVEI",'BR_VERDE')  
			EndIf
						
			oMdlGridDF8:SetValue("DF8_CAPACD",	Round((FwFldGet("DF8_CAPACD") -  nPesoTot), 2 )			) //(FwFldGet("DF8_CAPACD") - Iif(FwFldGet("DF8_CAPACD") > 0, nPesoTot, nPesoTot * (-1) )))
			oMdlGridDF8:SetValue("DF8_QTDVOL",	FwFldGet("DF8_QTDVOL") + nQtdVolTot						)
			oMdlGridDF8:LoadValue("DF8_QTDDOC", If(lAltPrg,nQtdDoc,FwFldGet("DF8_QTDDOC") + nQtdDoc)	)
			oMdlGridDF8:LoadValue("DF8_PESO",	FwFldGet("DF8_PESO") + nPesoTot							)
			oMdlGridDF8:LoadValue("DF8_PESOM3", FwFldGet("DF8_PESOM3") + nPesoM3Tot						)
			oMdlGridDF8:LoadValue("DF8_VALOR" , FwFldGet("DF8_VALOR") + nValorTot						)
			oMdlGridDF8:LoadValue("DF8_QTDCOL", If( lAltPrg, nQtdCol, FwFldGet("DF8_QTDCOL") + nQtdCol ))
			oMdlGridDF8:LoadValue("DF8_VOLCOL", FwFldGet("DF8_VOLCOL") + nQtdVolCol						)
			oMdlGridDF8:LoadValue("DF8_PESCOL", FwFldGet("DF8_PESCOL") + nPesoCol						)
			oMdlGridDF8:LoadValue("DF8_PM3COL", FwFldGet("DF8_PM3COL") + nPesoM3Col						)
			oMdlGridDF8:LoadValue("DF8_VLMCOL", FwFldGet("DF8_VLMCOL") + nValorCol						)
			oMdlGridDF8:LoadValue("DF8_VLFCOL", FwFldGet("DF8_VLFCOL") + nValFreCol						)
			oMdlGridDF8:LoadValue("DF8_QTDENT", If( lAltPrg, nQtdEnt, FwFldGet("DF8_QTDENT") + nQtdEnt)	)
			oMdlGridDF8:LoadValue("DF8_VOLENT", FwFldGet("DF8_VOLENT") + nQtdVolEnt						)
			oMdlGridDF8:LoadValue("DF8_PESENT", FwFldGet("DF8_PESENT") + nPesoEnt						)
			oMdlGridDF8:LoadValue("DF8_PM3ENT", FwFldGet("DF8_PM3ENT") + nPesoM3Ent						)
			oMdlGridDF8:LoadValue("DF8_VLMENT", FwFldGet("DF8_VLMENT") + nValorEnt						)
			oMdlGridDF8:LoadValue("DF8_VLFENT", FwFldGet("DF8_VLFENT") + nValFreEnt						)
			oMdlGridDF8:LoadValue("DF8_QTDTRA", If( lAltPrg, nQtdTra, FwFldGet("DF8_QTDTRA") + nQtdTra ))
			oMdlGridDF8:LoadValue("DF8_VOLTRA", FwFldGet("DF8_VOLTRA") + nQtdVolTra						)
			oMdlGridDF8:LoadValue("DF8_PESTRA", FwFldGet("DF8_PESTRA") + nPesoTra						)
			oMdlGridDF8:LoadValue("DF8_PM3TRA", FwFldGet("DF8_PM3TRA") + nPesoM3Tra						)
			oMdlGridDF8:LoadValue("DF8_VLMTRA", FwFldGet("DF8_VLMTRA") + nValorTra						)
			oMdlGridDF8:LoadValue("DF8_VLFTRA", FwFldGet("DF8_VLFTRA") + nValFreTra						)
			oMdlGridDF8:LoadValue("DF8_QTDRAT", FwFldGet("DF8_QTDRAT") + nQtdRat						)

			aAdd(aVeiRes,FwFldGet("DF8_CODVEI") )

			aCepCli := {}

			T146Visual( .F., @aCliLoj, @aCepCli )   //Adiciona os clientes da programação existente
			
			If  oMdlGridDF8:GetValue("DF8_RESTRI") <> 'BR_VERMELHO'

				lRestri:= Iif(lPesqRes,TMSA146Res("T",aCliLoj,aVeiRes,,,,,aCepCli),.F.)   //Restricao Cliente com Veiculo
				
				If lRestri
					oMdlGridDF8:LoadValue("DF8_RESTRI", "BR_VERMELHO")
				EndIf	
			EndIf	

			If lAltPrg .And. lIntTPR
				lAlteraTPR:= .T.
			EndIf
		EndIf			
	Else	
			//-- Marcou algum documento, indica que será descarregado o documento
		If oMdlGridDoc:SeekLine( { { "T01_MARK", .T.} } )
			While oMdlGridDoc:SeekLine( { { "T01_MARK", .T.} } )
				lRet := A146VldCol(FwFldGet('T01_SERTMS'), oMdlGridDoc:GetValue("T01_DOC"))
				
				If lRet
					If oMdlGridDF8:SeekLine( {  { "DF8_NUMPRG", FwFldGet("T01_NUMPRG") }, { "DF8_NUMTMP", Iif(!Empty(FwFldGet("T01_NUMTMP")),FwFldGet("T01_NUMTMP"),'') }, { "DF8_SEQPRG", FwFldGet('T01_SEQPRG') } })
						oMdlGridDF8:SetValue("DF8_CAPACD", (oMdlGridDF8:GetValue("DF8_CAPACD") + FwFldGet("T01_PESO")))
						
						If FwFldGet('DA3_CAPACM') == oMdlGridDF8:GetValue("DF8_PESO") - FwFldGet("T01_PESO") 
							oMdlGridDF8:LoadValue("DF8_STAVEI",'BR_AMARELO')  
						ElseIf  FwFldGet('DA3_CAPACM') < oMdlGridDF8:GetValue("DF8_PESO") - FwFldGet("T01_PESO")
							oMdlGridDF8:LoadValue("DF8_STAVEI",'BR_VERMELHO')  
						Else
							oMdlGridDF8:LoadValue("DF8_STAVEI",'BR_VERDE')  
						EndIf
						
						//If !Empty(oMdlGridDoc:GetValue("T01_DOC"))
						oMdlGridDF8:LoadValue("DF8_QTDVOL", oMdlGridDF8:GetValue("DF8_QTDVOL") - FwFldGet("T01_QTDVOL"))	
			    		oMdlGridDF8:LoadValue("DF8_PESO"  , oMdlGridDF8:GetValue("DF8_PESO") - FwFldGet("T01_PESO"))
			    		oMdlGridDF8:LoadValue("DF8_PESOM3", oMdlGridDF8:GetValue("DF8_PESOM3") - FwFldGet("T01_PESOM3"))
			    		oMdlGridDF8:LoadValue("DF8_VALOR" , oMdlGridDF8:GetValue("DF8_VALOR") - FwFldGet("T01_VALOR"))
			    		
			    		If FwFldGet('T01_SERTMS') == StrZero( 1, Len(DTC->DTC_SERTMS))  //Coleta 
							oMdlGridDF8:LoadValue("DF8_QTDCOL",oMdlGridDF8:GetValue("DF8_QTDCOL") - nQtdCol)
			    			oMdlGridDF8:LoadValue("DF8_VOLCOL",oMdlGridDF8:GetValue("DF8_VOLCOL") - FwFldGet("T01_QTDVOL"))
			    			oMdlGridDF8:LoadValue("DF8_PESCOL",oMdlGridDF8:GetValue("DF8_PESCOL") - FwFldGet("T01_PESO"))
			    			oMdlGridDF8:LoadValue("DF8_PM3COL",oMdlGridDF8:GetValue("DF8_PM3COL") - FwFldGet("T01_PESOM3"))
			    			oMdlGridDF8:LoadValue("DF8_VLMCOL",oMdlGridDF8:GetValue("DF8_VLMCOL") - FwFldGet("T01_VALOR"))
			    			oMdlGridDF8:LoadValue("DF8_VLFCOL",oMdlGridDF8:GetValue("DF8_VLFCOL") - FwFldGet("T01_VALFRE"))
			    		ElseIf FwFldGet('T01_SERTMS') == StrZero( 3, Len(DTC->DTC_SERTMS))  //Entrega
							oMdlGridDF8:LoadValue("DF8_QTDENT",oMdlGridDF8:GetValue("DF8_QTDENT") - nQtdEnt)
							oMdlGridDF8:LoadValue("DF8_VOLENT",oMdlGridDF8:GetValue("DF8_VOLENT") - FwFldGet("T01_QTDVOL"))
			    			oMdlGridDF8:LoadValue("DF8_PESENT",oMdlGridDF8:GetValue("DF8_PESENT") - FwFldGet("T01_PESO"))
			    			oMdlGridDF8:LoadValue("DF8_PM3ENT",oMdlGridDF8:GetValue("DF8_PM3ENT") - FwFldGet("T01_PESOM3"))
			    			oMdlGridDF8:LoadValue("DF8_VLMENT",oMdlGridDF8:GetValue("DF8_VLMENT") - FwFldGet("T01_VALOR"))
			    			oMdlGridDF8:LoadValue("DF8_VLFENT",oMdlGridDF8:GetValue("DF8_VLFENT") - FwFldGet("T01_VALFRE"))
			    		ElseIf FwFldGet('T01_SERTMS') == StrZero( 2, Len(DTC->DTC_SERTMS))  //Transferencia
		    				oMdlGridDF8:LoadValue("DF8_QTDTRA",oMdlGridDF8:GetValue("DF8_QTDTRA") - nQtdTra )
			    			oMdlGridDF8:LoadValue("DF8_VOLTRA",oMdlGridDF8:GetValue("DF8_VOLTRA") - FwFldGet("T01_QTDVOL"))
			    			oMdlGridDF8:LoadValue("DF8_PESTRA",oMdlGridDF8:GetValue("DF8_PESTRA") - FwFldGet("T01_PESO"))
			    			oMdlGridDF8:LoadValue("DF8_PM3TRA",oMdlGridDF8:GetValue("DF8_PM3TRA") - FwFldGet("T01_PESOM3"))
			    			oMdlGridDF8:LoadValue("DF8_VLMTRA",oMdlGridDF8:GetValue("DF8_VLMTRA") - FwFldGet("T01_VALOR"))
			    			oMdlGridDF8:LoadValue("DF8_VLFTRA",oMdlGridDF8:GetValue("DF8_VLFTRA") - FwFldGet("T01_VALFRE"))			    		
			    		EndIf
				   		
				   		oMdlGridDF8:LoadValue("DF8_QTDRAT",oMdlGridDF8:GetValue("DF8_QTDRAT") - nQtdRat )
				   		
						If oMdlGridDF8:GetValue("DF8_QTDVOL")  == 0  //Nao sobrou nenhum documento, exclui a programação 
							oMdlGridDF8:SetNoDeleteLine( .F. )
							If !oMdlGridDF8:IsDeleted() 
								oMdlGridDF8:DeleteLine() 
							EndIf 
			 				oMdlGridDF8:SetNoDeleteLine( .T. )
			 			EndIf
					
						oMdlGridDoc:SetValue('T01_NUMTMP', '')
						oMdlGridDoc:SetValue('T01_CODVEI', '')
						//oMdlGridDoc:SetValue('T01_SEQPRG', '')  -- Removido pois na alteracao ao desmarcar um documento nao estava descarregamento
						oMdlGridDoc:LoadValue("T01_LEGEN",TM146Cor('D',FwFldGet("T01_DOC"),FwFldGet("T01_BLQDOC"),'','',,FwFldGet("T01_FILDOC"),FwFldGet("T01_SERIE")) )  	
					EndIf	
					oMdlGridDoc:LoadValue("T01_MARK",.F.)
				
					aAdd(aVeiRes,DA3->DA3_COD)

					If lAltPrg .And. lIntTPR
						lAlteraTPR:= .T.
					EndIf
				Else
					oMdlGridDoc:LoadValue("T01_MARK",.F.)
				EndIf
			EndDo
			
			//-- Busca todos os clientes dos documentos da programação para verificar novamente a restrição
			If !oMdlGridDF8:IsDeleted() 
				aCepCli := {}
				T146Visual(.F.,@aCliLoj,@aCepCli)  
				If Len(aCliLoj) > 0
					lRestri:= Iif(lPesqRes,TMSA146Res("T",aCliLoj,aVeiRes,FwFldGet("DF8_ROTA"),,,,aCepCli),.F.)   //Restricao Cliente com Veiculo              
					oMdlGridDF8:LoadValue("DF8_RESTRI", Iif(lRestri,"BR_VERMELHO","BR_VERDE"))                 
				EndIf 
			EndIf
			
		Else  

			If lRet
				//Descarrega todos os doctos e programacoes 
				If !Empty(cNumTmp) .Or. !Empty(cNumPrg)			
					lAtualiza:= .F.
					While oMdlGridDoc:SeekLine( { Iif(!Empty(cNumTmp),{ "T01_NUMTMP", cNumTmp },{ "T01_NUMPRG", cNumPrg }), { "T01_SEQPRG", cSeqPrg } } )  
						oMdlGridDoc:SetValue( 'T01_NUMTMP', '' )
						oMdlGridDoc:SetValue( 'T01_NUMPRG', '' )
						oMdlGridDoc:SetValue( 'T01_SEQPRG', '' )
						oMdlGridDoc:SetValue( 'T01_CODVEI', '' )
						oMdlGridDoc:LoadValue( "T01_LEGEN", TM146Cor(	'D', ;
																		FwFldGet("T01_DOC"), ;
																		FwFldGet("T01_BLQDOC"), ;
																		'', ;
																		'', ;
																		, ;
																		FwFldGet("T01_FILDOC"), ;
																		FwFldGet("T01_SERIE") ) )
						lAtualiza:= .T.
					EndDo

					If lAtualiza
						oMdlGridDF8:SetNoDeleteLine( .F. )
						If !oMdlGridDF8:IsDeleted()
							oMdlGridDF8:DeleteLine()
						EndIf
						oMdlGridDF8:SetNoDeleteLine( .T. )
					EndIf
				EndIf	
			EndIf
		EndIf
			
	EndIf

	If lRet
		T146LimTot(aCamposTot,oMdlTotal)
		cSeqEnt:= ""  //zera variavel sequencia de entrega
		oMdlGridDoc:GoLine(nLinAtu)
		oView:Refresh('VwGridDoc')
	EndIf
	
EndIf

nCarretas:= 0

FWRestRows( aSaveLine )

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA146Leg
Legenda  
@author Katia
@since 11/08/2014
/*/
//-------------------------------------------------------------------
Function TMSA146Leg(cItem)

Local aLegenda  := {}		
Local cTitulo   := ''
       
Private cCadastro	:= STR0168 //'Manutenção de Documentos - Legenda'

Default cItem  := ""

If cItem == 'R'  //Restrições
	Aadd(aLegenda,{"BR_VERDE"	 , STR0057})  //Sem restricao 
	Aadd(aLegenda,{"BR_VERMELHO" , STR0058})  //Com restricao
  	 
	cTitulo:= STR0146 //'Restrições'
ElseIf cItem == 'P'  //Programação
	Aadd(aLegenda,{"BR_VERDE"	, STR0028}) 
	Aadd(aLegenda,{"BR_AZUL"	, STR0029}) 
	Aadd(aLegenda,{"BR_VERMELHO", STR0030})
	Aadd(aLegenda,{"BR_PRETO"   , STR0056})
	
	cTitulo:= STR0001  //'Prog. Carregamento'
ElseIf cItem == 'L'  //Legenda
	Aadd(aLegenda,{"BR_AMARELO"	, STR0022}) 
	Aadd(aLegenda,{"BR_AZUL"	, STR0021})
	Aadd(aLegenda,{"BR_VERMELHO", STR0046}) 
	Aadd(aLegenda,{"BR_PRETO"	, STR0117})
	
	cTitulo:= STR0023 //'Documentos'
ElseIf cItem == 'CV'  //Programacao Veiculo
	Aadd(aLegenda,{"BR_VERDE"	, STR0025}) 
	Aadd(aLegenda,{"BR_AMARELO"	, STR0026})
	Aadd(aLegenda,{"BR_VERMELHO", STR0104})
	
	cTitulo:= STR0145 //'Capacidade do Veiculo'

ElseIf cItem == 'DT6'  //Documentos
	aLegenda:= {}	
	Tmsa500Leg("BR_VIOLETA",STR0198)   //Cancelado da Viagem

ElseIf cItem == 'A' //-- Legenda para Prioridade de Agendamento de Entrega, executado a partir do TMSA141
	DbSelectArea("DYK")
	DYK->( DbSetOrder(1) )
	DYK->(DbGoTop() )

	aLegenda := {}
	Aadd( aLegenda, { "PMSEDT3", STR0055 } ) //"Não utiliza agendamento"

	While DYK->( !EOF() )

		aRetCor := RetSx3Box( Posicione('SX3', 2, 'DYK_CORPRI', 'X3CBox()' ),,, Len(DYK->DYK_CORPRI))
		cCorDYK := Upper( "BR_" + StrTran(AllTrim(aRetCor[Ascan(aRetCor, {|x| AllTrim(x[2]) == AllTrim(DYK->DYK_CORPRI)}), 3 ]),"Rosa","Pink"))

		Aadd( aLegenda, { cCorDYK, DYK_DESPRI } )

		DYK->( DbSkip() )
	EndDo

	cTitulo:= STR0053   //Agendamento de Entrega
EndIf

If Len(aLegenda) > 0  
	BrwLegenda(cTitulo, STR0009, aLegenda)
EndIf
				
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA146VldºAutor  ³ Daniel Leme        º Data ³  10/02/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação de Campos                                         º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSA146Vld(cCampo)

Local oModel     := FwModelActive()
Local oView      := FwViewActive()
Local oMdlGridDF8:= oModel:GetModel('MdGridDF8')
Local oMdlGridDDZ:= oModel:GetModel('MdGridDDZ')       
Local oMdlGridDA3:= oModel:GetModel('MdGridDA3') 
Local aArea		 := GetArea()
Local lRet		 := .T.
Local cCatVei    := ""
Local aVeiRes    := {}
Local aSaveDF8   := FWSaveRows()
Local nXX        := 0
Local cVeiculo   := ""
Local cNumPrgDDZ := ""
Local cSeqPrgDDZ := ""
Local lOk        := .F.
Local nY         := 0
Local nLine      := 0
Local cSerTmsT01 := ""

Default cCampo   := ReadVar()

FwClearHLP()

If "DF8_ROTA" $ cCampo
	If Empty(FwFldGet('DF8_NUMTMP')) .And. Empty(FwFldGet('DF8_NUMPRG'))
		lRet:= .F.
	Else
		If !Empty(M->DF8_ROTA)	
			lRet := ExistCpo("DA8",M->DF8_ROTA,1)
			
			If lRet
				If !F11RotRote(M->DF8_ROTA) 
					If FwFldGet('DF8_QTDRAT') > 0  
						oModel:GetModel():SetErrorMessage(,,,,,STR0199) //"Programação com Documentos com Criterio de Rateio 'A', não é permitido utilizar uma Rota por Cep/Cliente"
						lRet:= .F.
						M->DF8_ROTA:= ""
					EndIf
				Else
					If FwFldGet('DF8_SERTMS') == StrZero(2,Len(DUD->DUD_SERTMS)) //Servico de Transporte nao tem Rota Automatica
						If lRot146Aut
							TM146MsgAd(STR0215,"TMSA146VLD" )
						Else	
							Help('',1,'TMSA14637')  //'Obrigatorio informar uma Rota por CEP e ou Cliente'
						EndIf	
						lRet:=.F.
					EndIf
				EndIf		
			EndIf
		Else
			If 	FwFldGet('DF8_SERTMS') == StrZero(2,Len(DUD->DUD_SERTMS)) //Servico de Transporte nao tem Rota Automatica
				If lRot146Aut
					TM146MsgAd(STR0215,"TMSA146VLD" )
				Else			
					Help('',1,'TMSA14637')  //'Obrigatorio informar uma Rota por CEP e ou Cliente'  
				EndIf	
				lRet:=.F.
			EndIf 
		EndIf	
	EndIf
	
	If lRet
			
		If !Empty(M->DF8_ROTA)		
			If Empty(FwFldGet('DF8_SERTMS'))
				cSerTmsT01 := FwFldGet('T01_SERTMS')
			Else
				cSerTmsT01 := FwFldGet('DF8_SERTMS')
			EndIf
			lRet := A146VldRot(M->DF8_ROTA,cTpTransp,FwFldGet('DF8_QTDCOL'),FwFldGet('DF8_QTDTRA'),FwFldGet('DF8_QTDENT'), cSerTmsT01)
		EndIf	
		
		If lRet
			aAdd(aVeiRes,FwFldGet('DF8_CODVEI'))
			If FwFldGet('DF8_RESTRI') <> 'BR_VERMELHO' .And. !Empty(M->DF8_ROTA)
				lRestri:= Iif(lPesqRes,TMSA146Res("V",,aVeiRes,M->DF8_ROTA,DTOS(FwFldGet('DF8_DATGER')),FwFldGet('DF8_HORGER')),.F.) 
			  	//Se esta sem restricao, verifica novamente apos digitar a rota
				oMdlGridDF8:LoadValue('DF8_RESTRI',Iif(lRestri,'BR_VERMELHO','BR_VERDE'))
			EndIf	
		EndIf  
		     
		//---- Se programação COMBOIO, utiliza a mesma rota para todas as programações
		If lRet .And. oMdlGridDDZ:Length() > 1
				
			aSaveDF8 := FWSaveRows()
			For nXX:=1 To oMdlGridDDZ:Length()
				oMdlGridDDZ:GoLine(nXX)
				If !oMdlGridDDZ:IsDeleted()					
					lOk:= oMdlGridDF8:SeekLine( {{ "DF8_CODVEI", FwFldGet('DDZ_CODVEI')},{ "DF8_NUMTMP", FwFldGet('DDZ_NUMPRG')}, { "DF8_SEQPRG", FwFldGet('DDZ_SEQPRG')}  } )
					If lOk
						oMdlGridDF8:LoadValue('DF8_ROTA',M->DF8_ROTA)
					EndIf	
				EndIf
			Next nXX
			FWRestRows( aSaveDF8 )
			oView:Refresh('VwGridDF8')
		EndIf
	EndIf
EndIf

If cCampo $ "M->DF8_FILVGE|M->DF8_NUMVGE" 
	If cCampo == "M->DF8_NUMVGE" .And. Empty(FwFldGet('DF8_FILVGE'))
		Help('',1,'REGNOIS')
		lRet := .F.
	EndIf
	If lRet .And. !Empty(FwFldGet('DF8_NUMVGE'))
		lRet:= ExistCpo("DTQ",FwFldGet('DF8_FILVGE')+AllTrim(FwFldGet('DF8_NUMVGE')),2)
	EndIf
	If lRet .And. cCampo == 'M->DF8_NUMVGE'
		If FwFldGet('DF8_FILVGE')+FwFldGet('DF8_NUMVGE') == FwFldGet('DF8_FILORI') + FwFldGet('DF8_VIAGEM')
			Help("",1,"TMSA24013") // A Viagem Original Nao Podera ser igual a Viagem ..
			lRet := .F.
		EndIf	
	EndIf
	If lRet
		If !Empty(FwFldGet('DF8_NUMVGE'))
			DTR->(dbSetOrder(1))
			If !DTR->(MsSeek(xFilial("DTR")+FwFldGet('DF8_FILVGE')+FwFldGet('DF8_NUMVGE')))
				Help("",1,"TMSA24016") // Nao existe Complemento de Viagem para esta Viagem ...
				lRet := .F.
			Else
				DA3->( dbSetOrder( 1 ) )
				If DA3->( dbSeek( xFilial('DA3') + FwFldGet('DF8_CODVEI') ))		
					cCatVei:= Posicione('DUT',1,xFilial('DUT')+DA3->DA3_TIPVEI,'DUT_CATVEI') 
					If cCatVei == StrZero(3, Len(DUT->DUT_CATVEI)) ///Reboque
						If DTR->DTR_CODVEI <> FwFldGet('DF8_CODCAV')
							lRet := .F.
						ElseIf (DTR->DTR_CODRB1 <> DA3->DA3_COD) .Or. (DTR->DTR_CODRB2 <> DA3->DA3_COD)  
							lRet := .F.
						EndIf
					Else
						If DTR->DTR_CODVEI <> DA3->DA3_COD
							lRet := .F.
						EndIf
					EndIf	
					If !lRet
						Help("",1,"TMSA14626") // O veiculo da viagem nao é o mesmo que o veiculo da programacao....
					EndIf
				EndIf	
			EndIf
		EndIf	
	EndIf
	If lRet
		DTQ->( MsSeek(xFilial("DTQ")+FwFldGet('DF8_FILVGE')+FwFldGet('DF8_NUMVGE')) )
		If (DTQ->DTQ_VIAGEM == FwFldGet('DF8_NUMVGE')) .And. (DTQ->DTQ_STATUS > "2")  // Status != 1 - Em Aberto / 2 - Em Transito.
			Help(' ', 1, 'TMSA24003')  //-- Viagem nao esta Em Aberto e nem Em Transito!
			lRet := .F.
		EndIf
	EndIf
EndIf

If cCampo $ "M->DF8_DATGER|M->DF8_HORGER|M->DF8_CODCAV"    
	If cCampo $ "M->DF8_CODCAV"	.And. !Empty(M->DF8_CODCAV)
		lRet := ExistCpo("DA3",M->DF8_CODCAV,1)
		If lRet
			DA3->( dbSetOrder( 1 ) )
			If DA3->( dbSeek( xFilial('DA3') + M->DF8_CODCAV ))
				cCatVei:= Posicione('DUT',1,xFilial('DUT')+DA3->DA3_TIPVEI,'DUT_CATVEI') 
	
				If cCatVei <> StrZero(2, Len(DUT->DUT_CATVEI)) //Cavalo
					If lRot146Aut
						TM146MsgAd(STR0216,"TMSA146VLD" )
					Else	
						Help(' ', 1, 'TMSA14621')   //Veiculo Invalido
					EndIf	
					lRet := .F.
				EndIf
			EndIf
		Else
			If lRot146Aut
				TM146MsgAd(STR0217,"TMSA146VLD" )
			Else
				Help('',1,'REGNOIS')	
			EndIf	
		EndIf
	EndIf

	If lRet 
		aSaveDF8    := FWSaveRows()          
		cVeiculo    := FwFldGet('DF8_CODVEI')
		cCavalo     := FwFldGet('DF8_CODCAV')                                          
		cNumPrgDDZ  := FwFldGet('DF8_NUMTMP')                                          
		cSeqPrgDDZ  := FwFldGet('DF8_SEQPRG')    

		aSaveDF8 := FWSaveRows()
		If !Empty(cCavalo)  
			
			For nXX:=1 To oMdlGridDDZ:Length()  
				oMdlGridDDZ:GoLine(nXX)
				If !oMdlGridDDZ:IsDeleted()		
					If cCampo $ "M->DF8_CODCAV"			
						oMdlGridDDZ:LoadValue('DDZ_CODCAV',M->DF8_CODCAV)
					EndIf	
				EndIf
			Next nXX
		EndIf
		
		If oMdlGridDDZ:Length() > 1 //Comboio
			For nXX:=1 To oMdlGridDF8:Length()  
				oMdlGridDF8:GoLine(nXX)
				If !oMdlGridDF8:IsDeleted()
					If FwFldGet('DF8_NUMTMP')  == cNumPrgDDZ .And. FwFldGet('DF8_SEQPRG')  == cSeqPrgDDZ	
						If cCampo $ "M->DF8_CODCAV"			
							oMdlGridDF8:SetValue('DF8_CODCAV',M->DF8_CODCAV)
						ElseIf cCampo $ "M->DF8_DATGER"
							oMdlGridDF8:SetValue('DF8_DATGER',M->DF8_DATGER)
						ElseIf	cCampo $ "M->DF8_HORGER"
							oMdlGridDF8:SetValue('DF8_HORGER',M->DF8_HORGER)
						EndIf
					EndIf	
				EndIf	
			Next nXX	
		EndIf				
		
		If Type('oView') <> 'U'
			oView:Refresh('VwGridDF8')
			oView:Refresh('VwGridDDZ')
		EndIf	
		FWRestRows( aSaveDF8 )
   
	EndIf
EndIf

If DF8->(ColumnPos("DF8_DATINI")) > 0
	If cCampo == "DF8_DATINI"	
		If !Empty(FwFldGet("DF8_DATINI"))
			If FwFldGet("DF8_DATINI") < Date()
				Help(,, "HELP",, STR0226, 1, 0) //Data de início não pode ser anterior à data atual.
				lRet := .F.
			ElseIf !Empty(FwFldGet("DF8_DATFIM")) .AND. FwFldGet("DF8_DATINI") > FwFldGet("DF8_DATFIM")
				Help(,, "HELP",, STR0236, 1, 0) //Data de início não pode ser posterior à data de fim.
				lRet := .F.
			ElseIf FwFldGet("DF8_DATINI") == Date() .AND. !Empty(FwFldGet("DF8_HORINI")) .AND. FwFldGet("DF8_HORINI") < (Substr( TIME(),1,2  )+ Substr( TIME(),4,2  ))
				Help(,, "HELP",, STR0228, 1, 0) //Hora de fim não pode ser anterior à hora atual.
				lRet := .F.
			EndIf
		EndIf
		
		nLine := oMdlGridDA3:GetLine()
		For nY := 1 to oMdlGridDA3:Length()	
			oMdlGridDA3:GoLine(nY)
			oMdlGridDF8:SetValue('DF8_DATINI',FwFldGet('DF8_DATINI'))
		Next nY
		oMdlGridDA3:GoLine(nLine)
	EndIf

	If cCampo == "DF8_DATFIM"
		If !Empty(FwFldGet("DF8_DATFIM")) 
			If FwFldGet("DF8_DATFIM") < Date()
				Help(,, "HELP",, STR0229, 1, 0) //Data de fim não pode ser anterior à data atual.
				lRet := .F.
			ElseIf !Empty(FwFldGet("DF8_DATINI")) .AND. FwFldGet("DF8_DATINI") > FwFldGet("DF8_DATFIM")
				Help(,, "HELP",, STR0227, 1, 0) //Data de fim não pode ser anterior à data de início.
				lRet := .F.
			ElseIf FwFldGet("DF8_DATFIM") == Date() .AND. !Empty(FwFldGet("DF8_HORFIM")) .AND. FwFldGet("DF8_HORINI") < (Substr( TIME(),1,2  )+ Substr( TIME(),4,2  ))
				Help(,, "HELP",, STR0230, 1, 0) //Hora de fim não pode ser anterior à hora atual.
				lRet := .F.
			EndIf	
		EndIf

		nLine := oMdlGridDA3:GetLine()
		For nY := 1 to oMdlGridDA3:Length()
			oMdlGridDA3:GoLine(nY)
			oMdlGridDF8:SetValue('DF8_DATFIM',FwFldGet('DF8_DATFIM'))
		Next nY
		oMdlGridDA3:GoLine(nLine)
	EndIf

	If cCampo == "DF8_HORINI"
		If !Empty(FwFldGet("DF8_HORINI"))
			lRet := AtVldHora(FwFldGet("DF8_HORINI"))
			If lRet .AND. (FwFldGet("DF8_DATINI") == Date())
				If(FwFldGet("DF8_HORINI") < (Substr( TIME(),1,2  )+ Substr( TIME(),4,2  )))
					Help(,, "HELP",, STR0228, 1, 0) //Hora de início não pode ser anterior à hora atual.
					lRet := .F.
				EndIf
			EndIf
			
			If lRet .AND. ( FwFldGet("DF8_DATINI") == FwFldGet("DF8_DATFIM")) .AND. (!Empty(FwFldGet("DF8_DATINI")) .AND. !Empty(FwFldGet("DF8_DATFIM")))
				If !Empty(FwFldGet("DF8_HORFIM"))
					If FwFldGet("DF8_HORFIM") < FwFldGet("DF8_HORINI") 
						Help(,, "HELP",, STR0237, 1, 0) //Data e hora de início não pode ser posterior à data e hora de fim.
						lRet := .F.
					EndIf 
				EndIf
			EndIf	
		EndIf

		nLine := oMdlGridDA3:GetLine()
		For nY := 1 to oMdlGridDA3:Length()	
			oMdlGridDA3:GoLine(nY)
			oMdlGridDF8:SetValue('DF8_HORINI',FwFldGet('DF8_HORINI'))
		Next nY
		oMdlGridDA3:GoLine(nLine)
	EndIf

	If cCampo == "DF8_HORFIM"
		If !Empty(FwFldGet("DF8_HORFIM"))
			lRet := AtVldHora(FwFldGet("DF8_HORFIM"))
			If lRet .AND. (FwFldGet("DF8_DATFIM") == Date())
				If (FwFldGet("DF8_HORFIM") < (Substr( TIME(),1,2  )+ Substr( TIME(),4,2  )))
					Help(,, "HELP",, STR0230, 1, 0) //Hora de fim não pode ser anterior à hora atual.
					lRet := .F.
				EndIf
			EndIf
	
			If lRet .AND. ( FwFldGet("DF8_DATINI") == FwFldGet("DF8_DATFIM")) .AND. (!Empty(FwFldGet("DF8_DATINI")) .AND. !Empty(FwFldGet("DF8_DATFIM")))
				If !Empty(("DF8_HORINI"))
					If FwFldGet("DF8_HORFIM") < FwFldGet("DF8_HORINI")
						Help(,, "HELP",, STR0238, 1, 0) //Data e hora de fim não pode ser anterior à data e hora de início.
						lRet := .F.
					EndIf 
				EndIf
			EndIf 
		EndIf

 		nLine := oMdlGridDA3:GetLine()
		For nY := 1 to oMdlGridDA3:Length()		
			oMdlGridDA3:GoLine(nY)
			oMdlGridDF8:SetValue('DF8_HORFIM',FwFldGet('DF8_HORFIM'))
		Next nY
		oMdlGridDA3:GoLine(nLine)                                                                      
	EndIf
EndIf

RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TMA146Act
Ativa a Folder (Rota ou Documentos)  
@author Katia
@since 11/08/2014
/*/
//-------------------------------------------------------------------

Function TMA146Act(oView)

Local nOperation:= oView:GetOperation()
Local oVwGridDoc:= oView:GetModel('MdGridDoc') 
Local oVwGridDA3:= oView:GetModel('MdGridDA3')

If nOperation == 1 .Or. nOperation == 5 //Visualizar ou Excluir
	// Esconde a Aba da Rota
	oView:HideFolder('IdFldIni',2,2)
 	oView:HideFolder("IdFldIni",2,1)
	Return
EndIf
 
Pergunte("TMSA146C",.F.)
If mv_par01 == 1 .OR.  IsInCallStack("TMSAF76") 
	// Esconde a Aba da Rota
 	oView:HideFolder('IdFldIni',2,2)
 	oView:HideFolder("IdFldIni",2,1)
ElseIf mv_par01 == 2  //Rotas
	If IsInCallStack("TMSA146ALT")
		oView:SelectFolder("IdFldIni",1,2)
	Else
		oView:SelectFolder("IdFldIni",2,2)
	EndIf
EndIf

//-- Fechar a Tela quando nao existe registros a serem exibidos. Apos a apresentacao do help  TMSA14602
If ( oVwGridDoc:Length() <= 1 .And. (oVwGridDoc:IsEmpty()) ) .Or.;    //Grid Documentos
	( oVwGridDA3:Length() <= 1 .And. (oVwGridDA3:IsEmpty()) )          //Grid Veiculos   
	oView:ButtonCancelAction()
EndIf	

Pergunte("TMSA146",.F.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TMA146Seq
Sequencia de Entrega do Documento  
@author Katia
@since 11/08/2014
/*/
//-------------------------------------------------------------------

Function TMA146Seq()

Local cRet        := ""
Local cQuery      := ""
Local cAliasDD9   := ""

If !(FwFldGet('T01_SERTMS') $ StrZero(2,Len(DUD->DUD_SERTMS)))  
	If FwFldGet('T01_MARK')
		If !Empty(FwFldGet('T01_DOC')) 
			If Empty(cSeqEnt)
				If IsInCallStack('TMSA146ALT')
					cAliasDD9 := GetNextAlias()
					cQuery	+= "  SELECT MAX(DD9_SEQUEN) MAXSEQ "
					cQuery	+= "  FROM  " + RetSqlName("DD9") + " DD9 "
					cQuery	+= "  WHERE DD9.DD9_FILIAL = '"+ FwxFilial("DD9") +"' "
					cQuery	+= "  AND DD9.DD9_FILORI = '"+ FwFldGet('DF8_FILORI') +"' "
					cQuery	+= "  AND DD9.DD9_NUMPRG = '"+ FwFldGet('DF8_NUMPRG') +"' " 
					cQuery	+= "  AND DD9.D_E_L_E_T_ = ' '"
					
					cQuery := ChangeQuery(cQuery)	
					dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDD9,.T.,.T.)
					
					If (cAliasDD9)->(!Eof())
						cSeqEnt := (cAliasDD9)->MAXSEQ
					EndIf
					
					(cAliasDD9)->(dbCloseArea())	
				Else
					cSeqEnt:= Space(TamSx3("DUD_SEQENT")[1])
				EndIf
				
			EndIf
			cSeqEnt:= Soma1(cSeqEnt)
			cRet   := cSeqEnt
		Else
			cRet:= ""
		EndIf
	Else
		If !Empty(FwFldGet('T01_NUMTMP')) .OR. IsInCallStack("T146CarPrg")
			cRet:= FwFldGet('T01_SEQENT')
		EndIf
	EndIf
EndIf		

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T146PosVld
Pos Validacao  
@author Katia
@since 13/10/2014
/*/
//-------------------------------------------------------------------
Function T146PosVld(oModel)

Local oMdlGridDF8:= oModel:GetModel( "MdGridDF8" )
Local oMdlGridDA3:= oModel:GetModel( "MdGridDA3" )
Local lRet       := .T.
Local nCont      := 0
Local cCatVei    := 0
Local aArea      := GetArea()
Local aSaveLine  := FWSaveRows()
Local aVeiculos  := {}
Local cCampo     := ""
Local nOperation := oModel:GetOperation()
Local cVeiGen    := GetMv('MV_VEIGEN',,.T.)
Local nContDA3   := 0
Local lGravar    := .F. 
Local cMsg       := "" 
Local lDelPrg    := .F.
Local cNumPrg	 := ""
Local cNumDmd	 := ""
Local aDT5       := {}
Local nX         := 0
Local cIdRot     := ""

If nOperation == 4 .AND. Empty(FwFldGet("DF8_NUMPRG")) .AND. !('T153GEXEC' $ procname(9))
	cNumPrg	 := GetSX8Num('DF8','DF8_NUMPRG')
	RollBackSx8()
Else
	cNumPrg	 := FwFldGet("DF8_NUMPRG")
	cNumDmd	 := If( ColumnPos("DF8_PLNDMD") > 0, DF8->DF8_PLNDMD, "" )
EndIf

FwClearHLP()
If nOperation == 4 .Or. nOperation == 6
	If !IsInCallStack('TMSA146MNT')  .And. !lIncAuto
		If  DF8->DF8_STATUS == '2'   
			cMsg := STR0186  //Programação já efetivada
			lRet:= .F.
		ElseIf 	DF8->DF8_STATUS == '9'
			cMsg := STR0187   //A Programação está Cancelada !
			lRet:= .F.
		EndIf
	EndIf
EndIf

If nOperation == 4 .And. lRet
	
	//Validações dos campos de data do planejamento.
	If lRet .And. DF8->(ColumnPos("DF8_DATINI")) > 0
		If !Empty(FwFldGet("DF8_DATINI")) .AND. Empty(FwFldGet("DF8_DATFIM"))
			Help(,, "HELP",,STR0232, 1, 0) //Ao informar a Data Inicio é obrigatório informar a Data Fim.
			lRet := .F.
		ElseIf Empty(FwFldGet("DF8_DATINI")) .AND. !Empty(FwFldGet("DF8_DATFIM"))
			Help(,, "HELP",,STR0233, 1, 0) //Ao informar a Data Fim é obrigatório informar a Data Inicio.
			lRet := .F.
		EndIf

		//Caso o horário esteja preenchido, é obrigatório informar as datas.
		If lRet .AND. (Empty(FwFldGet("DF8_DATINI")) .AND. Empty(FwFldGet("DF8_DATFIM"))) .AND. (!Empty(FwFldGet("DF8_HORINI")) .OR. !Empty(FwFldGet("DF8_HORFIM")))
			Help(,, "HELP",,STR0234, 1, 0) //Ao informar o horário é obrigatório informar a Data Inicio e a Data Fim do planejamento.
			lRet := .F.
		EndIf

		//Caso alguma data esteja preenchida, é obrigatório informar um horário.
		If lRet .AND. (!Empty(FwFldGet("DF8_DATINI")) .OR. !Empty(FwFldGet("DF8_DATFIM"))) .AND. (Empty(FwFldGet("DF8_HORINI")) .OR. Empty(FwFldGet("DF8_HORFIM")))
			Help(,, "HELP",,STR0235 , 1, 0) //Ao informar a Data Inicio e a Data Fim do planejamento é obrigatório informar o horário.
			lRet := .F.
		EndIf
		//valida se existe um Planejamento, outra Programação de Carregamento ou Viagem, planejados para o mesmo período e utilizando o mesmo Veículo (Cavalo e reboques).
		If lRet	.AND. !Empty(cNumPrg) //Não executa na criação da programação via Integração com o TMS	
			AAdd( aVeiculos,FwFldGet("DDZ_CODVEI"))
			AAdd( aVeiculos,FwFldGet("DDZ_CODRB1"))
			AAdd( aVeiculos,FwFldGet("DDZ_CODRB2"))
			AAdd( aVeiculos,FwFldGet("DDZ_CODRB3"))
			lRet := TMSVldVei(cNumDmd,cNumPrg,,FwFldGet("DF8_DATINI"),FwFldGet("DF8_HORINI"),FwFldGet("DF8_DATFIM"),FwFldGet("DF8_HORFIM"),aVeiculos)
		EndIf 
	EndIf

	For nContDA3 := 1 To oMdlGridDA3:Length()
		oMdlGridDA3:GoLine(nContDA3)   
			
		If !oMdlGridDF8:IsEmpty()
			For nCont:=1 to oMdlGridDF8:Length()
				If !oMdlGridDF8:IsDeleted(nCont)
					lGravar:= .T.
					
					oMdlGridDF8:GoLine(nCont)
			
					Do Case
					Case Empty(FwFldGet('DF8_SERTMS'))
					 	cCampo:= 'DF8_SERTMS'
					Case Empty(FwFldGet('DF8_CODVEI'))
					 	cCampo:= 'DF8_CODVEI'
					Case Empty(FwFldGet('DF8_ROTA'))
						// Somente de Rota Automatica para servico de transporte diferente de Transporte
					 	If FwFldGet('DF8_SERTMS') == '2'
					 		cCampo:= 'DF8_ROTA'
					 	EndIf
					Case Empty(FwFldGet('DF8_DATGER'))
					 	cCampo:= 'DF8_DATGER'
					Case Empty(FwFldGet('DF8_HORGER'))
						cCampo:= 'DF8_HORGER'
					End Case
					
					If !Empty(cCampo)
						cMsg := STR0188 + RetTitle(cCampo)
						lRet:= .F.
						Exit
					EndIf
					
					If lRet 
						DA3->( dbSetOrder( 1 ) )
						If DA3->( dbSeek( xFilial('DA3')+FwFldGet('DF8_CODVEI') ))
							cCatVei:= Posicione('DUT',1,xFilial('DUT')+DA3->DA3_TIPVEI,'DUT_CATVEI') 
							If cCatVei == StrZero(3, Len(DUT->DUT_CATVEI)) .And. Empty(FwFldGet('DF8_CODCAV')) //-- Se o Tipo do Veiculo for 'Carreta', deverá informar o 'Cavalo'
								If Empty(cVeiGen) .And. !IsBlind()
									cMsg := STR0188 + RetTitle("DF8_CODCAV")
									lRet:= .F.
									Exit
								EndIf	
							EndIf
						EndIf	
					EndIf	 
				Else
					lDelPrg:= .T.
				EndIf	
			Next
		EndIf
	Next
	
	If lRet .And. !lGravar //Nao houve nenhum carregamento
		cMsg:= STR0189 //Não foi efetuado nenhum carregamento. Escolha determinado veículo e realize o carregamento.
		If lDelPrg .And. 	IsInCallStack("TMSA146ALT") 
			cMsg:= STR0201 //"Para efetuar o Descarregamento de todos os documentos da Programação deve-se utilizar a opção 'EXCLUIR'"
		EndIf
		lRet:= .F.
	EndIf	

	If lRet .And. lIntTPR .And. lAlteraTPR
		cIdRot:= T146VldTPR('DF8',DF8->DF8_FILORI,DF8->DF8_NUMPRG,DF8->DF8_SEQPRG)
		If !Empty(cIdRot) 
			If !MsgYesNo( STR0256, STR0257 ) //"Ao alterar a Programação a Roterização NÃO SERÁ mais valida ! Deseja Prosseguir ? ", "Programação de Carregamento com Roteirização.")
				lRet:= .F.
			EndIf
		EndIf
	EndIf

EndIf

If nOperation = 5 //Exclusao
	dbSelectArea("DTR")
	DTR->(DbSetOrder(2))
	If	DTR->(MsSeek(xFilial('DTR') + DF8->DF8_FILORI + DF8->DF8_VIAGEM))   //Viagem Coligada
		oModel:GetModel():SetErrorMessage(oModel:GetId(),,,,"TMSA14422", DTR->DTR_FILORI + ' - ' + DTR->DTR_VIAGEM)
		lRet:= .F.
	EndIf

	//Se estiver integrado com a gestão de demandas, valida se as coletas podem ser canceladas
	If lMVITMSDMD .And. DT5->(ColumnPos("DT5_CODDMD")) > 0
		dbSelectArea("DD9")
		DD9->(dbSetOrder(1)) //-- DD9_FILIAL+DD9_FILORI+DD9_NUMPRG+DD9_ITEM
		If DD9->(dbSeek(xFilial("DD9") + DF8->DF8_FILORI + DF8->DF8_NUMPRG))
			dbSelectArea("DT5")
			DT5->(dbSetOrder(4))
			While DD9->(DD9_FILORI + DD9_NUMPRG) == DF8->(DF8_FILORI + DF8_NUMPRG) .And. DD9->(!Eof())				 
				If DT5->(dbSeek(FwFilial('DT5') + DD9->(DD9_FILDOC + DD9_DOC + DD9_SERIE))) .And. !Empty(DT5->DT5_CODDMD)				
					Aadd(aDT5, {DD9->DD9_FILDOC, DD9->DD9_DOC, DD9->DD9_SERIE})
				EndIf
				
				DD9->(dbSkip())
			EndDo
		EndIf
		
		aDT5 := Tmsa460Can(aDT5)
		For nX := 1 To Len(aDT5)
			If aDT5[nX][4] == .F.
				oModel:GetModel():SetErrorMessage(oModel:GetId(),,,,, STR0240 + AllTrim(aDT5[nX][1]) + '/' + AllTrim(aDT5[nX][2]) + '/' + AllTrim(aDT5[nX][3]) + STR0241) //Coleta XX/XXXXX/XXX não pode ser cancelada.
				lRet := .F.				
				Exit
			EndIf
		Next nX
	EndIf

Else
	If !lRet .And. !Empty(cMsg)
		oModel:GetModel():SetErrorMessage(oModel:GetId(),,,,,cMsg)
	EndIf 
EndIf

FWRestRows( aSaveLine )
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T146Visual
Visualizacao dos Documentos da Programação Temporaria 
@author Katia
@since 14/10/2014
/*/
//-------------------------------------------------------------------
Function T146Visual(lMostra,aCliLoj,aCepCli)

Local oModel     := FwModelActive()
Local oMdlGridDoc:= oModel:GetModel("MdGridDoc")

Local cNumTmp    := If (!Empty(FwFldGet('DF8_NUMTMP')),FwFldGet('DF8_NUMTMP'),Space(Len(DF8->DF8_NUMPRG))) 
Local cNumPrg    := If (!Empty(FwFldGet('DF8_NUMPRG')),FwFldGet('DF8_NUMPRG'),Space(Len(DF8->DF8_NUMPRG)))
Local cSeqPrg    := FwFldGet('DF8_SEQPRG')
Local cCodVei    := FwFldGet('DF8_CODVEI')
Local nCntFor    := 0
Local nItem	   := 0
Local nPos       := 0
Local aCliRet    := {}
//-- Dialog
Local aBtnTabel  := {}
Local oDlgEsp    := Nil
Local aHeaderDTC	:= {}
Local aFldDTC		:= {}
Local nI			:= 0

//-- GetDados
Private aHeader := {}
Private aCols	:= {}
Private oGetD   := Nil

Default lMostra := .T.
Default aCliLoj := {}
Default aCepCli	:= {}

SaveInter()

If lMostra
	//-- Preenche aHeader
	aHeaderDTC := {"DTC_FILDOC", "DTC_DOC", "DTC_SERIE", "DTC_NUMNFC", "DTC_SERNFC", "DTC_SERTMS", "DTC_NOMREM", "DTC_NOMDES"}
	aFldDTC := ApBuildHeader("DTC")

	For nI := 1 To Len(aHeaderDTC)
		If (nPos := aScan(aFldDTC, {|x| AllTrim(x[2]) == aHeaderDTC[nI]})) > 0
			aAdd(aHeader, aFldDTC[nPos])
		EndIf
	Next

EndIf

For nCntFor := 1 To oMdlGridDoc:Length()
	If !oMdlGridDoc:IsDeleted(nCntFor)
		oMdlGridDoc:GoLine(nCntFor)
		
		If (FwFldGet('T01_NUMTMP') == cNumTmp .Or. FwFldGet('T01_NUMPRG') == cNumPrg) .And. FwFldGet('T01_SEQPRG') == cSeqPrg .And. FwFldGet('T01_CODVEI') == cCodVei
			If lMostra
				AAdd( aCols, Array( Len( aHeader ) + 1 ) )
				nItem := Len(aCols)
					
				GDFieldPut('DTC_FILDOC',FwFldGet('T01_FILDOC'), nItem )
				GDFieldPut('DTC_DOC'   ,FwFldGet('T01_DOC')   , nItem )
				GDFieldPut('DTC_SERIE' ,FwFldGet('T01_SERIE') , nItem )
				GDFieldPut('DTC_NUMNFC',FwFldGet('T01_NUMNFC'), nItem )
				GDFieldPut('DTC_SERNFC',FwFldGet('T01_SERNFC'), nItem )
				GDFieldPut('DTC_SERTMS',FwFldGet('T01_SERTMS'), nItem )
				If FwFldGet('T01_SERIE') == 'COL'
					DT5->(dbSetOrder(1))
					If DT5->(DbSeek(xFilial('DT5')+FwFldGet('T01_FILDOC')+FwFldGet('T01_DOC')+FwFldGet('T01_SERIE')))
						DUE->(dbSetOrder(1))
						If DUE->(MsSeek(xFilial('DUE')+DT5->(DT5_CODSOL)))
							GDFieldPut('DTC_NOMREM',DUE->DUE_NOME, nItem )
						EndIf	
					EndIf
				Else
					GDFieldPut('DTC_NOMREM',Posicione('SA1',1,xFilial('SA1')+FwFldGet('T01_CLIREM')+FwFldGet('T01_LOJREM'),'A1_NOME'), nItem )
					GDFieldPut('DTC_NOMDES',Posicione('SA1',1,xFilial('SA1')+FwFldGet('T01_CLIDES')+FwFldGet('T01_LOJDES'),'A1_NOME'), nItem )
				EndIf	
				aCols[ nItem, Len( aHeader ) + 1 ] := .F.
			Else
				aCliRet:= TM146ReCli(FwFldGet('T01_FILDOC'),FwFldGet('T01_DOC'),FwFldGet('T01_SERIE'),FwFldGet('T01_CLIDES'),FwFldGet('T01_LOJDES'),FwFldGet('T01_SQEDES'))
				If Len(aCliRet) > 0
					If aScan(aCliLoj,{|x| x[1]+x[2] == aCliRet[1][1] + aCliRet[1][2] }) == 0
						aAdd(aCliLoj,{ aCliRet[1][1], aCliRet[1][2] })     
					EndIf
				EndIf	
			EndIf	
			//Busca CEP's do documento do cliente
			If lRestricao .AND. cMVTMSRLC $ "1|3" .AND. FindFunction("BusCliServ")
				dbSelectArea("DT6")
				DT6->(dbSetOrder(1))
				If DT6->( dbSeek( FwxFilial("DT6")+ FwFldGet("T01_FILDOC") + FwFldGet("T01_DOC") + FwFldGet("T01_SERIE") ) ) 
					BusCliServ(,,@aCepCli)
				EndIf
			EndIf
				
		EndIf
	EndIf	
Next
	
If lMostra
	DEFINE MSDIALOG oDlgEsp TITLE 'Documentos da Programação: ' + cNumTmp + '/ ' + cSeqPrg FROM 9,0 TO 27.5,80 OF oMainWnd 
	
		oGetD := MSGetDados():New(30,3,138,314,2,'AllwaysTrue()','AllwaysTrue()') 
	
	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||oDlgEsp:End()},{||oDlgEsp:End()},, aBtnTabel ) CENTERED
EndIf	

RestInter()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TMA146VDoc
Validacao da selecao do Documento - Servico Adicional
@author Katia
@since 14/10/2014
/*/
//-------------------------------------------------------------------
Function TMA146VDoc(cServTms,cOrigem,lMark)
Local oModel     := FwModelActive()
Local oMdlGridDoc:= oModel:GetModel("MdGridDoc")
Local aSaveLine  := FWSaveRows()
Local oMdlGridVei:= Nil
Local oMdlGridDF8:= oModel:GetModel("MdGridDF8")
Local oMdlTotal  := oModel:GetModel("MdTotal")
Local lRet       := .T.
Local lEntrega   := .F.
Local lTransf    := .F.
Local nTotDocEnt := 0
Local nTotDocTra := 0
Local nTotDocCol := 0
Local nCntFor    := 0
Local cValidDoc  := 1   //Não
Local cLote      := ""
Local lDocRateio := .F.
Local lLotDif    := .F.
Local aRet       := {}

If cOrigem <> 'D'
	oMdlGridVei:= oModel:GetModel("MdGridVei")
EndIf	

Default cServTms := ""
Default cOrigem  := ""   //D-Documentos, V-Veiculo, P-Programacao
Default lMark    := .F.
FwClearHLP()
Pergunte('TMSA146C',.F.)
If !Empty(mv_par02)
	cValidDoc:= mv_par02  //Valida na selecao dos doctos ou no carregamento
EndIf
	
If cOrigem == 'D'
	
 	If oMdlGridDoc:GetValue('T01_BLQDOC') == '1'
		Return .F.
	EndIf

	If cValidDoc <>  1   //Selecao de Documentos
		Return lRet
	EndIf
	If cSerAdi == '0' //Servico Adicional
		If cServTms == '1'  //Coleta, verifica se existe outros servicos selecionados
			If oMdlGridDoc:SeekLine( { {"T01_MARK", .T.}, {"T01_SERTMS", '2' } } )
				lTransf:= .T. 
				lRet:= .F.
			ElseIf oMdlGridDoc:SeekLine( { {"T01_MARK", .T.}, {"T01_SERTMS", '3' } } )
				lEntrega:= .T. 
				lRet:= .F.
			EndIf
			If !lRet
				If lRot146Aut
					TM146MsgAd(STR0218,"TMA146VDoc" )
				Else	
					Help(' ', 1, 'TMSA14618',,Iif(lEntrega, STR0120, STR0119),3,1)   //Servico Adicional não está habilitado. Não é permitido selecionar Serviços de 
				EndIf	
			EndIf		
		Else
			If oMdlGridDoc:SeekLine( { {"T01_MARK", .T.}, {"T01_SERTMS", '1' } } )
				If lRot146Aut
					TM146MsgAd(STR0218,"TMA146VDoc" )
				Else	
					Help(' ', 1, 'TMSA14618',,Iif(cServTms == '3', STR0120, STR0119),3,1) //Servico Adicional não está habilitado. Não é permitido selecionar Serviços de
				EndIf	
				lRet:= .F.
			EndIf
		EndIf
	EndIf
	
	If lRet
		If cServTms == '1'
			//--- Se nao existir Documento de Entrega selecionado, nao permite selecionar Coleta com Transferencia
			If !(oMdlGridDoc:SeekLine( { {"T01_MARK", .T.}, {"T01_SERTMS", '3' } } )) .And. oMdlGridDoc:SeekLine( { {"T01_MARK", .T.}, {"T01_SERTMS", '2' } } )
				If lRot146Aut
					TM146MsgAd(STR0219,"TMA146VDoc" )
				Else
					Help(' ', 1, 'TMSA14619')  //Não é permitido selecionar documentos com Servicos de Transporte diferentes.
				EndIf	
				lRet:= .F.
			EndIf	
		ElseIf cServTms == '2'
			//--- Se nao existir Documento de Entrega selecionado, nao permite selecionar Coleta com Transferencia
			If !(oMdlGridDoc:SeekLine( { {"T01_MARK", .T.}, {"T01_SERTMS", '3' } } )) .And. oMdlGridDoc:SeekLine( { {"T01_MARK", .T.}, {"T01_SERTMS", '1' } } )
				If lRot146Aut
					TM146MsgAd(STR0219,"TMA146VDoc" )
				Else
					Help(' ', 1, 'TMSA14619') //Não é permitido selecionar documentos com Servicos de Transporte diferentes.
				EndIf	
				lRet:= .F.
			EndIf				
		EndIf
	EndIf

	//--- Integração TPR, valida se o Documento já está pendente para Roteirização
	If lRet .And. lIntTPR .And. !lMark
		If !IsBlind()
			aRet:= T146IdDMS(oMdlGridDoc)
			If Len(aRet) > 0 .And. !Empty(aRet[1])
				lRet:= TMSAC19Doc(aRet[1],aRet[2]) 
			EndIf
		EndIf
	EndIf

ElseIf  cOrigem == "DP"
	If oMdlGridDoc:SeekLine( { {"T01_MARK", .T.} })
		cLote  := oMdlGridDoc:GetValue("T01_LOTNFC")

		For nCntFor := 1 To oMdlGridDoc:Length()
			If !oMdlGridDoc:IsDeleted(nCntFor)
				oMdlGridDoc:GoLine(nCntFor)
				If oMdlTotal:GetValue('T03_QTDRAT') > 0 .Or.  oMdlGridDF8:GetValue('DF8_QTDRAT') > 0 
					
					If (oMdlGridDoc:GetValue('T01_NUMTMP') == oMdlGridDF8:GetValue('DF8_NUMTMP') .Or.  oMdlGridDoc:GetValue('T01_NUMPRG') == oMdlGridDF8:GetValue('DF8_NUMPRG')) .And.;
					    oMdlGridDoc:GetValue('T01_SEQPRG') == oMdlGridDF8:GetValue('DF8_SEQPRG') .And.;
					    oMdlGridDoc:GetValue('T01_CODVEI') == oMdlGridDF8:GetValue('DF8_CODVEI') .And.;
					    oMdlGridDoc:GetValue("T01_LOTNFC") != cLote
					
						If lRot146Aut
							TM146MsgAd(STR0203,"TMA146VDoc" )
						Else
							Help(" ",1,"TMSA14648",,STR0203,3,1)//'Programação com Lote de Rateio! Não é permitido carregar documentos de outro lote nesta Programação.'
						EndIf	
						lRet:= .F.
						Exit
					EndIf	
				EndIf
			EndIf
		Next nCntFor
	EndIf
Else
	
	nTotDocEnt:= oMdlTotal:GetValue('T03_QTDDTE') + oMdlTotal:GetValue('T03_QTDDCE') 
	nTotDocTra:= oMdlTotal:GetValue('T03_QTDDTT') + oMdlTotal:GetValue('T03_QTDDCT')
	nTotDocCol:= oMdlTotal:GetValue('T03_QTDDTC') + oMdlTotal:GetValue('T03_QTDDCC')
	
	If cSerAdi == '0' //Servico Adicional
		If nTotDocCol > 0  .And. (nTotDocEnt > 0 .Or. nTotDocTra > 0)
			If lRot146Aut
				TM146MsgAd(STR0220,"TMA146VDoc" )
			Else
				Help(' ', 1, 'TMSA14618',,Iif(nTotDocEnt > 0, STR0167, STR0165),3,1)  //Servico Adicional não está habilitado. Não é permitido selecionar Serviços de (Coleta e Entrega , Coleta e Transferencia) 
			EndIf	
			lRet:= .F.
		EndIf
	EndIf

	If lRet
		If nTotDocCol > 0  .And. nTotDocEnt > 0 .And. nTotDocTra > 0 .And. cSerAdi == '0'
			If lRot146Aut
				TM146MsgAd(STR0221,"TMA146VDoc" )
			Else
				Help(' ', 1, 'TMSA14619',,STR0166,3,1) //Não é permitido selecionar documentos com Servicos de Transporte diferentes. ( Coleta, Entrega e Transferencia )
			EndIf	
			lRet:= .F.
		EndIf
		If lRet
			If nTotDocCol > 0 .And. nTotDocEnt == 0 .And.  nTotDocTra > 0 
				If lRot146Aut
					TM146MsgAd(STR0175,"TMA146VDoc" )
				Else	
					Help(' ', 1, 'TMSA14619',,STR0165,3,1)  //Não é permitido selecionar documentos com Servicos de Transporte diferentes. (Coleta e Transferencia)
				EndIf	
				lRet:= .F.
			EndIf
		EndIf	
	EndIf	

	If lRet .And. cOrigem == 'P' 
		If nTotDocEnt > 0  
			If oMdlGridDF8:GetValue('DF8_SERTMS') <> '3'
				lRet:= .F.
			EndIf
		EndIf
		If nTotDocTra > 0
			If oMdlGridDF8:GetValue('DF8_SERTMS') <> '2'
				lRet:= .F.
			EndIf
		EndIf 	
		If cSerAdi == '0'
			If oMdlGridDF8:GetValue('DF8_SERTMS') <> '1'
				If nTotDocCol > 0
					lRet:= .F.
				EndIf
			EndIf
		EndIf
		If !lRet
			If lRot146Aut
				TM146MsgAd(STR0222,"TMA146VDoc" )
			Else
				Help(' ', 1, 'TMSA14620') //"Não é permitido carregar documentos", "com Servicos de Transporte diferentes."
			EndIf	
		EndIf
	EndIf	

	If lRet .And. cOrigem == 'V' 
		//-- Ao marcar um documento, verifica se existem Lote de rateio selecionado
		For  nCntFor := 1 To oMdlGridDoc:Length()
			oMdlGridDoc:GoLine(nCntFor)
			If !oMdlGridDoc:IsDeleted(nCntFor) .AND. oMdlGridDoc:GetValue("T01_MARK") 
				If !Empty(cLote) .AND. oMdlGridDoc:GetValue("T01_LOTNFC") != cLote
					lLotDif := .T.
				Else
					cLote := oMdlGridDoc:GetValue("T01_LOTNFC")
				EndIf

				If oMdlGridDoc:GetValue('T01_RATEIO') == '1'
					lDocRateio := .T.
				EndIf 
			EndIf
			If lDocRateio .AND. lLotDif 
				oModel:GetModel():SetErrorMessage(oModel:GetId(),"",,,,STR0204)//"Não é permitido carregar documentos de lotes diferentes quando for selecionado documento com Lote de Rateio."
				lRet:= .F.
				Exit
			EndIf
		Next nCntFor
			
	EndIf

EndIf

FwFreeArray(aRet)
FWRestRows( aSaveLine )
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA146Grv
Gravacao da Programacao de Carregamento  
@author Katia
@since 20/11/2014
/*/
//-------------------------------------------------------------------
Function TMSA146Grv(oModel,nRec,nOpcx,aCompVge)

Local nOpcViag	:= 0
Local oMdlGridDF8 := Nil
Local oMdlGridDA3 := Nil
Local oMdlGridDoc := Nil
Local oMdlGridDDZ := Nil
Local lHasDLS     := AliasInDic("DLS")
Local oMdlGridDLS := Nil
Local cRota       := ""

Local nCntFor	:= 0   
Local nOperation:= 0  

//-- Variaveis Utilizadas para Rotas de Entrega
Local nCntFor1  := 0
Local nCntFor2  := 0

Local cItem      := ""
Local cNumPrg    := ""
Local cMay       := ""
Local aAreaAtu   := GetArea()
Local aAreaSM0   := SM0->(GetArea())

Local lRet       := .F.
Local lAlteracao := .F.
Local cAliasDD9  := ""
Local cQuery     := ""
Local cFilOri    := ""
Local cSeqPrg    := ""
Local nQtdvol    := 0
Local nPeso      := 0
Local nPesoM3    := 0
Local nValor     := 0
Local nMetro3	   := 0
Local nCont      := 0
Local lGrava     := .F.
Local cTpSerTms  := ""
Local cUltSeqDF8 := ""
Local lTrans     := .T.
Local lDocCTE    := .F.
Local aVeiculos  := {}
Local cFilDF8    := ""        
Local cVeiculo   := ""
Local lProcessa  := .F.
Local cNumTmp    := ""
Local nYY        := 0
Local nPos1      := 0
Local aProcess   := {}
Local nPos       := 0

Local cAliasDL9	 := ""
Local cCodMot 	 := ""
Local cChvExt    := ""

Private aHeader   := {}
Private aCols     := {}
Private cStRota   := ""

Private aDocto    := {}
Private lColeta   := .F.
Private aCompViag := {}
Private aBkpDocto := {}
Private lLocaliz  := .F.
Private nCarreg   := 1 //-- Carregamento Manual
Private lTmsCFec  := TmsCFec()

//-- Variaveis dos itens do planejamento
Private aItensPC   := {}
Private aQtdVei    := {}
Private aQtdDoc    := {}
Private aValInf    := {}
Private aHeaderDVU := {}  // aHeader de Tipos de Veiculo da Nota Fiscal
Private aColsDVU   := {}  // aCols de Tipos de Veiculo da Nota Fiscal
Private lListVei   := .t.
Private cSerTms    := ""
Private cTipTra    := cTpTransp

Private aRotina   :=	{{ 'Pesquisar', "AxPesqui", 0, 1 },; //-- "Pesquisar"
						{ 'Visualizar', "AxVisual" , 0, 2 },; //-- "Visualizar"
				    	{ 'Incluir'   , "AxInclui" , 0, 3 },; //-- "Incluir"
				    	{ 'Alterar'   , "AxAltera" , 0, 4 },; //-- "Alterar"
						{ 'Excluir'   , "AxExclui" , 0, 5 } } //-- "Excluir"

Default nOpcx   := 4
Default aCompVge:= {}
Default nRec    := 0

SaveInter()

If nOpcx <> 6

	If lRot146Aut .AND. !Empty(cPlnDmd)	//SUAVIZAÇÃO DEMANDAS
		If DF8->(ColumnPos("DF8_DATINI")) > 0 
			cAliasDL9 := GetNextAlias()
			cQuery := " SELECT DL9_DATINI, DL9_HORINI, DL9_DATFIM, DL9_HORFIM, DL9_CODMOT
			cQuery +=   " FROM " + RetSqlName("DL9") + " DL9 "
			cQuery +=  " WHERE DL9.DL9_FILIAL = '" + FWxFilial("DL9") + "' "
			cQuery +=    " AND DL9.DL9_COD    = '" + cPlnDmd + "' "
			cQuery +=    " AND DL9.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDL9)
			TcSetField(cAliasQry,"DL9_DATINI","D",8,0) 
			TcSetField(cAliasQry,"DL9_DATFIM","D",8,0) 
			
			cCodMot := (cAliasDL9)->DL9_CODMOT
			If !Empty((cAliasDL9)->DL9_DATINI) .AND. !Empty((cAliasDL9)->DL9_DATFIM) .AND. !Empty((cAliasDL9)->DL9_HORINI) .AND. !Empty((cAliasDL9)->DL9_HORFIM)
				dDatIni := (cAliasDL9)->DL9_DATINI
				dDatFim := (cAliasDL9)->DL9_DATFIM
				cHorIni := (cAliasDL9)->DL9_HORINI
				cHorFim := (cAliasDL9)->DL9_HORFIM 
			EndIf
			(cAliasDL9)->(DbCloseArea())
		EndIf
	EndIf

   Begin Transaction

	oMdlGridDF8 := oModel:GetModel( "MdGridDF8" )
	oMdlGridDA3 := oModel:GetModel( "MdGridDA3" )
	oMdlGridDoc := oModel:GetModel( "MdGridDoc" )    
	oMdlGridDDZ := oModel:GetModel( "MdGridDDZ" )
	If lHasDLS
		oMdlGridDLS := oModel:GetModel( "MdGridDLS" )
		
		IF !Empty(cPlnDmd)
			oMdlGridDLS:SetValue("DLS_CODMOT", cCodMot)
		EndIf 
	EndIf
	nOperation  := oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_UPDATE
		If !IsInCallStack('TMSA146MNT') .And. !lIncAuto
			lAlteracao:= .T.
		EndIf
		
		aProcess := {}
		For nCont := 1 To oMdlGridDA3:Length()
			oMdlGridDA3:GoLine(nCont)   
			cVeiculo  := FwFldGet("DA3_COD")
			
			If !oMdlGridDF8:IsEmpty() 
				
				For nCntFor := 1 To oMdlGridDF8:Length()
					oMdlGridDF8:GoLine(nCntFor)
					aDocto  := {}
					aLinha   := Array(54)
					lGrava   := .F.
					
					lGravou   := .F.
					nQtdvol   := 0
					nPeso     := 0
			 		nPesoM3   := 0
					nValor    := 0
					nMetro3	  := 0
					aVeiculos := {}
					
					If !oMdlGridDF8:IsDeleted(nCntFor) //.And. !Empty(oMdlGridDF8:GetValue('DF8_CODVEI'))
						cFilOri:= FwFldGet('DF8_FILORI')
						cNumPrg:= FwFldGet('DF8_NUMPRG')
						cSeqPrg:= FwFldGet('DF8_SEQPRG')
						cSerTms:= FwFldGet('DF8_SERTMS')
						
						cRota  := FwFldGet('DF8_ROTA')
						//--- Rota por parametro
						If lIntTPR .And. Empty(cRota) .And. !Empty(cRota146)
							cRota  := cRota146
						EndIf
						
						cNumTmp:= FwFldGet('DF8_NUMTMP')  
						
						lComboio:= oMdlGridDDZ:Length() > 1   
						If !lComboio .And. Empty(FwFldGet('DF8_CODCAV'))   
							nPos:= aScan(aVeiculos, { |x| x[1] ==  cVeiculo })
							If nPos == 0
								aAdd(aVeiculos, {cVeiculo, {}})
					   		EndIf	 
						EndIf
						
						If lComboio .Or. !Empty(FwFldGet('DF8_CODCAV'))  //Busca o numero e sequencia da programação e Viagem 				
							For nCntFor1:= 1 To oMdlGridDDZ:Length() 
								oMdlGridDDZ:GoLine(nCntFor1)
								If !oMdlGridDDZ:IsDeleted()
									If Empty(FwFldGet('DDZ_CODCAV')	)			
										nPos:= aScan(aVeiculos, { |x| x[1] ==  FwFldGet('DDZ_CODVEI') })
										If nPos == 0	
											aAdd(aVeiculos, {FwFldGet('DDZ_CODVEI'),{}})
										EndIf	
									Else
										nPos:= aScan(aVeiculos, { |x| x[1] ==  FwFldGet('DDZ_CODCAV') }) 
										If nPos > 0 
											nPos1:= aScan(aVeiculos[nPos][2], { |x| x ==  FwFldGet('DDZ_CODVEI') })
											If nPos1 == 0
												aAdd(aVeiculos[nPos][2], FwFldGet('DDZ_CODVEI'))
											EndIf	
										Else
											aAdd(aVeiculos, {FwFldGet('DDZ_CODCAV'), {FwFldGet('DDZ_CODVEI')}} )
										EndIf	
									EndIf	 
								EndIf	
							Next nCntFor
							
							If lComboio		
								If ( nPos := Ascan( aRegDF8, { | e | e[1] == cNumTmp + cSeqPrg } ) ) >  0
									cNumPrg:= aRegDF8[nPos][2]
									cFilDF8:= aRegDF8[nPos][3]
								Else
									cFilDF8:= ""
									cNumPrg:= ""													
								EndIf                      
							EndIf		
						EndIf
										
						//--- verifica se tem programacao temporaria com mesmo numero e servico de transporte diferente
						cTpSerTms:= ""
						If cSerTms == '2'
							cTpSerTms:= '3'
						ElseIf cSerTms == '3'
							cTpSerTms:= '2'
						EndIf

						cUltSeqDF8:= ""
						//--- Se informou a viagem Coligada, procura se existe uma programacao para a viagem original e gera com a mesma numeracao
						If oMdlGridDF8:SeekLine({ { 'DF8_NUMTMP', FwFldGet('DF8_NUMTMP') }, {'DF8_SERTMS', cTpSerTms}, {'DF8_VGEINT', .T. } }  )
							If !oMdlGridDF8:IsDeleted() 
								If  !Empty(FwFldGet('DF8_NUMPRG'))
									cNumPrg   := FwFldGet('DF8_NUMPRG')
								EndIf    
								
							EndIf	
						EndIf	 
						
						oMdlGridDF8:GoLine(nCntFor)
						//---
						
						cItem:= Space(TamSX3("DD9_ITEM")[1])
						
						lProcessa:= .T.
						If lComboio .And. Len(aRegDF8) > 0 .And. !Empty(cNumPrg)
							lProcessa:= .F.
						EndIf
							
						If lProcessa

							If Empty(cNumPrg)  
								cNumPrg:= GetSX8Num('DF8','DF8_NUMPRG')
								cMay   := AllTrim(xFilial('DF8'))+cFilAnt+cNumPrg
								FreeUsedCode()
									
								DF8->( DbSetOrder( 1 ) )
								While DF8->(MsSeek(xFilial('DF8')+cFilAnt+cNumPrg)) .Or. !MayIUseCode(cMay)
									ConfirmSx8()
									cNumPrg := GetSX8Num('DF8','DF8_NUMPRG')
									FreeUsedCode()
									cMay := AllTrim(xFilial('DF8'))+cFilAnt+cNumPrg
								EndDo
									
								If __lSX8
									ConfirmSX8()
								EndIf
							EndIf
							DA3->(dbSetOrder(1))
							If DA3->( MsSeek( xFilial('DA3') + cVeiculo ) )
								If Posicione('DUT',1,xFilial('DUT')+DA3->DA3_TIPVEI,'DUT_CATVEI')  != StrZero(2, Len(DUT->DUT_CATVEI)) // Diferente de Cavalo
									For nCntFor1 := 1 To oMdlGridDoc:Length()
										oMdlGridDoc:GoLine(nCntFor1)
										If !oMdlGridDoc:IsDeleted(nCntFor1)

											If ( nPos := Ascan( aProcess, { | e | e[1]+e[2]+e[3]+e[4]+e[5]+e[6]+e[7]+e[8] ==  oMdlGridDoc:GetValue('T01_FILDOC')+;
																					oMdlGridDoc:GetValue('T01_DOC')+;
																					oMdlGridDoc:GetValue('T01_SERIE')+; 
																					oMdlGridDoc:GetValue('T01_NUMNFC')+;
																					oMdlGridDoc:GetValue('T01_SERNFC')+;
																					oMdlGridDoc:GetValue('T01_CODPRO')+;
																					oMdlGridDoc:GetValue('T01_CLIREM')+;
																					oMdlGridDoc:GetValue('T01_LOJREM') } ) ) <=  0
												If lAlteracao
													lRet:= oMdlGridDoc:GetValue('T01_NUMPRG') == cNumPrg .And. oMdlGridDoc:GetValue('T01_SEQPRG') == cSeqPrg 
												Else
													lRet:= oMdlGridDoc:GetValue('T01_NUMTMP') == oMdlGridDF8:GetValue('DF8_NUMTMP') .And. oMdlGridDoc:GetValue('T01_SEQPRG') == oMdlGridDF8:GetValue('DF8_SEQPRG') 
												EndIf
												
												If lRet								   		
													If lRet
														If lAlteracao
															DD9->( dbSeek( xFilial("DD9")+cFilOri+cNumPrg+cSeqPrg+'Z',.T. ) )
															DD9->( dbSkip(-1) )
															If DD9->( !Eof() ) .And. DD9->(DD9_FILIAL+DD9_FILORI+DD9_NUMPRG+DD9_SEQPRG) == xFilial("DD9")+cFilOri+cNumPrg+cSeqPrg
																cItem:= DD9->DD9_ITEM
															EndIf			   			
														EndIf
														
														cAliasDD9 := GetNextAlias()
														cQuery := "   SELECT R_E_C_N_O_ DD9_RECNO "
														cQuery += "     FROM " + RetSqlName("DD9") + " DD9 "
														cQuery += "    WHERE DD9.DD9_FILIAL  = '" + xFilial("DD9") + "' "
														cQuery += "      AND DD9.DD9_FILORI = '" + cFilOri + "' "
														cQuery += "      AND DD9.DD9_NUMPRG = '" + cNumPrg + "' "
														cQuery += "      AND DD9.DD9_SEQPRG = '" + cSeqPrg + "' "
														cQuery += "      AND DD9.DD9_FILDOC = '" + oMdlGridDoc:GetValue('T01_FILDOC') + "' "
														cQuery += "      AND DD9.DD9_DOC = '"    + oMdlGridDoc:GetValue('T01_DOC')    + "' "
														cQuery += "      AND DD9.DD9_SERIE = '"  + oMdlGridDoc:GetValue('T01_SERIE')  + "' "
														cQuery += "      AND DD9.DD9_NUMNFC = '" + oMdlGridDoc:GetValue('T01_NUMNFC') + "' "
														cQuery += "      AND DD9.DD9_SERNFC = '" + oMdlGridDoc:GetValue('T01_SERNFC') + "' "
														cQuery += "      AND DD9.DD9_CODPRO = '" + oMdlGridDoc:GetValue('T01_CODPRO') + "' "
														cQuery += "      AND DD9.DD9_CLIREM = '" + oMdlGridDoc:GetValue('T01_CLIREM') + "' "
														cQuery += "      AND DD9.DD9_LOJREM = '" + oMdlGridDoc:GetValue('T01_LOJREM') + "' "
														cQuery += "      AND DD9.D_E_L_E_T_ = ' ' "
														If !cDbType $ "MSSQL|MSSQL7|ORACLE"
															cQuery := ChangeQuery(cQuery)
														EndIf	
														dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDD9)
														If (cAliasDD9)->(!Eof())
															DD9->(MsGoto( (cAliasDD9)->DD9_RECNO ))
															If Empty(oMdlGridDoc:GetValue('T01_CODVEI'))   //Efetuou o descarregamento do documento
																If lRet
																	nQtdvol -= oMdlGridDoc:GetValue('T01_QTDVOL')
																	nPeso   -= oMdlGridDoc:GetValue('T01_PESO')
																	nPesoM3 -= oMdlGridDoc:GetValue('T01_PESOM3')
																	nValor  -= oMdlGridDoc:GetValue('T01_VALOR')
																	nMetro3	-= oMdlGridDoc:GetValue('T01_METRO3')
																	
																	RecLock("DD9",.F.)
																	DD9->(DbDelete())
																	DD9->(MsUnLock())

																	Aadd(aProcess,{ oMdlGridDoc:GetValue('T01_FILDOC'),;
																					oMdlGridDoc:GetValue('T01_DOC'),;
																					oMdlGridDoc:GetValue('T01_SERIE'),; 
																					oMdlGridDoc:GetValue('T01_NUMNFC'),;
																					oMdlGridDoc:GetValue('T01_SERNFC'),;
																					oMdlGridDoc:GetValue('T01_CODPRO'),;
																					oMdlGridDoc:GetValue('T01_CLIREM'),;
																					oMdlGridDoc:GetValue('T01_LOJREM')})

																EndIf	
															EndIf
														Else
															cItem:= Soma1(cItem)
															
															RecLock("DD9",.T.)
															DD9->DD9_FILIAL:= xFilial("DD9")
															DD9->DD9_FILORI:= Iif(lAlteracao,cFilOri,cFilAnt)
															DD9->DD9_NUMPRG:= cNumPrg 
															DD9->DD9_ITEM  := cItem
															DD9->DD9_CLIREM:= oMdlGridDoc:GetValue('T01_CLIREM')
															DD9->DD9_LOJREM:= oMdlGridDoc:GetValue('T01_LOJREM')
															DD9->DD9_NUMNFC:= oMdlGridDoc:GetValue('T01_NUMNFC')
															DD9->DD9_SERNFC:= oMdlGridDoc:GetValue('T01_SERNFC')
															DD9->DD9_CODPRO:= oMdlGridDoc:GetValue('T01_CODPRO')
															DD9->DD9_FILDOC:= oMdlGridDoc:GetValue('T01_FILDOC')
															DD9->DD9_DOC   := oMdlGridDoc:GetValue('T01_DOC')
															DD9->DD9_SERIE := oMdlGridDoc:GetValue('T01_SERIE')
															DD9->DD9_STROTA:= cStRota
															DD9->DD9_SEQPRG:= Iif(!Empty(cUltSeqDF8),cUltSeqDF8,oMdlGridDoc:GetValue('T01_SEQPRG'))
															DD9->DD9_CLIDES:= oMdlGridDoc:GetValue('T01_CLIDES')
															DD9->DD9_LOJDES:= oMdlGridDoc:GetValue('T01_LOJDES')
															DD9->DD9_SERTMS:= oMdlGridDoc:GetValue('T01_SERTMS')
															DD9->DD9_FILCFS:= oMdlGridDoc:GetValue('T01_FILCFS')
															DD9->DD9_NUMSOL:= oMdlGridDoc:GetValue('T01_NUMSOL')
															DD9->DD9_SEQUEN:= oMdlGridDoc:GetValue('T01_SEQENT')
															DD9->(MsUnLock())
															
															nQtdvol += oMdlGridDoc:GetValue('T01_QTDVOL')
															nPeso   += oMdlGridDoc:GetValue('T01_PESO')
															nPesoM3 += oMdlGridDoc:GetValue('T01_PESOM3')
															nValor  += oMdlGridDoc:GetValue('T01_VALOR')
															nMetro3	+= oMdlGridDoc:GetValue('T01_METRO3')

															Aadd(aProcess,{ oMdlGridDoc:GetValue('T01_FILDOC'),;
																				oMdlGridDoc:GetValue('T01_DOC'),;
																				oMdlGridDoc:GetValue('T01_SERIE'),; 
																				oMdlGridDoc:GetValue('T01_NUMNFC'),;
																				oMdlGridDoc:GetValue('T01_SERNFC'),;
																				oMdlGridDoc:GetValue('T01_CODPRO'),;
																				oMdlGridDoc:GetValue('T01_CLIREM'),;
																				oMdlGridDoc:GetValue('T01_LOJREM')})

															//--- Atualiza dados do TPR - DMS
															If lIntTPR .And. !Empty(cIdRotTPR)
																cChvExt:= xFilial("DF8")+DD9->(DD9_FILORI+DD9_NUMPRG+DD9_SEQPRG)
																T146PosDMS(oMdlGridDoc,cChvExt,cIdRotTPR)   
															EndIf

														EndIf
														(cAliasDD9)->(DbCloseArea())
													EndIf
													
													lGrava:= .T.
													//-- Tira o lock dos registros selecionados
													UnLockByName("PRGCARR"+FwFldGet("T01_FILDOC")+FwFldGet("T01_DOC")+FwFldGet("T01_SERIE"),.T.,.F.)

												EndIf
											EndIf
										EndIf
									Next nCntFor1
								EndIf
							EndIf

							If lGrava
								DF8->(dbSetOrder(1)) 
								If DF8->(dbSeek(xFilial("DF8")+oMdlGridDF8:GetValue('DF8_FILORI')+cNumPrg+oMdlGridDF8:GetValue('DF8_SEQPRG') ))
									RecLock("DF8",.F.)
									DF8->DF8_DATGER:= oMdlGridDF8:GetValue('DF8_DATGER')
									DF8->DF8_HORGER:= oMdlGridDF8:GetValue('DF8_HORGER')
									DF8->DF8_QTDVOL+= nQtdvol
									DF8->DF8_PESO  += nPeso
				 					DF8->DF8_PESOM3+= nPesoM3
									DF8->DF8_VALOR += nValor
									DF8->DF8_METRO3+= nMetro3
									If !Empty(cRota) .And. Empty(DF8->DF8_ROTA)
										DF8->DF8_ROTA:= cRota
										DF8->DF8_TIPTRA:= Posicione('DA8',1,xFilial('DA8')+ cRota,'DA8_TIPTRA')
									EndIf
									DF8->DF8_FILVGE:= oMdlGridDF8:GetValue('DF8_FILVGE')
									DF8->DF8_NUMVGE:= oMdlGridDF8:GetValue('DF8_NUMVGE')
									
									If DF8->(ColumnPos("DF8_DATINI")) > 0 
										DF8->DF8_DATINI := oMdlGridDF8:GetValue('DF8_DATINI')
										DF8->DF8_HORINI := oMdlGridDF8:GetValue('DF8_HORINI')
										DF8->DF8_DATFIM := oMdlGridDF8:GetValue('DF8_DATFIM')
										DF8->DF8_HORFIM := oMdlGridDF8:GetValue('DF8_HORFIM')
									EndIF
									
									DF8->(MsUnLock())
								Else
									RecLock( "DF8", .T. )
									DF8->DF8_FILIAL:= xFilial("DF8")
									DF8->DF8_FILORI:= cFilAnt
									DF8->DF8_NUMPRG:= cNumPrg
									DF8->DF8_SEQPRG:= Iif(!Empty(cUltSeqDF8),cUltSeqDF8,oMdlGridDF8:GetValue('DF8_SEQPRG')) 
									DF8->DF8_ROTA  := cRota
									DF8->DF8_SERTMS:= If( lHasViaM3 .AND. oMdlGridDF8:GetValue('DF8_SERTMS') == "1", "3", oMdlGridDF8:GetValue('DF8_SERTMS') )
									If Empty(cRota)
										DF8->DF8_TIPTRA:= oMdlGridDF8:GetValue('DF8_TIPTRA')
									Else
										DF8->DF8_TIPTRA:= Posicione('DA8',1,xFilial('DA8')+ cRota,'DA8_TIPTRA')
									EndIf	
									DF8->DF8_STATUS:= '1'   //Em Aberto
									DF8->DF8_DATGER:= oMdlGridDF8:GetValue('DF8_DATGER')
									DF8->DF8_HORGER:= oMdlGridDF8:GetValue('DF8_HORGER')
									DF8->DF8_QTDVOL:= nQtdvol
									DF8->DF8_PESO  := nPeso
				 					DF8->DF8_PESOM3:= nPesoM3
									DF8->DF8_VALOR := nValor
									DF8->DF8_METRO3:= nMetro3
									DF8->DF8_FILVGE:= oMdlGridDF8:GetValue('DF8_FILVGE')
									DF8->DF8_NUMVGE:= oMdlGridDF8:GetValue('DF8_NUMVGE')

									If lRot146Aut										
										if DF8->(ColumnPos("DF8_PLNDMD")) > 0 .And. !Empty(cPlnDmd)	//SUAVIZAÇÃO DEMANDAS
											DF8->DF8_PLNDMD := cPlnDmd
											DF8->DF8_SERTMS := StrZero(3,Len(DF8->DF8_SERTMS))
											DF8->DF8_TIPTRA := StrZero(1,Len(DF8->DF8_TIPTRA))
										EndIf
										If DF8->(ColumnPos("DF8_DATINI")) > 0 
											DF8->DF8_DATINI := dDatIni 
											DF8->DF8_HORINI := cHorIni
											DF8->DF8_DATFIM := dDatFim
											DF8->DF8_HORFIM := cHorFim
										EndIF										
									Else
										If DF8->(ColumnPos("DF8_DATINI")) > 0 
											DF8->DF8_DATINI := oMdlGridDF8:GetValue('DF8_DATINI')
											DF8->DF8_HORINI := oMdlGridDF8:GetValue('DF8_HORINI')
											DF8->DF8_DATFIM := oMdlGridDF8:GetValue('DF8_DATFIM')
											DF8->DF8_HORFIM := oMdlGridDF8:GetValue('DF8_HORFIM')
										EndIF
									EndIf
									DF8->(MsUnLock())
								EndIf

								oMdlGridDF8:GoLine(nCntFor)
								oMdlGridDF8:LoadValue('DF8_NUMPRG',cNumPrg)

							EndIf
							
							cFilDF8:= DF8->DF8_FILORI					
							//+------------------------------------------------------------------------------------
							//| Grava - Veiculos da Programacao
							//+------------------------------------------------------------------------------------
							For nCntFor1:= 1 To Len(aVeiculos)
								DDZ->(dbSetOrder(1)) 
								If !DDZ->(dbSeek(xFilial("DDZ")+cFilDF8+cNumPrg+cSeqPrg+aVeiculos[nCntFor1][1] )) 
									RecLock("DDZ",.T.)
									DDZ->DDZ_FILIAL:= xFilial("DDZ")
									DDZ->DDZ_FILORI:= cFilDF8
									DDZ->DDZ_CODVEI:= aVeiculos[nCntFor1][1]
									DDZ->DDZ_NUMPRG:= cNumPrg
					 				DDZ->DDZ_SEQPRG:= cSeqPrg
	                        	
									For nYY:= 1 To Len(aVeiculos[nCntFor1][2])
										If nYY == 1                                      
											DDZ->DDZ_CODRB1:= aVeiculos[nCntFor1][2][nYY]
										ElseIf nYY == 2
											DDZ->DDZ_CODRB2:= aVeiculos[nCntFor1][2][nYY]
										ElseIf nYY == 3
											DDZ->DDZ_CODRB3:= aVeiculos[nCntFor1][2][nYY]									
										EndIf													
									Next nYY
									DDZ->(MsUnLock())
								EndIf	
							
								//+------------------------------------------------------------------------------------
								//| Grava - Motoristas da Programacao
								//+------------------------------------------------------------------------------------
								If lHasDLS
									For nCntFor2 := 1 To oMdlGridDLS:Length()
										oMdlGridDLS:GoLine(nCntFor2)
										DLS->(DbSetorder(1)) //-> (1) DLS_FILIAL+DLS_FILORI+DLS_NUMPRG+DLS_ITEDF8+DLS_CODMOT
										If !oMdlGridDLS:IsDeleted()	.AND. !Empty(oMdlGridDLS:GetValue("DLS_CODMOT"))
											If DLS->(MsSeek(xFilial("DLS") + cFilDF8 + cNumPrg + cSeqPrg + oMdlGridDLS:GetValue("DLS_CODMOT")))											
												RecLock("DLS",.F.)
											Else	
												RecLock("DLS",.T.)
											EndIf
												
												DLS->DLS_FILIAL := xFilial("DLS")
												DLS->DLS_FILORI := cFilDF8
												DLS->DLS_NUMPRG := cNumPrg
												DLS->DLS_ITEDF8 := cSeqPrg
												DLS->DLS_CODVEI := aVeiculos[nCntFor1][1]
												DLS->DLS_CODMOT := oMdlGridDLS:GetValue("DLS_CODMOT") 
												DLS->DLS_TIPMOT := oMdlGridDLS:GetValue("DLS_TIPMOT")
												DLS->DLS_CONDUT := oMdlGridDLS:GetValue("DLS_CONDUT")
												DLS->DLS_FORADT := oMdlGridDLS:GetValue("DLS_FORADT")
												DLS->DLS_IDOPE  := oMdlGridDLS:GetValue("DLS_IDOPE" )
												DLS->DLS_FORPAG := oMdlGridDLS:GetValue("DLS_FORPAG")
												DLS->DLS_QTDTRA := oMdlGridDLS:GetValue("DLS_QTDTRA")
												DLS->DLS_TPSPDG := oMdlGridDLS:GetValue("DLS_TPSPDG")
												DLS->(MsUnLock())											
										Else																					
											If DLS->(DbSeek(xFilial("DLS") + cFilDF8 + cNumPrg + cSeqPrg + oMdlGridDLS:GetValue("DLS_CODMOT")))																					
												RecLock("DLS",.F.)
												DLS->(DbDelete())
												DLS->(MsUnLock())										
											EndIf										
										EndIf
									Next nCntFor2
								EndIf

							Next nCntFor1

						EndIf //| Fim do If lProcessa

						//--Verifica se existe o mesmo numero de programação temporaria para outros veiculos. (Viagem Comboio)
 						If ( nPos := Ascan( aRegDF8, { | e | e[1] == cNumTmp + cSeqPrg } ) ) ==  0
											Aadd( aRegDF8, { FwFldGet('DF8_NUMTMP') + cSeqPrg, cNumPrg, cFilAnt } )
						EndIf	

					Else   //Exclui a Programacao
						TMSA146Exc()
						If lMVITMSDMD .AND. DF8->(ColumnPos("DF8_PLNDMD")) > 0 .AND. FindFunction('TMSUpdDmd') .AND. !Empty(DF8->DF8_PLNDMD) //SUAVIZAÇÃO DEMANDAS
							If Empty(DF8->DF8_VIAGEM)
								TMSUpdDmd(DF8->DF8_PLNDMD, "2", 6)
							Else
								TMSUpdDmd(DF8->DF8_PLNDMD, "6", 8,DF8->DF8_VIAGEM)
								TMSUpdDmd(DF8->DF8_PLNDMD, "2", 6)
							EndIf
						EndIf
					EndIf
											
				Next nCntFor
			EndIf
		Next nCont
		
		//----- Cancela Roteirização, caso ocorra a Alteração de Programação com Roteirização com inclusao/exclusao de Doctos
		If lGrava .And. lAlteraTPR .And. FindFunction('T146CanRot')
			lRet:= T146CanRot(DF8->DF8_FILORI,DF8->DF8_NUMPRG,DF8->DF8_SEQPRG)
			If !lRet
				DisarmTransaction()
				Break
			EndIf
		EndIf
	
	ElseIf nOperation == MODEL_OPERATION_DELETE
		TMSA146Exc()
		If lMVITMSDMD .AND. DF8->(ColumnPos("DF8_PLNDMD")) > 0 .AND. FindFunction('TMSUpdDmd') .AND. !Empty(DF8->DF8_PLNDMD) //SUAVIZAÇÃO DEMANDAS
			If Empty(DF8->DF8_VIAGEM)
				TMSUpdDmd(DF8->DF8_PLNDMD, "2", 6)
			Else
				TMSUpdDmd(DF8->DF8_PLNDMD, "6", 8,DF8->DF8_VIAGEM)
				TMSUpdDmd(DF8->DF8_PLNDMD, "2", 6)
			EndIf
		EndIf
	EndIf

	End Transaction
Else   //Efetivar
  
	//aDocto  := {}
	//aLinha   := Array(54)
	//nOpcViag := 4   //Alteração
    //RegToMemory("DTQ",.F.)				
	//aCompViag:= aClone(aCompVge)	
	//TMSA146Com(aCompViag,.F.,,nOpcViag,,DF8->DF8_FILORI,DF8->DF8_DATGER,DF8->DF8_HORGER,;  
	//			DF8->DF8_ROTA,DF8->DF8_SERTMS,DF8->DF8_VIAGEM,DF8->DF8_FILVGE,DF8->DF8_NUMVGE)
						       
    lTrans:= .T.
	cAliasDD9 := GetNextAlias()
	cQuery := "   SELECT DD9_FILDOC, DD9_DOC, DD9_SERIE, DD9_SEQUEN, DT6_FILORI, DT6_LOTNFC, DT6_IDRCTE, DT6_CHVCTG "
	cQuery += "     FROM " + RetSqlName("DD9") + " DD9 "
	cQuery += "   LEFT JOIN " + RetSqlName("DT6") + " DT6 "
	cQuery += "      ON DT6.DT6_FILIAL  = '" + xFilial("DT6") + "' "
	cQuery += "      AND DT6.DT6_FILDOC = DD9.DD9_FILDOC  "
	cQuery += "      AND DT6.DT6_DOC = DD9.DD9_DOC  "
	cQuery += "      AND DT6.DT6_SERIE =  DD9.DD9_SERIE "
	cQuery += "      AND DT6.D_E_L_E_T_ = ' ' "
	cQuery += "    WHERE DD9.DD9_FILIAL  = '" + xFilial("DD9") + "' "
	cQuery += "      AND DD9.DD9_FILORI = '" + DF8->DF8_FILORI + "' "
	cQuery += "      AND DD9.DD9_NUMPRG = '" + DF8->DF8_NUMPRG + "' "
	cQuery += "      AND DD9.DD9_SEQPRG = '" + DF8->DF8_SEQPRG + "' "
	cQuery += "      AND DD9.D_E_L_E_T_ = ' ' "
	If lIntTPR
		cQuery += "ORDER BY DD9_SEQUEN, DD9_FILDOC, DD9_DOC, DD9_SERIE "
	EndIf
	If !cDbType $ "MSSQL|MSSQL7|ORACLE"
		cQuery := ChangeQuery(cQuery)
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDD9)
	While (cAliasDD9)->(!Eof())
									
		lRet:= TM146DocDUD((cAliasDD9)->DD9_FILDOC, (cAliasDD9)->DD9_DOC, (cAliasDD9)->DD9_SERIE, DF8->DF8_SERTMS, DF8->DF8_ROTA, nOpcViag,.F.,(cAliasDD9)->DD9_SEQUEN)
		
		If !Empty((cAliasDD9)->DT6_FILORI + (cAliasDD9)->DT6_LOTNFC) .And. (cAliasDD9)->DD9_SERIE <> "COL"  
			DTP->(dbSetOrder(2))
			If DTP->(MsSeek(xFilial("DTP") + (cAliasDD9)->DT6_FILORI + (cAliasDD9)->DT6_LOTNFC)) .And. (DTP->DTP_TIPLOT == StrZero(3,Len(DTP->DTP_TIPLOT)) .Or. DTP->DTP_TIPLOT == StrZero(4,Len(DTP->DTP_TIPLOT)))
				lDocCTE:= Alltrim((cAliasDD9)->DT6_IDRCTE) == "100" .Or. !Empty((cAliasDD9)->DT6_CHVCTG)  .Or. Alltrim((cAliasDD9)->DT6_IDRCTE) == "136" 
	    	    If !lDocCTE
					lTrans:= .F.
				EndIf
			EndIf
		EndIf		
		(cAliasDD9)->(dbSkip())
	EndDo
	(cAliasDD9)->(dbCloseArea())
	                
	If lRet	
		RecLock("DF8",.F.)
		DF8->DF8_STATUS:= Iif(lTrans,'2','3')   //Efetivada ou Doctos nao transmitidos
		DF8->(MsUnLock())

		//T146GrvVge(nOpcViag,DF8->DF8_ROTA,DF8->DF8_FILORI,DF8->DF8_VIAGEM,DF8->DF8_SERTMS,;
		//			DF8->DF8_DATGER,DF8->DF8_HORGER, ,.T., , DF8->DF8_TIPTRA)
					
	EndIf
		
EndIf

RestInter()
RestArea(aAreaAtu)
RestArea(aAreaSM0)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA146Exc
Exclusao  da Programacao de Carregamento  
@author Katia
@since 20/11/2014

/*/
//-------------------------------------------------------------------

Function TMSA146Exc()
Local aArea      := GetArea()
Local lHasDLS    := AliasInDic("DLS")
Local aCabecDT5  := {}
Local lDT5CodDmd := DT5->(ColumnPos("DT5_CODDMD")) > 0

	//| Exclui Documentos da Programação
	DD9->(dbSetOrder(1)) //-- DD9_FILIAL+DD9_FILORI+DD9_NUMPRG+DD9_ITEM
	DD9->(dbGoTop())

	dbSelectArea('DT5')
	DT5->(dbSetOrder(4))
	
	While DD9->(dbSeek(xFilial("DD9")+DF8->DF8_FILORI+DF8->DF8_NUMPRG+DF8->DF8_SEQPRG))

		//Se estiver integrado com a gestão de demandas, cancela somente as coletas geradas a partir da gestão de demandas
		If lMVITMSDMD .And. lDT5CodDmd 
			If DT5->(dbSeek(FwFilial('DT5') + DD9->(DD9_FILDOC + DD9_DOC + DD9_SERIE))) .And. !Empty(DT5->DT5_CODDMD)
				aCabecDT5 := {}
				AAdd(aCabecDT5, {"DT5_FILIAL", DT5->DT5_FILIAL, Nil})
				AAdd(aCabecDT5, {"DT5_FILORI", DT5->DT5_FILORI, Nil})
				AAdd(aCabecDT5, {"DT5_NUMSOL", DT5->DT5_NUMSOL, Nil})
				MSExecAuto({|x,y,k,w,z| TMSA460(x,y,k,w,z)},aCabecDT5,,,,5)
			EndIf
		EndIf

		RecLock("DD9",.F.)
		DD9->(DbDelete())
		DD9->(MsUnLock())
	EndDo
	//| Exclui Veiculos da Programação
	DDZ->(dbSetOrder(1)) 
	While DDZ->(dbSeek(xFilial("DDZ")+DF8->DF8_FILORI+DF8->DF8_NUMPRG+DF8->DF8_SEQPRG))
		RecLock("DDZ",.F.)
		DDZ->(DbDelete())
		DDZ->(MsUnLock())
	EndDo
	//| Exclui Motoristas da Programação
	If lHasDLS
		DLS->(dbSetOrder(1)) 
		While DLS->(dbSeek(xFilial("DLS")+DF8->DF8_FILORI+DF8->DF8_NUMPRG+DF8->DF8_SEQPRG))
			RecLock("DLS",.F.)
			DLS->(DbDelete())
			DLS->(MsUnLock())
		EndDo
	EndIf
	
	//Exclui registros da Integração TPR
	If lIntTPR .And. FindFunction('T146ExcTPR')
		 T146ExcTPR()
	EndIf

	//| Exclui cabecalho da Programação
	RecLock("DF8", .F.)
	DF8->(DbDelete())
	DF8->(MsUnLock())	


RestArea(aArea)
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMS146Comp       ³ Daniel Leme        º Data ³  10/02/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Complemento                                                 º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA146                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSA146Com(aCompViag,lMostra,lEdita,nOpcx,nTipoViag,cFilOri,dDatGer,cHorGer,cRota,cSerTms,cViagem,cFilVge,cNumVge,aVeiculos, aMotPrg)
Local lRet := .T.                                       
Local nX   := 0
Local aArea:= GetArea()

Default lMostra   := .T.
Default lEdita    := .T.
Default nOpcx     := 3
Default nTipoViag := 3     
Default aVeiculos := {}
Default aMotPrg   := {}
Default cFilVge   := ""
Default cNumVge   := ""
SaveInter()

If !Empty(cRota)  .Or. Empty(cRota)

	//-- Variavies utilizadas na viagem de transporte
	Private aHeader   := {}
	Private aCols     := {}
	Private aDocto    := {}
	Private lColeta   := .F.
	Private nTipVia   := nTipoViag
	Private aBkpDocto := {}
	Private lLocaliz  := .F.
	Private nCarreg   := 1 //-- Carregamento Manual

	//--- variaveis para a rotina tmsa240mot
	Private aMotViag  := {}
	Private aAjuViag  := {}
	Private asetkey   := {}
	Private n         := 1
	Private aHeaderDup:= {}
	Private aHeaderDuq:= {}
	
	Private aRotina   := {	{ STR0002 , "AxPesqui", 0, 1 },; //-- "Pesquisar"
					    		{ STR0003 , "AxVisual", 0, 2 },; //-- "Visualizar"
						    	{ STR0004 , "AxInclui", 0, 3 },; //-- "Incluir"
								{ STR0005 , "AxAltera", 0, 4 } } //-- "Alterar"
	
	M->DTQ_FILORI := cFilOri
	M->DTQ_DATGER := dDatGer
	M->DTQ_HORGER := cHorGer
	M->DTQ_ROTA   := cRota
	M->DTQ_SERTMS := cSerTms
	If !Empty(cRota)
		M->DTQ_TIPTRA := Posicione('DA8',1,xFilial('DA8')+cRota,'DA8_TIPTRA')
	EndIf	  
	M->DTQ_TIPVIA := StrZero( nTipVia, TamSX3("DTQ_TIPVIA")[1] )
	M->DTQ_GERSUG := '1' //-- Sim
	M->DTQ_OBS    := ''
	
	If nOpcx <> 3
		DTQ->(dbSetOrder(2))
		DTQ->(dbSeek(xFilial('DTQ')+cFilOri+cViagem))
	EndIf
	
	If Len(aCompViag) == 0 
		aHeadBkp:= aClone(aHeader)
		aColsBkp:= aClone(aCols)
		
		aCompViag := TmsA240Mnt(,,nOpcx,M->DTQ_FILORI, IIf(nOpcx<>3,cViagem,M->DTQ_VIAGEM),aCompViag,M->DTQ_ROTA,M->DTQ_SERTMS,M->DTQ_TIPTRA,@M->DTQ_OBS,,,lMostra,nTipVia,lEdita,,,,.T.,dDatGer,cHorGer,,cFilVge,cNumVge)
		
		If Len(aCompViag) > 0
			If Empty(aCompViag[3]) .And. nOpcx == 3		
				aHeader:= aClone(aCompViag[1])
				aCols  := aClone(aCompViag[2])
				//---- Motoristas da Viagem
				TMSA240Mot(nOpcx, , .F., , , , .T.,, aMotPrg)
				
				If Len(aHeaderDUP) > 0 
					aCompViag[3]:= aClone(aHeaderDUP)
					aCompViag[4]:= aClone(aMotViag)
				EndIf	
				
				//---- Ajudantes da Viagem
				TMSA240Ajud(nOpcx,,.F.,,.T.)
				
				If Len(aHeaderDUQ) > 0 
					aCompViag[5]:= aClone(aHeaderDUQ)
					aCompViag[6]:= aClone(aAjuViag)
				EndIf	
				
			EndIf
		EndIf
		aHeader:= aClone(aHeadBkp)
		aCols  := aClone(aColsBkp)
	EndIf	
	
	If Len(aCompViag) == 0
		lRet:= .F.   	
	Else
		If Len(aVeiculos) > 1   //Comboio                 
			For nX:= 1 To Len(aVeiculos)
				If nX > 1
					DA3->( dbSetOrder( 1 ) )
					If DA3->( dbSeek( xFilial('DA3') + aVeiculos[nX][1] ))
						aAdd(aCompViag[2],aClone(aCompViag[2][1]))
						aCompViag[2][nX][1]:= StrZero(nX,2)
						aAdd(aCompViag[4],aClone(aCompViag[4][1]))
						aCompViag[4][nX][1]:= StrZero(nX,2)
					EndIf		
				EndIf
			Next nX			
		EndIf			
	EndIf
EndIf
	
RestArea(aArea)
RestInter()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TM146LdDF8
Carrega dados da Tabela DF8
@author Katia
@since 11/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TM146LdDF8(oMdl,cFilOri,cNumPrg,cSeqPrg)
Local aAreaDF8	:= DF8->(GetArea())
Local aAreaDA3	:= DA3->(GetArea())
Local oStructDF8:= oMdl:GetStruct()
Local aCamposDF8:= aClone(oStructDF8:GetFields())
Local aLoadDF8	:= {}
Local nLinha	:= 0
Local nY		:= 0
Local cAliasQry := GetNextAlias()
Local cAliasQry1:= GetNextAlias()
Local cQuery    := ""
Local cQuery1   := ""
Local aDadosDF8 := {}
Local nSeek     := 0
Local cDocumento:= ""
Local nCapacM   := 0
Local nCapacRB1 := 0
Local nCapacRB2 := 0                      
Local cVeiculo  := ""
Local cFuncNull := ""
Local cCodCav   := ""
Local cDemanda := IIF(DF8->(ColumnPos("DF8_DATINI"))>0,", DF8_DATINI, DF8_HORINI, DF8_DATFIM, DF8_HORFIM","")
		
Private cVSerTms  := ""
		
Default cFilOri:= ""
Default cNumPrg:= ""
Default cSeqPrg:= ""

Do Case
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case cDbType $ "ORACLE/INFORMIX"  
  		cFuncNull	:= "NVL"
 	Otherwise
 		cFuncNull	:= "ISNULL"
EndCase                       

cQuery := " SELECT DDZ.DDZ_CODVEI, DA3.DA3_TIPVEI, " + cFuncNull + "(SUM(DA3.DA3_CAPACM),0) NCAPACM, " + cFuncNull + "(SUM(DA31.DA3_CAPACM),0) NCAPRB1 , " + cFuncNull + "(SUM(DA32.DA3_CAPACM),0) NCAPRB2 "
cQuery += " FROM " + RetSqlName("DDZ") + " DDZ "
cQuery += " JOIN " + RetSqlName("DA3") + " DA3 "
cQuery += " ON DA3.DA3_FILIAL = '" + xFilial("DA3") + "' "
cQuery += " AND DA3.DA3_COD = DDZ.DDZ_CODVEI  "
cQuery += " AND DA3.D_E_L_E_T_ = ' '"                  
cQuery += " LEFT JOIN " + RetSqlName("DA3") + " DA31 "
cQuery += " ON DA31.DA3_FILIAL = '" + xFilial("DA3") + "' "
cQuery += " AND DA31.DA3_COD = DDZ.DDZ_CODRB1 "
cQuery += " AND DA31.D_E_L_E_T_ = ' '" 
cQuery += " LEFT JOIN " + RetSqlName("DA3") + " DA32 "
cQuery += " ON DA32.DA3_FILIAL = '" + xFilial("DA3") + "' "
cQuery += " AND DA32.DA3_COD = DDZ.DDZ_CODRB2 "
cQuery += " AND DA32.D_E_L_E_T_ = ' '" 
cQuery += " WHERE DDZ.DDZ_FILIAL = '" + xFilial("DDZ") + "' "
cQuery += " AND DDZ.DDZ_FILORI = '" + cFilOri + "' " 
cQuery += " AND DDZ.DDZ_NUMPRG = '" + cNumPrg + "' " 
cQuery += " AND DDZ.DDZ_SEQPRG = '" + cSeqPrg + "' " 
cQuery += " AND DDZ.D_E_L_E_T_ = ' '"                  
cQuery += " GROUP BY DDZ.DDZ_CODVEI, DA3.DA3_TIPVEI "
If !cDbType $ "MSSQL|MSSQL7|ORACLE"
	cQuery := ChangeQuery(cQuery)
EndIf	
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
While (cAliasQry)->(!Eof())
	nCapacM  += (cAliasQry)->NCAPACM
	nCapacRB1+= (cAliasQry)->NCAPRB1
	nCapacRB2+= (cAliasQry)->NCAPRB2
 	
 	//--- Cavalo
 	If Posicione('DUT',1,xFilial('DUT')+ (cAliasQry)->DA3_TIPVEI ,'DUT_CATVEI') == StrZero(2, Len(DUT->DUT_CATVEI))
 		cCodCav:= (cAliasQry)->DDZ_CODVEI
	EndIf
			
	If Empty(cVeiculo)
		cVeiculo := (cAliasQry)->DDZ_CODVEI
	EndIf
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())

cAliasQry := GetNextAlias()
cQuery := " SELECT DISTINCT DF8_FILORI, DF8_NUMPRG, DF8_SEQPRG, DF8_ROTA, DF8_TIPTRA, DF8_SERTMS, DF8_DATGER, DF8_HORGER, DF8_VIAGEM, DF8_FILVGE, DF8_NUMVGE "+cDemanda+" FROM "
cQuery +=  RetSqlName("DF8") + " DF8 "
cQuery += " JOIN " + RetSqlName("DDZ") + " DDZ "
cQuery += " ON DDZ.DDZ_FILIAL = '" + xFilial("DDZ") + "' "
cQuery += " AND DDZ.DDZ_FILORI = DF8.DF8_FILORI " 
cQuery += " AND DDZ.DDZ_NUMPRG = DF8.DF8_NUMPRG " 
cQuery += " AND DDZ.DDZ_SEQPRG = DF8.DF8_SEQPRG " 
cQuery += " AND DDZ.D_E_L_E_T_ = ' '"                  
cQuery += " WHERE DF8.DF8_FILIAL = '" + xFilial("DF8") + "' "
cQuery += " AND DF8.DF8_FILORI = '" + cFilOri + "' AND DF8.DF8_NUMPRG = '" + cNumPrg + "' AND DF8.DF8_SEQPRG = '" + cSeqPrg + "' "
cQuery += " AND DF8.D_E_L_E_T_ = ' ' " 
If !cDbType $ "MSSQL|MSSQL7|ORACLE"
	cQuery := ChangeQuery(cQuery)
EndIf	
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
TCSetField(cAliasQry,"DF8_DATGER","D",8,0)
IF DF8->(ColumnPos("DF8_DATINI"))>0
	TCSetField(cAliasQry,"DF8_DATINI","D",8,0)
	TCSetField(cAliasQry,"DF8_DATFIM","D",8,0)
EndIf

While (cAliasQry)->(!Eof())
	aAdd(aDadosDF8,{StrZero(1, Len(DTC->DTC_SERTMS)) ,0,0,0,0,0,0,0,0})  //Coleta
	aAdd(aDadosDF8,{StrZero(2, Len(DTC->DTC_SERTMS)) ,0,0,0,0,0,0,0,0})  //Transferencia
	aAdd(aDadosDF8,{StrZero(3, Len(DTC->DTC_SERTMS)) ,0,0,0,0,0,0,0,0})  //Entrega
	cDocumento:= ""
		
	cQuery1 := " SELECT DD9_FILORI, DD9_NUMPRG, DD9_SEQPRG, DD9_SERTMS, DD9_FILDOC, DD9_CLIREM, DD9_LOJREM, DD9_DOC, DD9_SERIE, DD9_NUMNFC, DD9_SERNFC, DD9_SEQUEN, DTP_RATEIO, DTP_CRIRAT, "
	cQuery1 += " SUM(DT6_QTDVOL) DT6QTDVOL, SUM(DT6_VALFRE) DT6VALFRE, SUM(DT6_VALMER) DT6VALMER, SUM(DT6_PESO) DT6PESO, "
	cQuery1 += " SUM(DT6_PESOM3) DT6PESOM3, SUM(DT6_METRO3) DT6METRO3, SUM(DTC_QTDVOL) DTCQTDVOL, SUM(DTC_VALOR) DTCVALOR, SUM(DTC_PESO) DTCPESO, SUM(DTC_PESOM3) DTCPESOM3, SUM(DTC_METRO3) DTCMETRO3 FROM "
	cQuery1 +=  RetSqlName("DD9")  + " DD9 "
	cQuery1 += " LEFT JOIN " + RetSqlName("DT6") + " DT6 "
	cQuery1 += " ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
	cQuery1 += " AND DT6.DT6_FILDOC = DD9.DD9_FILDOC "
	cQuery1 += " AND DT6.DT6_DOC = DD9.DD9_DOC "
	cQuery1 += " AND DT6.DT6_SERIE = DD9.DD9_SERIE "
	cQuery1 += " AND DT6.D_E_L_E_T_='' "
	cQuery1 += " LEFT JOIN " + RetSqlName("DTC") + " DTC "
	cQuery1 += " ON DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
	cQuery1 += " AND DTC.DTC_NUMNFC = DD9.DD9_NUMNFC "
	cQuery1 += " AND DTC.DTC_SERNFC = DD9.DD9_SERNFC "
	cQuery1 += " AND DTC.DTC_CLIREM = DD9.DD9_CLIREM "
	cQuery1 += " AND DTC.DTC_LOJREM = DD9.DD9_LOJREM "
	cQuery1 += " AND DTC.DTC_DOC = ' '  "
	cQuery1 += " AND DTC.D_E_L_E_T_= ' ' "
	cQuery1 += " LEFT JOIN " + RetSqlName("DTP") + " DTP "
	cQuery1 += " ON DTP.DTP_FILIAL = '" + xFilial("DTP") + "' "
	cQuery1 += " AND DTP.DTP_FILORI = DTC.DTC_FILORI "
	cQuery1 += " AND DTP.DTP_LOTNFC = DTC.DTC_LOTNFC "
	cQuery1 += " AND DTP.D_E_L_E_T_= ' ' "
	cQuery1 += " WHERE DD9_FILIAL = '" + xFilial("DD9") + "' "
	cQuery1 += " AND DD9.DD9_FILORI = '" + (cAliasQry)->DF8_FILORI + "' "
	cQuery1 += " AND DD9.DD9_NUMPRG = '" + (cAliasQry)->DF8_NUMPRG + "' "
	cQuery1 += " AND DD9.DD9_SEQPRG = '" + (cAliasQry)->DF8_SEQPRG + "' "
	//cQuery1 += " AND DD9.DD9_CODVEI = '" + (cAliasQry)->DF8_CODVEI + "' "
	cQuery1 += " AND DD9.D_E_L_E_T_ = '' "
	cQuery1 += " GROUP BY  DD9_FILORI, DD9_NUMPRG, DD9_SEQPRG, DD9_SERTMS, DD9_FILDOC, DD9_CLIREM, DD9_LOJREM, DD9_DOC, DD9_SERIE, DD9_NUMNFC,"
	cQuery1 += " DD9_SERNFC, DD9_SEQUEN, DTP_RATEIO, DTP_CRIRAT "
	If !cDbType $ "MSSQL|MSSQL7|ORACLE"
		cQuery1 := ChangeQuery(cQuery1)
	EndIf	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery1),cAliasQry1,.T.,.T.)
	While (cAliasQry1)->(!Eof())
		nSeek := Ascan( aDadosDF8,{|x| x[1] == (cAliasQry1)->DD9_SERTMS })
		If nSeek > 0
			aDadosDF8[nSeek][NPOSQTDVOL] += ((cAliasQry1)->DT6QTDVOL + (cAliasQry1)->DTCQTDVOL)
			aDadosDF8[nSeek][NPOSVALFRE] += (cAliasQry1)->DT6VALFRE
			aDadosDF8[nSeek][NPOSVALOR]  += ((cAliasQry1)->DT6VALMER + (cAliasQry1)->DTCVALOR)
			aDadosDF8[nSeek][NPOSPESO]   += ((cAliasQry1)->DT6PESO  + (cAliasQry1)->DTCPESO)
			aDadosDF8[nSeek][NPOSPESOM3] += ((cAliasQry1)->DT6PESOM3 + (cAliasQry1)->DTCPESOM3)
			aDadosDF8[nSeek][NPOSMETRO3] += ((cAliasQry1)->DT6METRO3 + (cAliasQry1)->DTCMETRO3)
			If ((cAliasQry1)->DD9_FILDOC+(cAliasQry1)->DD9_DOC+(cAliasQry1)->DD9_SERIE) <> cDocumento
				aDadosDF8[nSeek][NPOSDOCTOS] += 1
				If (cAliasQry1)->DTP_RATEIO == '1' .And. (cAliasQry1)->DTP_CRIRAT == 'A'
					aDadosDF8[nSeek][NPOSQTDRAT] += 1
				EndIf	
			EndIf
		EndIf
			
		cDocumento:= (cAliasQry1)->DD9_FILDOC + (cAliasQry1)->DD9_DOC + (cAliasQry1)->DD9_SERIE
			                	
		(cAliasQry1)->(dbSkip())
	EndDo
	(cAliasQry1)->(DbCloseArea())
		
	nLinha++
	aAdd(aLoadDF8,{nLinha,Array(Len(aCamposDF8))})
	
	For nY := 1 To Len(aCamposDF8)
		If !aCamposDF8[nY][MODEL_FIELD_VIRTUAL]
			If (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_QTDVOL"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[1][NPOSQTDVOL] + aDadosDF8[2][NPOSQTDVOL] + aDadosDF8[3][NPOSQTDVOL]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_PESO"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[1][NPOSPESO] + aDadosDF8[2][NPOSPESO] + aDadosDF8[3][NPOSPESO]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_PESOM3"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[1][NPOSPESOM3] + aDadosDF8[2][NPOSPESOM3] + aDadosDF8[3][NPOSPESOM3]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_METRO3"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[1][NPOSMETRO3] + aDadosDF8[2][NPOSMETRO3] + aDadosDF8[3][NPOSMETRO3]				
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_VALOR"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[1][NPOSVALOR] + aDadosDF8[2][NPOSVALOR] + aDadosDF8[3][NPOSVALOR]
			Else				
				aLoadDF8[nLinha][2][nY]	:= (cAliasQry)->&(aCamposDF8[nY][MODEL_FIELD_IDFIELD])
			EndIf				
		Else
			If (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_BTCAR"))
				aLoadDF8[nLinha][2][nY]	:= 'CARGANEW'  
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_BTDES"))
				aLoadDF8[nLinha][2][nY]	:= 'CARGA'  
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_BTVIS"))
				aLoadDF8[nLinha][2][nY]	:= 'PESQUISA' 
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_STAPRG"))
				aLoadDF8[nLinha][2][nY]	:= TM146Cor('P',,,,,DF8->DF8_STATUS)
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_STAVEI"))	
				If nCapacM == (aDadosDF8[1][NPOSPESO] + aDadosDF8[2][NPOSPESO] + aDadosDF8[3][NPOSPESO])  //Peso Total
					aLoadDF8[nLinha][2][nY]	:= "BR_AMARELO"
				ElseIf nCapacM < (aDadosDF8[1][NPOSPESO] + aDadosDF8[2][NPOSPESO] + aDadosDF8[3][NPOSPESO])  //Peso Total
					aLoadDF8[nLinha][2][nY]	:= "BR_VERMELHO"
				Else
					aLoadDF8[nLinha][2][nY]	:= "BR_VERDE" 
				EndIf
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_QTDDOC"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[1][NPOSDOCTOS] + aDadosDF8[2][NPOSDOCTOS] + aDadosDF8[3][NPOSDOCTOS]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_QTDCOL"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[1][NPOSDOCTOS]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_VOLCOL"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[1][NPOSQTDVOL] 
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_PESCOL"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[1][NPOSPESO]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_PM3COL"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[1][NPOSPESOM3] 
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_VLMCOL"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[1][NPOSVALOR] 
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_VLFCOL"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[1][NPOSVALFRE] 
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_QTDENT"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[3][NPOSDOCTOS]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_VOLENT"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[3][NPOSQTDVOL]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_PESENT"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[3][NPOSPESO] 
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_PM3ENT"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[3][NPOSPESOM3]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_VLMENT"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[3][NPOSVALOR]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_VLFENT"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[3][NPOSVALFRE]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_QTDTRA"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[2][NPOSDOCTOS]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_VOLTRA"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[2][NPOSQTDVOL]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_PESTRA"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[2][NPOSPESO]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_PM3TRA"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[2][NPOSPESOM3]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_VLMTRA"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[2][NPOSVALOR]
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_VLFTRA"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[2][NPOSVALFRE]	
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_QTDRAT"))
				aLoadDF8[nLinha][2][nY]	:= aDadosDF8[2][NPOSQTDRAT]	
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_CAPACM"))
				aLoadDF8[nLinha][2][nY]	:= nCapacM //DA3->DA3_CAPACM
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_CAPACD"))
				aLoadDF8[nLinha][2][nY]	:= Round(nCapacM	- (aDadosDF8[1][NPOSPESO] + aDadosDF8[2][NPOSPESO] + aDadosDF8[3][NPOSPESO]), 2)
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_CODCAV"))  
				aLoadDF8[nLinha][2][nY]	:= cCodCav
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_CODVEI"))  
					aLoadDF8[nLinha][2][nY]	:= cVeiculo
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_MODCAV")) 
				aLoadDF8[nLinha][2][nY]	:= Iif(Empty(cCodCav),"",Posicione('DA3',1,xFilial('DA3')+cCodCav,'DA3_DESC'))	
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_VGEINT")) 
				aLoadDF8[nLinha][2][nY]	:= .F.
			ElseIf (aCamposDF8[nY][MODEL_FIELD_IDFIELD] $ ("DF8_DESSVT"))
				cVSerTms:= (cAliasQry)->DF8_SERTMS
				aLoadDF8[nLinha][2][nY]	:= TMSValField('cVSerTms',.F.) 
			Else
				aLoadDF8[nLinha][2][nY]	:= ""
			EndIf		
	 	EndIf
	Next nY
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())

aCamposDF8 := aSize(aCamposDF8,0)
RestArea(aAreaDF8)
RestArea(aAreaDA3)
Return( aLoadDF8 )

//-------------------------------------------------------------------
/*/{Protheus.doc} T146QryVis
Monta Query da Visualizacao da Programacao
@author Katia
@since 21/10/2014
/*/
//-------------------------------------------------------------------
Function T146QryVis(lAgdEntr)

Local cQuery    := ""
Local aRetPrd   := RetSx3Box( Posicione('SX3', 2, 'DYD_PRDAGD', 'X3CBox()' ),,, Len(DYD->DYD_PRDAGD))
Local aRetTipo  := RetSx3Box( Posicione('SX3', 2, 'DYD_TIPAGD', 'X3CBox()' ),,, Len(DYD->DYD_TIPAGD))

Default lAgdEntr:= .T.            

	
	cQuery := " SELECT DISTINCT DTC.DTC_FILIAL T01_FILIAL, DTC.DTC_FILDOC T01_FILDOC, DTC.DTC_DOC    T01_DOC   , DTC.DTC_SERIE  T01_SERIE , DTC.DTC_NUMNFC T01_NUMNFC, DTC.DTC_SERNFC T01_SERNFC, "
	cQuery += "        DTC.DTC_EMINFC T01_EMINFC, DTC.DTC_FILCFS T01_FILCFS, DTC.DTC_NUMSOL T01_NUMSOL, DTC.DTC_CLIREM T01_CLIREM, DTC.DTC_LOJREM T01_LOJREM, REM.A1_NREDUZ  T01_NOMREM, " 
	cQuery += "        DTC.DTC_CLIDES T01_CLIDES, DTC.DTC_LOJDES T01_LOJDES, DES.A1_NREDUZ  T01_NOMDES, DTC_SQEDES     T01_SQEDES,  " 
	cQuery += "        CASE WHEN DTC_SQEDES = ' ' THEN DES.A1_END     WHEN DUL_CODRED = ' ' THEN DUL_END    ELSE RED.A1_END    END AS T01_END, "         
	cQuery += "        CASE WHEN DTC_SQEDES = ' ' THEN DES.A1_EST     WHEN DUL_CODRED = ' ' THEN DUL_EST    ELSE RED.A1_EST    END AS T01_EST, " 
	cQuery += "        CASE WHEN DTC_SQEDES = ' ' THEN DES.A1_MUN     WHEN DUL_CODRED = ' ' THEN DUL_MUN    ELSE RED.A1_MUN    END AS T01_MUN, " 
	cQuery += "        CASE WHEN DTC_SQEDES = ' ' THEN DES.A1_BAIRRO  WHEN DUL_CODRED = ' ' THEN DUL_BAIRRO ELSE RED.A1_BAIRRO END AS T01_BAIRRO, "
	cQuery += "        CASE WHEN DTC_SQEDES = ' ' THEN DES.A1_CEP     WHEN DUL_CODRED = ' ' THEN DUL_CEP    ELSE RED.A1_CEP    END AS T01_CEP,"
	cQuery += "       DES.A1_CGC     T01_CGC, "
	cQuery += "        DTC.DTC_QTDVOL T01_QTDVOL, DTC.DTC_PESO   T01_PESO  , DTC.DTC_PESOM3 T01_PESOM3, DTC.DTC_METRO3 T01_METRO3, "
	cQuery += "        DTC.DTC_VALOR  T01_VALOR , 0              T01_VALFRE, DTC.DTC_CDRORI T01_CDRORI, DTC.DTC_CDRDES T01_CDRDES,  "
	cQuery += "        DTC.DTC_CDRCAL T01_CDRCAL, DTC.DTC_PRVENT T01_PRVENT,  "
	cQuery += "        DTC.DTC_CODPRO T01_CODPRO, DTC.DTC_CODEMB T01_CODEMB, DTC.DTC_CLIDEV T01_CLIDEV, DTC.DTC_LOJDEV T01_LOJDEV, DEV.A1_NREDUZ  T01_NOMDEV, "
	cQuery += "        DTC.DTC_LOTNFC T01_LOTNFC, DTP.DTP_RATEIO T01_RATEIO, DTP.DTP_CRIRAT T01_CRIRAT, DTC.DTC_TIPFRE T01_TIPFRE, DTC.DTC_SERTMS T01_SERTMS, DTC.DTC_TIPTRA T01_TIPTRA, "
	cQuery += "        DTC.DTC_SERVIC T01_SERVIC, DTC.DTC_FILORI T01_FILORI, ''             T01_CHVCTE, DTC.DTC_NFEID T01_NFEID, ''  T01_BLQDOC, '' T01_FILDES, "
	cQuery += "        DD9_NUMPRG T01_NUMPRG, DD9_SEQPRG T01_SEQPRG, DDZ.DDZ_CODVEI  T01_CODVEI, DD9_SEQUEN T01_SEQENT, ' ' T01_STATUS, X5_DESCRI T01_DESSER, 'N' T01_RECREM,  'N' T01_RECDES, " 
	cQuery += "        ' '            T01_CDROTA, ' ' T01_NUMTMP, '.F.' T01_MARK, 'PMSEDT3' T01_LEGPAG, " 
		
	If lAgdEntr 
		If Len(aRetPrd)> 0 //.And. cSerTMS == "3"
			cQuery += "     DYD.DYD_NUMAGD T01_NUMAGD, DYD.DYD_DATAGD T01_DATAGD, DYD.DYD_PRDAGD T01_PRDAGD, DYD.DYD_INIAGD T01_INIAGD, "
			cQuery += "     DYD.DYD_FIMAGD T01_FIMAGD, DYD.DYD_TIPAGD T01_TIPAGD, "
			cQuery += "     CASE WHEN DYD.DYD_PRDAGD = '1'  THEN  '" + aRetPrd[1][3] + "' "
			cQuery += "          WHEN DYD.DYD_PRDAGD = '2'  THEN  '" + aRetPrd[2][3] + "' " 
			cQuery += "          WHEN DYD.DYD_PRDAGD = '3'  THEN  '" + aRetPrd[3][3] + "' "   
			cQuery += "          WHEN DYD.DYD_PRDAGD = '4'  THEN  '" + aRetPrd[4][3] + "' "
			cQuery += "          ELSE ' ' END AS T01_DETPAG, "
		EndIf
			
		If Len(aRetTipo)> 0 	
			cQuery += "     CASE WHEN DYD.DYD_TIPAGD = '0'  THEN  '" + aRetTipo[1][3] + "' "
			cQuery += "          WHEN DYD.DYD_TIPAGD = '1'  THEN  '" + aRetTipo[2][3] + "' " 
			cQuery += "          WHEN DYD.DYD_TIPAGD = '2'  THEN  '" + aRetTipo[3][3] + "' "   
			cQuery += "          WHEN DYD.DYD_TIPAGD = '3'  THEN  '" + aRetTipo[4][3] + "' "
			cQuery += "          WHEN DYD.DYD_TIPAGD = '4'  THEN  '" + aRetTipo[5][3] + "' "
			cQuery += "          ELSE ' ' END AS T01_DEPRAG "
		EndIf	
	Else
		cQuery += "     ''             T01_NUMAGD, ''             T01_DATAGD, ''             T01_PRDAGD, ''             T01_INIAGD, "
		cQuery += "     ''             T01_FIMAGD, ''             T01_TIPAGD, '' T01_DETPAG, ' ' T01_DEPRAG "
	EndIf
		
	cQuery += " FROM  "
	cQuery += RetSqlName("DD9") + " DD9 "
		
	cQuery+= "  JOIN " + RetSqlname('DTC') + " DTC " 
	cQuery+= "   ON DTC_FILIAL = '" + xFilial('DTC') + "' "
	cQuery += "  AND DTC.DTC_CLIREM = DD9.DD9_CLIREM "
	cQuery += "  AND DTC.DTC_LOJREM = DD9.DD9_LOJREM "
	cQuery += "  AND DTC.DTC_NUMNFC = DD9.DD9_NUMNFC "
	cQuery += "  AND DTC.DTC_SERNFC = DD9.DD9_SERNFC "
	cQuery += "  AND DTC.DTC_FILDOC = DD9.DD9_FILDOC "
	cQuery += "  AND DTC.DTC_DOC    = DD9.DD9_DOC "
	cQuery += "  AND DTC.DTC_SERIE = DD9.DD9_SERIE "
	cQuery += "  AND DTC.DTC_DOC = ' ' "
	cQuery += "  AND DTC.D_E_L_E_T_ = ' '  "
	
	cQuery+= "  JOIN " + RetSqlname('DF8') + " DF8 " 
	cQuery+= "   ON DF8_FILIAL = '" + xFilial('DF8') + "' "
	cQuery += "  AND DF8.DF8_FILORI = DD9.DD9_FILORI "
	cQuery += "  AND DF8.DF8_NUMPRG = DD9.DD9_NUMPRG  "
	cQuery += "  AND DF8.DF8_SEQPRG = DD9.DD9_SEQPRG  "
	cQuery += "  AND DF8.D_E_L_E_T_ = ' '  "
	
	cQuery+= "  LEFT JOIN " + RetSqlname('DDZ') + " DDZ " 
	cQuery+= "   ON DDZ_FILIAL = '" + xFilial('DDZ') + "' "
	cQuery += "  AND DDZ.DDZ_FILORI = DD9.DD9_FILORI "
	cQuery += "  AND DDZ.DDZ_NUMPRG = DD9.DD9_NUMPRG  "
	cQuery += "  AND DDZ.DDZ_SEQPRG = DD9.DD9_SEQPRG  "
	cQuery += "  AND DDZ.D_E_L_E_T_ = ' '  "
	cQuery += " JOIN  " 
	cQuery += RetSqlName("SA1") + " REM" 
	cQuery += "    ON  REM.A1_FILIAL   = '"+xFilial('SA1')+"'"
	cQuery += "   AND  REM.A1_COD      = DTC_CLIREM"
	cQuery += "   AND  REM.A1_LOJA     = DTC_LOJREM"
	cQuery += "   AND  REM.D_E_L_E_T_  = ' '"
	cQuery += " JOIN  " 
	cQuery += RetSqlName("SA1") + " DES" 
	cQuery += "    ON  DES.A1_FILIAL   = '"+xFilial('SA1')+"'"
	cQuery += "   AND  DES.A1_COD      = DTC_CLIDES"
	cQuery += "   AND  DES.A1_LOJA     = DTC_LOJDES"
	cQuery += "   AND  DES.D_E_L_E_T_  = ' '"
	cQuery += " JOIN " 
	cQuery += RetSqlName("SA1") + " DEV" 
	cQuery += "    ON  DEV.A1_FILIAL   = '"+xFilial('SA1')+"'"
	cQuery += "   AND  DEV.A1_COD      = DTC_CLIDEV"
	cQuery += "   AND  DEV.A1_LOJA     = DTC_LOJDEV"
	cQuery += "   AND  DEV.D_E_L_E_T_  = ' '"
	cQuery += " JOIN " 
	cQuery += RetSqlName("SA1") + " CAL" 
	cQuery += "    ON  CAL.A1_FILIAL   = '"+xFilial('SA1')+"'"
	cQuery += "   AND  CAL.A1_COD      = DTC_CLICAL"
	cQuery += "   AND  CAL.A1_LOJA     = DTC_LOJCAL"
	cQuery += "   AND  CAL.D_E_L_E_T_  = ' '"
	
	If lAgdEntr //.And. cSerTMS == "3"
		cQuery += " LEFT JOIN  "
		cQuery += RetSqlName("DYD") + " DYD"
		cQuery += "    ON  DYD.DYD_FILIAL  =  '"+xFilial('DYD')+"'"
		cQuery += "   AND  DYD.DYD_NUMAGD  =  DTC.DTC_NUMAGD"
		cQuery += "   AND  DYD.D_E_L_E_T_  =  ' '"
	EndIf

	cQuery += "   LEFT JOIN " + RetSqlName("SX5") + " SX5 "
	cQuery += "    ON SX5.X5_FILIAL ='"  + xFilial("SX5") + "'"
	cQuery += "    AND SX5.X5_TABELA ='L4'"
	cQuery += "    AND SX5.X5_CHAVE  = DTC_SERVIC "
	cQuery += "    AND SX5.D_E_L_E_T_ = ' '"
		                       
	//-- Sequencia de Endereco
	cQuery += "   LEFT JOIN " + RetSqlName("DUL") + " DUL "
	cQuery += "    ON DUL.DUL_FILIAL ='"  + xFilial("DUL") + "'"
	cQuery += "    AND DUL_CODCLI = DTC_CLIDES "
	cQuery += "    AND DUL_LOJCLI = DTC_LOJDES "
	cQuery += "    AND DUL_SEQEND = DTC_SQEDES "
	cQuery += "    AND DUL.D_E_L_E_T_ = ' '"	

	cQuery += "   LEFT JOIN " + RetSqlName("SA1") + " RED" 
	cQuery += "    ON  RED.A1_FILIAL   = '"+xFilial('SA1')+"'"
	cQuery += "   AND  RED.A1_COD      = DUL_CODRED "
	cQuery += "   AND  RED.A1_LOJA     = DUL_LOJRED "
	cQuery += "   AND  RED.D_E_L_E_T_  = ' '"		
	
	cQuery += "   JOIN " + RetSqlName("DTP") + " DTP" 
	cQuery += "    ON  DTP.DTP_FILIAL  = '" + xFilial('DTP') + "'"
	cQuery += "   AND  DTP.DTP_FILORI  = DTC_FILORI "
	cQuery += "   AND  DTP.DTP_LOTNFC  = DTC_LOTNFC "
	cQuery += "   AND  DTP.D_E_L_E_T_  = ' '"		
	cQuery += "  WHERE DD9.DD9_FILIAL = '" + xFilial("DD9") + "' "
	cQuery += "  AND DD9.DD9_FILORI = '" + DF8->DF8_FILORI + "' "
	cQuery += "  AND DD9.DD9_NUMPRG= '" + DF8->DF8_NUMPRG + "' "
	cQuery += "  AND DD9.DD9_SEQPRG= '" + DF8->DF8_SEQPRG + "' "
	cQuery += "  AND DD9.D_E_L_E_T_ = ' '"
		
	cQuery += "  UNION ALL "

	cQuery += " SELECT DISTINCT DT6.DT6_FILIAL T01_FILIAL, DT6.DT6_FILDOC T01_FILDOC, DT6.DT6_DOC    T01_DOC   , DT6.DT6_SERIE  T01_SERIE , DD9.DD9_NUMNFC   T01_NUMNFC, DD9.DD9_SERNFC    T01_SERNFC, "
	cQuery += "        DT6.DT6_DATEMI T01_EMINFC, ''             T01_FILCFS, ''             T01_NUMSOL, "
	cQuery += "			CASE    "
	cQuery += "				WHEN DT6.DT6_SERIE = 'COL'    "
	cQuery += "					THEN     "
	cQuery += "						CASE      "
	cQuery += "							WHEN DT6.DT6_CLIREM <> ' '      "
	cQuery += "								THEN DT6.DT6_CLIREM    "
	cQuery += "							ELSE DUE.DUE_CODCLI    "
	cQuery += "						END     "
	cQuery += "				WHEN  DT6.DT6_SERIE <> 'COL'    "
	cQuery += "					THEN DT6.DT6_CLIREM    "
	cQuery += "			END AS T01_CLIREM,    "

	cQuery += "          CASE    "
	cQuery += "          	WHEN DT6.DT6_SERIE = 'COL'    "
	cQuery += "          		THEN     "
	cQuery += "          			CASE      "
	cQuery += "          				WHEN DT6.DT6_LOJREM <> ' '     " 
	cQuery += "          					THEN DT6.DT6_LOJREM    "
	cQuery += "          				ELSE DUE.DUE_LOJCLI    "
	cQuery += "          			END     "
	cQuery += "          	WHEN  DT6.DT6_SERIE <> 'COL'    "
	cQuery += "          		THEN DT6.DT6_LOJREM    "
	cQuery += "          END AS T01_LOJREM,    "
	
	cQuery += "        CASE WHEN DT6_SERIE = 'COL' AND DT6.DT6_CLIREM = ' '  THEN DUE_NOME ELSE  REM.A1_NREDUZ END T01_NOMREM, " 
	cQuery += "        DT6.DT6_CLIDES T01_CLIDES, DT6.DT6_LOJDES T01_LOJDES, DES.A1_NREDUZ  T01_NOMDES, ''             T01_SQEDES, DES.A1_END     T01_END   , DES.A1_EST     T01_EST,"
	cQuery += "        DES.A1_MUN     T01_MUN   , DES.A1_BAIRRO  T01_BAIRRO, DES.A1_CEP     T01_CEP   , DES.A1_CGC     T01_CGC, "
	cQuery += "        DT6.DT6_QTDVOL T01_QTDVOL, DT6.DT6_PESO   T01_PESO  , DT6.DT6_PESOM3 T01_PESOM3, DT6.DT6_METRO3 T01_METRO3, "
	cQuery += "        DT6.DT6_VALMER T01_VALOR , DT6.DT6_VALFRE T01_VALFRE, DT6.DT6_CDRORI T01_CDRORI, DT6.DT6_CDRDES T01_CDRDES,  "
	cQuery += "        DT6.DT6_CDRCAL T01_CDRCAL, DT6.DT6_PRZENT T01_PRVENT,  "
	cQuery += "        DD9.DD9_CODPRO     T01_CODPRO, ''             T01_CODEMB, DT6.DT6_CLIDEV T01_CLIDEV, DT6.DT6_LOJDEV T01_LOJDEV, DEV.A1_NREDUZ  T01_NOMDEV, "
	cQuery += "        ''             T01_LOTNFC, '' T01_RATEIO,  '' T01_CRIRAT, DT6.DT6_TIPFRE T01_TIPFRE, DD9_SERTMS T01_SERTMS,  DT6.DT6_TIPTRA T01_TIPTRA, "
	cQuery += "        DT6.DT6_SERVIC T01_SERVIC, ''             T01_FILORI, DT6.DT6_CHVCTE T01_CHVCTE, '' T01_NFEID,DT6.DT6_BLQDOC T01_BLQDOC, DT6.DT6_FILDES T01_FILDES, "
	cQuery += "        DD9_NUMPRG T01_NUMPRG, DD9_SEQPRG T01_SEQPRG,  DDZ.DDZ_CODVEI T01_CODVEI, DD9_SEQUEN T01_SEQENT, DT6.DT6_STATUS T01_STATUS, X5_DESCRI T01_DESSER, 'N' T01_RECREM,  'N' T01_RECDES,"
	cQuery += "        ' '            T01_CDROTA, ' ' T01_NUMTMP, '.F.' T01_MARK, 'PMSEDT3' T01_LEGPAG,"		
			
	If lAgdEntr 
			If Len(aRetPrd)> 0 //.And. cSerTMS == "3"
				cQuery += "     DYD.DYD_NUMAGD T01_NUMAGD, DYD.DYD_DATAGD T01_DATAGD, DYD.DYD_PRDAGD T01_PRDAGD, DYD.DYD_INIAGD T01_INIAGD, "
				cQuery += "     DYD.DYD_FIMAGD T01_FIMAGD, DYD.DYD_TIPAGD T01_TIPAGD, "
				cQuery += "     CASE WHEN DYD.DYD_PRDAGD = '1'  THEN  '" + aRetPrd[1][3] + "' "
				cQuery += "          WHEN DYD.DYD_PRDAGD = '2'  THEN  '" + aRetPrd[2][3] + "' " 
				cQuery += "          WHEN DYD.DYD_PRDAGD = '3'  THEN  '" + aRetPrd[3][3] + "' "   
				cQuery += "          WHEN DYD.DYD_PRDAGD = '4'  THEN  '" + aRetPrd[4][3] + "' "
				cQuery += "          ELSE ' ' END AS T01_DETPAG, "
			EndIf
			
			If Len(aRetTipo)> 0 	
				cQuery += "     CASE WHEN DYD.DYD_TIPAGD = '0'  THEN  '" + aRetTipo[1][3] + "' "
				cQuery += "          WHEN DYD.DYD_TIPAGD = '1'  THEN  '" + aRetTipo[2][3] + "' " 
				cQuery += "          WHEN DYD.DYD_TIPAGD = '2'  THEN  '" + aRetTipo[3][3] + "' "   
				cQuery += "          WHEN DYD.DYD_TIPAGD = '3'  THEN  '" + aRetTipo[4][3] + "' "
				cQuery += "          WHEN DYD.DYD_TIPAGD = '4'  THEN  '" + aRetTipo[5][3] + "' "
				cQuery += "          ELSE ' ' END AS T01_DEPRAG "
			EndIf	
	Else
			cQuery += "     ''             T01_NUMAGD, ''             T01_DATAGD, ''             T01_PRDAGD, ''             T01_INIAGD, "
			cQuery += "     ''             T01_FIMAGD, ''             T01_TIPAGD, '' T01_DETPAG, ' ' T01_DEPRAG "
	EndIf
		
	cQuery += "  FROM  " 
	cQuery += RetSqlName("DD9") + " DD9 "
	
	cQuery+= "  JOIN " + RetSqlname('DT6') + " DT6 " 
	cQuery+= "   ON DT6_FILIAL = '" + xFilial('DT6') + "' "
	cQuery += "  AND DT6.DT6_FILDOC = DD9.DD9_FILDOC  "
	cQuery += "  AND DT6.DT6_DOC = DD9.DD9_DOC "
	cQuery += "  AND DT6.DT6_SERIE = DD9.DD9_SERIE "
	cQuery += "  AND DT6.D_E_L_E_T_ = ' '  "
	
	If lAgdEntr //.And. cSerTMS == "3"
		cQuery += " LEFT JOIN  "
		cQuery += RetSqlName("DYD") + " DYD"
		cQuery += "    ON  DYD.DYD_FILIAL  =  '"+xFilial('DYD')+"'"
		cQuery += "   AND  DYD.DYD_NUMAGD  =  DT6.DT6_NUMAGD"
		cQuery += "   AND  DYD.DYD_TIPAGD  >= '" + cValToChar(MV_PAR22) + "'" 
		cQuery += "   AND  DYD.DYD_TIPAGD  <= '" + cValToChar(MV_PAR23) + "'"
		cQuery += "   AND  DYD.D_E_L_E_T_  =  ' '"
	EndIf	
	

	cQuery+= "  JOIN " + RetSqlname('DF8') + " DF8 " 
	cQuery+= "   ON DF8_FILIAL = '" + xFilial('DF8') + "' "
	cQuery += "  AND DF8.DF8_FILORI = DD9.DD9_FILORI "
	cQuery += "  AND DF8.DF8_NUMPRG = DD9.DD9_NUMPRG  "
	cQuery += "  AND DF8.DF8_SEQPRG = DD9.DD9_SEQPRG  "
	cQuery += "  AND DF8.D_E_L_E_T_ = ' '  "
	
	cQuery+= "  LEFT JOIN " + RetSqlname('DDZ') + " DDZ " 
	cQuery+= "   ON DDZ_FILIAL = '" + xFilial('DDZ') + "' "
	cQuery += "  AND DDZ.DDZ_FILORI = DD9.DD9_FILORI "
	cQuery += "  AND DDZ.DDZ_NUMPRG = DD9.DD9_NUMPRG  "
	cQuery += "  AND DDZ.DDZ_SEQPRG = DD9.DD9_SEQPRG  "
	cQuery += "  AND DDZ.D_E_L_E_T_ = ' '  "
		
	cQuery += "   LEFT JOIN " + RetSqlName("SA1") + " REM "      
	cQuery += "   ON  REM.A1_FILIAL  = '"+xFilial('SA1')+"'"
	cQuery += "   AND  REM.A1_COD     = DT6_CLIREM"
	cQuery += "   AND  REM.A1_LOJA    = DT6_LOJREM"
	cQuery += "   AND  REM.D_E_L_E_T_ = ' '"          
	cQuery += "   LEFT JOIN " + RetSqlName("SA1") + " DES "
	cQuery += "   ON  DES.A1_FILIAL  = '"+xFilial('SA1')+"'"
	cQuery += "   AND  DES.A1_COD     = DT6_CLIDES"
	cQuery += "   AND  DES.A1_LOJA    = DT6_LOJDES"
	cQuery += "   AND  DES.D_E_L_E_T_ = ' '"
	cQuery += "   LEFT JOIN " + RetSqlName("SA1") + " DEV "
	cQuery += "   ON  DEV.A1_FILIAL  = '"+xFilial('SA1')+"'"
	cQuery += "   AND  DEV.A1_COD     = DT6_CLIDEV"
	cQuery += "   AND  DEV.A1_LOJA    = DT6_LOJDEV"
	cQuery += "   AND  DEV.D_E_L_E_T_ = ' '"
	cQuery += "   LEFT JOIN " + RetSqlName("SX5") + " SX5 "
	cQuery += "    ON SX5.X5_FILIAL ='"  + xFilial("SX5") + "'"
	cQuery += "    AND SX5.X5_TABELA ='L4'"
	cQuery += "    AND SX5.X5_CHAVE  = DT6_SERVIC "
	cQuery += "    AND SX5.D_E_L_E_T_ = ' '"
	cQuery += "   LEFT JOIN " + RetSqlName("DT5") + " DT5 " 
	cQuery += "   ON  DT5.DT5_FILIAL  = '"+xFilial('DT5')+"'"   
	cQuery += "   AND DT5.DT5_FILDOC = DT6_FILDOC AND DT5.DT5_DOC = DT6_DOC AND DT5.DT5_SERIE = DT6_SERIE AND DT5.D_E_L_E_T_= ' ' "
	cQuery += "   LEFT JOIN " + RetSqlName("DUE") + " DUE "   
	cQuery += "   ON  DUE.DUE_FILIAL =  '"+xFilial('DUE')+"'" 
	cQuery += "   AND DUE.DUE_CODSOL   = DT5.DT5_CODSOL "
	cQuery += "   AND DUE.D_E_L_E_T_ = ' ' "
	
	cQuery += "  WHERE DD9.DD9_FILIAL = '" + xFilial("DD9") + "' "
	cQuery += "  AND DD9.DD9_FILORI = '" + DF8->DF8_FILORI + "' "
	cQuery += "  AND DD9.DD9_NUMPRG= '" + DF8->DF8_NUMPRG + "' "
	cQuery += "  AND DD9.DD9_SEQPRG= '" + DF8->DF8_SEQPRG + "' "
	cQuery += "  AND DD9.D_E_L_E_T_ = ' '"
		
Return(cQuery)	


//-------------------------------------------------------------------
/*/{Protheus.doc} T146GrvVge
Grava a Viagem
@author Katia
@since 21/10/2014
/*/
//-------------------------------------------------------------------

Function T146GrvVge(nOpcViag,cRotaDF8,cFilOriDF8,cViagemDF8,cSerTmsDF8,dDatGerDF8,cHorGerDF8,aVeiculos,lValBlq,aMotPrg,cTipTraDF8)

Local cCodMot     := GetMv('MV_MOTGEN',,.T.)
Local nCnt        := 0
Local nCntFor     := 0
Local nPosMot     := 0
Local cCodRb1     := "" 
Local cCodRb2     := ""
Local cCodRb3     := ""
Local lAgdEntr    := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)   //-- Agendamento de Entrega.
Local lRet        := .F.
Local nX          := 0      
Local nY          := 0
Local nXX         := 0
Local nYY         := 0
Local dDatVge     := dDataBase
Local cHorVge     := Left(StrTran(Time(),":",""),4)
Local cCondut     := ""

Private aRota      := {}
Private nTipVia	   := 0
Private cSerTms    := cSerTmsDF8
//--- variaveis do tmsa240 - motorista
Private aMotViag   := {}
Private aHeaderDUP := {}
Private aSetKey    := {}
Private n          :=0
Private aCols      := {}
Private aHeader    := {}
Private lVgeExpr   := .F.
Private cSerAdi    := ""

Default aVeiculos := {}
Default lValBlq   := .T.
Default aMotPrg   := {}
Default cTipTraDF8:= ""

Pergunte("TMB144",.F.)

If Type("MV_PAR02") == "C"
	cSerAdi := mv_par02
EndIf

If nOpcViag != 0
	SetFunName("TMSA144")
	Aadd( aRota, { .T., cRotaDF8,,,,,,,.F. } )

	nTipVia := 1 //-- Normal 

	If nOpcViag != 3
		DTQ->( DbSetOrder(2)) //-- DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM
		DTQ->( MsSeek( xFilial("DTQ") + cFilOriDF8 + cViagemDF8 ))
		RegToMemory('DTQ',.F.)
		
	Else
		                                                                                                 
		If Len(aVeiculos) > 0
			For nX:= 1 To Len(aVeiculos)
				lCompViag:= .T.
				nY:= nX
				cCodRb1:= ""
				cCodRb2:= ""
				cCodRb3:= ""		
				DA3->( dbSetOrder( 1 ) )
				If DA3->( dbSeek( xFilial('DA3') + aVeiculos[nX][1] ))
					If Empty(aMotPrg)
						cCodMot := DA3->DA3_MOTORI
					Else
						For nYY:= 1 To Len(aMotPrg)
							If aMotPrg[nYY][1][8] == '1' //--Se for Condutor Principal
								cCodMot := aMotPrg[nYY][1][6]	
							EndIf						
						Next nYY	
					EndIf

					For nXX:= 1 To Len(aVeiculos[nX][2])
						lCompViag:= .F.
						If nXX ==1
							cCodRb1:= aVeiculos[nX][2][nXX]
						ElseIf nXX == 2
							cCodRb2:= aVeiculos[nX][2][nXX]
						ElseIf nXX == 3
							cCodRb3:= aVeiculos[nX][2][nXX]
						EndIf
					Next nXX	
					
					If !Empty(cCodMot)
						DA4->( dbSetOrder( 1 ) )
						DA4->( dbSeek( xFilial('DA4') + cCodMot ))
					EndIf
				
				EndIf

				If Len(aCompViag) > 0
					For nCntFor := 1 To Len(aCompViag[2])
						//---Motorista da Viagem
						If Len(aCompViag[4]) > 0
							For nCnt := 1 To Len(aCompViag[4][nY][2])
								If !Empty(aMotPrg)
									cCodMot := aMotPrg[nCnt][1][6]
									cCondut := aMotPrg[nCnt][1][8]
								EndIf
								nPosMot := Ascan(aCompViag[3],{|x| x[2] == 'DUP_CODMOT'})
								If !Empty( aCompViag[4][nY][2][nCnt][nPosMot] ) .Or. aCompViag[4][nY][2][nCnt][nPosMot] <> cCodMot
									aCompViag[4][nY][2][nCnt][nPosMot] := cCodMot
									aCompViag[4][nY][2][nCnt][7]       := cCondut										
								EndIf
							Next nCnt
						EndIf	
						
						//---Ajudante da Viagem
						If Len(aCompViag[6]) > 0
							If !Empty(DA4->DA4_AJUDA2)
								aAdd(aCompViag[6][nY][2],aClone(aCompViag[6][nY][2][1]))
							EndIf

							If !Empty(DA4->DA4_AJUDA3)
								aAdd(aCompViag[6][nY][2],aClone(aCompViag[6][nY][2][1]))
							EndIf
							
							If !Empty(DA4->DA4_AJUDA1)
								For nCnt := 1 To Len(aCompViag[6][nY][2])
									nPosAju := Ascan(aCompViag[5],{|x| x[2] == 'DUQ_CODAJU'})
									If nCnt == 1 
										aCompViag[6][nY][2][nCnt][nPosAju] := DA4->DA4_AJUDA1
									ElseIf nCnt == 2 .And. !Empty(DA4->DA4_AJUDA2)
										aCompViag[6][nY][2][nCnt][nPosAju] := DA4->DA4_AJUDA2
									ElseIf nCnt == 3 .And. !Empty(DA4->DA4_AJUDA3)
										aCompViag[6][nY][2][nCnt][nPosAju] := DA4->DA4_AJUDA3
									EndIf
								Next nCnt
							EndIf
						EndIf

						If !aCompViag[2][nY][Len(aCompViag[1])+1]
							aCompViag[2][nY][ Ascan( aCompViag[1], { |x| x[2] == 'DTR_CODVEI'} ) ] := DA3->DA3_COD
							aCompViag[2][nY][ Ascan( aCompViag[1], { |x| x[2] == 'DTR_CREADI'} ) ] := DA3->DA3_CODFOR     
							aCompViag[2][nY][ Ascan( aCompViag[1], { |x| x[2] == 'DTR_LOJCRE'} ) ] := DA3->DA3_LOJFOR
							aCompViag[2][nY][ Ascan( aCompViag[1], { |x| x[2] == 'DTR_NOMCRE'} ) ] := Posicione('SA2',1,xFilial("SA2")+DA3->DA3_CODFOR+DA3->DA3_LOJFOR,'A2_NOME')                                    
							aCompViag[2][nY][ Ascan( aCompViag[1], { |x| x[2] == 'DTR_CODRB1'} ) ] := cCodRb1
							aCompViag[2][nY][ Ascan( aCompViag[1], { |x| x[2] == 'DTR_CODRB2'} ) ] := cCodRb2
							aCompViag[2][nY][ Ascan( aCompViag[1], { |x| x[2] == 'DTR_CODRB3'} ) ] := cCodRb3
						EndIf
					Next nContFor

				EndIf
			Next nX
		
		EndIf
	EndIf

	SaveInter()
	If cSerTMSDF8 == '2'
		Pergunte( 'TMA144', .F. )
		
		nCarreg			:= MV_PAR01
		M->DTQ_TIPVIA	:= StrZero( nTipVia, Len( DTQ->DTQ_TIPVIA ) )
		
		If lHasViaM3
			lRet	:= TMSVMod3( nOpcViag, dDatVge, cHorVge, DF8->DF8_NUMPRG, M->DTQ_FILORI, M->DTQ_VIAGEM, aCompViag, cSerTMSDF8, cRotaDF8, cTipTraDF8)
		Else
			lRet	:= TmsA140Grv( nOpcViag, , , dDatVge, cHorVge, , lValBlq )			
		EndIf
		
	Else
		If cSerTMSDF8 <> '3'
			Pergunte( 'TMA141', .F. )
		Else
			If lAgdEntr
				Pergunte( 'TMSA141A', .F. )
			Else
				Pergunte( 'TMA141', .F. )
			EndIf

			nCarreg	:= mv_par02
		EndIf
		If lHasViaM3
			lRet	:= TMSVMod3( nOpcViag, dDatVge, cHorVge, DF8->DF8_NUMPRG, M->DTQ_FILORI, M->DTQ_VIAGEM, aCompViag, cSerTMSDF8, cRotaDF8, cTipTraDF8 )
		Else
			lRet	:= TmsA141Grv( nOpcViag, , , dDatVge, cHorVge, , lValBlq )
		EndIf

	EndIf

	RestInter()
	Pergunte( 'TMSA146', .F. )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TM146DocDUD
Monta estrutura do DUD 
@author Katia
@since 20/11/2014
/*/
//-------------------------------------------------------------------
Function TM146DocDUD(cFilDoc,cDoc,cSerie,cSerTms,cRota,nOpcViag,lExcDoc,cSeqEnt,lEstorno)
Local lRet     := .F.
Local aArea    := GetArea()
Local aAreaDD9 := DD9->(GetArea())
Local nElem    := 0
Local aRegiao  := {}
Local nCntFo1	:= 0
Local aLinha   := Array(54)
Local aRotaDA8 := {}
Local lAchou   := .F.
Local aRet 	 := {}
Local cSeqDD9  := ""

Local lTMSDCol  := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.
Local cAliasDUD := ""
Local cQuery    := ""

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default cSerTms := ""
Default cRota   := ""
Default nOpcViag:= 3
Default lExcDoc := .F.
Default cSeqEnt := ""

DT6->( DbSetOrder(1) ) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
If DT6->( MsSeek( xFilial("DT6") + cFilDoc + cDoc + cSerie ))
	
	DUD->( DbSetOrder(1)) //-- DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
	If nOpcViag <> 5
		If !lTMSDCol
			DUD->( MsSeek(xFilial("DUD")+cFilDoc+cDoc+cSerie+cFilAnt))
		Else
			cAliasDUD := GetNextAlias()
			cQuery := " SELECT (MAX(R_E_C_N_O_)) R_E_C_N_O_"
			cQuery += "   FROM " + RetSqlName("DUD")
			cQuery += "  WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
			cQuery += "    AND DUD_FILDOC = '" + cFilDoc + "' "
			cQuery += "    AND DUD_DOC    = '" + cDoc + "' "
			cQuery += "    AND DUD_SERIE  = '" + cSerie + "' "
			cQuery += "    AND D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDUD,.F.,.T.)

			If (cAliasDUD)->(!Eof())
				If (cAliasDUD)->R_E_C_N_O_ > 0
					DUD->(DbGoto((cAliasDUD)->R_E_C_N_O_))
				EndIf
			EndIf
			(cAliasDUD)->(DbCloseArea())
			RestArea(aArea)
		EndIf
	Else
		DUD->( MsSeek(xFilial("DUD")+cFilDoc+cDoc+cSerie+DF8->DF8_FILORI+DF8->DF8_VIAGEM))
	EndIf
				
	If cSerTms == '2' //-- Transporte
	   	aRegiao := TMSNivSup(DUD->DUD_CDRCAL,,,,,"TMSA146") // Obtem os niveis superiores da regiao de calculo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorna as Regioes / Filiais de Destino da Rota                       ³
		//³ Elementos contidos por dimensao:                                      ³
		//³ 1. Regiao Origem da Rota                                              ³
		//³ 2. Regioes de Destino da Rota                                         ³
		//³ 3. Filiais de Destino da Rota                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRegRot := TMSRegDes(cRota) // Obtem as regioes da rota.
		For nElem:= 1 To Len(aRegiao)
		/* Verifica se a regiao de destino do CTRC pertence a regiao da rota. */
			lAchou := Ascan(aRegRot, {|x| x[2] == aRegiao[nElem]}) > 0
			If lAchou
				Exit
			EndIf
		Next nElem
		
		If lAchou
			cStRota := "1"  //Da Rota
		Else
			cStRota := "3"  //De outra Rota
		EndIf
		aLinha[CTSTATUS] := DUD->DUD_STATUS
		aLinha[CTSTROTA] := cStRota
		aLinha[CTMARCA ] := Iif(lExcDoc,.F.,.T.) 
		aLinha[CTSEQUEN] := Iif(!Empty(cSeqEnt),cSeqEnt,Replicate('x',Len(DUD->DUD_SEQUEN)))
		aLinha[CTARMAZE] := Space(Len(DUH->DUH_LOCAL)) 
		aLinha[CTLOCALI] := Space(Len(DUH->DUH_LOCALI))
		aLinha[CTFILDOC] := DUD->DUD_FILDOC
		aLinha[CTDOCTO ] := DUD->DUD_DOC
		aLinha[CTSERIE ] := DUD->DUD_SERIE
		aLinha[CTREGDES] := Posicione("DUY",1,xFilial("DUY")+DUD->DUD_CDRCAL,"DUY_DESCRI")
		aLinha[CTDATEMI] := DTC->DTC_DATENT
		aLinha[CTPRZENT] := Ctod('')
		aLinha[CTNOMREM] := Posicione('SA1',1,xFilial('SA1')+DT6->(DT6_CLIREM+DT6_LOJREM),'A1_NREDUZ')
		aLinha[CTNOMDES] := Posicione('SA1',1,xFilial('SA1')+DT6->(DT6_CLIDES+DT6_LOJDES),'A1_NREDUZ')
		aLinha[CTESTADO] := Space(Len(DUY->DUY_EST) )
		aLinha[CTDATENT] := CtoD('') 
		aLinha[CTQTDVOL] := DT6->DT6_QTDVOL
		aLinha[CTVOLORI] := DT6->DT6_QTDVOL 
		aLinha[CTPLIQUI] := DT6->DT6_PESO 
		aLinha[CTPESOM3] := DT6->DT6_PESOM3 
		aLinha[CTVALMER] := DT6->DT6_VALMER 
		aLinha[CTVIAGEM] := .T.  
		aLinha[CTSEQDA7] := '' 
		aLinha[CTSOLICI] := Space(Len(DUE->DUE_NOME))   			//-- DUE_NOME
		aLinha[CTENDERE] := Space(Len(SA1->A1_END))     			//-- DUE_END
		aLinha[CTBAIRRO] := Space(Len(SA1->A1_BAIRRO))  			//-- DUE_BAIRRO
		aLinha[CTMUNICI] := Space(Len(SA1->A1_MUN))     			//-- DUE_MUN
		aLinha[CTDATSOL] := CtoD('')								//-- DT5_DATSOL
		aLinha[CTHORSOL] := Space(Len(DT5->DT5_HORSOL))  			//-- DT5_HORSOL
		aLinha[CTDATPRV] := CtoD('') 								//-- DT5_DATPRV
		aLinha[CTHORPRV] := Space(Len(DT5->DT5_HORPRV))				//-- DT5_HORPRV
		aLinha[CTDOCROT] := '' 										//-- Codigo que identifica a q rota pertence o documento
		aLinha[CTBLQDOC] := '' 										//-- Tipos de bloqueio do documento
		aLinha[CTNUMAGE] := '' 										//-- Numero do Agendamento( Carga Fechada ).
		aLinha[CTITEAGE] := '' 										//-- Item do Agendamento( Carga Fechada ).
		aLinha[CTSERTMS] := '' 										//-- Tipo do Servico.
		aLinha[CTDESSVT] := ''										//-- Descricao do Servico.
		aLinha[CTUNITIZ] := Space(Len(DUH->DUH_UNITIZ))
		aLinha[CTCODANA] := Space(Len(DUH->DUH_CODANA))
		Aadd(aDocto,AClone(aLinha))
		lRet:= .T.
	Else              
		aRet:= OmsHasDa7(cFilAnt,DT6->DT6_CLIDES,DT6->DT6_LOJDES)
		For nCntFo1:= 1 To Len(aRet)
			DA7->(dbGoTo(aRet[nCntFo1]))
			If DA9->(dbSeek(xFilial('DA9')+DA7->(DA7_PERCUR+DA7_ROTA))) .And. ;
				DA8->(dbSeek(xFilial('DA8')+DA9->DA9_ROTEIR)) .And. DA8->DA8_COD == cRota
				Aadd(aRotaDA8,{ DA8->DA8_COD, DA8->DA8_DESC, DA7->DA7_PERCUR, DA7->DA7_ROTA  })
			EndIf
		Next nCntFo1
							
		dbSelectArea("DD9")
		DD9->(dbSetOrder(3))
		If DD9->(dbSeek(FwxFilial("DD9")+cFilDoc+cDoc+cSerie))
			cSeqDD9:= DD9->DD9_SEQUEN
		EndIf
							
		aLinha[CTSTATUS]	:= DUD->DUD_STATUS                     
		aLinha[CTSTROTA]	:= ''
		aLinha[CTMARCA ]	:= Iif(lExcDoc,.F.,.T.)
		aLinha[CTSEQUEN]	:= Iif(nOpcViag <> 5, cSeqDD9, DUD->DUD_SEQUEN)
		aLinha[CTARMAZE]	:= ''
		aLinha[CTLOCALI]	:= ''
		aLinha[CTFILDOC]	:= DUD->DUD_FILDOC
		aLinha[CTDOCTO ]	:= DUD->DUD_DOC   		
		aLinha[CTSERIE ]	:= DUD->DUD_SERIE
		aLinha[CTQTDVOL]	:= DT6->DT6_QTDVOL
		aLinha[CTPLIQUI]	:= DT6->DT6_PESO
		aLinha[CTVIAGEM]	:= .T.
			
		If Len(aRotaDA8) != 1 
			DA8->( DbSetOrder(1)) //-- DA8_FILIAL+DA8_COD
			If DA8->( MsSeek(xFilial('DA8')+cRota))
				aLinha[CTDOCROT]	:= DA8->DA8_COD + DA8->DA8_DESC
			Else
				aLinha[CTDOCROT]	:= cRota
			EndIf
		Else
			aLinha[CTDOCROT]	:= DA8->DA8_COD + DA8->DA8_DESC + DA7->DA7_PERCUR + DA7->DA7_ROTA
		EndIf
		Aadd(aDocto,AClone(aLinha))
		
		lRet:= .T.
		
	EndIf
EndIf
RestArea(aAreaDD9)
RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA146WheºAutor  ³ Daniel Leme        º Data ³  10/02/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna se o campo é editável                               º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA146Whe(cCampo) 

Local lRet	    := .T.
Local cCatVei   := ""

Default cCampo := ReadVar()

If !IsInCallStack('TMSA146MNT') .And. !lIncAuto .AND. !("DF8_ROTA" $ cCampo)
	If !IsInCallStack("RUNTRIGGER") //-- Libera Edição Para Atualização De Gatilhos
		lRet:= .F.
	EndIf
Else
	If "DF8_CODCAV" $ cCampo
		DA3->( dbSetOrder( 1 ) )     
		If DA3->( dbSeek( xFilial('DA3') + FwFldGet('DF8_CODVEI') ))
			cCatVei:= Posicione('DUT',1,xFilial('DUT')+DA3->DA3_TIPVEI,'DUT_CATVEI') 
	
			If cCatVei <> StrZero(3, Len(DUT->DUT_CATVEI)) //Carreta 
				lRet := .F.
			EndIf
		EndIf
	ElseIf "DF8_FILVGE|DF8_NUMVGE" $ cCampo
		If FwFldGet('DF8_VGEINT') == .T.   //Interligado automaticamente na inclusao da programacao
			lRet:= .F.
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMSA146Eft Marcelo Corrêa Coutinho    º Data ³  10/02/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa Efetivação da Programação Selecionada               º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA146                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA146Eft()
Local lRet       := .T.
Local cCodMot    := GetMv('MV_MOTGEN',,.T.)
Local cVeiGen    := GetMv('MV_VEIGEN',,.T.)
Local cCodVei    := ''
Local nCntFor    := 0
Local nCnt       := 0
Local aArea      := GetArea()
Local aAreaDUP   := DUP->(GetArea())
Local aAreaDTQ   := DTQ->(GetArea())
Local aAreaAnt   := {} 
Local aAreaDF8   := {} 
Local nOpcViag   := 3
Local cFilDF8    := ""
Local cNumDF8    := ""
Local cQuery     := ""
Local cAliasQry  := ""
Local lAgdEntr   := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)   //-- Agendamento de Entrega.
Local cStReg     := ''
Local cQryPag	 := ""
Local cAliasPag  := ""
Local cSrvAdc	 := "2"					// Recebe se o serviço adicional esta ativo para a Programação
Local lDTCPag    := .F.					// Verifica se existem itens para pagadores a partir da DTC
Local lDT5Pag    := .F.					// Verifica se existem itens para pagadores a partir da DT5		
Local cRota		 := ""					// Recupera a Rota a partir da rotina de rota automatica
Local aTabRec	 := {} 					// Recebe as tabelas e recnos dos registro de Pagadores
Local aRetTela   := {}					// Recebe o Retorno da TMSF79Tela()
Local aRetPag	 := {}					// Recebe o retorna da Rotina de Pagadores
Local aVeiculos  := {}
Local cSeek		 := ""
Local lComplem   := .F.
Local aVisErr    := {}
Local lSerAdi    := .F.
Local cFilOri    := ""
Local cViagem    := ""
Local cMay       := ""
Local lRoteiro   := .F.
Local lDmd       := .F. //SUAVIZAÇÃO DEMANDAS
Local lMostra	 := If( FwIsInCallStack('T153GExec') .AND. !FwIsInCallStack('TMSA146') , lMostra := .F., lMostra := .T. )

Local lTMSDCol	 := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.
Local lHasDLS	 := AliasInDic("DLS")

Private aHeader  := {}
Private aCols    := {}
Private cStRota  := ""

Private aDocto   := {}
Private lColeta  := .F.
Private aCompViag:= {}
Private aBkpDocto:= {}
Private lLocaliz := .F.
Private nCarreg  := 1 //-- Carregamento Manual
Private lTmsCFec := TmsCFec()

//-- Variaveis dos itens do planejamento
Private aItensPC  := {}
Private aQtdVei   := {}
Private aQtdDoc   := {}
Private aValInf   := {}
Private aHeaderDVU:= {}  // aHeader de Tipos de Veiculo da Nota Fiscal
Private aColsDVU  := {}  // aCols de Tipos de Veiculo da Nota Fiscal
Private lListVei  := .T.
Private INCLUI	  := .T.
Private cSerTms   := ""
Private cTipTra   := cTpTransp

Private aRotina   :=	{{ 'Pesquisar', "AxPesqui", 0, 1 },; //-- "Pesquisar"
						{ 'Visualizar', "AxVisual" , 0, 2 },; //-- "Visualizar"
				    	{ 'Incluir'   , "AxInclui" , 0, 3 },; //-- "Incluir"
				    	{ 'Alterar'   , "AxAltera" , 0, 4 },; //-- "Alterar"
						{ 'Excluir'   , "AxExclui" , 0, 5 } } //-- "Excluir"
Private cTipAgdEnt := '2' // Retorna o tipo de lançamento de agendamento de entrega no lançamento do documento (1=Sim, 2=Não, 3=Obrigatório).
Private lPsqAgdEnt := .T. // Executa pesquisa para validar lançamento de agendamento de entrega no lançamento do documento.
Private aMotPrg    := {}

If DF8->DF8_STATUS == '2'
	Help('',1,'TMSA14601') // "Programação já Efetivada!"
	lRet := .F.   
ElseIf DF8->DF8_STATUS == '9'	                               
	Help('',1,'TMSA14629') // "A Programação está Cancelada!"
	lRet := .F. 
ElseIf DF8->DF8_STATUS == '3'	                               
	Help( ,, 'Help',,STR0242,2,0,,,,,, {STR0243}) // Existem documentos não transmitidos na programação de carregamento. / "Acesse o Monitor Cte em (Outras Ações -> Monitor Cte), transmita os documentos e retorne nesta tela para atualizar o status da programação"
	lRet := .F. 
ElseIf cFilAnt <> DF8->DF8_FILORI
	Help('',1,'TMSA14631') // "Manutenção permitida somente na filial da Programação.
	lRet := .F. 
EndIf

If lRet .AND. lMVITMSDMD
	If DF8->(ColumnPos("DF8_PLNDMD")) > 0 //SUAVIZAÇÃO DEMANDAS
		If !Empty(DF8->DF8_PLNDMD)
			lDmd := .T.
		EndIf
	Endif
EndIf

If lRet .AND. Empty( DF8->DF8_ROTA )
	Help( , , 'TMSA146Eft', , STR0244, 2, 0, , , , , , { STR0245 } ) // STR0244"Programação sem Rota (DF8_ROTA) definida." STR0245"Altere a programação de viagem preenchendo o campo Rota (DF8_ROTA)."
	lRet := .F. 
EndIf

If lRet
	cFilDF8   := DF8->DF8_FILORI
	cNumDF8   := DF8->DF8_NUMPRG

	DbSelectArea("DTQ")
	DTQ->( DbSetOrder(1) )

	lSerAdi := .F.

	Pergunte("TMB144",.F.)
	
	If Type("MV_PAR02") == "C" .And. mv_par02 == '1'
		lSerAdi:= .T. 
	EndIf

	If lAgdEntr   //--- Verificar se os clientes da programação exige agendamento
		cAliasQry := GetNextAlias()
		cQuery := " SELECT DD9_CLIDES, DD9_LOJDES, DD9_FILDOC, DD9_DOC, DD9_SERIE, DT6_NUMAGD, DT6_FILDOC, DT6_DOC, DT6_SERIE, DYD_TIPAGD "
		cQuery += " FROM " + RetSqlName("DD9") + " DD9 "
		cQuery += " INNER JOIN " + RetSqlName("DT6") + " DT6 "
		cQuery += 				" ON DT6.DT6_FILIAL  = '" + xFilial("DT6") + "' "
		cQuery += 				" AND DT6.DT6_FILDOC = DD9.DD9_FILDOC "
		cQuery += 				" AND DT6.DT6_DOC = DD9.DD9_DOC "
		cQuery += 				" AND DT6.DT6_SERIE = DD9.DD9_SERIE "
		cQuery += 				" AND DT6.DT6_CLIDES = DD9.DD9_CLIDES "
		cQuery += 				" AND DT6.DT6_LOJDES = DD9.DD9_LOJDES "
		cQuery += 				" AND DT6.DT6_NUMAGD <> ' ' "
		cQuery += 				" AND DT6.D_E_L_E_T_ = ' ' "
		cQuery += " INNER JOIN " + RetSqlName("DYD") + " DYD"
		cQuery += 				" ON DYD.DYD_FILIAL = '"+xFilial('DYD')+"'"
		cQuery += 				" AND DYD.DYD_NUMAGD = DT6.DT6_NUMAGD"
		cQuery += 				" AND DYD.D_E_L_E_T_ = ' '"
		cQuery += " WHERE DD9.DD9_FILIAL = '" + xFilial("DD9") + "' "
		cQuery += 		" AND DD9.DD9_FILORI = '" + DF8->DF8_FILORI + "' "
		cQuery += 		" AND DD9.DD9_NUMPRG = '" + DF8->DF8_NUMPRG + "' "
		cQuery += 		" AND DD9.DD9_SEQPRG = '" + DF8->DF8_SEQPRG + "' "
		cQuery += 		" AND DD9.DD9_DOC <> ' ' " 
		cQuery += 		" AND DD9.D_E_L_E_T_ = ' ' "

		If !cDbType $ "MSSQL|MSSQL7|ORACLE"
			cQuery := ChangeQuery(cQuery)
		EndIf

		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

		While (cAliasQry)->(!Eof())

			If (cAliasQry)->DYD_TIPAGD == '4' //Aguardando Agendamento
				Help( '', 1, 'TMSA14632', , STR0163 + (cAliasQry)->DD9_CLIDES + ' / ' + (cAliasQry)->DD9_LOJDES + ' - ' + STR0164 + (cAliasQry)->DT6_NUMAGD +  ' - ' +  STR0180 + ":"+ (cAliasQry)->DT6_FILDOC + "/" +  (cAliasQry)->DT6_DOC + "/" + (cAliasQry)->DT6_SERIE  , 4,1) // "Cliente Destinatario exige Agendamento de Entrega.
				lRet:= .F.
				Exit
			EndIf

			(cAliasQry)->( DbSkip() )
		EndDo

		(cAliasQry)->(dbCloseArea())
	EndIf
	
	If lRet  
		//Verifica se as Notas estao em lote com status diferente de digitado
		cAliasQry := GetNextAlias()
		cQuery := " SELECT DTP_FILORI, DTP_LOTNFC, DTC_NUMNFC, DTC_SERNFC  "
		cQuery += " FROM " + RetSqlName("DD9") + " DD9 "
		cQuery += 		" JOIN " + RetSqlName("DTC") + " DTC "
		cQuery += 				" ON DTC.DTC_FILIAL  = '" + xFilial("DTC") + "' "
		cQuery += 				" AND DTC.DTC_FILORI = DD9.DD9_FILORI "
		cQuery += 				" AND DTC.DTC_CLIREM = DD9.DD9_CLIREM "
		cQuery += 				" AND DTC.DTC_LOJREM = DD9.DD9_LOJREM "
		cQuery += 				" AND DTC.DTC_NUMNFC = DD9.DD9_NUMNFC "
		cQuery += 				" AND DTC.DTC_SERNFC = DD9.DD9_SERNFC "
		cQuery += 				" AND DTC.D_E_L_E_T_ = ' ' "
		cQuery += 		" JOIN " + RetSqlName("DTP") + " DTP "
		cQuery += 				" ON DTP.DTP_FILIAL  = '" + xFilial("DTP") + "' "
		cQuery += 				" AND DTP.DTP_FILORI = DTC.DTC_FILORI "
		cQuery += 				" AND DTP.DTP_LOTNFC = DTC.DTC_LOTNFC "
		cQuery += 				" AND DTP.DTP_STATUS NOT IN ('2','3') "     
		cQuery += 				" AND DTP.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE DD9.DD9_FILIAL  = '" + xFilial("DD9") + "' "
		cQuery += 		" AND DD9.DD9_FILORI = '" + DF8->DF8_FILORI + "' "
		cQuery += 		" AND DD9.DD9_NUMPRG = '" + DF8->DF8_NUMPRG + "' "
		cQuery += 		" AND DD9.DD9_SEQPRG = '" + DF8->DF8_SEQPRG + "' "
		cQuery += 		" AND DD9.DD9_DOC = ' '  "
		cQuery += 		" AND DD9.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

		While (cAliasQry)->(!Eof())
			//--- Digitacao do Lote nao concluida
			Aadd( aVisErr, {STR0191 + " " + (cAliasQry)->DTP_FILORI + " - " + (cAliasQry)->DTP_LOTNFC + " Doc.Cliente: " + (cAliasQry)->DTC_NUMNFC + " - " + (cAliasQry)->DTC_SERNFC } )  
						
			(cAliasQry)->(DbSkip())	
		EndDo

		(cAliasQry)->(DbCloseArea())
		
		//-- Verificar se os documentos estao disponiveis para entrar na viagem 
		cAliasQry := GetNextAlias()

		cQuery := " SELECT DD9_FILDOC, DD9_DOC, DD9_SERIE "
		cQuery += " FROM " + RetSqlName("DD9") + " DD9 "
		cQuery += " WHERE DD9.DD9_FILIAL  = '" + xFilial("DD9") + "' "
		cQuery += 		" AND DD9.DD9_FILORI = '" + DF8->DF8_FILORI + "' "
		cQuery += 		" AND DD9.DD9_NUMPRG = '" + DF8->DF8_NUMPRG + "' "
		cQuery += 		" AND DD9.DD9_SEQPRG = '" + DF8->DF8_SEQPRG + "' "
		cQuery += 		" AND DD9.DD9_DOC <> ' '  "
		cQuery += 		" AND DD9.D_E_L_E_T_ = ' ' "
		cQuery += 		" AND NOT EXISTS (SELECT 1 FROM " + RetSqlName("DUD") + " DUD "
		cQuery += 							" WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += 							" AND DUD.DUD_FILDOC = DD9.DD9_FILDOC  "
		cQuery += 							" AND DUD.DUD_DOC = DD9.DD9_DOC "
		cQuery += 							" AND DUD.DUD_SERIE = DD9.DD9_SERIE "

		If !lTMSDCol
			cQuery += 						" AND DUD.DUD_FILORI = '" + cFilAnt  + "'"
		EndIf

		If !Empty(DF8->DF8_ROTA)
			cQuery += 						" AND DUD.DUD_TIPTRA =  '" + DF8->DF8_TIPTRA + "' "
		EndIf

		cQuery += 							" AND DUD.DUD_STATUS = '" + StrZero( 1, Len( DUD->DUD_STATUS ) ) + "' " 
		cQuery += 							" AND DUD.DUD_VIAGEM = ' ' "

		If lSerAdi .AND. DF8->DF8_SERTMS == StrZero( 3, Len( DF8->DF8_SERTMS ) )
			cQuery += 						" AND DUD.DUD_SERTMS IN ('1','3') "
		Else
			cQuery += 						" AND DUD.DUD_SERTMS = '" + DF8->DF8_SERTMS + "' "
		EndIf

		cQuery += 							" AND DUD.D_E_L_E_T_ = ' ' ) "

		cQuery := ChangeQuery(cQuery)

		DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry )

		While (cAliasQry)->(!Eof())
			//Para uma solicitação de coleta, pode ocorrer via painel de agendamento, programar uma Coleta já efetuada para digitação de Nota de Entrega
			If (cAliasQry)->DD9_SERIE <> 'COL' .Or. ((cAliasQry)->DD9_SERIE == 'COL' .And. DF8->DF8_SERTMS == StrZero( 1, Len( DF8->DF8_SERTMS ) ) )
	    		//---- Documento não disponível na Filial:	       
				Aadd(aVisErr,{STR0192 +" "+ (cAliasQry)->DD9_FILDOC + " - " + (cAliasQry)->DD9_DOC + " - " + (cAliasQry)->DD9_SERIE  })
	    	EndIf	
			(cAliasQry)->(dbSkip())
		EndDo

		(cAliasQry)->(dbCloseArea())
		
		If Len(aVisErr) > 0
			TmsMsgErr(aVisErr)
			lRet:= .F.
		EndIf
	EndIf	
		
	If lRet
		If FwIsInCallStack('T153GExec') .AND. lMostra == .F.
			lRet := .T.
		Else
			lRet := MsgYesNo( STR0017 ) //-- Confirma a efetivação da Programação? // Sim   // Não
		EndIf

		If lRet
			
			BEGIN TRANSACTION				
			// Criação da Viagem 
				If lRet
					If Empty(DF8->DF8_VIAGEM)
						RegToMemory("DTQ",.T.)

						nOpcViag   := 3
						// Ajusta SXE e SXF caso estejam corrompidos.
						cFilOri	:= M->DTQ_FILORI
						cViagem	:= M->DTQ_VIAGEM
						cMay	:= AllTrim(xFilial('DTQ')) + cFilOri + cViagem

						FreeUsedCode()
						DTQ->( DbSetOrder( 2 ) )

						While DTQ->( MsSeek(xFilial('DTQ') + cFilOri + cViagem ) ) .OR. !MayIUseCode(cMay)
							ConfirmSx8()
							cViagem := CriaVar("DTQ_VIAGEM")
							FreeUsedCode()
							cMay := AllTrim(xFilial('DTQ')) + cFilOri + cViagem
						EndDo
						
						M->DTQ_FILORI := cFilOri
						M->DTQ_VIAGEM := cViagem

						RestArea( aAreaDTQ )
						
					Else
						If DTQ->( dbSeek(FwxFilial("DTQ") + DF8->DF8_VIAGEM ) ) 
							RegToMemory("DTQ",.F.)
							nOpcViag   := 4
						Else
							RecLock( "DF8", .F. )
								DF8->DF8_VIAGEM := 	CriaVar('DF8_VIAGEM',.F.)		
							DF8->(MsUnLock())						
							
							RegToMemory("DTQ",.T.)
							nOpcViag   := 3
						EndIf
					EndIf
					
					M->DTQ_SERTMS	:= If( lHasViaM3 .AND. DF8->DF8_SERTMS == "1", "3", DF8->DF8_SERTMS )

					If Empty(cTipTra)
						cTipTra		:= DF8->DF8_TIPTRA
					EndIf

					M->DTQ_TIPTRA	:= cTipTra
					M->DTQ_SERADI	:= If( lSerAdi, '1', '0' )
					
					// Busca de Veiculos da Viagem 
					DDZ->(dbSetOrder(1))
					If	DDZ->(DbSeek( cSeek := FwxFilial('DDZ')+ DF8->DF8_FILORI + DF8->DF8_NUMPRG + DF8->DF8_SEQPRG ))
						While DDZ->( ! Eof() .And. DDZ->DDZ_FILIAL + DDZ->DDZ_FILORI + DDZ->DDZ_NUMPRG + DDZ->DDZ_SEQPRG  == cSeek )
							
							aAdd( aVeiculos, { DDZ->DDZ_CODVEI, { DDZ->DDZ_CODRB1, DDZ->DDZ_CODRB2, DDZ->DDZ_CODRB3 } } )
							
							DDZ->(DbSkip())
						EndDo
					EndIf	
					
					//--Busca o Motorista
					If lHasDLS
						DLS->(dbSetOrder(1))								
						If	DLS->(DbSeek( cSeek := FwxFilial('DLS')+ DF8->DF8_FILORI + DF8->DF8_NUMPRG + DF8->DF8_SEQPRG ))						
							While DLS->( ! Eof() .And. DLS->DLS_FILIAL + DLS->DLS_FILORI + DLS->DLS_NUMPRG + DLS->DLS_ITEDF8  == cSeek )							
								//--Estrutura da DLS Motorista. 
								Aadd(aMotPrg, { { DLS->DLS_FILIAL, DLS->DLS_FILORI, DLS->DLS_NUMPRG, DLS->DLS_ITEDF8, DLS->DLS_CODVEI, DLS->DLS_CODMOT, DLS->DLS_TIPMOT, DLS->DLS_CONDUT, DLS->DLS_FORADT, DLS->DLS_IDOPE, DLS->DLS_FORPAG, DLS->DLS_QTDTRA, DLS->DLS_TPSPDG } } )
								DLS->(DbSkip())
							EndDo
						EndIf
					EndIf	
					
					// Gera o Complemento
					lRet:= TMSA146Com(	@aCompViag, .F., , nOpcViag, , DF8->DF8_FILORI, DF8->DF8_DATGER, DF8->DF8_HORGER, DF8->DF8_ROTA, ;
										DF8->DF8_SERTMS, DF8->DF8_VIAGEM, DF8->DF8_FILVGE, DF8->DF8_NUMVGE, aVeiculos, aMotPrg )
					If !lRet
						lComplem := lRet := TMSA146Com( @aCompViag, lMostra, , nOpcViag, , DF8->DF8_FILORI, DF8->DF8_DATGER, DF8->DF8_HORGER, DF8->DF8_ROTA, ;
														DF8->DF8_SERTMS, DF8->DF8_VIAGEM, DF8->DF8_FILVGE, DF8->DF8_NUMVGE, aVeiculos, aMotPrg )
					EndIf
					
					// Gera a Viagem
					If lRet
						aAreaAnt	:= Getarea()
						lRet		:= T146GrvVge(	nOpcViag, DF8->DF8_ROTA, DF8->DF8_FILORI, DF8->DF8_VIAGEM, DF8->DF8_SERTMS, ;
													DF8->DF8_DATGER, DF8->DF8_HORGER, aVeiculos, .F., aMotPrg, DF8->DF8_TIPTRA )
						If lRet
							RestArea(aAreaAnt)
							
							RecLock( "DF8", .F. )
								DF8->DF8_VIAGEM:= M->DTQ_VIAGEM
							DF8->(MsUnLock())
							
							//Atualiza o status do planejamento para Viagem Gerada 
							//Atualiza o saldo do contrato de demanda e da meta, retirando de programação e passando para em viagem
							If lMVITMSDMD .AND. DF8->(ColumnPos("DF8_PLNDMD")) > 0  .AND. FindFunction('TMSUpdDmd') .AND. !Empty(DF8->DF8_PLNDMD) //SUAVIZAÇÃO DEMANDAS
								TMSUpdDmd( DF8->DF8_PLNDMD, "3", 7 )
							EndIf
							// Atualiza os campos de Viagem Coligada		
							If Val(DF8->DF8_SEQPRG) == 1 
								aAreaDF8	:= DF8->(GetArea())

								DF8->(dbSetOrder(1))
								If DF8->(DbSeek( cSeek := FwxFilial('DF8')+ cFilDF8 + cNumDF8 ) )
									While DF8->( ! Eof() .And. DF8->DF8_FILIAL + DF8->DF8_FILORI + DF8->DF8_NUMPRG == cSeek )
										If Val(DF8->DF8_SEQPRG)  > 1
											RecLock( "DF8", .F. )
												DF8->DF8_FILVGE:= M->DTQ_FILORI
												DF8->DF8_NUMVGE:= M->DTQ_VIAGEM
											DF8->( MsUnLock() )
										EndIf		
										DF8->( DbSkip() )
									EndDo
								EndIf
								RestArea(aAreaDF8)
							EndIf
							
							// Atualia Viagem na DDZ
							DDZ->(dbSetOrder(1))
							If	DDZ->(DbSeek( cSeek := FwxFilial('DDZ')+ DF8->DF8_FILORI + DF8->DF8_NUMPRG + DF8->DF8_SEQPRG ))
								While DDZ->( ! Eof() .And. DDZ->DDZ_FILIAL + DDZ->DDZ_FILORI + DDZ->DDZ_NUMPRG + DDZ->DDZ_SEQPRG  == cSeek )
									RecLock('DDZ',.F.)
										DDZ->DDZ_VIAGEM := M->DTQ_VIAGEM
									DDZ->(MsUnLock())		
															
									DDZ->(DbSkip())
								EndDo
							EndIf
																
							nOpcViag := 4
						EndIf
					EndIf
					
					// Chama a Rotina de Pagadores e de Roteiro
					If lRet
						
						// Verifica Rota de Roteiro
						lRoteiro := Empty(DF8->DF8_ROTA) .Or. F11RotRote(DF8->DF8_ROTA)

						lRet:= TMSA146Lot(.F.)   //-- Aglutina os Lotes mas não calcula, antes de chamar a Pagadores
					 	
						cAliasPag := GetNextAlias() 
						cQryPag := A146QryPag( DF8->DF8_FILORI, DF8->DF8_NUMPRG, DF8->DF8_SEQPRG )
						If !Empty(cQryPag)
						
							// Executa a Query para retornar os dados para Rotina de Pagadoes
							cQryPag := ChangeQuery(cQryPag)
							
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryPag),cAliasPag)
							
							// Monta array de registro para pagadores
							While (cAliasPag)->(!Eof())
								
								If (cAliasPag)->TABELA == "DTC"
									lDTCPag := .T.
								ElseIf(cAliasPag)->TABELA == "DT5"
									lDT5Pag := .T.
								EndIf
								
								 AADD(aTabRec,{(cAliasPag)->TABELA,(cAliasPag)->RECNO})
								(cAliasPag)->(dbSkip())			
							EndDo
							(cAliasPag)->(dbCloseArea())
							
							// Possui Serviço adicional
							If (lDTCPag .AND. lDT5Pag) .OR. (DF8->DF8_SERTMS == "3" .AND. lDT5Pag)
								cSrvAdc := "1"
							EndIf
						
							// Carrega aCols dos pagadores de frete
							aRetPag := TMSF79Cols(aTabRec,DF8->DF8_SERTMS,DF8->DF8_TIPTRA,"2",cSrvAdc,M->DTQ_FILORI,M->DTQ_VIAGEM,nOpcViag)
							           
							// Chama a Função de Tela de Pagadores
							aRetTela := TMSF79Tela(Aclone(aRetPag[1]),Aclone(aRetPag[2]),.T.,M->DTQ_FILORI,M->DTQ_VIAGEM,nOpcViag,DF8->DF8_SERTMS,cSrvAdc)
							
						    If  Len(aRetTela) > 0 //-- Executa a View (Nesta Rotina Não Existe o Browse Inicial Padrão MVC )
					    		If DF8->DF8_SERTMS != "2" // Chama a Rota para Entrega e Coleta - Rota Automatica 
						    		
									If lRoteiro
										If Len(aRetTela[5]) > 0
											TMSAF12Inc(aRetTela[5],DF8->DF8_SERTMS,M->DTQ_FILORI,M->DTQ_VIAGEM)
										
											//--Chama Função do TMSAF12 que retornará a rota utilizada
											aRoteiros := TF12RetRot(2)
											
											If Len(aRoteiros) > 0
												cRota := aRoteiros[1][1]
											Else
												lRet := .F.
											EndIf	
										Else
											lRet := .F.
										EndIf
									EndIf
								Else
									
									// Chama a Rota para Transferencia 
									cRota := A146RotTrf( DF8->DF8_ROTA, DF8->DF8_TIPTRA, Len(aTabRec), DF8->DF8_SERTMS )
									
									If Empty(cRota)
										lRet := .F.
									EndIf
									
								EndIf
								
								If lRet .AND. !lHasViaM3
									// Altera a Viagem para a gravação do Roteiro
									lRet := T146GrvVge(4,DF8->DF8_ROTA,DF8->DF8_FILORI,DF8->DF8_VIAGEM,DF8->DF8_SERTMS,;
										DF8->DF8_DATGER,DF8->DF8_HORGER, ,.F., ,DF8->DF8_TIPTRA)
									If lRet
										// Chama a Rotina de Criação de Lotes
										TMSF79Lot(aRetTela[4],DF8->DF8_FILORI,DF8->DF8_VIAGEM,.T.,"2")
										TMSF79Lot(aRetTela[4],DF8->DF8_FILORI,DF8->DF8_VIAGEM,.T.,"3")
										
										// Abre a Tela para Digitação das Notas
										TMSF79Nota(Aclone(aRetTela[4]))
										
										// Atualiza a Rota da Programação
										If !Empty(cRota) .AND. DF8->DF8_ROTA != cRota
											RecLock("DF8", .F.)  
												DF8->DF8_ROTA := cRota
												DF8->DF8_TIPTRA:= Posicione('DA8',1,xFilial('DA8')+ cRota,'DA8_TIPTRA')
											DF8->(MsUnLock())
										EndIf
									EndIf
								EndIf
							
							Else
								lRet := .F.
							EndIf
						Else
							lRet := .F.
						EndIf
					EndIf
					
					If 	lRet .AND. !lComplem
						lRet := TMSA146Com(	@aCompViag,lMostra,,nOpcViag,,DF8->DF8_FILORI,DF8->DF8_DATGER,DF8->DF8_HORGER,;
											DF8->DF8_ROTA,DF8->DF8_SERTMS,DF8->DF8_VIAGEM,DF8->DF8_FILVGE,DF8->DF8_NUMVGE)
						If lRet
							If __lSX8 
								ConfirmSX8()
							EndIf
						Else
							DTQ->(RollbackSx8())
						EndIf
					
					EndIf

					If lRet
						//--- Verifica Bloqueios da Viagem
						If lTmsa029 
							If Tmsa029Use("TMSA140")  
								DTQ->( dbSetOrder( 2 ) )
								If DTQ->( MsSeek( xFilial('DTQ') + DF8->DF8_FILORI + DF8->DF8_VIAGEM ) )
									cStReg := Tmsa029Blq( 9  ,'TMSA140', ''  ,DTQ->DTQ_FILORI, 'DTQ' , '1' ,DTQ->(DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM), DTQ->DTQ_VIAGEM , "" )
								EndIf
								If !Empty(cStReg) .And. cStReg $ ("B|P")  //B= Bloqueado Totalmente ou P= Parcialmente Liberado
									lRet:= .F.	
								EndIf	
							EndIf
							
							//--- Verifica Bloqueios do Lote que nao calcularam devido ao bloqueio de RRE/Incompatibilidade
							If lRet  .And. Tmsa029Use("TMSA200")  
								cStReg:= ""
								cAliasQry := GetNextAlias()
								cQuery := " SELECT DISTINCT DTC_FILORI, DTC_LOTNFC "
								cQuery += " FROM " + RetSqlName("DD9") + " DD9 "
								cQuery += 			" INNER JOIN " + RetSqlName("DTC") + " DTC "
								cQuery += 						" ON DTC.DTC_FILIAL  = '" + xFilial("DTC") + "' "
								cQuery += 						" AND DTC.DTC_CLIREM = DD9.DD9_CLIREM "
								cQuery += 						" AND DTC.DTC_LOJREM = DD9.DD9_LOJREM "
								cQuery += 						" AND DTC.DTC_NUMNFC = DD9.DD9_NUMNFC "
								cQuery += 						" AND DTC.DTC_SERNFC = DD9.DD9_SERNFC "
								cQuery += 						" AND DTC.D_E_L_E_T_ = ' ' "	
								cQuery += " WHERE DD9.DD9_FILIAL  = '" + xFilial("DD9") + "' "
								cQuery += 		" AND DD9.DD9_FILORI = '" + DF8->DF8_FILORI + "' "
								cQuery += 		" AND DD9.DD9_NUMPRG = '" + DF8->DF8_NUMPRG + "' "
								cQuery += 		" AND DD9.DD9_SEQPRG = '" + DF8->DF8_SEQPRG + "' "
								cQuery += 		" AND DD9.DD9_DOC = ' ' " 
								cQuery += 		" AND DD9.D_E_L_E_T_ = ' ' "

								If !cDbType $ "MSSQL|MSSQL7|ORACLE"
									cQuery := ChangeQuery(cQuery)
								EndIf

								DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry )

								While (cAliasQry)->(!Eof())
									DTP->(dbSetOrder(2))
									If DTP->(MsSeek(xFilial("DTP")+(cAliasQry)->DTC_FILORI+(cAliasQry)->DTC_LOTNFC))
										cStReg := Tmsa029Blq( 9  ,'TMSA200', ''  ,DTP->DTP_FILORI, 'DTP' , '1' ,DTP->(DTP_FILIAL + DTP_LOTNFC), DTP->DTP_LOTNFC , "" )

										If !Empty(cStReg) .And. cStReg $ ("B|P")  //B= Bloqueado Totalmente ou P= Parcialmente Liberado
											lRet:= .F.
											Exit
										EndIf

									EndIf
									(cAliasQry)->(dbSkip())
								EndDo
								(cAliasQry)->(dbCloseArea())
							EndIf

							If !lRet
								Help( ' ', 1, 'TMSA14633') //Não é possível efetivar a Programação. Existem bloqueios pendentes para liberação.
							EndIf
						EndIf
					EndIf
					If !lRet
						DisarmTransaction()
						Break
					EndIf
				EndIf	
			END TRANSACTION		
						
			If lRet //Operação realizada fora de transação devido a transmissão automatic. de Cte que não pode estar em transação.
				lRet:= TMSA146Lot(.T.)   //Aglutina e ou Calcula Lote
				If !lRet
				
				   // Estorna o Complemento                                     
				   TMSA146Com(@aCompViag,.F.,,5,,DF8->DF8_FILORI,DF8->DF8_DATGER,DF8->DF8_HORGER,DF8->DF8_ROTA,DF8->DF8_SERTMS,DF8->DF8_VIAGEM)
				
				   //Estorna Efetiavação realizada em transação
				   TMSA146Est(.F.)
				   DTQ->(RollbackSx8())
				   
					Help( ' ', 1, 'TMSA14634') //Não é possível efetivar a Programação, pois o Lote não foi calculado. 
				EndIf
			EndIf		
			
			If lRet
				For nCntFor := 1 To Len(aCompViag[2])
					If !aCompViag[2][nCntFor][Len(aCompViag[1])+1]
						If Len(aCompViag[4]) > 0
						For nCnt := 1 To Len(aCompViag[4])
								If Empty(aCompViag[4][nCnt][2][1][Ascan(aCompViag[3],{|x| x[2] == 'DUP_CODMOT'})])
									lRet := .F.
									Help('',1,'TMSA14613') // "Não é possivel efetivar uma programação de carregamento, sem informar o motorista que executará a viagem!"
								ElseIf aCompViag[4][nCnt][2][1][Ascan(aCompViag[3],{|x| x[2] == 'DUP_CODMOT'})] == cCodMot					   
									lRet := .F.
									Help('',1,'TMSA14609') // "Não é possivel efetivar uma programação de carregamento, com motorista genérico!"
								EndIf
							Next nCnt
						Else
							lRet := .F.
							Help('',1,'TMSA14613') // "Não é possivel efetivar uma programação de carregamento, sem informar o motorista que executará a viagem!"
						EndIf  
						
						If lRet
							cCodVei := aCompViag[2][nCntFor][Ascan(aCompViag[1],{|x| x[2] == 'DTR_CODVEI'})]
							If	cCodVei == cVeiGen
								lRet := .F.
								Help('',1,'TMSA14608') // "Não é possivel efetivar uma programação de carregamento, com veículo genérico!"
							EndIf

							If lRet
								If	Empty(cCodVei)
									lRet := .F.
									Help('',1,'TMSA14612') // "Não é possivel efetivar uma programação de carregamento, sem informar o veículo que executará a viagem!"
								EndIf
							EndIf

							If lContVei .And. lRet
								If Posicione( 'DA3', 1, xFilial( 'DA3' ) + cCodVei, 'DA3_STATUS' ) <> '2'
									lRet := .F.
									Help('',1,'TMSA14607') // "O veículo selecionado para efetuar a viagem, não está na filial!"
								EndIf
							EndIf
						EndIf
					EndIf
				Next nCntFor
				
				If !lRet //Estorna Efetiavação realizada em transação
					TMSA146Est(.F.)
					DTQ->(RollbackSx8())
				EndIf
			EndIf
		  	
			If lRet
				TMSA146GRV(,,6,aCompViag)  //Efetivar
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aAreaDUP )	
RestArea( aArea )

Return lRet


/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA146LotºAutor  ³ Katia              ºData  ³ 10/02/11     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Preparação de NF´s                                          º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA146Lot(lCalcula)
Local lTM146Lot   := ExistBlock("TM146Lot")
Local lRet        := .T.
Local cAliasDD9   := ""
Local cQuery      := ""
Local aListBox    := {}
Local nPos        := 0
Local aLotes      := {}
Local nLotes      := 0
Local nTipoLote   := 3   //1- Normal, 2-Refaturamento,3-Eletronico  (4-Cte Unico nao considera, pois somente é gerado pelo EXPRESS)
Local nCont       := 0
Local aListDocs   := {}
Local aLotesRat   := {}
Local aRetPELot   := {}

Default lCalcula  := .T.   //.F. - Somente irá agrupar os Lotes que nao sao de Rateio antes de enviar para a rotina de Pagadores

Private cCadastro	:= 'Selecionar Lotes'

For nCont:= 1  To nTipoLote    //Para o agrupamento de lote, precisa estar separado por tipo de lote
	aListBox  := {}
	aLotes    := {}
	aLotesRat := {}
		
	cAliasDD9 := GetNextAlias()
	cQuery := " SELECT DISTINCT DTC_FILORI, DTC_LOTNFC, DTP_FILORI, DTP_LOTNFC, DTP_DATLOT, DTP_HORLOT, DTP_QTDLOT, DTP_STATUS, "
	cQuery += 			" DTP_TIPLOT, DTP_QTDDIG, DTP_RATEIO, DTC_NUMNFC, DTC_SERNFC, DTC_CLIREM, DTC_LOJREM "
	cQuery += " FROM " + RetSqlName("DD9") + " DD9 "
	cQuery += 		" JOIN " + RetSqlName("DTC") + " DTC "
	cQuery += 				" ON DTC.DTC_FILIAL  = '" + xFilial("DTC") + "' "
	cQuery += 				" AND DTC.DTC_CLIREM = DD9.DD9_CLIREM "
	cQuery += 				" AND DTC.DTC_LOJREM = DD9.DD9_LOJREM "
	cQuery += 				" AND DTC.DTC_NUMNFC = DD9.DD9_NUMNFC "
	cQuery += 				" AND DTC.DTC_SERNFC = DD9.DD9_SERNFC "
	cQuery += 				" AND DTC.D_E_L_E_T_ = ' ' "
	cQuery += 		" JOIN " + RetSqlName("DTP") + " DTP "
	cQuery += 				" ON DTP.DTP_FILIAL  = '" + xFilial("DTP") + "' "
	cQuery += 				" AND DTP.DTP_FILORI = DTC.DTC_FILORI "
	cQuery += 				" AND DTP.DTP_LOTNFC = DTC.DTC_LOTNFC "
	cQuery += 				" AND DTP.DTP_TIPLOT =  '" + cValToChar(nCont) + "'"
	cQuery += 				" AND DTP.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DD9.DD9_FILIAL  = '" + xFilial("DD9") + "' "
	cQuery += 		" AND DD9.DD9_FILORI = '" + DF8->DF8_FILORI + "' "
	cQuery += 		" AND DD9.DD9_NUMPRG = '" + DF8->DF8_NUMPRG + "' "
	cQuery += 		" AND DD9.DD9_SEQPRG = '" + DF8->DF8_SEQPRG + "' "
	cQuery += 		" AND DD9.DD9_DOC = ' '  "
	cQuery += 		" AND DD9.D_E_L_E_T_ = ' ' "

	If !cDbType $ "MSSQL|MSSQL7|ORACLE"
		cQuery := ChangeQuery(cQuery)
	EndIf

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDD9)

	While (cAliasDD9)->(!Eof())
		If 	(cAliasDD9)->DTP_RATEIO <>  StrZero(1, Len(DTP->DTP_RATEIO)) //Lote Rateio nao deve haver agrupamento de lotes
			Aadd(aListBox,Array(NROCPOS))
			
			nPos:= Ascan(aLotes, { |x| x[1]+x[2] ==  (cAliasDD9)->DTP_FILORI+(cAliasDD9)->DTP_LOTNFC })
			If nPos == 0
				Aadd(aLotes,{(cAliasDD9)->DTP_FILORI,(cAliasDD9)->DTP_LOTNFC,(cAliasDD9)->DTP_TIPLOT,(cAliasDD9)->DTP_STATUS,(cAliasDD9)->DTP_QTDDIG,(cAliasDD9)->DTP_RATEIO })
			EndIf
		
			aListBox[Len(aListBox),LTMARCA]  := '1'
			aListBox[Len(aListBox),LTCORBRW] := Nil
			aListBox[Len(aListBox),LTFILORI] := (cAliasDD9)->DTP_FILORI
			aListBox[Len(aListBox),LTLOTNFC] := (cAliasDD9)->DTP_LOTNFC
			aListBox[Len(aListBox),LTDATLOT] := (cAliasDD9)->DTP_DATLOT
			aListBox[Len(aListBox),LTHORLOT] := Transform((cAliasDD9)->DTP_HORLOT,X3Picture("DTP_HORLOT"))
			aListBox[Len(aListBox),LTQTDLOT] := (cAliasDD9)->DTP_QTDLOT
			aListBox[Len(aListBox),LTTIPLOT] := (cAliasDD9)->DTP_TIPLOT
			aListBox[Len(aListBox),LTSTALOT] := (cAliasDD9)->DTP_STATUS
			aListBox[Len(aListBox),LTRATEIO] := ""
			aListBox[Len(aListBox),LTBACRAT] := "" 
			aListBox[Len(aListBox),LTCRIRAT] := "" 
			aListBox[Len(aListBox),LTPRORAT] := "" 
			aListBox[Len(aListBox),LTORIRAT] := "" 
			aListBox[Len(aListBox),LTCALRAT] := "" 
			aListBox[Len(aListBox),LTTABRAT] := "" 
			aListBox[Len(aListBox),LTTIPRAT] := "" 
			aListBox[Len(aListBox),LTTPLOTE] := (cAliasDD9)->DTP_TIPLOT
			aListBox[Len(aListBox),LTNUMNFC] := (cAliasDD9)->DTC_NUMNFC
			aListBox[Len(aListBox),LTSERNFC] := (cAliasDD9)->DTC_SERNFC
			aListBox[Len(aListBox),LTCLIREM] := (cAliasDD9)->DTC_CLIREM
			aListBox[Len(aListBox),LTLOJREM] := (cAliasDD9)->DTC_LOJREM
		Else
			nPos:= Ascan(aLotesRat, { |x| x[1]+x[2] ==  (cAliasDD9)->DTP_FILORI+(cAliasDD9)->DTP_LOTNFC })
			If nPos == 0
				Aadd(aLotesRat,{(cAliasDD9)->DTP_FILORI,(cAliasDD9)->DTP_LOTNFC,(cAliasDD9)->DTP_TIPLOT,(cAliasDD9)->DTP_STATUS,(cAliasDD9)->DTP_QTDDIG,(cAliasDD9)->DTP_RATEIO })
			EndIf	
		EndIf
		(cAliasDD9)->( DbSkip() )
	EndDo

	(cAliasDD9)->( DbCloseArea() )
	
	If Len(aLotes) > 0 .Or. Len(aLotesRat) > 0
		
		// Chamada de Ponto de entrada 
		If lTM146Lot
			aRetPELot := ExecBlock("TM146Lot",.F.,.F., Aclone(aLotes))
			If Valtype(aRetPELot) == "A" .AND. Len(aRetPELot) > 0
				aLotes := Nil
				ACopy(aRetPELot,aLotes)
			EndIf
		EndIf
		
		aRetPELot := {}
		// Chamada de Ponto de entrada 
		If lTM146Lot
			aRetPELot := ExecBlock("TM146Lot",.F.,.F., Aclone(aLotesRat))
			If Valtype(aRetPELot) == "A" .AND. Len(aRetPELot) > 0
				aLotesRat := Nil
				ACopy(aRetPELot,aLotesRat)
			EndIf
		EndIf

		If lCalcula .And. ((IsInCallStack("TMSAF76") .AND. DF8->DF8_SERTMS != '2') .Or.  Len(aLotesRat) > 0) //Lotes de Rateio calcula e nao há agrupamento de lotes 
			// Realiza o Calculo do Lote sem Rateio
			If Len(aLotes) > 0  
				Processa( {|lEnd| lRet := T200APrpLt(aLotes,1) }, STR0149, STR0150, .F. )     //Calcula todos os Lotes
			EndIf
			
			// Realiza o Calculo do Lote com Rateio	 
			If Len(aLotesRat) > 0  
				Processa( {|lEnd| lRet := T200APrpLt(aLotesRat,1) }, STR0149, STR0150, .F. )   //Calcula o Lote de Rateio			
			EndIf	 
		Else
			//--- Lotes sem Rateio
			nLotes:= Len(aLotes)
			If lRet .And. lCalcula .And. nLotes == 1 .And. Len(aListBox) == aLotes[1][5]  
				Processa( {|lEnd| lRet := T200AProc(aListBox,1,,.T.) }, STR0149, STR0150, .F. ) 
			ElseIf lRet .And. (nLotes <> 1 .Or. Len(aListBox) <> aLotes[1][5])
				If Len(aLotes) > 0 
					A146QrbLot(@aLotes,DF8->DF8_FILORI,DF8->DF8_NUMPRG,DF8->DF8_SEQPRG)
				EndIf
				If Len(aLotesRat) > 0 
					A146QrbLot(@aLotesRat,DF8->DF8_FILORI,DF8->DF8_NUMPRG,DF8->DF8_SEQPRG)
				EndIf

				Processa( {|lEnd| lRet := T200AProc(@aListBox,5,,.T.) }, STR0149, STR0150, .F. ) 
				If lRet .And. lCalcula
					aListDocs:= aClone(aListBox) 
					//--- Prepara o aListBox no formato para Calcular o Frete
					aListBox:= {}
					For nCont:= 1 To Len(aListDocs)
						nPos:= Ascan(aListBox, { |x| x[LTFILORI]+x[LTLOTNFC] ==  aListDocs[nCont,LTFILORI]+aListDocs[nCont,LTLOTNFC] })
						If nPos == 0
							Aadd(aListBox,Array(NROCPOS))
							aListBox[Len(aListBox),LTMARCA]  := '1'
							aListBox[Len(aListBox),LTCORBRW] := Nil
							aListBox[Len(aListBox),LTFILORI] := aListDocs[nCont,LTFILORI]
							aListBox[Len(aListBox),LTLOTNFC] := aListDocs[nCont,LTLOTNFC]
							aListBox[Len(aListBox),LTDATLOT] := aListDocs[nCont,LTDATLOT]
							aListBox[Len(aListBox),LTHORLOT] := aListDocs[nCont,LTHORLOT]
							aListBox[Len(aListBox),LTQTDLOT] := aListDocs[nCont,LTQTDLOT]
							aListBox[Len(aListBox),LTTIPLOT] := aListDocs[nCont,LTTIPLOT]
							aListBox[Len(aListBox),LTSTALOT] := aListDocs[nCont,LTSTALOT] 
						EndIf	
					Next nCont

					Processa( {|lEnd| lRet := T200AProc(aListBox,1,,.T.)  }, STR0149, STR0150, .F. )
				EndIf
			EndIf
		EndIf
		
		//--- Verifica se todas as notas foram calculadas
		If lCalcula
			lRet := T146AtuDoc( DF8->DF8_FILORI, DF8->DF8_NUMPRG, DF8->DF8_SEQPRG )
		EndIf
	EndIf
Next nCont

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMSA146PAE   ³ Marcelo CorrÊa Coutinho   º Data ³  07/11/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Classifica Prioridade no Agendamento de Entrega             º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA146                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSA146PAE(aPriorAGD,dDatAGD)

Local nI
Local nPosPri  := 0
Local nDiasPri := 0
Local cCorPri  := ''
Local cTipPri  := ''

If Empty(dDatAGD)
	cTipPri := "04"
	nPosPri := Ascan( aPriorAGD, { |x| x[PE_TIPPRI] == cTipPri} )

	If nPosPri > 0
		cCorPri := aPriorAGD[nPosPri,PE_CORPRI]
	EndIf
Else
	If dDatAGD == dDatabase
		cTipPri := "02"
		nPosPri := Ascan( aPriorAGD, { |x| x[PE_TIPPRI] == cTipPri} )

		If nPosPri > 0
			cCorPri := aPriorAGD[nPosPri,PE_CORPRI]
		EndIf
	ElseIf dDatAGD < dDatabase
      cTipPri  := "01"
		nDiasPri := ( dDatabase - dDatAGD )
	Else
      cTipPri  := "03"
         nDiasPri := ( dDatAGD - dDatabase )
	EndIf
EndIf

If cTipPri $ "01;03"
  	cCorPri := ""
	For nI := 1 To Len(aPriorAGD)
		If aPriorAGD[nI,PE_TIPPRI] == cTipPri
			If nDiasPri >= aPriorAGD[nI,PE_DEPRI] .And. nDiasPri <= aPriorAGD[nI,PE_ATEPRI]
  	        	cCorPri := aPriorAGD[nI,PE_CORPRI]
			EndIf
   		EndIf
	Next
EndIf
Return cCorPri

//-------------------------------------------------------------------
/*/{Protheus.doc} TM146LdTot
Totalizador
@author Katia
@since 11/08/2014
/*/
//-------------------------------------------------------------------
Static Function TM146LdTot(oMdl)
Local oStructT03 := oMdl:GetStruct()
Local aCamposT03 := aClone(oStructT03:GetFields())
Local aLoadT03   := {}
Local nY		   := 0

For nY := 1 To Len(aCamposT03)
	aAdd(aLoadT03,0)
Next nY
	
aCamposT03 := aSize(aCamposT03,0)
Return aLoadT03


//-------------------------------------------------------------------
/*/{Protheus.doc} TM146Total
Totalizadores dos documentos selecionados
@author Katia
@since 26/08/2014
/*/
//-------------------------------------------------------------------		
Static Function TM146Total(cAlias,cServTms,nQtdVol,nPeso,nPesoM3,nValMer,nValFre,nDoc,oModel,nDocRat)           

Default oModel  := FwModelActive()

oModel:LoadValue('MdTotal','T03_VOLUME', oModel:GetValue('MdTotal','T03_VOLUME')  + nQtdVol)
oModel:LoadValue('MdTotal','T03_PESO'  , oModel:GetValue('MdTotal','T03_PESO')    + nPeso)
oModel:LoadValue('MdTotal','T03_PESOM3', oModel:GetValue('MdTotal','T03_PESOM3')  + nPesoM3)
oModel:LoadValue('MdTotal','T03_VALOR' , oModel:GetValue('MdTotal','T03_VALOR')   + nValMer)
oModel:LoadValue('MdTotal','T03_VALFRE', oModel:GetValue('MdTotal','T03_VALFRE')  + nValFre)
	
If cAlias == 'DT6'
	oModel:LoadValue('MdTotal','T03_QTDDT',oModel:GetValue('MdTotal','T03_QTDDT')+ nDoc)
	
	If cServTms ==  StrZero( 1, Len(DTC->DTC_SERTMS))  //Coleta
		oModel:LoadValue('MdTotal','T03_QTDDTC',oModel:GetValue('MdTotal','T03_QTDDTC') + nDoc)
		oModel:LoadValue('MdTotal','T03_VOLDTC',oModel:GetValue('MdTotal','T03_VOLDTC') + nQtdVol)
		oModel:LoadValue('MdTotal','T03_PESDTC',oModel:GetValue('MdTotal','T03_PESDTC') + nPeso)
		oModel:LoadValue('MdTotal','T03_PM3DTC',oModel:GetValue('MdTotal','T03_PM3DTC') + nPesoM3)
		oModel:LoadValue('MdTotal','T03_VLMDTC',oModel:GetValue('MdTotal','T03_VLMDTC') + nValMer)
		oModel:LoadValue('MdTotal','T03_VLFDTC',oModel:GetValue('MdTotal','T03_VLFDTC') + nValFre)
	ElseIf cServTms ==  StrZero( 2, Len(DTC->DTC_SERTMS))  //Transferencia
		oModel:LoadValue('MdTotal','T03_QTDDTT',oModel:GetValue('MdTotal','T03_QTDDTT') + nDoc)
		oModel:LoadValue('MdTotal','T03_VOLDTT',oModel:GetValue('MdTotal','T03_VOLDTT') + nQtdVol)
		oModel:LoadValue('MdTotal','T03_PESDTT',oModel:GetValue('MdTotal','T03_PESDTT') + nPeso)
		oModel:LoadValue('MdTotal','T03_PM3DTT',oModel:GetValue('MdTotal','T03_PM3DTT') + nPesoM3)
		oModel:LoadValue('MdTotal','T03_VLMDTT',oModel:GetValue('MdTotal','T03_VLMDTT') + nValMer)
		oModel:LoadValue('MdTotal','T03_VLFDTT',oModel:GetValue('MdTotal','T03_VLFDTT') + nValFre)
	ElseIf cServTms ==  StrZero( 3, Len(DTC->DTC_SERTMS))  //Entrega
		oModel:LoadValue('MdTotal','T03_QTDDTE',oModel:GetValue('MdTotal','T03_QTDDTE') + nDoc)
		oModel:LoadValue('MdTotal','T03_VOLDTE',oModel:GetValue('MdTotal','T03_VOLDTE') + nQtdVol)
		oModel:LoadValue('MdTotal','T03_PESDTE',oModel:GetValue('MdTotal','T03_PESDTE') + nPeso)
		oModel:LoadValue('MdTotal','T03_PM3DTE',oModel:GetValue('MdTotal','T03_PM3DTE') + nPesoM3)
		oModel:LoadValue('MdTotal','T03_VLMDTE',oModel:GetValue('MdTotal','T03_VLMDTE') + nValMer)
		oModel:LoadValue('MdTotal','T03_VLFDTE',oModel:GetValue('MdTotal','T03_VLFDTE') + nValFre)
	EndIf
		
Else
	oModel:LoadValue('MdTotal','T03_QTDDC',oModel:GetValue('MdTotal','T03_QTDDC')+nDoc)
	
	If cServTms ==  StrZero( 1, Len(DTC->DTC_SERTMS))  //Coleta
		oModel:LoadValue('MdTotal','T03_QTDDCC',oModel:GetValue('MdTotal','T03_QTDDCC') + nDoc)
		oModel:LoadValue('MdTotal','T03_VOLDCC',oModel:GetValue('MdTotal','T03_VOLDCC') + nQtdVol)
		oModel:LoadValue('MdTotal','T03_PESDCC',oModel:GetValue('MdTotal','T03_PESDCC') + nPeso)
		oModel:LoadValue('MdTotal','T03_PM3DCC',oModel:GetValue('MdTotal','T03_PM3DCC') + nPesoM3)
		oModel:LoadValue('MdTotal','T03_VLMDCC',oModel:GetValue('MdTotal','T03_VLMDCC') + nValMer)
		oModel:LoadValue('MdTotal','T03_VLFDCC',oModel:GetValue('MdTotal','T03_VLFDCC') + nValFre)
		
	ElseIf cServTms ==  StrZero( 2, Len(DTC->DTC_SERTMS))  //Transferencia
		oModel:LoadValue('MdTotal','T03_QTDDCT',oModel:GetValue('MdTotal','T03_QTDDCT') + nDoc)
		oModel:LoadValue('MdTotal','T03_VOLDCT',oModel:GetValue('MdTotal','T03_VOLDCT') + nQtdVol)
		oModel:LoadValue('MdTotal','T03_PESDCT',oModel:GetValue('MdTotal','T03_PESDCT') + nPeso)
		oModel:LoadValue('MdTotal','T03_PM3DCT',oModel:GetValue('MdTotal','T03_PM3DCT') + nPesoM3)
		oModel:LoadValue('MdTotal','T03_VLMDCT',oModel:GetValue('MdTotal','T03_VLMDCT') + nValMer)
		oModel:LoadValue('MdTotal','T03_VLFDCT',oModel:GetValue('MdTotal','T03_VLFDCT') + nValFre)
	ElseIf cServTms ==  StrZero( 3, Len(DTC->DTC_SERTMS))  //Entrega
		oModel:LoadValue('MdTotal','T03_QTDDCE',oModel:GetValue('MdTotal','T03_QTDDCE') + nDoc)
		oModel:LoadValue('MdTotal','T03_VOLDCE',oModel:GetValue('MdTotal','T03_VOLDCE') + nQtdVol)
		oModel:LoadValue('MdTotal','T03_PESDCE',oModel:GetValue('MdTotal','T03_PESDCE') + nPeso)
		oModel:LoadValue('MdTotal','T03_PM3DCE',oModel:GetValue('MdTotal','T03_PM3DCE') + nPesoM3)
		oModel:LoadValue('MdTotal','T03_VLMDCE',oModel:GetValue('MdTotal','T03_VLMDCE') + nValMer)
		oModel:LoadValue('MdTotal','T03_VLFDCE',oModel:GetValue('MdTotal','T03_VLFDCE') + nValFre)
	EndIf
	oModel:LoadValue('MdTotal','T03_QTDRAT',oModel:GetValue('MdTotal','T03_QTDRAT')+nDocRat)
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMS146CTe  ºAutor ³ Marcelo C. Coutinho  º Data ³  22/08/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monitor CT-e                                                º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA146                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA146CTe()

Local cFilDoc   := Posicione( 'DD9', 1, xFilial( 'DD9' ) + DF8->( DF8_FILORI + DF8_NUMPRG ), 'DD9_FILORI' )
Local cLotNFC   := Posicione( 'DTC', 5, xFilial( 'DTC' ) + DD9->( DD9_CLIREM + DD9_LOJREM + DD9_NUMNFC + DD9_SERNFC ), 'DTC_LOTNFC' )

SaveInter()

TMSAE70( 1, cFilDoc, cLotNFC,,,, 3, .T. )

RestInter()

If DF8->DF8_STATUS = '3' .AND. !Empty(cFilDoc) .And. !Empty(cLotNFC) 
	//Verifica se todos os documentos da Programação estão transmitidos para alterar o status.	
	If TM146DocTr( DF8->DF8_FILORI, DF8->DF8_NUMPRG, DF8->DF8_SEQPRG) 
		RecLock("DF8", .F.)    
		DF8->DF8_STATUS := "2"
		DF8->(MsUnLock())
	EndIf
EndIf		

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} TM146Cons
Consultas
@author Katia
@since 11/08/2014
/*/
//-------------------------------------------------------------------
Function TM146Cons(cTipo,cFilDoc,cDocto,cSerie,cNumNfc,cSerNfc,cCliRem,cLojRem)

Local aArea    := GetArea()
Local aAreaDT6 := DT6->(GetArea())

Default cFilDoc:= ""
Default cDocto := ""
Default cSerie := ""
Default cNumNfc:= ""
Default cSerNfc:= ""
Default cCliRem:= ""
Default cLojRem:= ""

Private cCadastro:='Manutencao de Documentos'
SaveInter()
If cTipo == 'D'
	DT6->(dbSetOrder(1))
	If DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDocto+cSerie))
		TMSA500Mnt('DT6',DT6->(Recno()),2)
	Else
		DTC->(DbSetOrder(2)) 
		If DTC->( DbSeek( xFilial('DTC')+ cNumNFC + cSerNFC + cCliRem + cLojRem ))
			TmsA050Mnt('DTC',DTC->(Recno()),2)
		EndIf	
	EndIf
ElseIf cTipo == 'V'
	TMSC060()
EndIf

RestInter()
RestArea(aAreaDT6)
RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TM146Edit
Edicao do campo
@author Katia
@since 11/08/2014
/*/
//-------------------------------------------------------------------
Function TM146Edit()
Local lRet      := .T.

If !IsInCallStack('TMSA146MNT')  .And.!lIncAuto
	lRet:= .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA146Sol
Nome do Solicitante
@author Katia
@since 11/08/2014
/*/
//-------------------------------------------------------------------
Function TMSA146Sol(cFilDoc,cDoc,cSerie,cNomeSol,aCliLoj, cTpFrete)
Local aArea      := GetArea()

Default cNomeSol := ""
Default aCliLoj  := {}
Default cTpFrete := ""
	
DT5->(dbSetOrder(1))
If DT5->(DbSeek(xFilial('DT5')+cFilDoc+cDoc+cSerie))
	cTpFrete := DT5->DT5_TIPFRE
	DUE->(dbSetOrder(1))
	If DUE->(MsSeek(xFilial('DUE')+DT5->(DT5_CODSOL)))
		cNomeSol:= DUE->DUE_NREDUZ
		If Empty(DT5->DT5_SEQEND) 
			If !Empty(DUE->DUE_CODCLI)
				aAdd(aCliLoj,{ DUE->DUE_CODCLI, DUE->DUE_LOJCLI })
			EndIf	
		Else
			DUL->(dbSetOrder(3))
			If DUL->(DbSeek(xFilial('DUL')+DT5->(DT5_CODSOL+DT5_SEQEND)))
				If !Empty(DUL->DUL_CODRED)
					aAdd(aCliLoj,{ DUL->DUL_CODRED, DUL->DUL_LOJRED })
				Else
					aAdd(aCliLoj,{ DUL->DUL_CODCLI, DUL->DUL_LOJCLI })
				EndIf
			EndIf						
		EndIf
	EndIf		
EndIf
	
RestArea(aArea)
Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA146Res
Restrição Cliente / Veiculo  
@author Katia
@since 21/01/2015
/*/
//-------------------------------------------------------------------
Function TMSA146Res(cTipRes,aCliLoj,aVeiRes,cRota,cData,cHora,aRestricao,aCepCli)
Local lRet       := .F.
Local aCepDeAte  := {}
Local nPosCliRst := 0

Default cTipRes   := ""   //C-Cliente ou V-Veiculo
Default aCliLoj   := {}
Default aVeiRes   := {}
Default cRota     := ""
Default cData     := ""
Default cHora     := ""
Default aRestricao:= {}
Default aCepCli   := {}

If lRestricao                            
	If !Empty(cRota)
		If cMVTMSRLC $ "2|3" // Por Faixa de Cep ou Ambos
			aCepDeAte	:= A023CepRot(cRota,.T.)
		EndIf
	EndIf	
	
	If cTipRes == "C"   //Cliente
		If nPosCliRst := Ascan( aCliRestri,{ |x| x[1] + x[2] == aCliLoj[1][1] + aCliLoj[1][2] } ) > 0
			aRestricao := aCliRestri[nPosCliRst][3]
		Else
			aRestricao :=  TMSRESTRI("C",,,aCliLoj,,'B',cData)
			AADD(aCliRestri,{aCliLoj[1][1] , aCliLoj[1][2], aRestricao})
		EndIf
		
		If Len(aRestricao) > 0
			If aRestricao[1]
				lRet:= .T.
			EndIf
		EndIf
		 	
	ElseIf cTipRes == "T"   //Cliente x Veiculo
		aRestricao :=  TMSRESTRI("T",aCepDeAte,cRota,aCliLoj,aVeiRes,'B',cData,,,aCepCli)   //B-Regras de Bloqueio
		
		If Len(aRestricao) > 0
			If Ascan( aRestricao[3], { |x| x[10] <> '' }) > 0  //Na 10a posicao contem o tipo do veiculo, se estiver preenchido indica que a restricao é por veiculo
				lRet:= .T.			
			EndIf 
		EndIf
	ElseIf cTipRes == "V"   //Veiculo
	
		aRestricao :=  TMSRESTRI("A",aCepDeAte,cRota,,aVeiRes,'B',cData,,,aCepCli)   //B-Regras de Bloqueio
		
		If Len(aRestricao) > 0
			If Ascan( aRestricao[3], { |x| x[10] <> '' }) > 0  //Na 10a posicao contem o tipo do veiculo, se estiver preenchido indica que a restricao é por veiculo
				lRet:= .T.			
			EndIf 
		EndIf
	EndIf
EndIf 				
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} T146MrkVei
Validacao dos veiculos selecionados
@author Katia
@since 28/01/2015
/*/
//-------------------------------------------------------------------
Static Function T146MrkVei()
Local oModel       := FWModelActive()   
Local oMdlGridDA3  := oModel:GetModel('MdGridDA3') 
Local lMark        := .F.
Local aSaveLine    := FWSaveRows()
Local cCatVei      := ""
Local lRet         := .T.
Local nCarTMS      := Iif(DTR->(ColumnPos("DTR_CODRB3")) > 0, 3, 2)
Local aAreaDA3     := DA3->(GetArea())

lMark:= oMdlGridDA3:GetValue( "DA3_MARK")       
FwClearHLP()
DA3->(dbSetOrder(1))
If DA3->(MsSeek(xFilial('DA3')+oMdlGridDA3:GetValue( "DA3_COD")))  
	cCatVei:= Posicione('DUT',1,xFilial('DUT')+DA3->DA3_TIPVEI,'DUT_CATVEI')
EndIf
	
If lMark
	If cCatVei == StrZero(2, Len(DUT->DUT_CATVEI)) //Cavalo
		oModel:GetModel():SetErrorMessage(,,,,,STR0157) //"Não é permitido carregar em veiculo da categoria 'Cavalo'. Selecione outro veiculo."
		lRet:= .F.
	ElseIf cCatVei == StrZero(3, Len(DUT->DUT_CATVEI)) 
		If nCarretas >= nCarTMS
			oModel:GetModel():SetErrorMessage(,,,,,STR0190) //'O numero de carretas selecionadas para este Cavalo, ultrapassou a quantidade permitida.'
			lRet:= .F.
		Else
			nCarretas+= 1
		EndIf			
	EndIf
Else
	If cCatVei == StrZero(3, Len(DUT->DUT_CATVEI)) 
		nCarretas-= 1
	EndIf	
EndIf

RestArea(aAreaDA3)
FWRestRows( aSaveLine )	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TM146ReCli
Restrição Cliente
@author Katia
@since 11/08/2014
/*/
//-------------------------------------------------------------------
Function TM146ReCli(cFilDoc,cDoc,cSerie,cCliDes,cLojDes,cSqeDes)

Local aCliLoj  := {}

Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""
Default cCliDes:= ""
Default cLojDes:= ""
Default cSqeDes:= ""
	
If cSerie <> 'COL'
	DUL->(dbSetOrder(2))
	If DUL->(DbSeek(xFilial('DUL')+ cCliDes + cLojDes + cSqeDes ))
		If !Empty(DUL->DUL_CODRED)
			If aScan(aCliLoj,{|x| x[1]+x[2] == DUL->DUL_CODRED + DUL->DUL_ }) == 0
				aAdd(aCliLoj,{ DUL->DUL_CODRED, DUL->DUL_LOJRED })
			EndIf
		EndIf
	EndIf
	If Empty(aCliLoj)
		aAdd(aCliLoj,{ cCliDes, cLojDes })
	EndIf
Else  
	TMSA146Sol(cFilDoc,cDoc,cSerie,,@aCliLoj)					
EndIf			

Return aCliLoj	

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA146Obs
Visualizacao dos dados da restricao 
@author Katia
@since 14/10/2014
/*/
//-------------------------------------------------------------------
Function TMSA146Obs( cParam )

Local oModel		:= FwModelActive()
Local oMdlGridDoc	:= oModel:GetModel("MdGridDoc")
Local oDlgObs		:= Nil
Local cNumTmp		:= If (!Empty(FwFldGet('DF8_NUMTMP')),FwFldGet('DF8_NUMTMP'),Space(Len(DF8->DF8_NUMPRG))) 
Local cNumPrg		:= If (!Empty(FwFldGet('DF8_NUMPRG')),FwFldGet('DF8_NUMPRG'),Space(Len(DF8->DF8_NUMPRG)))
Local lRet			:= .F.
Local nOpcao		:= 0
Local nCntFor		:= 0
Local cObsRes		:= ""
Local aVeiRes		:= {}
Local aCliLoj		:= {}
Local aCliRet		:= {}
Local aRestricao	:= {}

Default cParam		:= "R"

For nCntFor := 1 To oMdlGridDoc:Length()
	If !oMdlGridDoc:IsDeleted(nCntFor)
		oMdlGridDoc:GoLine(nCntFor)
		If (FwFldGet('T01_NUMTMP') == cNumTmp .Or. FwFldGet('T01_NUMPRG') == cNumPrg) .And. FwFldGet('T01_SEQPRG') == cSeqPrg 
			aCliRet:= TM146ReCli(FwFldGet('T01_FILDOC'),FwFldGet('T01_DOC'),FwFldGet('T01_SERIE'),FwFldGet('T01_CLIDES'),FwFldGet('T01_LOJDES'),FwFldGet('T01_SQEDES'))
			If aScan(aCliLoj,{|x| x[1]+x[2] == aCliRet[1][1] + aCliRet[1][2] }) == 0
				aAdd(aCliLoj,{ aCliRet[1][1], aCliRet[1][2] })     
			EndIf
		EndIf	
	EndIf	
Next         

aAdd(aVeiRes,FwFldGet('DF8_CODVEI'))

lRet:= Iif(lPesqRes,TMSA146Res("T",aCliLoj,aVeiRes,FwFldGet('DF8_ROTA'),DTOS(FwFldGet('DF8_DATGER')),FwFldGet('DF8_HORGER'),@aRestricao),.F.) 
If lRet
	cObsRes:= aRestricao[2]
	
	DEFINE MSDIALOG oDlgObs TITLE STR0146 FROM 15,20 TO 25,62 
	
	@ 0.5,0.7  GET oGet VAR cObsRes OF oDlgObs MEMO SIZE 150,40
	
	oGet :lReadOnly:= .T.
	
	DEFINE SBUTTON FROM 52,100 TYPE 1 OF oDlgObs ENABLE ACTION (nOpcao := 1,oDlgObs:End())
	DEFINE SBUTTON FROM 52,128 TYPE 2 OF oDlgObs ENABLE ACTION (nOpcao := 0,oDlgObs:End())
	
	ACTIVATE MSDIALOG oDlgObs CENTERED

EndIf
	
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA146AGD
Retorna o Codigo do Tipo de Agendamento (DTC_TIPAGD)
@author Katia
@since 17/03/2015
/*/
//-------------------------------------------------------------------
Function TMSA146AGD(MVPAR22, MVPAR23, cMV_PAR22,cMV_PAR23)

Default MVPAR22 := ""
Default MVPAR23 := ""
Default cMV_PAR22:= ""
Default cMV_PAR23:= ""

If MVPAR22 == 1      //Prioridade Cliente
	cMV_PAR22:= '0'
ElseIf MVPAR22 == 2  //Prioridade Transportador
 	cMV_PAR22:= '1'
ElseIf MVPAR22 == 3  //Cliente
 	cMV_PAR22:= '2'
ElseIf MVPAR22 == 4  //Transportador
 	cMV_PAR22:= '3'
ElseIf MVPAR22 == 5  //Aguardando Agendamento
	cMV_PAR22:= '4'
Else
	cMV_PAR22:= '4'
EndIf

If MVPAR23 == 1     //Prioridade Cliente
	cMV_PAR23:= '0'
ElseIf MVPAR23 == 2 //Prioridade Transportador
 	cMV_PAR23:= '1'
ElseIf MVPAR23 == 3 //Cliente
 	cMV_PAR23:= '2'
ElseIf MVPAR23 == 4 //Transportador
 	cMV_PAR23:= '3'
ElseIf MVPAR23 == 5 //Aguardando Agendamento
	cMV_PAR23:= '4'
Else	            
	cMV_PAR23:= '4'
EndIf

Return Nil


/*/-----------------------------------------------------------
{Protheus.doc} A146SrAdPn
Monta tela de exibição de Agendamentos à Confirmar

Uso: TMSA146

@sample
//A146SrAdPn()

@author Paulo Henrique Corrêa Cardoso.
@since 13/04/2016
@version 1.0
-----------------------------------------------------------/*/
Function A146SrAdPn()
Local aAreaBKP	:= GetArea()			// Recebe a Area Ativa
Local oDlg			:= Nil  				// Recebe o objeto da Dialog				
Local oListBox	:= Nil					// Recebe o objeto do ListBox
Local oCheck  	:= LoadBitmap( GetResources(), "CHECKED" )      // Legends : CHECKED  / LBOK  /LBTIK
Local oNoCheck	:= LoadBitmap( GetResources(), "UNCHECKED" )    // Legends : UNCHECKED /LBNO  
Local cQuery		:= ""					// Recebe a Query
Local cAliasQry	:= GetNextAlias()		// Recebe o proximo alias disponivel
Local lDiverg		:= .F.					// Recebe se há divergencia de tipo de Serviço de Transporte
Local nCntCol		:= 0					// Recebe o Contador de Coletas
Local nCntColEft	:= 0					// Recebe o Contador de Coletas Efetuadas
Local nCntEnt		:= 0					// Recebe o contado de Entregas	
Local nCntTrf		:= 0					// Recebe o contador de Transferencias
Local cSrvAdc		:= ""					// Recebe se o serviço adicional esta ativo
Local aGrid		:= {}					// Recebe os itens que serão exibidos na tela
Local cServic		:= ""					// Recebe a descrição do Serviço de Transporte
Local cMsg			:= ""					// Recebe a Mensagem que será exibida na tela

// Busca o parametro do Serviço Adicional
Pergunte("TMB144",.F.)
If Type("MV_PAR02") == "C"
	cSrvAdc := mv_par02
EndIf

// Recebe os dados do Pergunte da Programação
Pergunte('TMSA146',.F.)


// Monta a query para retornar os registros selecionados no Painel de Agendamento
cQuery += " SELECT DISTINCT DF1.DF1_NUMAGE "
cQuery += " 	,DF1.DF1_ITEAGE "
cQuery += " 	,DTC.DTC_SERTMS T01_SERTMS "
cQuery += " 	,DTC.DTC_FILDOC T01_FILDOC "
cQuery += " 	,DTC.DTC_DOC    T01_DOC "
cQuery += " 	,DTC.DTC_SERIE  T01_SERIE "
cQuery += " 	,DTC.DTC_FILCFS T01_FILCFS "
cQuery += " 	,DTC.DTC_NUMSOL T01_NUMSOL " 
cQuery += " FROM  "
cQuery += RetSqlName("DTC") + " DTC "

//--- CLAUSULA WHERE DO DTC
cQuery += T146SelDTC('D')	


cQuery += "  UNION ALL "

cQuery += " SELECT DISTINCT DF1.DF1_NUMAGE "
cQuery += " 	,DF1.DF1_ITEAGE "
cQuery += " 	   ,DT6.DT6_SERTMS T01_SERTMS "
cQuery += " 	   ,DT6.DT6_FILDOC T01_FILDOC  "
cQuery += " 	   ,DT6.DT6_DOC    T01_DOC     "
cQuery += " 	   ,DT6.DT6_SERIE  T01_SERIE   "
cQuery += " 	   , ' '           T01_FILCFS " 
cQuery += " 	   , ' '           T01_NUMSOL "

cQuery += "  FROM  " 
cQuery += RetSqlName("DUD") + " DUD "

cQuery+= " LEFT JOIN " + RetSqlname('DT6') + " DT6 " 
cQuery+= "   ON DT6_FILIAL = '" + xFilial('DT6') + "' "

//--- CLAUSULA WHERE DO DT6
cQuery += T146SelDT6('D')

If !cDbType $ "MSSQL|MSSQL7|ORACLE"
	cQuery := ChangeQuery(cQuery)
EndIf	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

dbSelectArea("DT5")
DT5->(dbSetOrder(1))

While (cAliasQry)->(!Eof())
	
	// Varifica o serviço de transporte do registro
	Do Case
		Case (cAliasQry)->T01_SERTMS == "1" 
			
			If DT5->( dbSeek(FwxFilial("DT5") + (cAliasQry)->T01_FILDOC + (cAliasQry)->T01_DOC ) )
			
				If DT5->DT5_STATUS $ "1|2" // Em Aberto ou Indicado para Coleta
					nCntCol += 1
					cServic := STR0173  	// "Coleta"
					
				ElseIf DT5->DT5_STATUS == "4" // Encerrada
					nCntColEft += 1
					cServic := "Coleta Efet."  	// "Coleta Efet."
				EndIf
				
			EndIf
			
		Case (cAliasQry)->T01_SERTMS  == "3"
	  		nCntEnt += 1
	  		cServic := STR0011 	//"Entrega"
	 	Case (cAliasQry)->T01_SERTMS  == "2" 
	 		nCntTrf += 1
	 		cServic := STR0010	//"Transporte"
	EndCase      
	
	// Preenche o array do Grid
	AADD(aGrid,{	 .T. ,;
					(cAliasQry)->DF1_NUMAGE,;
					(cAliasQry)->DF1_ITEAGE,;
					 cServic,;
					(cAliasQry)->T01_FILDOC,;
					(cAliasQry)->T01_DOC,;
					(cAliasQry)->T01_SERIE,;
					(cAliasQry)->T01_FILCFS,;
					(cAliasQry)->T01_NUMSOL } )   
		 
	(cAliasQry)->(dbSkip())
EndDo

// Veridica se permite mais de um tipo de doc.
If nCntCol > 0 .AND. nCntEnt > 0 .AND. cSrvAdc <> '1' // Coleta + Entrega  e Serviço Adicional
	lDiverg := .T.
	cMsg += STR0174 + CHR(10)+ CHR(13) //"Servico Adicional não está habilitado. Não é permitido selecionar Serviços de  (Coleta e Entrega)"
EndIf

If nCntCol > 0 .AND. nCntTrf > 0 // Coleta + Transferencia
	lDiverg := .T.
	cMsg += STR0175 + CHR(10)+ CHR(13) //"Não é permitido selecionar documentos com Servicos de Transporte diferentes. (Coleta e Transferencia)"
EndIf

If nCntColEft > 0 .AND.  nCntEnt > 0 .AND.  nCntTrf > 0
	lDiverg := .T.
	cMsg += STR0194 //"Não é permitido selecionar Entrega com Transferencia junto com uma coleta já efetuada."
EndIf

If nCntColEft > 0 .AND.  nCntCol > 0 
	lDiverg := .T.
	cMsg += STR0195 //"Não é permitido selecionar Coleta junto com uma coleta já efetuada."
EndIf

(cAliasQry)->(dbCloseArea())

// Caso exista divergencia, monta a tela
If lDiverg

	 dbSelectArea("DF0")
	 DF0->(dbSetOrder(1))
	
	 Define MSDialog oDlg title STR0176 From c( 180 ), c( 180 ) To c( 530 ), c( 910 ) Pixel //"Divergencias - Tipo de Serviço de Transporte."
	 // Chamadas das Listbox do Sistema
	 @  c( 005 ), c( 005 )Say   cMsg  PIXEL OF oDlg // 
	 @  c( 035 ), c( 005 )Say   STR0177  PIXEL OF oDlg // "Desmarque os itens que deseja remover."
	 @ c( 045 ), c( 005 ) ListBox oListBox Fields ;
	 Header "",STR0171,STR0172,STR0178,STR0179,STR0180,STR0181,STR0182,STR0183; //"Num. Agend."###"Item Agend."###"Serv. Transp."###"Fil. Doc."###"Doc."###"Serie"###"Fil. Sol."###"Num. Sol."
	 Size c( 360 ), c( 100 ) Of oDlg Pixel 
	 oListBox:SetArray( aGrid )
	 oListBox:bLine := {|| { 	If(aGrid[oListBox:nAt][1], oCheck , oNoCheck ),;
	 								aGrid[oListBox:nAt][2],;
									aGrid[oListBox:nAt][3],;
									aGrid[oListBox:nAt][4],;
									aGrid[oListBox:nAt][5],;
									aGrid[oListBox:nAt][6],;
									aGrid[oListBox:nAt][7],;
									aGrid[oListBox:nAt][8],;
									aGrid[oListBox:nAt][9]}}
									
	 oListBox:BLDBLCLICK := { ||	aGrid[oListBox:nAt][1] := !aGrid[oListBox:nAt][1], oListBox:Refresh()}
									 
	 // Cria componentes padroes do sistema
	 Define SButton From c( 160 ), c( 300 ) Type 2 Enable  Of oDlg Action (AF76CofAgd(aGrid,.F.,.T.),oDlg:End() ) // Cancela 
	 Define SButton From c( 160 ), c( 335 ) Type 1 Enable  Of oDlg Action (AF76CofAgd(aGrid,.F.,.F.),oDlg:End(),A146SrAdPn() ) // OK
	  
	 Activate MSDialog oDlg Centered
EndIf

RestArea(aAreaBKP)

Return


/*/-----------------------------------------------------------
{Protheus.doc} A146QryPag
Rotorna a Query para preenche o array de Pagadores

Uso: TMSA146

@sample
//A146QryPag(cFilDF8,cNumDF8)

@author Paulo Henrique Corrêa Cardoso.
@since 13/05/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function  A146QryPag(cFilDF8,cNumDF8,cSeqDF8)
Local cQryPag			:= ""			// Recebe a Query de Retorno
Local aAreaAtu		:= GetArea()	// Recebe a Area Atual

Default cFilDF8		:= ""			// Recebe a Filial da Programação
Default cNumDF8		:= ""			// Recebe o Numero da Programação
Default cSeqDF8		:= ""			// Recebe a Sequencia da Programação

If !Empty(cFilDF8) .AND. !Empty(cNumDF8) .AND. !Empty(cSeqDF8) 
	
	// Busca as Notas Selecionadas
	cQryPag += " SELECT  'DTC' TABELA									"
	cQryPag += " 		,DTC.R_E_C_N_O_ RECNO           				"
	
	cQryPag += " FROM " + RetSqlName("DD9") + " DD9   				"
	cQryPag += " INNER JOIN " + RetSqlName("DTC") + " DTC  			"
	cQryPag += " 	ON  DTC.DTC_FILIAL  = '"+ FwxFilial("DTC") + "'  "
	cQryPag += " 	AND DTC.DTC_CLIREM = DD9.DD9_CLIREM     			"
	cQryPag += " 	AND DTC.DTC_LOJREM = DD9.DD9_LOJREM       		"
	cQryPag += " 	AND DTC.DTC_NUMNFC = DD9.DD9_NUMNFC       		"
	cQryPag += " 	AND DTC.DTC_SERNFC = DD9.DD9_SERNFC       		"
	cQryPag += " 	AND DTC.D_E_L_E_T_ = ' ' 	              		"
	
	cQryPag += " WHERE DD9.DD9_FILIAL  = '"+ FwxFilial("DD9") + "' "
	cQryPag += " 	   AND DD9.DD9_FILORI = '"+ cFilDF8 +"' 	  		"
	cQryPag += " 	   AND DD9.DD9_NUMPRG = '"+ cNumDF8 +"'       	"
	cQryPag += " 	   AND DD9.DD9_SEQPRG = '"+ cSeqDF8 +"'  			"
	cQryPag += " 	   AND DD9.DD9_DOC = ' '								"
	cQryPag += " 	   AND DD9.D_E_L_E_T_ = ' '							"
	
	cQryPag += " UNION ALL                                    		"
	
	// Buscas as notas a partir do documento
	cQryPag += " SELECT  'DTC' TABELA	                      		"
	cQryPag += " 		,DTC.R_E_C_N_O_ RECNO                 			"
	cQryPag += " FROM " + RetSqlName("DD9") + " DD9					"
	cQryPag += " INNER JOIN " + RetSqlName("DTC") + " DTC  			"
	cQryPag += " 	ON  DTC.DTC_FILIAL = '"+ FwxFilial("DTC") + "'	"
	cQryPag += " 	AND DTC.DTC_FILDOC = DD9.DD9_FILDOC       		"
	cQryPag += " 	AND DTC.DTC_DOC    = DD9.DD9_DOC          		"
	cQryPag += " 	AND DTC.DTC_SERIE  = DD9.DD9_SERIE        		"
	cQryPag += " 	AND DTC.D_E_L_E_T_ = ' '                 	 		"
	
	cQryPag += " WHERE DD9.DD9_FILIAL  = '"+ FwxFilial("DD9") + "' "
	cQryPag += " 	   AND DD9.DD9_FILORI = '"+ cFilDF8 +"' 	  		"
	cQryPag += " 	   AND DD9.DD9_NUMPRG = '"+ cNumDF8 +"'       	"
	cQryPag += " 	   AND DD9.DD9_SEQPRG = '"+ cSeqDF8 +"'  			"
	cQryPag += " 	  AND DD9.DD9_DOC <> ' '                  		"
	cQryPag += " 	  AND DD9.D_E_L_E_T_ = ' ' 	              		"
	
	cQryPag += " UNION ALL                                    		"
	
	// Buscas as notas a partir do documento considerando DY4
	cQryPag += " SELECT  'DTC' TABELA	                     		"
	cQryPag += " 		,DTC.R_E_C_N_O_ RECNO                 			"
	cQryPag += " FROM " + RetSqlName("DD9") + " DD9					"
	cQryPag += " INNER JOIN  " + RetSqlName("DY4") + " DY4 			"
	cQryPag += " 	ON  DY4.DY4_FILIAL = '"+ FwxFilial("DY4") + "' 	"
	cQryPag += " 	AND DY4.DY4_FILDOC =  DD9.DD9_FILDOC     			"
	cQryPag += " 	AND DY4.DY4_DOC    =  DD9.DD9_DOC         		"
	cQryPag += " 	AND DY4.DY4_SERIE  =  DD9.DD9_SERIE       		"
	cQryPag += " 	AND DY4.D_E_L_E_T_ =  ' ' 	              		"
	cQryPag += " INNER JOIN " + RetSqlName("DTC") + " DTC  			"
	cQryPag += " 	ON  DTC.DTC_FILIAL = '"+ FwxFilial("DTC") + "'	"
	cQryPag += " 		AND DTC.DTC_FILORI =  DY4.DY4_FILORI  			"
	cQryPag += " 		AND DTC.DTC_LOTNFC =  DY4.DY4_LOTNFC  			"
	cQryPag += " 		AND DTC.DTC_NUMNFC =  DY4.DY4_NUMNFC  			"
	cQryPag += " 		AND DTC.DTC_SERNFC =  DY4.DY4_SERNFC  			"
	cQryPag += " 		AND DTC.DTC_CODPRO =  DY4.DY4_CODPRO  			"
	cQryPag += " 		AND DTC.D_E_L_E_T_ =  ' '             			"
	
	cQryPag += " WHERE DD9.DD9_FILIAL  = '"+ FwxFilial("DD9") + "' "
	cQryPag += " 	   AND DD9.DD9_FILORI = '"+ cFilDF8 +"' 	  		"
	cQryPag += " 	   AND DD9.DD9_NUMPRG = '"+ cNumDF8 +"'       	"
	cQryPag += " 	   AND DD9.DD9_SEQPRG = '"+ cSeqDF8 +"'  			"
	cQryPag += " 	  AND DD9.DD9_DOC <> ' '                  		"
	cQryPag += " 	  AND DD9.D_E_L_E_T_ = ' ' 	              		"
	
	cQryPag += " UNION ALL                                    		"
	
	// Busca Coletas na DT5
	cQryPag += " SELECT  'DT5' TABELA	                      		"
	cQryPag += " 		,DT5.R_E_C_N_O_ RECNO                 			"
	
	cQryPag += " FROM " + RetSqlName("DD9") + " DD9					"
	cQryPag += " INNER JOIN " + RetSqlName("DT5") + " DT5          "
	cQryPag += " 	ON  DT5.DT5_FILIAL  = '"+ FwxFilial("DT5") + "'  "
	cQryPag += " 	AND DT5.DT5_FILDOC = DD9.DD9_FILDOC       		"
	cQryPag += " 	AND DT5.DT5_DOC = DD9.DD9_DOC             		"
	cQryPag += " 	AND DT5.DT5_SERIE = DD9.DD9_SERIE         		"
	cQryPag += " 	AND DT5.D_E_L_E_T_ = ' '                  		"
	
	cQryPag += " WHERE DD9.DD9_FILIAL  = '"+ FwxFilial("DD9") + "' "
	cQryPag += " 	   AND DD9.DD9_FILORI = '"+ cFilDF8 +"' 	  		"
	cQryPag += " 	   AND DD9.DD9_NUMPRG = '"+ cNumDF8 +"'       	"
	cQryPag += " 	   AND DD9.DD9_SEQPRG = '"+ cSeqDF8 +"'  			"
	cQryPag += " 	  AND DD9.DD9_DOC <> ' '                  		"
	cQryPag += " 	  AND DD9.D_E_L_E_T_ = ' ' 	              		"
EndIf

RestArea(aAreaAtu)
Return cQryPag

/*/-----------------------------------------------------------
{Protheus.doc} A146RotTrf()
Busca a Rota para Transferencia - Painel com Rota Automatica ativa

Uso: TMSA146

@sample
//A146RotTrf()

@author Paulo Henrique Corrêa Cardoso.
@since 02/06/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function A146RotTrf(cRota,cTipTra,nQtdTranf,cSrvTms)
Local oDlg			:= NIL 	// Recebe o Objeto da Dialog
Local cTitulo		:= ""		//
Local cF3			:= ""		//
Local cPicture	:= ""		//

Default cRota 	:= ""		    // Recebe a Rota
Default cTipTra	:= cTpTransp   // Recebe o Tipo de transporte  
Default nQtdTranf	:= 0		    // Recebe a Quantidade de docs de Transf
Default cSrvTms   := ""


DEFINE MSDIALOG oDlg FROM 00,00 TO 90,290 PIXEL TITLE STR0184// "Escolha a Rota"
		
		 cTitulo	:= GetSx3Cache("DF8_ROTA", "X3_TITULO")		
		 cF3		:= GetSx3Cache("DF8_ROTA", "X3_F3")
		 cPicture	:= GetSx3Cache("DF8_ROTA", "X3_PICTURE") 
		
		
		@ 05,05 SAY cTitulo PIXEL // "Rota"
		@ 05,60 MSGET cRota F3 cF3 SIZE 15, 07 OF oDlg PIXEL PICTURE cPicture ;
			VALID A146VldRot(cRota,cTipTra,0,nQtdTranf,0,cSrvTms)

		DEFINE SBUTTON FROM 05,115 TYPE 1 OF oDlg ENABLE ACTION (nOpcao := 1,oDlg:End())
		DEFINE SBUTTON FROM 20,115 TYPE 2 OF oDlg ENABLE ACTION (nOpcao := 0,oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpcao == 1
		If Empty(cRota)
			Help('',1,'TMSA14639') // "A rota deve ser preenchida"
			cRota := A146RotTrf(cRota,cTipTra,nQtdTranf,cSrvTms)
		EndIf
	Else
		If !MsgYesNo(STR0185) //"A rota atual será mantida. Deseja Continuar ?"
			cRota := A146RotTrf(cRota,cTipTra,nQtdTranf,cSrvTms)
		EndIf
		 
	EndIf
	

Return cRota

/*/-----------------------------------------------------------
{Protheus.doc} A146VldRot()
Validações de Rota

Uso: TMSA146

@sample
//A146VldRot(cRota,cTipTra,nQtdCol,nQtdTra,nQtdEnt,cSrvTms)

@author Paulo Henrique Corrêa Cardoso.
@since 02/06/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function A146VldRot(cRota,cTipTra,nQtdCol,nQtdTra,nQtdEnt,cSrvTms)
Local lRet			:= .T.												 // Recebe o Retorno
Local cCdrOri		:= Padr(GetMv("MV_CDRORI",,""),Len(DA8->DA8_CDRORI)) // Recebe a Região de Origem

Default cRota		:= ""	           // Recebe a Rota que será Validada	
Default cTipTra		:= cTpTransp	// Recebe o tipo de Transporte  
Default nQtdCol		:= 0 	       // Recebe a Quantidade de Coleta	
Default nQtdTra		:= 0	       // Recebe a Quantidade de Transporte
Default nQtdEnt		:= 0	       // Recebe a Quantidade de Entrega
Default cSrvTms      := ""

DA8->(DbSetOrder(1))
DA8->(MsSeek(xFilial("DA8")+ cRota))
If DA8->DA8_TIPTRA != cTipTra  .Or. DA8->DA8_SERTMS != cSrvTms 
	If lRot146Aut
		TM146MsgAd(STR0223,"A146VldRot" )
	Else	
		Help(' ', 1, 'TMSA14403') //"Rota não pertence ao Serviço de Transporte e ou Tipo de Transporte da viagem"
	EndIf	
	lRet := .F.
ElseIf DA8->DA8_CDRORI != cCdrOri
	If lRot146Aut
		TM146MsgAd(STR0224,"A146VldRot" )
	Else
		Help(' ', 1, 'TMSA14404',,cCdrOri,2,1) //"Rota não pertence a região de origem: "
	EndIf	
	lRet := .F.
ElseIf DA8->DA8_ATIVO == StrZero(2,Len(DA8->DA8_ATIVO))
	If lRot146Aut
		TM146MsgAd(STR0225,"A146VldRot" )
	Else	
		Help(' ', 1, 'TMSA14405',,DA8->DA8_COD,3,1) //"Rota não está ativa no Cadastro de Rotas: "
	EndIf	
	lRet := .F.
Else
	//Verifica se o servico da Rota é a mesma dos documentos
	If DA8->DA8_SERTMS == '1'    //Coleta
		If nQtdCol == 0
			If lRot146Aut
				TM146MsgAd(STR0223,"A146VldRot" )
			Else
				Help(' ', 1, 'TMSA14403') //"Rota não pertence ao Serviço de Transporte e ou Tipo de Transporte da viagem"
			EndIf	
			lRet := .F.
		Else
			If nQtdTra > 0 .Or. nQtdEnt > 0
				If lRot146Aut
					TM146MsgAd(STR0223,"A146VldRot" )
				Else
					Help(' ', 1, 'TMSA14403') //"Rota não pertence ao Serviço de Transporte e ou Tipo de Transporte da viagem"
				EndIf		
				lRet := .F.
			EndIf	
		EndIf
	ElseIf DA8->DA8_SERTMS == '3'   //Entrega
		If cSerAdi <> '1' .And. nQtdCol > 0
			If lRot146Aut
				TM146MsgAd(STR0174,"A146VldRot" )
			Else
				Help(' ', 1, 'TMSA14618',,STR0167,3,1)  //Servico Adicional não está habilitado. Não é permitido selecionar Serviços de  (Coleta e Entrega)  
			EndIf	
			lRet:= .F.
		EndIf	
	EndIf
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSA146Per()
Validações do Pergunte TMSA146

Uso: Pergunte TMSA146

@sample
//TMSA146Per(nPosicao)

@author Katia
@since 22/08/2016
@version 1.0
-----------------------------------------------------------/*/

Function TMSA146Per(nPosicao,cConteudo)
Local lRet:= .T.

Default nPosicao := 0
Default cConteudo:= ""

If nPosicao == 26  //Servico De
	If !(cConteudo $ '1|2|3')
		lRet:= .F.
	EndIf
	 
ElseIf nPosicao == 27  //Servico Ate
	If !(cConteudo $ '1|2|3')
		lRet:= .F.
	EndIf
	
	If lRet
		If Val(mv_par27) < Val(mv_par26)
			lRet:= .F.
		EndIf
	EndIf
EndIf

If !lRet
	Help('',1,'TMSA14642') // "Codigo de Serviço de Transporte invalido.
EndIf

Return lRet                                              

/*/-----------------------------------------------------------
{Protheus.doc} TMSA146Prg()
Valida se o documento está em uma Programação de Carregamento
em Aberot

Uso: TMSA210, TMSA141, TMSA140

@sample
//TMSA146Prg(cFilDoc,cDoc,cSerie)

@author Katia
@since 25/08/2016
@version 1.0
-----------------------------------------------------------/*/
Function TMSA146Prg(cFilDoc,cDoc,cSerie,cFilDF8,cNumDF8)

Local lRet     := .T.
Local cAliasDF8:= ""
Local cQuery   := ""

Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""

//--- Verifica se o documento está em uma Programacao de Carregamento em Aberto
If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
	cAliasDF8 := GetNextAlias()
	cQuery += "  SELECT DF8.DF8_FILORI, DF8.DF8_NUMPRG FROM " + RetSqlName("DD9")+" DD9 "
	cQuery += "   JOIN " +RetSqlName("DF8")+" DF8 "
	cQuery += "     ON DF8.DF8_FILIAL = '"+xFilial('DF8')+"'"
	cQuery += "    AND DF8.DF8_FILORI = DD9.DD9_FILORI"
	cQuery += "    AND DF8.DF8_NUMPRG = DD9.DD9_NUMPRG"
	cQuery += "    AND DF8.DF8_STATUS = '" +  StrZero( 1, Len( DF8->DF8_STATUS ) ) + "' "
	cQuery += "    AND DF8.D_E_L_E_T_ = ' '"
	cQuery += "      WHERE DD9.DD9_FILIAL = '"+xFilial('DD9')+"'"
	cQuery += "      AND DD9.DD9_FILDOC = '" +  cFilDoc + "' "
	cQuery += "      AND DD9.DD9_DOC    = '" + cDoc + "' "
	cQuery += "      AND DD9.DD9_SERIE  = '" + cSerie + "' "
	cQuery += "      AND DD9.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDF8, .F., .T.)
	If (cAliasDF8)->(!EOF())
		lRet:= .F.
		cFilDF8:= (cAliasDF8)->DF8_FILORI 
		cNumDF8:= (cAliasDF8)->DF8_NUMPRG
		 
		(cAliasDF8)->(DbCloseArea())
		Return(.F.) 
	EndIf
	(cAliasDF8)->(DbCloseArea())
EndIf		

Return lRet	

/*/-----------------------------------------------------------
{Protheus.doc} TMSA146Est()
Estorno da Efetivação da Programação

Uso: TMSA146

@sample
//TMSA146Est()

@author Katia
@since 29/08/2016
@version 1.0
-----------------------------------------------------------/*/
Function TMSA146Est(lEstCalLot)

Local nOpcViag  := 5   //Exclusao
Local lRet      := .T.
Local aArea     := GetArea()
Local cSeek     := ""
Local cRecnoDF8 := ""
Local cViagemPrg:= ""
Local cFuncNull := ""
Local cAliasNew := ""
Local cQuery    := ""
Local lDocOut   := .F.

Private aCompViag := {}
Private aDocto    := {}
Private lTmsCFec  := TmsCFec()
Private lColeta   := .F.

Default lEstCalLot:= .T.

Do Case
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case cDbType $ "ORACLE/INFORMIX"  
  		cFuncNull	:= "NVL"
 	Otherwise
 		cFuncNull	:= "ISNULL"
EndCase     
	

If (!(DF8->DF8_STATUS $ "2;3") .AND. lEstCalLot) .Or. Empty(DF8->DF8_VIAGEM) //Efetivada
	lRet:= .F. 
	If DF8->DF8_STATUS == '1'
		Help('',1,'TMSA14648') // "Operação não permitida para Programação com status Em Aberto!"
	ElseIf DF8->DF8_STATUS == '9'	                               
		Help('',1,'TMSA14629') // "A Programação está Cancelada!"
	EndIf	
EndIf

If lRet
	lRet:= T146VldVge(@cRecnoDF8)
		
	If lRet 
		If !lEstCalLot .OR. MsgYesNo(STR0197)   //Deseja efetuar o Estorno da efetivação da Programação ?
			lDocOut:= .F.
			cAliasNew := GetNextAlias()
			cQuery := " SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE, DUD_SERTMS, " + cFuncNull + "(DD9_NUMPRG, '') DD9_NUMPRG " 
			cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
			cQuery += "   LEFT JOIN " + RetSqlName("DD9") + " DD9 "
			cQuery += "     ON  DD9_FILIAL    = '"+xFilial("DD9")+"'"
			cQuery += "     AND DD9_FILDOC    = DUD_FILDOC"
			cQuery += "     AND DD9_DOC       = DUD_DOC"
			cQuery += "     AND DD9_SERIE     = DUD_SERIE"
			cQuery += "     AND DD9_FILORI    = '" + DF8->DF8_FILORI  + "' "
			cQuery += "     AND DD9_NUMPRG    = '" + DF8->DF8_NUMPRG  + "' "
			cQuery += "     AND DD9_SEQPRG    = '" + DF8->DF8_SEQPRG  + "' "
			cQuery += "     AND DD9.D_E_L_E_T_    = ' '"
			cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
			cQuery += "     AND DUD_FILORI = '" + DF8->DF8_FILORI  + "' "
			cQuery += "     AND DUD_VIAGEM = '" + DF8->DF8_VIAGEM  + "' "
			cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
			(cAliasNew)->(DbGoTop())
			While (cAliasNew)->(!Eof())
				lRet:= TM146DocDUD((cAliasNew)->DUD_FILDOC, (cAliasNew)->DUD_DOC, (cAliasNew)->DUD_SERIE, (cAliasNew)->DUD_SERTMS, DF8->DF8_ROTA, nOpcViag)
				If Empty((cAliasNew)->DD9_NUMPRG)
					lDocOut:= .T.
				EndIf 
				(cAliasNew)->(DbSkip())
			EndDo
			(cAliasNew)->(dbCloseArea())
				
			If lRet .And. lDocOut
				If lEstCalLot .OR. !MsgYesNo(STR0200)  //"Existem documentos na viagem que não foram incluidos pela Programação de Carregamento. Ao efetuar o estorno a viagem será excluida. Deseja prosseguir ?                                                                                                                                                                                                                                                                                                                                                           
					lRet:= .F.
				EndIf
			EndIf		
			
			If lRet
				TMSA146Com(@aCompViag,.F.,,nOpcViag,,DF8->DF8_FILORI,DF8->DF8_DATGER,DF8->DF8_HORGER,DF8->DF8_ROTA,DF8->DF8_SERTMS,DF8->DF8_VIAGEM)
				
				lRet := T146GrvVge(nOpcViag,DF8->DF8_ROTA,DF8->DF8_FILORI,DF8->DF8_VIAGEM, ,DF8->DF8_SERTMS,DF8->DF8_DATGER,DF8->DF8_HORGER, , ,DF8->DF8_TIPTRA)
				If lRet	
					RecLock("DF8", .F.)
					DF8->DF8_STATUS := StrZero(1,Len(DF8->DF8_STATUS))
					cViagemPrg := DF8->DF8_VIAGEM
						DF8->DF8_VIAGEM := " "   
					DF8->(MsUnLock())
					
					If lMVITMSDMD .AND. DF8->(ColumnPos("DF8_PLNDMD")) > 0 .AND. FindFunction('TMSUpdDmd') .AND. !Empty(DF8->DF8_PLNDMD) //SUAVIZAÇÃO DEMANDAS
						TMSUpdDmd(DF8->DF8_PLNDMD, "6", 8,cViagemPrg)
					EndIf
					
					DDZ->(dbSetOrder(1))
					If	DDZ->(DbSeek( cSeek := FwxFilial('DDZ')+ DF8->DF8_FILORI + DF8->DF8_NUMPRG + DF8->DF8_SEQPRG ))
						While DDZ->( ! Eof() .And. DDZ->DDZ_FILIAL + DDZ->DDZ_FILORI + DDZ->DDZ_NUMPRG + DDZ->DDZ_SEQPRG  == cSeek )
							RecLock("DDZ", .F.)
							DDZ->DDZ_VIAGEM := " "
							DDZ->(MsUnLock())
								
							DDZ->(DbSkip())
						EndDo
					EndIf	
					
					//---- Atualiza o campo referente a Viagem Coligada.
					
					If !Empty(cRecnoDF8)
						DF8->(dbGoTo(cRecnoDF8))
						RecLock("DF8", .F.)    
						DF8->DF8_FILVGE := ""   
						DF8->DF8_NUMVGE := ""
						DF8->(MsUnLock())
					EndIf
				EndIf
			EndIf		
		EndIf
	EndIf
EndIf		
RestArea(aArea)
aCompViag := {}
aDocto    := {}

Return lRet	

/*/-----------------------------------------------------------
{Protheus.doc} T146VldVge()
Verifica status da Viagem

Uso: VldActMdl / TMSA146Est

@sample
//TMSA146Est()

@author Katia
@since 29/08/2016
@version 1.0
-----------------------------------------------------------/*/
Function T146VldVge(cRecnoDF8)

Local lRet      := .T.
Local cFilOriDF8:= DF8->DF8_FILORI
Local cNumPrgDF8:= DF8->DF8_NUMPRG
Local cSeqPrgDF8:= DF8->DF8_SEQPRG

Default cRecnoDF8:= ""
		
If !Empty(DF8->DF8_VIAGEM)
	DTQ->( dbSetOrder( 2 ) )
	If DTQ->( MsSeek( xFilial('DTQ') + DF8->DF8_FILORI + DF8->DF8_VIAGEM ) ) .And. DTQ->DTQ_TIPVIA <>  StrZero( 3, Len( DTQ->DTQ_TIPVIA ) )  //Planejada
		If DTQ->DTQ_SERTMS == StrZero(1,Len(DUD->DUD_SERTMS)) .And. ; //-- Coleta
			DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) //-- Em Transito
			Help(' ', 1, 'TMSXFUNA03') //-- Viagem nao esta em Aberto
			lRet:= .F.	
		EndIf
		
		If lRet
			//-- Somente permite manutencoes em viagens em aberto ou em transito
			If	! TMSChkViag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,,.F.,.T.,,.T.,,,,,,.F.,.F.,,.T.,,, cFilAnt, .T.)
				lRet:= .F.
			EndIf
			DTQ->(MsUnLock())  //Quando utilizado SIGAMDI
				
			//-- Se houver documentos carregados, a exclusao da viagem sera permitida apos o estorno do carregamento
			If lRet
				DTA->( DbSetOrder( 2 ) )
				If	DTA->( MsSeek( xFilial('DTA') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM, .F. ) )
					Help(' ', 1, 'TMSA14009',, DTQ->DTQ_FILORI + ' / ' + DTQ->DTQ_VIAGEM,4,1)	//-- Ha documentos carregados nesta viagem.###"Fil.Origem : "###" Viagem : "
					lRet:= .F.
				EndIf
			EndIf
		EndIf	
	EndIf
	
	
	If lRet
		If Empty(DF8->DF8_NUMVGE)
			//-- Verifica se está em uma Programação Coligada
			cAliasTmp := GetNextAlias()
			cQuery := "  SELECT DF8.DF8_FILORI, DF8.DF8_VIAGEM, DF8.R_E_C_N_O_ DF8_RECNO FROM " + RetSqlName("DF8") + " DF8 "
			cQuery += "   WHERE DF8.DF8_FILIAL  = '" + xFilial("DF8") + "' "
			cQuery += "      AND DF8.DF8_FILORI  = '" + cFilOriDF8 + "' "
			cQuery += "      AND DF8.DF8_NUMPRG  = '" + cNumPrgDF8 + "' "
			cQuery += "      AND DF8.DF8_SEQPRG  <> '" + cSeqPrgDF8 + "' "
			cQuery += "      AND DF8.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)
			If (cAliasTmp)->(!Eof())
				If !Empty((cAliasTmp)->DF8_VIAGEM)
					//Nao é possivel excluir a Viagem quando a mesma encontra-se como coligada de outra Viagem.              
					Help('',1,'TMSA14028',,AllTrim(RetTitle('DTQ_FILORI')) + ': ' + (cAliasTmp)->DF8_FILORI + "  - " + AllTrim(RetTitle('DTQ_VIAGEM')) + ": " + (cAliasTmp)->DF8_VIAGEM ,4,1)
					lRet:= .F.
				Else
					cRecnoDF8:= (cAliasTmp)->DF8_RECNO   //Recno para atualizar o campo df8_filvge/df8_numvge
				EndIf							
			EndIf
			(cAliasTmp)->(dbCloseArea())
		EndIf
	EndIf
EndIf

Return lRet
/*/-----------------------------------------------------------
{Protheus.doc} T146VerVge()
Verifica se o documento está em viagem

Uso: VldActMdl 

@sample
//T146VerVge()

@author Katia
@since 29/08/2016
@version 1.0
-----------------------------------------------------------/*/
Function T146VerVge(cFilDoc,cDoc,cSerie)
Local lRet:= .T.

DUD->(dbSetOrder(1))
If !DUD->(dbSeek(xFilial("DUD")+cFilDoc+cDoc+cSerie+DF8->DF8_FILORI+DF8->DF8_VIAGEM))
	lRet:= .F.
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} T146LimTot()
Limpa Totalizadores

Uso: T146CarVei / T146CarPrg / TM146MrkTd

@sample
//T146LimTot(aCamposTot, oMdlTotal)

@author Katia
@since 29/08/2016
@version 1.0
-----------------------------------------------------------/*/
Function T146LimTot(aCamposTot, oMdlTotal)
Local nY:= 0
Default aCamposTot:= {}
Default oMdlTotal := Nil

For nY := 1 To Len(aCamposTot)
	oMdlTotal:LoadValue(aCamposTot[nY][3], 0)
Next nY

Return 	

/*/-----------------------------------------------------------
{Protheus.doc} T146AtuDoc()
Atualiza os Documentos de Cliente

Uso: TMSA146Lot()

@sample
//T146AtuDoc(cFilProg, cNumProg, cSerProg)

@author Katia
@since 14/10/16
@version 1.0
-----------------------------------------------------------/*/
Function T146AtuDoc(cFilProg, cNumProg, cSeqProg)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""

Default cFilProg:= ""
Default cNumProg:= ""
Default cSeqProg:= ""

If !Empty(cNumProg)
	cAliasQry := GetNextAlias()
	cQuery := " SELECT DISTINCT DTC_FILORI, DTC_LOTNFC "
	cQuery += " FROM " + RetSqlName("DD9") + " DD9 "
	cQuery += " INNER JOIN " + RetSqlName("DTC") + " DTC "
	cQuery += " ON DTC.DTC_FILIAL  = '" + xFilial("DTC") + "' "
	cQuery += " AND DTC.DTC_CLIREM = DD9.DD9_CLIREM "
	cQuery += " AND DTC.DTC_LOJREM = DD9.DD9_LOJREM "
	cQuery += " AND DTC.DTC_NUMNFC = DD9.DD9_NUMNFC "
	cQuery += " AND DTC.DTC_SERNFC = DD9.DD9_SERNFC "
	cQuery += " AND DTC.D_E_L_E_T_ = ' ' "	
	cQuery += " WHERE DD9.DD9_FILIAL  = '" + xFilial("DD9") + "' "
	cQuery += " AND DD9.DD9_FILORI = '" + cFilProg + "' "
	cQuery += " AND DD9.DD9_NUMPRG = '" + cNumProg + "' "
	cQuery += " AND DD9.DD9_SEQPRG = '" + cSeqProg + "' "
	cQuery += " AND DD9.DD9_DOC = ' ' " 
	cQuery += " AND DD9.D_E_L_E_T_ = ' ' "
	If !cDbType $ "MSSQL|MSSQL7|ORACLE"
		cQuery := ChangeQuery(cQuery)
	EndIf	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	While (cAliasQry)->(!Eof())
		DTP->(dbSetOrder(2))
		If DTP->(MsSeek(xFilial("DTP")+(cAliasQry)->DTC_FILORI+(cAliasQry)->DTC_LOTNFC))
			If DTP->DTP_STATUS <> StrZero(3,Len(DTP->DTP_STATUS))	//Calculado
				lRet:= .F.
				Exit	
			EndIf	
		EndIf	
		(cAliasQry)->(dbSkip())			
	EndDo
	(cAliasQry)->(dbCloseArea())
			
	If lRet	
		//-- Atualiza DD9 o numero do Documento	
		cAliasDD9 := GetNextAlias()
		cQuery := "   SELECT DD9_NUMNFC, DD9_SERNFC, DD9_CLIREM, DD9_LOJREM, DD9_CODPRO, DD9.R_E_C_N_O_ DD9RECNO FROM " + RetSqlName("DD9") + " DD9 "
		cQuery += "    WHERE DD9.DD9_FILIAL  = '" + xFilial("DD9") + "' "
		cQuery += "      AND DD9.DD9_FILORI = '" + cFilProg + "' "
		cQuery += "      AND DD9.DD9_NUMPRG = '" + cNumProg + "' "
		cQuery += "      AND DD9.DD9_SEQPRG = '" + cSeqProg + "' "
		cQuery += "      AND DD9.DD9_DOC = ' '  "
		cQuery += "      AND DD9.D_E_L_E_T_ = ' ' "
		If !cDbType $ "MSSQL|MSSQL7|ORACLE"
			cQuery := ChangeQuery(cQuery)
		EndIf	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDD9)
		While (cAliasDD9)->(!Eof())
			DTC->(dbSetOrder(2)) //-- DTC_FILIAL+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM
			If DTC->(dbSeek(xFilial("DTC")+(cAliasDD9)->(DD9_NUMNFC+DD9_SERNFC+DD9_CLIREM+DD9_LOJREM+DD9_CODPRO)) )
				DD9->(MsGoto( (cAliasDD9)->DD9RECNO ))
				RecLock("DD9",.F.)
				DD9->DD9_FILDOC:= DTC->DTC_FILDOC 
				DD9->DD9_DOC   := DTC->DTC_DOC
				DD9->DD9_SERIE := DTC->DTC_SERIE
				DD9->(MsUnLock())
			EndIf
			(cAliasDD9)->(dbSkip())
		EndDo
		(cAliasDD9)->(dbCloseArea())
	EndIf
EndIf

Return lRet 

/*/-----------------------------------------------------------
{Protheus.doc} A146QrbLot()
Limpa e atualiza os lotes que não forem incluidos totalmente na programação

Uso: A146QrbLot()

@sample
//(aLote,cFilProg,cNumProg,cSeqProg)

@author paulo.henrique
@since 17/07/17
@version 1.0
-----------------------------------------------------------/*/
Function A146QrbLot(aLote,cFilProg,cNumProg,cSeqProg)
	Local nCount      := 0      // Recebe o Contador 
	Local nCount1     := 0      // Recebe o Contador 1
	Local nCntNf      := 0      // Recebe o contador de nfs
	Local cQuery      := ""     // Recebe a query
	Local cAliasQry   := ""     // Recebe o proximo alias disponivel
	Local cNewLot     := ""     // Recebe o proximo numero de lote 

	Default aLote     := {}     // Recebe o array de lotes
	Default cFilProg  := ""     // Recebe a filial da programação
	Default cNumProg  := ""     // Recebe o numero da programação
	Default cSeqProg  := ""     // Recebe a sequencia da programação

	dbSelectArea("DTC")
	DTC->(dbSetOrder(1))

	dbSelectArea("DTP")
	DTP->(dbSetOrder(1))

	For nCount := 1 To Len(aLote)
		cAliasQry := GetNextAlias()
		aNfProg   := {}
		nCntNf    := 0

		cQuery := " SELECT DTC.DTC_LOTNFC,"
		cQuery += "        DTC.R_E_C_N_O_,"
		cQuery += "        DD9_FILORI,"
		cQuery += "        DD9_NUMPRG,"
		cQuery += "        DD9_SEQPRG "
		cQuery += " FROM " + RetSqlName("DTC") + " DTC"
		
		cQuery += " LEFT JOIN " + RetSqlName("DD9") + " DD9"
		cQuery += "   ON DD9.DD9_FILIAL  = '"+ FwxFilial("DD9") +"'"
		cQuery += " 	 AND DD9.DD9_CLIREM = DTC.DTC_CLIREM"
		cQuery += " 	 AND DD9.DD9_LOJREM = DTC.DTC_LOJREM" 
		cQuery += " 	 AND DD9.DD9_NUMNFC = DTC.DTC_NUMNFC"
		cQuery += " 	 AND DD9.DD9_SERNFC = DTC.DTC_SERNFC"
		cQuery += " 	 AND DD9.D_E_L_E_T_ = ' '"
		cQuery += "      AND DD9.DD9_FILORI = '"+ cFilProg +"'"
		cQuery += "      AND DD9.DD9_NUMPRG = '"+ cNumProg +"'"
		cQuery += "      AND DD9.DD9_SEQPRG = '"+ cSeqProg +"'"
		 
		cQuery += " WHERE  DTC.DTC_FILIAL = '"+ FwxFilial("DTC") +"'"
		cQuery += " AND DTC.DTC_LOTNFC = '"+aLote[nCount][2]+"'"
		cQuery += " AND DTC.D_E_L_E_T_ = ' '"
		
		If !cDbType $ "MSSQL|MSSQL7|ORACLE"
			cQuery := ChangeQuery(cQuery)
		EndIf	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		
		While (cAliasQry)->(!Eof())
			// Busca as notas do lote que estão na programação
			If  (cAliasQry)->DD9_FILORI == cFilProg .AND.(cAliasQry)->DD9_NUMPRG == cNumProg .AND.(cAliasQry)->DD9_SEQPRG == cSeqProg
				
				Aadd(aNfProg,(cAliasQry)->R_E_C_N_O_)
			EndIf
			nCntNf += 1
			
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
		
		If Len(aNfProg) < nCntNf

			cNewLot := CriaVar("DTP_LOTNFC")	
			ConfirmSX8()
			
			// Cria um novo Lote
			If DTP->(dbSeek(FwxFilial("DTP")+ aLote[nCount][2] ))
				aCampos := {}

				Aadd( aCampos, { 'DTP_LOTNFC', cNewLot } )
				Aadd( aCampos, { 'DTP_DATLOT', dDataBase } )			
				Aadd( aCampos, { 'DTP_HORLOT', StrTran(Left(Time(),5),":","") } )
				Aadd( aCampos, { 'DTP_QTDLOT', Len(aNfProg) } )				
				Aadd( aCampos, { 'DTP_QTDDIG', Len(aNfProg) } )
				Aadd( aCampos, { 'DTP_STATUS', "2" } ) // Digitado

				DTP->(TmsCopyReg(aCampos))
			EndIf

			// Limpas o campo lote das notas
			For nCount1 :=1 To Len(aNfProg)
				DTC->(DBGoto(aNfProg[nCount1]))
				RecLock("DTC",.F.)
				DTC->DTC_LOTNFC := cNewLot
				DTC->(MsUnlock())
			Next nCount1
			
			// Acerta a quantidade do Lote Original
			If DTP->(dbSeek(FwxFilial("DTP")+ aLote[nCount][2] ))
				RecLock("DTP",.F.)
				DTP->DTP_QTDLOT := DTP_QTDLOT - Len(aNfProg)
				DTP->DTP_QTDDIG := DTP_QTDDIG - Len(aNfProg)
				DTP->(MsUnlock())
			EndIf
		
			aLote[nCount][2] := cNewLot
			aLote[nCount][5] := Len(aNfProg)
		EndIf
		
	Next nCount

Return
/*/-----------------------------------------------------------
{Protheus.doc} A146PlnDmd()
Seta o Planejamento de Demandas que será vinculado a Progranação de CVarregamento.

Uso: A146PlnDmd()

@author André Luiz Custódio
@since 24/07/18
@version 12.1.17
-----------------------------------------------------------/*/
Function A146PlnDmd(cPlanDmd)
	Local lRet    := .T.

	cPlnDmd := AllTrim(cPlanDmd)

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} A146VldCol()
Valida se a Coleta está relacionada a uma Demanda. Se estiver, não permite seu descarregamento.

Uso: A146VldCol()

@author Aluizio Fernando Habizenreuter
@since 25/07/18
@version 12.1.17
-----------------------------------------------------------/*/
Static Function A146VldCol(cSerTms, cDocto)
Local lRet := .T.
Local aAreaDT5 := {}

If lMVITMSDMD
	If cSerTms == StrZero( 1, Len(DTC->DTC_SERTMS))  //Coleta
		aAreaDT5 := DT5->(GetArea())
		DT5->(dbSetOrder(1))
		If DT5->(DbSeek(xFilial('DT5')+cFilAnt+cDocto ))
			If DT5->(ColumnPos("DT5_CODDMD")) > 0 .And. !Empty(DT5->DT5_CODDMD) .And.;
			   DT5->(ColumnPos("DT5_SEQDMD")) > 0 .And. !Empty(DT5->DT5_SEQDMD) .And.;
			   DT5->(ColumnPos("DT5_ORIDMD")) > 0 .And. !Empty(DT5->DT5_ORIDMD) .And. DT5->DT5_ORIDMD == '1' //1=Demanda; 2=TMS			
				MsgAlert(STR0206 + cDocto + STR0207)
				lRet := .F.
			EndIf 
		EndIf
		RestArea(aAreaDT5)						
	EndIf
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TM146MsgAd()
Armazena as mensagens de help para rotina automatica

Uso: TMSA146()

@author Katia
@since 30/07/18
@version 12.1.17
-----------------------------------------------------------/*/
Function TM146MsgAd(cMensag,cFuncao)

AADD(aMsgErrPrg,{cMensag,'', cFuncao})

Return

/*/
{Protheus.doc} TM146VLDLS
Validação de inclusao, alteracao, exclusao e alternancia de linha do modelo MdlGridDLS

@Uso: TMSA146()
@Since: 2019/02/13 16:22
@Author: Tiago dos Santos
@Version: 12.1.17+
/*/
Function TM146VLDLS(oMdl,nLine,cOperation,cFieldId,xValueNew,xValueOld)

Local oMdl		   := FWModelActive()
Local oMdlGridDF8:= oMdl:GetModel('MdGridDF8')
Local oMdGridDLS := oMdl:GetModel('MdGridDLS')
Local lResult   := .T.
Local cFilDF8	  := oMdlGridDF8:GetValue("DF8_FILORI")
Local cNumPrg	  := oMdlGridDF8:GetValue("DF8_NUMPRG")
Local cSeqPrg	  := oMdlGridDF8:GetValue("DF8_SEQPRG")
 
	If cFieldId == "DLS_CODMOT"	
		If !Empty(xValueOld)
			lResult := TMVALDMOT(cFilDF8,cNumPrg,cSeqPrg,xValueOld)		 
		EndIf	
	EndIf	
	
	If oMdGridDLS:SeekLine( { { "DLS_CONDUT", PADR('1',TamSX3('DLS_CONDUT')[1]) }  } )
		oMdGridDLS:GoLine(nLine)
		oMdGridDLS:LoadValue("DLS_CONDUT", '2' )	
	Else
		oMdGridDLS:GoLine(nLine)
		oMdGridDLS:LoadValue("DLS_CONDUT", '1' )	
	EndIf	
	oMdGridDLS:GoLine(nLine)
	
Return lResult

/*/----------------------------------------------------------------------
{Protheus.doc} T146INIT
Validação de inclusao, alteracao, exclusao e alternancia de linha do modelo MdlGridDLS

@Uso: TMSA146()
@Since: 19/02/2019 
@Author: Alex Amaral
@Version: 12.1.17+
----------------------------------------------------------------------/*/

Function T146INIT( oMdl )

	Local lResult	:= .T.
	Local cCodMot	:= DLS->DLS_CODMOT

	If !Empty(cCodMot)
		lResult := .F. 	 
	EndIf
	
Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} TM146DocTr()
Função responsável por verificar se existe algum documento não transmitido na programação de carregamento.
@author  Marlon Augusto Heiber
@since   06/08/2019
@version 12.1.25
@Param   cFilOri: Filial origem programação; cNumPrg: Nº programação; cSeqPrg: Sequencia programação.
/*/
//-------------------------------------------------------------------

Static Function TM146DocTr(cFilOri,cNumPrg,cSeqPrg)

Local lRet		:= .T.
Local cAliasDT6	:= GetNextAlias()

cQuery := " SELECT DT6_IDRCTE "
cQuery += " FROM " + RetSqlName("DD9") + " DD9 "
cQuery += 		" LEFT JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += 					" ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += 					" AND DT6.DT6_FILDOC = DD9.DD9_FILDOC  "
cQuery += 					" AND DT6.DT6_DOC = DD9.DD9_DOC  "
cQuery += 					" AND DT6.DT6_SERIE = DD9.DD9_SERIE "
cQuery += 					" AND DT6.D_E_L_E_T_ = ' ' "
cQuery += " WHERE DD9.DD9_FILIAL = '" + xFilial("DD9") + "' "
cQuery += 			" AND DD9.DD9_FILORI = '" + cFilOri + "' "
cQuery += 			" AND DD9.DD9_NUMPRG = '" + cNumPrg + "' "
cQuery += 			" AND DD9.DD9_SEQPRG = '" + cSeqPrg + "' "
cQuery += 			" AND DD9.D_E_L_E_T_ = ' ' "

If !cDbType $ "MSSQL|MSSQL7|ORACLE"
	cQuery := ChangeQuery( cQuery )
EndIf

DbUseArea( .T., "TOPCONN", TCGENQRY( , , cQuery ), cAliasDT6, .F., .T. )

While (cAliasDT6)->(!Eof())
	If (cAliasDT6)->DT6_IDRCTE != '100'
		lRet := .F.
		Exit
	EndIf
	(cAliasDT6)->(dbSkip())
EndDo

(cAliasDT6)->(DbCloseArea())

Return lRet

//-----------------------------------------------------------
/* {Protheus.doc} TMSVMod3
Verifica se o Ambiente está atualizado com Viagem Modelo 3

@author		Rodrigo.Pirolo
@since		26/02/2021
@version	1.0
*/
//-----------------------------------------------------------

Static Function TMSVMod3( nOpc, dDatVge, cHorVge, cNumProg, cFilOri, cViagem, aCompViag, cSerTMS, cRota, cTipTraDF8 )

	Local lRet			:= .F.
	Local lTMS3GFE		:= TmsIntGFE("02")
	Local aAreas		:= { DUP->(GetArea()), DD9->(GetArea()), DM3->(GetArea()), DTR->(GetArea()), DLS->(GetArea()), DUD->(GetArea()), GetArea() }
	Local aDadosDM3		:= {}
	Local aDadosDM4		:= {}
	Local aDadosDM5		:= {}
	Local aDadosDM8		:= {}
	Local aDadosDTR		:= {}
	Local aDadosDUP		:= {}
	Local aCab			:= {}
	Local aMaster		:= {}
	Local aGrid			:= {}
	Local cSeekDD9		:= ""
	Local cSequen		:= StrZero(0,Len(DUD->DUD_SEQUEN))
	Local nSeqDUD		:= 0
	Local oModel		:= Nil
	Local nPCodVei		:= AScan( aCompViag[1], { |x| AllTrim( x[2] ) == "DTR_CODVEI" } )
	Local nPModVei		:= AScan( aCompViag[1], { |x| AllTrim( x[2] ) == "DTR_MODVEI" } )
	Local nPProVei		:= AScan( aCompViag[1], { |x| AllTrim( x[2] ) == "DTR_PROVEI" } )
	Local nPCodRB1		:= AScan( aCompViag[1], { |x| AllTrim( x[2] ) == "DTR_CODRB1" } )
	Local nPModRB1		:= AScan( aCompViag[1], { |x| AllTrim( x[2] ) == "DTR_MODRB1" } )
	Local nPCodRB2		:= AScan( aCompViag[1], { |x| AllTrim( x[2] ) == "DTR_CODRB2" } )
	Local nPModRB2		:= AScan( aCompViag[1], { |x| AllTrim( x[2] ) == "DTR_MODRB2" } )
	Local nPCodRB3		:= AScan( aCompViag[1], { |x| AllTrim( x[2] ) == "DTR_CODRB3" } )
	Local nPModRB3		:= AScan( aCompViag[1], { |x| AllTrim( x[2] ) == "DTR_MODRB3" } )
	Local nPCliCre		:= AScan( aCompViag[1], { |x| AllTrim( x[2] ) == "DTR_CREADI" } )
	Local nPLojCre		:= AScan( aCompViag[1], { |x| AllTrim( x[2] ) == "DTR_LOJCRE" } )
	Local nPNomCre		:= AScan( aCompViag[1], { |x| AllTrim( x[2] ) == "DTR_NOMCRE" } )

	Local nPDUPMot		:= AScan( aCompViag[3], { |x| AllTrim( x[2] ) == "DUP_CODMOT" } )
	Local nPDUPLiS		:= AScan( aCompViag[3], { |x| AllTrim( x[2] ) == "DUP_LIBSEG" } )
	Local nPDUPVSe		:= AScan( aCompViag[3], { |x| AllTrim( x[2] ) == "DUP_VALSEG" } )
	Local nPDUPCon		:= AScan( aCompViag[3], { |x| AllTrim( x[2] ) == "DUP_CONDUT" } )
	Local nPDUPSEv		:= AScan( aCompViag[3], { |x| AllTrim( x[2] ) == "DUP_SEQEVE" } )
	Local nX			:= 0
	Local nY			:= 0
	Local nLine			:= 0
	Local cFilRot       := ""
	Local cIdRot        := ""

	Default nOpc		:= ""
	Default dDatVge		:= ""
	Default cHorVge		:= ""
	Default cNumProg	:= ""
	Default cFilOri		:= ""
	Default cViagem		:= ""
	Default aCompViag	:= ""

	DbSelectArea( "DUD" )
	DUD->( DbSetOrder( 1 ) ) // DUD_FILIAL + DUD_FILDOC + DUD_DOC + DUD_SERIE + DUD_FILORI + DUD_VIAGEM

	DbSelectArea( "DLS" )
	DLS->( DbSetOrder( 1 ) ) // DLS_FILIAL + DLS_FILORI + DLS_NUMPRG + DLS_ITEDF8 + DLS_CODMOT

	DbSelectArea( "DD9" )
	DD9->( DbSetOrder( 1 ) ) // DD9_FILIAL + DD9_FILORI + DD9_NUMPRG + DD9_SEQPRG + DD9_ITEM
	cSeekDD9 := xFilial("DD9") + cFilOri + cNumProg

	DbSelectArea( "DM3" )
	DM3->( DbSetOrder( 1 ) ) // DM3_FILIAL + DM3_FILDOC + DM3_DOC + DM3_SERIE + DM3_FILORI + DM3_VIAGEM

	//Busca o valor do pedagio TPR
	If lIntTPR .And. nOpc == 3
		TMSAC24Id( 'DF8', DF8->(Recno()), 3, @cFilRot, @cIdRot ) 
		//--- Pendente TPR
		If !Empty(cIdRot)
			nValPdg:= TMS21VlPdg(cFilRot+cIdRot)
		EndIf
	EndIf

	If nOpc == 3 .Or. nOpc == 4	 //Incluir - Alterar
		//--- Busca a Ultima Sequencia do DUD da Viagem

		If !Empty(cFilOri) .And. !Empty(cViagem)
			nSeqDUD:= TmsSeqDUD( cFilOri, cViagem )
		EndIf

		If nSeqDUD > 0
			cSequen:= StrZero( nSeqDUD, Len(DUD->DUD_SEQUEN) )
		EndIf

		If nOpc == 3
			AAdd( aCab, {"DTQ_FILIAL",	xFilial("DTQ"), Nil	})
			AAdd( aCab, {"DTQ_FILORI",	cFilOri		, Nil	})
			AAdd( aCab, {"DTQ_VIAGEM",	cViagem		, Nil	})
			AAdd( aCab, {"DTQ_SERTMS",	cSerTMS		, Nil	})
			AAdd( aCab, {"DTQ_TIPTRA",	cTipTraDF8  , Nil	})
		EndIf

		AAdd( aCab, {"DTQ_ROTA",	cRota		, Nil	})

		If !Empty( DF8->DF8_FILVGE ) .AND. !Empty( DF8->DF8_NUMVGE )
			AAdd( aDadosDM4, { "DM4_FILVGE",	DF8->DF8_FILVGE, Nil	})
			AAdd( aDadosDM4, { "DM4_NUMVGE",	DF8->DF8_NUMVGE, Nil	})						
		EndIf

		If lIntTPR
			AAdd( aDadosDM4, { "DM4_DATINI", DF8->DF8_DATINI , NIL } )
			AAdd( aDadosDM4, { "DM4_HORINI", DF8->DF8_HORINI , NIL } )
			AAdd( aDadosDM4, { "DM4_DATFIM", DF8->DF8_DATFIM , NIL } )
			AAdd( aDadosDM4, { "DM4_HORFIM", DF8->DF8_HORFIM , NIL } )
		EndIf

		//-- Carrega Vetor do Planejamento da Viagem e da Operadora de Frotas
		If DLS->( DbSeek( xFilial("DLS") + cFilOri + cNumProg ) )
			If DLS->DLS_TPSPDG $ '3|5'   //REPOM PAMCARD				
				AAdd( aDadosDM5, { "DM5_FILIAL",	xFilial("DM5")						, Nil	})
				AAdd( aDadosDM5, { "DM5_CODOPE",	If( DLS->DLS_TPSPDG == '5', '02', '01'), Nil	})
				AAdd( aDadosDM5, { "DM5_TPSPDG",	DLS->DLS_TPSPDG						, Nil	})
				AAdd( aDadosDM5, { "DM5_QTDSAQ",	4									, Nil	})
				AAdd( aDadosDM5, { "DM5_QTDTRA",	DLS->DLS_QTDTRA						, Nil	})
			EndIf
		EndIf

		If DD9->( DbSeek( cSeekDD9 ) )
			
			While  DD9->( !Eof() ) .AND. DD9->( DD9_FILIAL + DD9_FILORI + DD9_NUMPRG ) == cSeekDD9

				If DUD->( DbSeek( xFilial("DUD") + DD9->(DD9_FILDOC + DD9_DOC + DD9_SERIE ) ) )

					If !DM3->( DbSeek(xFilial("DM3") + DUD->(DUD_FILDOC + DUD_DOC + DUD_SERIE ) ) )

						If lIntTPR .And. !Empty(cIdRot)
							cSequen:= DD9->DD9_SEQUEN
						Else
							If Empty( DUD->DUD_SEQUEN )
								cSequen := Soma1( cSequen, Len(DUD->DUD_SEQUEN) )
							Else
								cSequen := DUD->DUD_SEQUEN
							EndIf
						EndIf
						Aadd( aDadosDM3, { } )
						Aadd( aDadosDM3[Len(aDadosDM3)],{"DM3_SEQUEN", cSequen , Nil })
						Aadd( aDadosDM3[Len(aDadosDM3)],{"DM3_FILDOC",cFilOri , Nil })
						Aadd( aDadosDM3[Len(aDadosDM3)],{"DM3_DOC"   ,DUD->DUD_DOC , Nil })
						Aadd( aDadosDM3[Len(aDadosDM3)],{"DM3_SERIE" ,DUD->DUD_SERIE , Nil  })
						
						If lTMS3GFE .And. !Empty(DUD->DUD_UFORI)
							Aadd( aDadosDM8, {} )

							Aadd( aDadosDM8[Len(aDadosDM8)], { "DM8_FILDOC",	DUD->DUD_FILDOC,	Nil	} )
							Aadd( aDadosDM8[Len(aDadosDM8)], { "DM8_DOC",		DUD->DUD_DOC,		Nil } )
							Aadd( aDadosDM8[Len(aDadosDM8)], { "DM8_SERIE",		DUD->DUD_SERIE,		Nil	} )
							Aadd( aDadosDM8[Len(aDadosDM8)], { "DM8_UFORI",		DUD->DUD_UFORI,		Nil	} )
							Aadd( aDadosDM8[Len(aDadosDM8)], { "DM8_CDMUNO",	DUD->DUD_CDMUNO,	Nil	} )
							Aadd( aDadosDM8[Len(aDadosDM8)], { "DM8_CEPORI",	DUD->DUD_CEPORI,	Nil	} )
							Aadd( aDadosDM8[Len(aDadosDM8)], { "DM8_UFDES",		DUD->DUD_UFDES,		Nil	} )
							Aadd( aDadosDM8[Len(aDadosDM8)], { "DM8_CDMUND",	DUD->DUD_CDMUND,	Nil	} )
							Aadd( aDadosDM8[Len(aDadosDM8)], { "DM8_CEPDES",	DUD->DUD_CEPDES,	Nil	} )
							Aadd( aDadosDM8[Len(aDadosDM8)], { "DM8_TIPVEI",	DUD->DUD_TIPVEI,	Nil	} )
							Aadd( aDadosDM8[Len(aDadosDM8)], { "DM8_CDTPOP",	DUD->DUD_CDTPOP,	Nil	} )
							Aadd( aDadosDM8[Len(aDadosDM8)], { "DM8_CDCLFR",	DUD->DUD_CDCLFR,	Nil	} )
							Aadd( aDadosDM8[Len(aDadosDM8)], { "DM8_CHVEXT",	DUD->DUD_CHVEXT,	Nil	} )

						EndIf
					EndIf
				EndIf
				DD9->( DbSkip() )
			EndDo
		EndIf
		
		nLine := 1

		For nX := 1 To Len(aCompViag[2])

			If nPCodVei > 0
				Aadd( aDadosDTR, {} )
				
				AAdd( aDadosDTR[Len(aDadosDTR)], { "DTR_FILIAL",	xFilial("DTR") , NIL})
				AAdd( aDadosDTR[Len(aDadosDTR)], { "DTR_ITEM",	StrZero( nX, Len( DTR->DTR_ITEM ) ), NIL})
				AAdd( aDadosDTR[Len(aDadosDTR)], { "DTR_CODVEI", aCompViag[2][nx][nPCodVei]  , NIL})
				AAdd( aDadosDTR[Len(aDadosDTR)], { "DTR_MODVEI", aCompViag[2][nx][nPModVei]  , NIL})
				AAdd( aDadosDTR[Len(aDadosDTR)], { "DTR_PROVEI", aCompViag[2][nx][nPProVei]  , NIL})

				If !Empty( aCompViag[2][nx][nPCodRB1] )
					AAdd( aDadosDTR[Len(aDadosDTR)], { "DTR_CODRB1", aCompViag[2][nx][nPCodRB1]  , NIL})
					AAdd( aDadosDTR[Len(aDadosDTR)], { "DTR_MODRB1", aCompViag[2][nx][nPModRB1]  , NIL})
				EndIf
				If !Empty(aCompViag[2][nx][nPCodRB2])
					AAdd( aDadosDTR[Len(aDadosDTR)], { "DTR_CODRB2", aCompViag[2][nx][nPCodRB2]  , NIL})
					AAdd( aDadosDTR[Len(aDadosDTR)], { "DTR_MODRB2", aCompViag[2][nx][nPModRB2]  , NIL})
				EndIf
				If !Empty(aCompViag[2][nx][nPCodRB3])
					AAdd( aDadosDTR[Len(aDadosDTR)], { "DTR_CODRB3", aCompViag[2][nx][nPCodRB3] , NIL})
					AAdd( aDadosDTR[Len(aDadosDTR)], { "DTR_MODRB3", aCompViag[2][nx][nPModRB3]  , NIL})
				EndIf
				
				AAdd( aDadosDTR[Len(aDadosDTR)], { "DTR_CREADI", aCompViag[2][nx][nPCliCre] , NIL})
				AAdd( aDadosDTR[Len(aDadosDTR)], { "DTR_LOJCRE", aCompViag[2][nx][nPLojCre] , NIL})

				If lIntTPR 
					AAdd( aDadosDTR[Len(aDadosDTR)], { "DTR_VALPDG", nValPdg , NIL } )
				EndIf

				If Len(aDadosDTR) > 0 
					Aadd( aGrid     , {} )
					Aadd( aGrid[Len(aGrid)] , aClone(aDadosDTR) )
					Aadd( aGrid[Len(aGrid)] , "MdGridDTR" )
					Aadd( aGrid[Len(aGrid)] , "DTR" )
					Aadd( aGrid[Len(aGrid)] , .T.)	//-- Indica que a linha do GRID será pesquisada para alteração
				EndIf
			EndIf

			aDadosDUP := {}
			For nY := 1 To Len( aCompViag[4][nX][2] )
				
				If nPDUPMot > 0
					Aadd( aDadosDUP, {} )

					AAdd( aDadosDUP[Len(aDadosDUP)], { "DUP_FILIAL", xFilial("DUP")						, NIL})
					AAdd( aDadosDUP[Len(aDadosDUP)], { "DUP_CODMOT", aCompViag[4][nX][2][nY][nPDUPMot]	, NIL})
					AAdd( aDadosDUP[Len(aDadosDUP)], { "DUP_LIBSEG", aCompViag[4][nX][2][nY][nPDUPLiS]	, NIL})
					AAdd( aDadosDUP[Len(aDadosDUP)], { "DUP_VALSEG", aCompViag[4][nX][2][nY][nPDUPVSe]	, NIL})
					AAdd( aDadosDUP[Len(aDadosDUP)], { "DUP_CONDUT", aCompViag[4][nX][2][nY][nPDUPCon]	, NIL})
					AAdd( aDadosDUP[Len(aDadosDUP)], { "DUP_SEQEVE", aCompViag[4][nX][2][nY][nPDUPSEv]	, NIL})

					If Len(aDadosDUP) > 0 
						Aadd( aGrid     , {} )
						Aadd( aGrid[Len(aGrid)] , aClone(aDadosDUP) )
						Aadd( aGrid[Len(aGrid)] , "MdGridDUP" )
						Aadd( aGrid[Len(aGrid)] , "DUP" )
						Aadd( aGrid[Len(aGrid)] , .T.)	//-- Indica que a linha do GRID será pesquisada para alteração
					EndIf
				EndIf
			Next nY
			
		Next nX

		Aadd( aMaster     , {} )
		Aadd( aMaster[Len(aMaster)] , aClone(aCab) )
		Aadd( aMaster[Len(aMaster)] , "MdFieldDTQ" )
		Aadd( aMaster[Len(aMaster)] , "DTQ" )


		If Len(aDadosDM4) > 0 
			Aadd( aMaster     , {} )
			Aadd( aMaster[Len(aMaster)] , aClone(aDadosDM4) )
			Aadd( aMaster[Len(aMaster)] , "MdFieldDM4" )
			Aadd( aMaster[Len(aMaster)] , "DM4" )
		EndIf

		If Len(aDadosDM5) > 0 
			Aadd( aMaster     , {} )
			Aadd( aMaster[Len(aMaster)] , aClone(aDadosDM5) )
			Aadd( aMaster[Len(aMaster)] , "MdFieldDM5" )
			Aadd( aMaster[Len(aMaster)] , "DM5" )
		EndIf

		If Len(aDadosDM3) > 0 
			Aadd( aGrid  , {} )
			Aadd( aGrid[Len(aGrid)]  , aClone(aDadosDM3) )
			Aadd( aGrid[Len(aGrid)]  , "MdGridDM3")
			Aadd( aGrid[Len(aGrid)]  , "DM3" )
		EndIf
		
		If Len(aDadosDM8) > 0 
			Aadd( aGrid  , {} )
			Aadd( aGrid[Len(aGrid)]  , aClone(aDadosDM8) )
			Aadd( aGrid[Len(aGrid)]  , "MdGridDM8")
			Aadd( aGrid[Len(aGrid)]  , "DM8" )
		EndIf

		If Len(aMaster) > 0
			lRet	:= TMSExecAuto( "TMSAF60", aMaster, aGrid, nOpc, .T. )
		EndIf
	Else
		oModel := FWLoadModel( "TMSAF60" )
		oModel:SetOperation( 5 )
		oModel:Activate()
		lRet := oModel:CommitData()
		// Desativamos o Model
		oModel:DeActivate()
		oModel:Destroy()

		FwFreeObj(oModel)
	EndIf

	FwFreeArray(aDadosDM3)
	FwFreeArray(aDadosDM4)
	FwFreeArray(aDadosDM5)
	FwFreeArray(aDadosDM8)
	FwFreeArray(aDadosDTR)
	FwFreeArray(aDadosDUP)

	AEval( aAreas, { | x, y | RestArea(x), FwFreeArray(x) } )

Return lRet

//-----------------------------------------------------------
/* {Protheus.doc} LimpaVar
Limpa variaveis Static
@author		Katia
@since		14/10/21
@version	1.0
*/
//-----------------------------------------------------------
Static Function LimpaVar()
	lRot146Aut :=.F.
	aDoc146Aut := aSize(aDoc146Aut,0)
	aMsgErrPrg := aSize(aMsgErrPrg,0)
	lIncAuto   := .F.
	cCodCavAut := ""
	cRota146   := ""
	aDocErr    := aSize(aDocErr,0)
	nValPdg    := 0
	cIdRotTPR  := ""
	dDatIni	   := cTod('')
	dDatFim	   := cTod('')
	cHorIni	   := ""
	cHorFim	   := ""
	lAlteraTPR := .F.
Return

