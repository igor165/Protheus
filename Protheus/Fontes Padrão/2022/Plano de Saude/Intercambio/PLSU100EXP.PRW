#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "COLORS.CH"
#include "TCBROWSE.CH"
#include "JPEG.CH"
#include "fileIO.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#include "FWMVCDEF.CH"
#include "PLSU100EXP.CH"

#define F_BLOCK  512
static cFileHASH := criatrab( nil,.F. ) + ".tmp"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSU100EXP
Exportação do PTU A100 XML

@author  PLS
@version P12
@since   26/02/2019
/*/
//-------------------------------------------------------------------
function PLSU100EXP
local cPerg    := "PLSU100"
local cEmpIni := ""
local cEmpFin := ""
local cCodLay := ""
local dDatGer := date()
local aTipEnv := {"A","M","P"}
local lEnd := .T.

private cTipEnv := ""
private dDatIni := date()  
private dDatFin := date()
private cTipo   := ""

if Pergunte(cPerg,.T.)
    cEmpIni := mv_par01
    cEmpFin := mv_par02
    dDatIni := mv_par03
    dDatFin := mv_par04
    cTipEnv := aTipEnv[mv_par05]    
    dDatGer := dDataBase       
    cCodLay := cvaltochar(mv_par06)
    cOpeDe 	:= mv_par07
    cOpeAte := mv_par08
    cTipo 	:= cvaltochar(mv_par09)

	Processa({| lEnd|GerArqA100(cEmpIni,cEmpFin,dDatIni,dDatFin,cTipEnv,dDatGer,cCodLay,cOpeDe,cOpeAte,cTipo,@lEnd)},STR0001,STR0002,.T.)//"Geração do arquivo do PTU A100";"Processando"
		
endif

return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GerArqA100
Processamento do PTU A100

@author  PLS
@version P12
@since   26/02/2019
/*/
//-------------------------------------------------------------------
static function GerArqA100(cEmpIni,cEmpFin,dDatIni,dDatFin,cTipEnv,dDatGer,cCodLay,cOpeDe,cOpeAte,cTipo,lEnd)
//--- cGetFile -----
local cMascara	:= STR0003 + " .XML | *.XML" //"Arquivos"
local cTitulo	:= STR0004 //"Selecione o local"
local nMascpad	:= 0
local cRootPath	:= ""
local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
local l3Server	:= .F.
//------------------
//------------------
local cFileXML	:= ""
local cPathXML	:= ""
local lAmbos	:= cTipo == '3'
local nCabXml	:= 0
local nArqFull	:= 0
local cCodInt	:= plsintpad()
local nBytes	:= 0
local cCabTMP	:= ""
local cDetTMP	:= ""
local cXmlTMP	:= ""
local cBuffer	:= ""
local lFinal	:= .F.
local cSql		:= ""
local cLog		:= ""
local aCritica	:= {}
local aBenef    := {}
local cArqFinal	:= ""
local cTP_CONTR	:= ""
local cDatTemp 	:= ""
local cMsgX		:= ""
local nI		:= ""
Local cMask     	:= STR0005 + " (*.TXT) |*.txt|" //"Arquivos Texto"

private nArqHash := 0
default lEnd	:= .F.

If cTipo == "1" .or. lAmbos // Repasse ou ambos
	/*cSql += " SELECT 'P' AS TIPO, BA1_OPEDES OPEDES, BG9_DESCRI, BG9_TIPO, BG9_NREDUZ, BI3_DESCRI, BI3_DATINC, BI3_DATBLO, BI3_NATJCO, BI3_ABRANG, BA0_SUSEP, " 	
	cSql += " BA1_CODEMP, BA1_TIPREG, BA1_MATRIC, BTS_NOMCAR, BA1_DATNAS, BA1_SEXO, BA1_CPFUSR, BA1_ESTCIV, BA1_DATINC, BA1_TIPREG, BI3_MODPAG, BI3_CPFM, BA1_TIPREG, BI3_CLAPLS, " 	
	cSql += " BA1_NOMUSR, BTS_NRCRNA, BA1_MAE, BA1_PISPAS, BA1_CODINT, BA1_ENDERE, BA1_NR_END, BA1_BAIRRO, BA1_CEPUSR, BA1_MUNICI, BA1_ESTADO, BA1_DDD, BA1_TIPUSU, " 
	cSql += " BA1_GRAUPA, BA1_OPEDES, BA1_TELEFO, BA1_DATREP DATREP, BI3_CODIGO, BA1_DIGITO, BI3_CODSEG, BI3_SUSEP, BI3_APOSRG, BI3_CODPTU, BA1_DATINC VIGINI, BA1_DATBLO VIGFIM,  "
	cSql += " BQC.R_E_C_N_O_ BQCREC, BT5.R_E_C_N_O_ BT5REC, BQC_CODEMP, BQC_NUMCON, BQC_SUBCON, BQC_DATBLO, BT6_DATINC, BA3_DATBAS, BA3_DATBLO "
	
	cSql += " FROM " + RetSQLName("BA0") + " BA0 " 			// Operadora	
	
	cSql += " INNER JOIN " + RetSQLName("BA1") + " BA1 " 	// Beneficiario
	cSql += " 	ON  BA1_FILIAL = '" + xFilial("BA1") + "'" 
	cSql += "	AND BA1_OPEORI = '" + cCodInt + "'" 
	cSql += "	AND BA1_CODINT = '" + cCodInt + "'" 
	cSql += "	AND BA1_CODEMP BETWEEN '" + cEmpIni + "' AND '" + cEmpFin + "' "  
	cSql += "   AND BA1_OPEDES <> BA1_OPEORI "
	cSql += "   AND BA1_OPEDES BETWEEN '" + cOpeDe + "' AND '" + cOpeAte + "' " 
	cSql += "   AND BA1.D_E_L_E_T_ = ' ' "

	cSql += " INNER JOIN " + RetSQLName("BG9") + " BG9 " 	// Grupo Empresa
	cSql += " 	ON BG9_FILIAL  = '" + xFilial("BG9") + "'"
	cSql += "	AND BG9_CODINT = BA1_CODINT "
	cSql += "	AND BG9_CODIGO = BA1_CODEMP "
	//cSql += "	AND BG9_TIPO   = '2' "
	cSql += "   AND BG9.D_E_L_E_T_ = ' ' "
	
	cSql += " INNER JOIN " + RetSQLName("BA3") + " BA3 " 	// Familia
	cSql += " 	ON  BA3_FILIAL = '" + xFilial("BA3") + "'" 
	cSql += "	AND BA3_CODINT = BA1_CODINT "
	cSql += "	AND BA3_CODEMP = BA1_CODEMP "
	cSql += "	AND BA3_MATRIC = BA1_MATRIC " 
	cSql += "   AND BA3.D_E_L_E_T_ = ' ' "
	
	
	cSql += " INNER JOIN " + RetSQLName("BI3") + " BI3 " 	// Produto
	cSql += " ON BI3_FILIAL  = '" + xFilial("BI3") + "'"
	cSql += "	AND BI3_CODINT = BA1_CODINT "
	cSql += "   AND BI3_CODIGO = CASE WHEN BA1_CODPLA <> ' ' THEN BA1_CODPLA ELSE BA3_CODPLA END "
    cSql += "   AND BI3_VERSAO = CASE WHEN BA1_CODPLA <> ' ' THEN BA1_VERSAO ELSE BA3_VERSAO END "
	cSql += "   AND BI3.D_E_L_E_T_ = ' ' "
	
	
	cSql += " LEFT JOIN " + RetSQLName("BT5") + " BT5 " 	// Contrato 
	cSql += " ON BT5_FILIAL  = '" + xFilial("BT5") + "'"
	cSql += "	AND BT5_CODINT = BA1_CODINT "
	cSql += "	AND BT5_CODIGO = BA1_CODEMP "
	cSql += "	AND BT5_NUMCON = BA1_CONEMP "
	cSql += "	AND BT5_VERSAO = BA1_VERCON "
	cSql += "   AND BT5.D_E_L_E_T_ = ' ' "
	
	cSql += " LEFT JOIN " + RetSQLName("BQC") + " BQC " 	// Sub-Contrato 
	cSql += " ON BQC_FILIAL  = '" + xFilial("BQC") + "'"			
	cSql += "	AND BQC_CODIGO = BA1_CODINT || BA1_CODEMP "
	cSql += "	AND BQC_NUMCON = BA1_CONEMP "
	cSql += "	AND BQC_VERCON = BA1_VERCON "
	cSql += "	AND BQC_SUBCON = BA1_SUBCON "
	cSql += "	AND BQC_VERSUB = BA1_VERSUB "
	cSql += "   AND BQC.D_E_L_E_T_ = ' ' "    
	
	cSql += " LEFT JOIN " + RetSQLName("BT6") + " BT6 " 	// Plano no Subcontrato
	cSql += " ON BT6_FILIAL  = '" + xFilial("BT6") + "'"
	cSql += "   AND BT6_CODINT = BQC_CODINT "
	cSql += "   AND BT6_CODIGO = BA1_CODEMP "
	cSql += "   AND BT6_NUMCON = BQC_NUMCON "
	cSql += "   AND BT6_VERCON = BQC_VERCON " 
	cSql += "   AND BT6_SUBCON = BQC_SUBCON "
	cSql += "   AND BT6_VERSUB = BQC_VERSUB "
	cSql += "   AND BT6_CODPRO = BA3_CODPLA "
	cSql += "   AND BT6_VERSAO = BA3_VERSAO "
	cSql += "   AND BT6.D_E_L_E_T_ = ' ' "
	
	cSql += " INNER JOIN " + RetSQLName("BTS") + " BTS " 	// Vidas
	cSql += " ON BTS_FILIAL  = '" + xFilial("BTS") + "'"			
	cSql += "	AND BTS_MATVID  = BA1_MATVID " 
	cSql += "   AND BTS.D_E_L_E_T_ = ' '

	cSql += " WHERE BA0_FILIAL = '" + xFilial("BA0") + "' "
	cSql += " 	AND BA0_CODIDE = '"+Substr(cCodInt,1,1)+"' "
	cSql += " 	AND BA0_CODINT = '"+Substr(cCodInt,2,3)+"' "
	cSql += " 	AND BA0.D_E_L_E_T_ = ' ' "
	
	if !lAmbos
		cSql += " ORDER BY BA1_OPEDES "
	endIf*/
	msgAlert( STR0009,STR0007 )//"Implementação futura, PTU A100 simplificado contempla somente pós pagamento."; "Atenção"
	return
EndIf

If  cTipo == "2" .or. lAmbos // Habitual ou ambos
	/*if lAmbos
		cSql += " UNION " 
	endIf*/
	
	cSql += " SELECT DISTINCT 'C' AS TIPO, B5F_OPEHAB OPEDES, BG9_DESCRI, BG9_TIPO, BG9_NREDUZ, BI3_DESCRI, BI3_DATINC, BI3_DATBLO, BI3_NATJCO, BI3_ABRANG, BA0_SUSEP, "
	cSql += " BA1_CODEMP, BA1_TIPREG, BA1_MATRIC, BTS_NOMCAR, BA1_DATNAS, BA1_SEXO, BA1_CPFUSR, BA1_ESTCIV, BA1_DATINC, BA1_TIPREG, BI3_MODPAG, BI3_CPFM, BA1_TIPREG, BI3_CLAPLS, " 
	cSql += " BA1_NOMUSR, BTS_NRCRNA, BA1_MAE, BA1_PISPAS, BA1_CODINT, BA1_ENDERE, BA1_NR_END, BA1_BAIRRO, BA1_CEPUSR, BA1_MUNICI, BA1_ESTADO, BA1_DDD, BA1_TIPUSU, " 
	cSql += " BA1_GRAUPA, BA1_OPEDES, BA1_TELEFO, B5F_VIGINI DATREP, BI3_CODIGO, BA1_DIGITO, BI3_CODSEG, BI3_SUSEP, BI3_APOSRG, BI3_CODPTU, B5F_VIGINI VIGINI, B5F_VIGFIM VIGFIM,  "
	cSql += " BQC.R_E_C_N_O_ BQCREC, BT5.R_E_C_N_O_ BT5REC, BQC_CODEMP, BQC_NUMCON, BQC_SUBCON, BQC_DATBLO, BT6_DATINC, BA3_DATBAS, BA3_DATBLO "
	
	cSql += " FROM " + RetSQLName("BA0") + " BA0 " 			// Operadora
	
	cSql += " INNER JOIN " + RetSQLName("B5F") + " B5F " 	// Habituais
	cSql += "   ON B5F_FILIAL  = '" + xFilial("B5F") + "'"
	cSql += "   AND B5F_OPEORI  = '" + cCodInt + "'" 
	cSql += "   AND B5F_OPEHAB BETWEEN '" + cOpeDe + "' AND '" + cOpeAte + "' " 
	cSql += "   AND B5F_CODINT  = '" + cCodInt 	+ "'" 
	cSql += "   AND B5F_CODEMP BETWEEN '" + cEmpIni + "' AND '" + cEmpFin + "' "  
	cSql += "   AND B5F_VIGINI BETWEEN '" + dtos(dDatIni) + "' AND '" + dtos(dDatFin) + "' " 
	If cTipEnv == 'C'
		cSql += "   AND B5F_STATUS = '1' "
	EndIf
	cSql += "   AND B5F.D_E_L_E_T_ = ' ' "
	
	cSql += " INNER JOIN " + RetSQLName("BA1") + " BA1 " 	// Beneficiario
	cSql += " 	ON  BA1_FILIAL = '" + xFilial("BA1") + "'" 
	cSql += "	AND BA1_CODINT = B5F_CODINT "
	cSql += "	AND BA1_CODEMP = B5F_CODEMP "
	cSql += "	AND BA1_MATRIC = B5F_MATRIC " 
	cSql += "	AND BA1_TIPREG = B5F_TIPREG " 
	cSql += "	AND BA1_DIGITO = B5F_DIGITO " 
	cSql += "   AND BA1.D_E_L_E_T_ = ' ' "
	
	cSql += " INNER JOIN " + RetSQLName("BG9") + " BG9 " 	// Grupo Empresa
	cSql += " 	ON BG9_FILIAL  = '" + xFilial("BG9") + "'"
	cSql += "	AND BG9_CODINT = B5F_CODINT "
	cSql += "	AND BG9_CODIGO = B5F_CODEMP "
	//cSql += "	AND BG9_TIPO   = '2' "
	cSql += "   AND BG9.D_E_L_E_T_ = ' ' "
	
	cSql += " INNER JOIN " + RetSQLName("BA3") + " BA3 " 	// Familia
	cSql += " 	ON  BA3_FILIAL = '" + xFilial("BA3") + "'" 
	cSql += "	AND BA3_CODINT = B5F_CODINT "
	cSql += "	AND BA3_CODEMP = B5F_CODEMP "
	cSql += "	AND BA3_MATRIC = B5F_MATRIC " 
	cSql += "   AND BA3.D_E_L_E_T_ = ' ' "
	
	cSql += " INNER JOIN " + RetSQLName("BI3") + " BI3 " 	// Produto
	cSql += " ON BI3_FILIAL  = '" + xFilial("BI3") + "'"
	cSql += "	AND BI3_CODINT = B5F_CODINT "
	cSql += "   AND BI3_CODIGO = CASE WHEN BA1_CODPLA <> ' ' THEN BA1_CODPLA ELSE BA3_CODPLA END "
    cSql += "   AND BI3_VERSAO = CASE WHEN BA1_CODPLA <> ' ' THEN BA1_VERSAO ELSE BA3_VERSAO END "
    cSql += "   AND BI3.D_E_L_E_T_ = ' ' "
	
	cSql += " LEFT JOIN " + RetSQLName("BT5") + " BT5 " 	// Contrato 
	cSql += " ON BT5_FILIAL  = '" + xFilial("BT5") + "'"
	cSql += "	AND BT5_CODINT = BA1_CODINT "
	cSql += "	AND BT5_CODIGO = BA1_CODEMP "
	cSql += "	AND BT5_NUMCON = BA1_CONEMP "
	cSql += "	AND BT5_VERSAO = BA1_VERCON "
	cSql += "   AND BT5.D_E_L_E_T_ = ' ' "
	
	cSql += " LEFT JOIN " + RetSQLName("BQC") + " BQC " 	// Sub-Contrato 
	cSql += " ON BQC_FILIAL  = '" + xFilial("BQC") + "'"			
	cSql += "	AND BQC_CODIGO = BA1_CODINT || BA1_CODEMP "
	cSql += "	AND BQC_NUMCON = BA1_CONEMP "
	cSql += "	AND BQC_VERCON = BA1_VERCON "
	cSql += "	AND BQC_SUBCON = BA1_SUBCON "
	cSql += "	AND BQC_VERSUB = BA1_VERSUB "
	cSql += "   AND BQC.D_E_L_E_T_ = ' ' "
	
	cSql += " LEFT JOIN " + RetSQLName("BT6") + " BT6 " 	// Plano no Subcontrato
	cSql += " ON BT6_FILIAL  = '" + xFilial("BT6") + "'"
	cSql += "   AND BT6_CODINT = BQC_CODINT "
	cSql += "   AND BT6_CODIGO = BA1_CODEMP "
	cSql += "   AND BT6_NUMCON = BQC_NUMCON "
	cSql += "   AND BT6_VERCON = BQC_VERCON " 
	cSql += "   AND BT6_SUBCON = BQC_SUBCON "
	cSql += "   AND BT6_VERSUB = BQC_VERSUB "
	cSql += "   AND BT6_CODPRO = BA3_CODPLA "
	cSql += "   AND BT6_VERSAO = BA3_VERSAO "
	cSql += "   AND BT6.D_E_L_E_T_ = ' ' "
	
	cSql += " INNER JOIN " + RetSQLName("BTS") + " BTS " 	// Vidas
	cSql += " ON BTS_FILIAL  = '" + xFilial("BTS") + "'"			
	cSql += "	AND BTS_MATVID  = BA1_MATVID " 
	cSql += "   AND BTS.D_E_L_E_T_ = ' '

	cSql += " WHERE BA0_FILIAL = '" + xFilial("BA0") + "' "
	cSql += " 	AND BA0_CODIDE = '"+Substr(cCodInt,1,1)+"' "
	cSql += " 	AND BA0_CODINT = '"+Substr(cCodInt,2,3)+"' "
	cSql += " 	AND BA0.D_E_L_E_T_ = ' ' "	
	
	cSql += " ORDER BY OPEDES, BA1_CODEMP, BI3_CODIGO " 
Endif

If  cTipo == "2" //No futuro com a implementação do ptu A100 completo, não será necessário esse if
    cSql := ChangeQuery(cSql)   
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB",.F.,.T.)

	If TRB->(eof())
		msgAlert("Não encontrados dados para os parametros informados.")
		disarmTransaction()
		return()
	EndIf

	cArqFinal := cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
	
	If Empty(cArqFinal)
		msgAlert( STR0006,STR0007 ) //"Local não selecionado. Processo de geração de arquivo interrompido." # "Atenção!"
		disarmTransaction()
		return()
	EndIf

	cPathXML := PLSMUDSIS( "\temp\" )
	if( !existDir( cPathXML ) )
		if( MakeDir( cPathXML ) <> 0 )
			msgAlert( STR0008+ cPathXML,STR0007 ) //"Não foi possível criar o diretorio no servidor: " # "Atenção!"
			disarmTransaction()
			return()
		endIf
	endIf


	cXmlTMP := ""
	cFileXML  	:= getNomeArq(cCodInt)
	cLog := ""
	nArqFull := FCreate(cPathXML+cFileXML,FC_NORMAL,,.F.)
	nArqHash := fCreate( lower( cPathXML+cFileHASH ),FC_NORMAL,,.F. )
	cCabTMP := geraCabec( cPathXML, cFileXML, cOpeDe, cOpeAte, dDatGer, dDatIni, dDatFin  )
	//--< Append cabecalho TMP >--					
	nCabXml := fOpen( cCabTMP,FO_READ )

	if( nCabXml <= 0 )
		cLog +=  STR0010 + cCabTMP  //"Não foi possível abrir o arquivo: "
	else
		lFinal	:= .F.
		nBytes	:= 0
		cBuffer	:= ""

		Do While !lFinal
			nBytes := fRead( nCabXml,@cBuffer,F_BLOCK )

			if( fWrite( nArqFull,cBuffer,nBytes ) < nBytes )
				lFinal := .T.
			else
				lFinal := ( nBytes == 0 )
			endIf
		EndDo

		fClose( nCabXml )
		fErase( cCabTMP )
		fWrite( nArqFull,cXmlTMP )
		
		//percorrendo beneficiários para que sejam inseridos no arquivos
		While !TRB->(eof())
			//verificando o tipo de contratacao
			/*Do Case
				Case TRB->BI3_CLAPLS == "1" //Individual
					cTP_CONTR := "2"
				Case TRB->BI3_CLAPLS == "2" //Coletivo Empresarial
					cTP_CONTR := "3"
				Case TRB->BI3_CLAPLS == "3" //Coletivo por Adesao
					cTP_CONTR := "4"
				Otherwise
					cTP_CONTR := "0"
			EndCase	*/
       		 //adicionando dados do beneficário ao array que irá ser escrito no arquivo
        	aAdd(aBenef, {"cd_Unimed", TRB->BA1_CODINT})
        	aAdd(aBenef, {"id_Benef", TRB->BA1_CODEMP + TRB->BA1_MATRIC + TRB->BA1_TIPREG + TRB->BA1_DIGITO })
        	aAdd(aBenef, {"cd_cpf", TRB->BA1_CPFUSR})
        	aAdd(aBenef, {"nm_compl_benef", TRB->BA1_NOMUSR})
        	aAdd(aBenef, {"dt_Nasc", TRB->BA1_DATNAS})
        	aAdd(aBenef, {"tp_contr_local", cTipo}) // robertin - Só é permitido 1 e 2. Tipo de repasse - Pré ou Pós Pagamento
       		aAdd(aBenef, {"dt_ini_comp_risco",iif(TRB->TIPO == 'C',TRB->VIGINI,space(8))})
        	aAdd(aBenef, {"dt_fim_com_risco",TRB->VIGFIM})
			//gerando xml com os dados dos beneficiarios
			cDetTMP := geraBenef(cOpeDe, cOpeAte, @lend, @aCritica, aBenef )
			fWrite( nArqFull,cDetTMP )
			TRB->(dbSkip())
			aBenef := {}
		EndDo
		//--< Calculo e inclusao do HASH no arquivo >--					
		fClose( nArqHash )
		cHash := A100Hash( cPathXML+cFileHASH,nArqHash )
		cDatTemp := conDatXML( dDataBase )+ allTrim( time() )
		cXmlTMP := gerRodape( cHash, cDatTemp  )
		fWrite( nArqFull,cXmlTMP )
		fClose( nArqFull )
		CpyS2T( cPathXML+cFileXML,cArqFinal,.F.,.F. )
	endIf

EndIf
TRB->(dbCloseArea())
//exibição das críticas quando existirem
If len(aCritica) > 0
	//Exibe o Log
	nI := 0
	For nI:= 1 To len(aCritica)
		cMsgX += "Beneficiário não gerado: "+ AllTrim(aCritica[nI][1]) + " Matrícula: " + AllTrim(aCritica[nI][2]) + CRLF + "Crítica: " +AllTrim(aCritica[nI][3]) + CRLF
	Next
	__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG", cMsgX)
	DEFINE MSDIALOG oDlgLog TITLE "Arquivo gerado, porém existem críticas:" From 3,0 to 340,417 PIXEL//
	
	@ 5,5 GET oMemo  VAR cMsgX MEMO SIZE 200,145 OF oDlgLog PIXEL
	oMemo:bRClicked := {||AllwaysTrue() } 
	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlgLog:End() ENABLE OF oDlgLog PIXEL //Apaga
	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cMsgX))) ENABLE OF oDlgLog PIXEL	
	ACTIVATE MSDIALOG oDlgLog CENTER
Else
	msgAlert( STR0011 + cArqFinal+cFileXML,STR0012 )//"Arquivo gerado com sucesso em: ";
EndIf

return ()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gerRodape
Compoe os dados do rodapé do arquivo

@author    PLS
@version   1.xx
@since     28/02/2019

/*/
//------------------------------------------------------------------------------------------
static function gerRodape( cHash, dtTran )

	local cXML := ""

	cXML += A100Tag( 3,"Cad_simplificado"				        ,''						 ,.F.,.T.,.T. )
	cXML += A100Tag( 2,"Compart_Pos"				        	,''						 ,.F.,.T.,.T. )
	cXML += A100Tag( 1,"arquivoA100"				        	,''						 ,.F.,.T.,.T. )
	cXML += A100Tag( 1,"hash",cHash														 ,.T.,.T.,.T. )
	cXML += A100Tag( 1,"carimboCMB"		    		,''									 ,.T.,.F.,.T. )
	cXML += A100Tag( 2,"dt_postagem",dtTran+"~AA"									   	 ,.T.,.T.,.T.,,,.F.) 
	cXML += A100Tag( 2,"nr_protocolo","0"											     ,.T.,.T.,.T. )
	cXML += A100Tag( 1,"carimboCMB"		    		,''									 ,.F.,.T.,.T. )
	cXML += "</ptuA100>"

return cXML

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraBenef
Compoe os dados do arquivo

@author    PLS
@version   1.xx
@since     28/02/2019

@param     cPathXML = caminho do arquivo
@param     cFileXML = nome do arquivo
@return    cFileCAB = nome do arquivo
/*/
//------------------------------------------------------------------------------------------
static function geraBenef(cOpeDe, cOpeAte, lend, aCritica, aBenef )
	local cXML		:= ""
    local nI        := 0
    local lVld      := .T. //se não forem encontradas críticas, será inserido no arquivo
    local nPosNome  := 0
    local nPosId    := 0
	Local nPosCpf	:= 0
	local cTpCont 	:= ""
    
    nPosNome := aScan(aBenef,{|x| x[1] == "nm_compl_benef" })
    nPosId := aScan(aBenef, {|x| x[1] == "id_Benef"})
	nPosCpf := aScan(aBenef, {|x| x[1] == "cd_cpf"})

	//validando se o nome e a matricula estão preenchidos para que sejam validados os outros campos
	If nPosNome > 0 .AND. nPosId > 0
		If !Empty(aBenef[nPosNome][2]) .And. !Empty(aBenef[nPosId][2])
			For nI:=1 To len(aBenef)
				//validando cd_Unimed
				If aBenef[nI][1] == "cd_Unimed"
					If Empty(aBenef[nI][2])
						//add critica e não escreve no arquivo
						lVld := .F.
						aAdd(aCritica,{aBenef[nPosNome][2], aBenef[nPosId][2] , STR0013 })//"Cod UNimed não preenchido"
					EndIf
				EndIf

				//validando dt_Nasc
				If aBenef[nI][1] == "dt_Nasc"
					If Empty(aBenef[nI][2])
						//add critica e não escreve no arquivo
						lVld := .F.
						aAdd(aCritica,{aBenef[nPosNome][2], aBenef[nPosId][2] , STR0014 })//"Data de nascimento não preenchida"
					Else
						If DateDiffYear(dDataBase, Stod(aBenef[nI][2])) > 18 .And. nPosCpf > 0
							If Empty(aBenef[nPosCpf][2])
								lVld := .F.
								aAdd(aCritica,{aBenef[nPosNome][2], aBenef[nPosId][2] , STR0015 })//"Maior de 18 anos sem CPF preenchido"
							EndIf	
						EndIf
					EndIf
				EndIf

				//validando dt_ini_comp_risco
				If aBenef[nI][1] == "dt_ini_comp_risco"
					If Empty(aBenef[nI][2])
						//add critica e não escreve no arquivo
						lVld := .F.
						aAdd(aCritica,{aBenef[nPosNome][2], aBenef[nPosId][2] , STR0016 })//"dt_ini_comp_risco não preenchida"
					EndIf
				EndIf

				//validando tp_contr_local
				If aBenef[nI][1] == "tp_contr_local"
					If Empty(aBenef[nI][2])
						//add critica e não escreve no arquivo
						lVld := .F.
						aAdd(aCritica,{aBenef[nPosNome][2], aBenef[nPosId][2] , STR0017 })//"tp_contr_local não preenchida"
					EndIf
				EndIf

			Next
		Else
			lVld := .F.
		EndIf
	Else
		lVld := .F.
	EndIf

	//se não houve nenhuma crítica, gera as tags
	If lVld
	   cXML += A100Tag( 4,"beneficiario"		    		,''						 ,.T.,.F.,.T. )
	   cXML += A100Tag( 5,"identificacaoBenef"		    		,''						 ,.T.,.F.,.T. )
	   cXML += A100Tag( 6,"cd_Unimed",aBenef[aScan(aBenef, {|x| x[1] == "cd_Unimed"})][2] ,.T.,.T.,.T. )
	   cXML += A100Tag( 6,"id_Benef",aBenef[aScan(aBenef, {|x| x[1] == "id_Benef"})][2] ,.T.,.T.,.T. )
	   cXML += A100Tag( 5,"identificacaoBenef"		    		,''						 ,.F.,.T.,.T. )
	   If !Empty(aBenef[aScan(aBenef, {|x| x[1] == "cd_cpf"})][2])
	   	cXML += A100Tag( 5,"cd_cpf",aBenef[aScan(aBenef, {|x| x[1] == "cd_cpf"})][2] ,.T.,.T.,.T. )
	   EndIf
	   cXML += A100Tag( 5,"nm_compl_benef",aBenef[aScan(aBenef, {|x| x[1] == "nm_compl_benef"})][2] ,.T.,.T.,.T. )
	   cXML += A100Tag( 5,"dt_Nasc",aBenef[aScan(aBenef, {|x| x[1] == "dt_Nasc"})][2] ,.T.,.T.,.T. )
	   cXML += A100Tag( 5,"tp_contr_local",aBenef[aScan(aBenef, {|x| x[1] == "tp_contr_local"})][2] ,.T.,.T.,.T. )
	   cXML += A100Tag( 5,"dt_ini_comp_risco",aBenef[aScan(aBenef, {|x| x[1] == "dt_ini_comp_risco"})][2] ,.T.,.T.,.T. )
	   If !Empty(aBenef[aScan(aBenef, {|x| x[1] == "dt_fim_com_risco"})][2])
	   	cXML += A100Tag( 5,"dt_fim_com_risco",aBenef[aScan(aBenef, {|x| x[1] == "dt_fim_com_risco"})][2] ,.T.,.T.,.T. )		
	   EndIf
	   cXML += A100Tag( 4,"beneficiario"		    		,''						 ,.F.,.T.,.T. )

	EndIf

return cXML  

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraCabec
Compoe os dados do cabecalho do arquivo

@author    PLS
@version   1.xx
@since     28/02/2019

@param     cPathXML = caminho do arquivo
@param     cFileXML = nome do arquivo
@return    cFileCAB = nome do arquivo
/*/
//------------------------------------------------------------------------------------------
static function geraCabec( cPathXML, cFileXML, cOpeDe, cOpeAte, dDatGer, dDatIni, dDatFin  )
	local cXML := ""
	local cFileCAB	:= cPathXML + criatrab( nil,.F. ) + ".tmp"
	local nArqCab	:= fCreate( cFileCAB,FC_NORMAL,,.F. )

	cXML := '<?xml version="1.0" encoding="UTF-8"?>' + CRLF
	cXML += '<ptuA100 xmlns="http://ptu.unimed.coop.br/schemas/V1_0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ptu.unimed.coop.br/schemas/V1_0">' + CRLF

	cXML += A100Tag( 1,"cabecalho"		    		,''						 ,.T.,.F.,.T. )
	cXML += A100Tag( 2,"nrVerTra_PTU"          ,'18'						 ,.T.,.T.,.T. )
	cXML += A100Tag( 2,"unimed"		    	                    ,''		     ,.T.,.F.,.T. )
    cXML += A100Tag( 3,"cd_Uni_Destino"         ,cOpeDe						 ,.T.,.T.,.T. )
    cXML += A100Tag( 3,"cd_Uni_Origem"         ,cOpeAte						 ,.T.,.T.,.T. )
    cXML += A100Tag( 2,"unimed"				        ,''						 ,.F.,.T.,.T. )
    cXML += A100Tag( 2,"dt_geracao"          ,DToS(dDatGer)					 ,.T.,.T.,.T. )
    cXML += A100Tag( 2,"dt_Ini_Mov"          ,DToS(dDatIni)						 ,.T.,.T.,.T. )
    cXML += A100Tag( 2,"dt_Fim_Mov"          ,DToS(dDatFin)						 ,.T.,.T.,.T. )
    cXML += A100Tag( 1,"cabecalho"		    		,''						 ,.F.,.T.,.T. )
    cXML += A100Tag( 1,"arquivoA100"		    		,''						 ,.T.,.F.,.T. )
    cXML += A100Tag( 2,"Compart_Pos"		    		,''						 ,.T.,.F.,.T. )
    cXML += A100Tag( 3,"Cad_simplificado"		    		,''						 ,.T.,.F.,.T. )
	
	if( nArqCab == -1 )
		msgAlert( STR0018 + cFileCAB,STR0007 ) //"Não conseguiu criar o arquivo: " # "Atenção!"
		
		disarmTransaction()
		break
	else
		fWrite( nArqCab,cXML )
		fClose( nArqCab )
	endIf

return cFileCAB

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A100Tag
Formata a TAG XML a ser escrita no arquivo

@author    Jonatas Almeida
@version   1.xx
@since     02/09/2016

@param nSpc    = quantidade de tabulacao para identar o arquivo
@param cTag    = nome da tab
@param cVal    = valor da tag
@param lIni    = abertura de tag
@param lFin    = fechamento de tag
@param lPerNul = permitido nulo na tag
@param lRetPto = retira caracteres especiais
@param lEnvTag = retorna o conteudo da tag
@param lAtiva = será ativada as transformações feita pela função retPont

@return cRetTag= tag ou vazio
/*/
//------------------------------------------------------------------------------------------
function A100Tag( nSpc,cTag,cVal,lIni,lFin,lPerNul,lRetPto,lEnvTag, lAtiva )
	local	cRetTag := "" // Tag a ser gravada no arquivo texto
	
	Default lRetPto	:= .T.
	Default lEnvTag	:= .T.

	if( !empty( cVal ) .or. lPerNul )
		if( lIni ) // Inicializa a tag ?
			cRetTag += '<' + cTag + '>'
			cRetTag += allTrim( iif( lRetPto,retPont( cVal,lAtiva ),cVal ) )
		endIf

		if( lFin ) // Finaliza a tag ?
			cRetTag += '</' + cTag + '>'
		EndIf
		
		if lEnvTag .And. ( nArqHash > 0 ) // Escreve conteudo da tag no temporario pra calculo do hash
			FWrite(nArqHash,AllTrim(Iif(lRetPto,retPont(cVal,lAtiva),cVal))) 
		endIf

		cRetTag := replicate( "	", nSpc ) + cRetTag + CRLF // Identa o arquivo
	endIf
return iif( lEnvTag,cRetTag,"" )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} retPont
Tratamento de caracteres

@author    Jonatas Almeida
@version   1.xx
@since     1/09/2016
@return    cExp = sem tratamento
@param     cExp = tratado
/*/
//------------------------------------------------------------------------------------------
Function retPont( cExp,lAtiva )
default lAtiva := .T.

If lAtiva
	cExp := StrTran( cExp,"."," " )
	cExp := StrTran( cExp,"´"," " )
	cExp := StrTran( cExp,","," " )
	cExp := StrTran( cExp,"("," " )
	cExp := StrTran( cExp,")"," " )
	cExp := StrTran( cExp,"/"," " )
	cExp := StrTran( cExp,"\"," " )
	cExp := StrTran( cExp,":"," " )
	cExp := StrTran( cExp,"^"," " )
	cExp := StrTran( cExp,"*"," " )
	cExp := StrTran( cExp,"$"," " )
	cExp := StrTran( cExp,"#"," " )
	cExp := StrTran( cExp,"!"," " )
	cExp := StrTran( cExp,"["," " )
	cExp := StrTran( cExp,"]"," " )
	cExp := StrTran( cExp,"?"," " )
	cExp := StrTran( cExp,";"," " )
	cExp := StrTran( cExp,"ç","c" )
	cExp := StrTran( cExp,"`"," " )
	cExp := StrTran( cExp,Chr( 166)," " )
	cExp := StrTran( cExp,Chr( 167)," " )
	cExp := StrTran( cExp,"á","a" )
	cExp := StrTran( cExp,"ã","a" )
	cExp := StrTran( cExp,"à","a" )
	cExp := StrTran( cExp,"â","a" )
	cExp := StrTran( cExp,"é","e" )
	cExp := StrTran( cExp,"è","e" )
	cExp := StrTran( cExp,"ê","e" )
	cExp := StrTran( cExp,"í","i" )
	cExp := StrTran( cExp,"ì","i" )
	cExp := StrTran( cExp,"ó","o" )
	cExp := StrTran( cExp,"ò","o" )
	cExp := StrTran( cExp,"õ","o" )
	cExp := StrTran( cExp,"ô","o" )
	cExp := StrTran( cExp,"ú","u" )
	cExp := StrTran( cExp,"ù","u" )
	cExp := StrTran( cExp,"Á","A" )
	cExp := StrTran( cExp,"À","A" )
	cExp := StrTran( cExp,"Â","A" )
	cExp := StrTran( cExp,"Ã","A" )
	cExp := StrTran( cExp,"É","E" )
	cExp := StrTran( cExp,"È","E" )
	cExp := StrTran( cExp,"Ê","E" )
	cExp := StrTran( cExp,"Í","I" )
	cExp := StrTran( cExp,"Ì","I" )
	cExp := StrTran( cExp,"Ó","O" )
	cExp := StrTran( cExp,"Ò","O" )
	cExp := StrTran( cExp,"Õ","O" )
	cExp := StrTran( cExp,"Ô","O" )
	cExp := StrTran( cExp,"Ú","U" )
	cExp := StrTran( cExp,"Ç","C" )
	cExp := StrTran( cExp,"@"," " )
	cExp := StrTran( cExp,"%"," " )
	cExp := StrTran( cExp,"~"," " )
	cExp := StrTran( cExp,"¨"," " )
	cExp := StrTran( cExp,"{"," " )
	cExp := StrTran( cExp,"}"," " )
	cExp := StrTran( cExp,"+"," " )
	cExp := StrTran( cExp,"="," " )
	cExp := StrTran( cExp,"_"," " )
	cExp := StrTran( cExp,"<"," " )
	cExp := StrTran( cExp,">"," " )
	cExp := StrTran( cExp,"&"," " )
	cExp := StrTran( cExp,"|"," " )
	cExp := StrTran( cExp,"	"," " ) //TAB
EndIf	
return( cExp )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A100Hash
Calculo do hash

@author    Jonatas Almeida
@version   1.xx
@since     1/09/2016
@param     cHashFile	= nome do arquivo
@param     nArqFull		= Arquivo de hash
@return    cRetHash		= Codigo Hash

/*/
//------------------------------------------------------------------------------------------
function A100Hash( cHashFile,nArqFull )
	local cRetHash    := ""			// Hash calculado do arquivo SBX
	local cBuffer	  := ""			// Buffer lido
	local cHashBuffer := ""			// Buffer do hash calculado
	local cFnHash     := "MD5File"	// Definicao da função MD5File
	local nBytesRead  := 0			// Quantidade de bytes lidos no arquivo
	local nTamArq	  := 0			// Tamanho do arquivo em bytes
	local nFileHash	  := nArqFull	// Arquivo de hash
	local aPatch      := { }		// Conteudo do diretorio

	aPatch := directory( cHashFile,"F" )

	if( len( aPatch ) > 0 )
		nTamArq := aPatch[1,2]/1048576

		if( nTamArq > 0.9 )
			// Utilizado a macro-execucao por solicitacao da tecnologia, para evitar  
			// erro na funcao MD5File decorrente a utilizacao de binarios mais antigos
			cRetHash := &( cFnHash + "('" + cHashFile + "')" )
		else
			cBuffer   := space( F_BLOCK )
			nFileHash := fOpen( lower( cHashFile),FO_READ )
			nTamArq   := aPatch[ 1,2 ]	//Tamanho em bytes

			do while nTamArq > 0
				nBytesRead	:= fRead( nFileHash,@cBuffer,F_BLOCK )
				nTamArq		-= nBytesRead
				cHashBuffer	+= cBuffer
			endDo
			
			fClose( nFileHash )
			fErase( lower( cHashFile ) )
			cRetHash := md5( cHashBuffer,2 )
		endIf
	else
		msgInfo( STR0019 + cHashFile + CRLF + STR0020 ) //"O arquivo não foi encontrado ou não está acessível: " # "Hash do arquivo não pode ser calculado!"
	endIf
return cRetHash

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} conDatXML
Formatador de datas para o arquivo XML

@author    Jonatas Almeida
@version   1.xx
@since     5/09/2016
@param     cDataAnt	= Data nao formatada
@return    cNovaData = Data formatada para o XML

/*/
//------------------------------------------------------------------------------------------
function conDatXML( cDataAnt )
	local cNovaData := ""
	
	if( cDataAnt <> nil )
		if( valType( cDataAnt ) == "D" )
			cDataAnt := DtoS( cDataAnt )
		else
			cDataAnt := allTrim( cDataAnt )
		endIf
		
		if(! empty( cDataAnt ))
			cNovaData := subStr( cDataAnt,1,4 ) + "/"
			cNovaData += subStr( cDataAnt,5,2 ) + "/"
			cNovaData += subStr( cDataAnt,7,2 )
		endIf
	endIf
return cNovaData

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} validXML
Validador do arquivo XML em cima do arquivo XSD

@author    Jonatas Almeida
@version   1.xx
@since     5/09/2016
@param     cDataAnt	= Data nao formatada
@return    [lRet], lógica 

/*/
//------------------------------------------------------------------------------------------
function validXML( cXML,cXSD, cDir, cFileXML )
	local cError	:= ""
	local cWarning	:= ""	
	local lRet		:= .F.

	//--< Valida um arquivo XML com o XSD >--
	if( xmlFVldSch( cXML,cXSD,@cError,@cWarning ) )
		lRet := .T.
	endIf

	if( !lRet )		
		gerLogErr( cError, cDir, cFileXML )		
	endIf
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gerLogErr
Grava arquivo de log

@author    Jonatas Almeida
@version   1.xx
@since     8/09/2016
@param     cError = lista de erros encontrados

/*/
//------------------------------------------------------------------------------------------
function gerLogErr( cError, cDir, cFileXML )
	local cMascara	:= STR0003 + " .LOG | *.log" //"Arquivos"
	local cTitulo	:= STR0004 //"Selecione o local"
	local nMascpad	:= 0
	local cRootPath	:= ""
	local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
	local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
	local l3Server	:= .T.	//.T. = apresenta o árvore do servidor || .F. = não apresenta
	local cFileLOG	:= strtran(cFileXML,".xml") + "_" + allTrim( B2S->B2S_OPEORI ) + allTrim( B2S->B2S_NUMLOT ) + ".log"
	local cPathLOG	:= ""	
	local nArqLog	:= 0	

	cPathLOG	:= cDir//cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
	nArqLog		:= fCreate( cPathLOG+cFileLOG,FC_NORMAL,,.F. )
	
	fWrite( nArqLog,cError )
	fClose( nArqLog )
	
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getNomeArq
Gerador de numerico sequencial para controle da nomenclatura do arquivo

@author    PLS
@version   1.xx
@since     18/04/2018


/*/
//------------------------------------------------------------------------------------------
static function getNomeArq(cUniEnv)

local cSeq 		:= ""
local cProxSeq	:= ""
local cNomArq	:= ""
local cUniOri	:= plsintpad()

If BA0->(MsSeek(xFilial("BA0")+cUniEnv))

	cSeq := BA0->BA0_A100

    If val(cSeq) < 9999
    	cProxSeq := strzero(val(cSeq)+1,4)
    	cSeq     := cProxSeq
    Else
    	cProxSeq := "0000"
    	cSeq     := "9999"
    Endif
	
	BA0->(Reclock("BA0",.F.))
	BA0->BA0_A100 := cProxSeq
	BA0->(MsUnlock())
	
	cNomArq := "U" + substr(cUniOri,2,3) + cSeq + ".xml"	
endif

return cNomArq //U00010001.xml

