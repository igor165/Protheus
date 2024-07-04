#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSR640.CH"

//===========================================================================================================
/* Impressao de produtos perigosos
@author  	Fabio Marchiori
@version 	
@build		
@since 		24/10/2013
@return 	*/
//===========================================================================================================

Function TMSR640    
                     
Local oReport

oReport := ReportDef()
oReport:PrintDialog()

Return()

//===========================================================================================================
/* ReportDef
@author  	
@version 	
@build		
@since 		24/10/2013
@return 	*/
//===========================================================================================================

Static Function ReportDef()

Local oReport
Local oProdutos
Local oItens
Local cAliasQry   := GetNextAlias()
Local cTipoProd   := "QUIMICO"  
  
oReport:= TReport():New("TMSR640",STR0001,"TMR640", {|oReport| ReportPrint(oReport,cAliasQry)},STR0002)      
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)
Pergunte("TMR640",.F.)

oProdutos:= TRSection():New(oReport,STR0001,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oProdutos:SetPageBreak(.T.)
oProdutos:SetTotalInLine(.F.)

TRCell():New(oProdutos,"REM_CNPJ"			,"   ",STR0003	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| Transform(REM_CNPJ,PesqPict('SA1','A1_CGC')) })
TRCell():New(oProdutos,"REM_NOME"			,"   ",STR0004	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProdutos,"DES_CNPJ"			,"   ",STR0005	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| Transform(DES_CNPJ,PesqPict('SA1','A1_CGC')) })
TRCell():New(oProdutos,"DES_NOME"			,"   ",STR0006	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProdutos,"DEV_CNPJ"			,"   ",STR0007	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| Transform(DEV_CNPJ,PesqPict('SA1','A1_CGC')) })
TRCell():New(oProdutos,"DEV_NOME"			,"   ",STR0008	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oProdutos,"REGORI_DESCRI" 	,"   ",STR0009	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| AllTrim(REGORI_DESCRI) +"/"+REGORI_UF })
TRCell():New(oProdutos,"REGDES_DESCRI"		,"   ",STR0010	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| AllTrim(REGDES_DESCRI) +"/"+REGDES_UF })

TRCell():New(oProdutos,"NF_KM"				,"   ",STR0011	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oProdutos,"VEICUL_PLACA"		,"   ",STR0012	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oProdutos,"MOTORI_CNPJ"		,"   ",STR0035	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| IIF(Len(AllTrim(MOTORI_CNPJ)) < 14, Transform(MOTORI_CNPJ,"@R 999.999.999-99"), Transform(MOTORI_CNPJ,"@R 99.999.999/9999-99")) })
TRCell():New(oProdutos,"MOTORI_NOME"		,"   ",STR0036	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oProdutos,"VIAGEM_NUM"		,"   ",STR0030	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProdutos,"MANIFE_NUM"		,"   ",STR0013	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProdutos,"MANIFE_TIPO"		,"   ",STR0014	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| IIF(VIAGEM_TIPO =="2", "TRANSFERENCIA", IIF(VIAGEM_TIPO =="3", "ENTREGA", " ")) })

TRCell():New(oProdutos,"NF_NUMNF" 			,"   ",STR0015	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProdutos,"NF_SERNF"			,"   ",STR0016	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProdutos,"NF_VOL"				,"   ",STR0027	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProdutos,"NF_PESO"			,"   ",STR0028	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProdutos,"NF_VALOR"			,"   ",STR0017	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProdutos,"NF_DTCOLETA"		,"   ",STR0033	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| stod(NF_DTCOLETA) /*code-block de impressao*/ })

TRCell():New(oProdutos,"CTRC_DOC"  			,"   ",STR0018	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProdutos,"CTRC_DATEMI"		,"   ",STR0019	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| stod(CTRC_DATEMI) /*code-block de impressao*/ })
TRCell():New(oProdutos,"CTRC_DATEMI"		,"   ",STR0034	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| MesExtenso(Month(stod(CTRC_DATEMI))) /*code-block de impressao*/ })
TRCell():New(oProdutos,"CTRC_FRETE"		,"   ",STR0020	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProdutos,"CTRC_DATENT"		,"   ",STR0029	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| stod(CTRC_DATENT) /*code-block de impressao*/ })

TRCell():New(oProdutos,"PRODUT_DESC"		,"   ",STR0021	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProdutos,"CLAPRD_DESCRI"		,"   ",STR0022	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProdutos,"GRUPO_NATUREZA"	,"   ",STR0032	,	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| IIF(CLAPRD_RISCO =" ", "NÃO CLASSIFICADO", "PRODUTO PERIGOSO") })
TRCell():New(oProdutos,"CLAPRD_ONU"		,"   ",STR0023	,  	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| IIF(CLAPRD_RISCO =" ", "NÃO CLASSIFICADO", CLAPRD_ONU) })
TRCell():New(oProdutos,"CLAPRD_CLASSE"		,"   ",STR0024	, 	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProdutos,"CLAPRD_RISCO"		,"   ",STR0025	,  	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| IIF(CLAPRD_RISCO =" ", "NÃO CLASSIFICADO", CLAPRD_RISCO) })
TRCell():New(oProdutos,cTipoProd			,"   ",STR0031	,  	/*Picture*/,12/*Tamanho*/,/*lPixel*/,{|| "QUIMICO" })
TRCell():New(oProdutos,"SM0->M0_NOMECOM"	,"   ",STR0026	,  	/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)


Return(oReport)

//===========================================================================================================
/* ReportPrint
@author  	Fabio Marchiori
@version 	
@build		
@since 		24/10/2013
@return 	*/
//===========================================================================================================

Static Function ReportPrint(oReport,cAliasQry)

	BeginSql Alias cAliasQry	
	
		SELECT 
			//REMETENTE
			CLIREM.A1_CGC REM_CNPJ,
			CLIREM.A1_NOME REM_NOME, 
			CLIREM.A1_PESSOA REM_PESSOA,
		
			//DESTINATÁRIO
			CLIDES.A1_CGC DES_CNPJ,
			CLIDES.A1_NOME DES_NOME,
			CLIDES.A1_PESSOA DES_PESSOA,
			
			//DEVEDOR DO FRETE
			CLIDEV.A1_CGC DEV_CNPJ,
			CLIDEV.A1_NOME DEV_NOME,
			CLIDEV.A1_PESSOA DEV_PESSOA,
			
			//DADOS CTRC
			CTRC.DT6_FILIAL CTRC_FILIAL,
			CTRC.DT6_FILDOC CTRC_FILDOC,
			CTRC.DT6_DOC CTRC_DOC,
			CTRC.DT6_SERIE CTRC_SERIE,
			CTRC.DT6_DATEMI CTRC_DATEMI,
			CTRC.DT6_CDRCAL CTRC_ORICAL,
			CTRC.DT6_VALTOT CTRC_FRETE,
			CTRC.DT6_STATUS CTRC_STATUS,
			CTRC.DT6_DATENT CTRC_DATENT,
			
			//DADOS NF
			NFSCTR.DTC_NUMNFC NF_NUMNF,
			NFSCTR.DTC_SERNFC NF_SERNF,
			NFSCTR.DTC_VALOR NF_VALOR,
			NFSCTR.DTC_KM NF_KM,
			NFSCTR.DTC_QTDVOL NF_VOL,
			NFSCTR.DTC_PESO NF_PESO,
			NFSCTR.DTC_EMINFC NF_DTCOLETA,
			
			//PRODUTO DO CTRC
			PRODUT.B1_COD PRODUT_COD,
			PRODUT.B1_DESC PRODUT_DESC,
			
			//COMPLEMENTO DO PRODUTO
			PRDCOM.B5_CEME PRDCOM_NCIENT,
			
			//CLASSICACAO DO PRODUTO ONU
			CLAPRD.DY3_ONU CLAPRD_ONU,
			CLAPRD.DY3_CLASSE CLAPRD_CLASSE,
			CLAPRD.DY3_NRISCO CLAPRD_RISCO,
			CLAPRD.DY3_DESCRI CLAPRD_DESCRI,
						
			//DADOS VEICULO
			VEICUL.DA3_PLACA VEICUL_PLACA,
			VEICUL.DA3_DESC VEICUL_DESC,
			
			//DADOS MOTORISTA
			MOTORI.DA4_NOME MOTORI_NOME,
			MOTORI.DA4_CGC  MOTORI_CNPJ,
			
			//DADOS DA VIAGEM
			VIAGEM.DTQ_VIAGEM VIAGEM_NUM,
			VIAGEM.DTQ_SERTMS VIAGEM_TIPO,
			
			//REGIAO DE ORIGEM CALCULO
			REGORI.DUY_DESCRI REGORI_DESCRI,
			REGORI.DUY_EST	REGORI_UF,
			
			//REGIAO DE DESTINO DO CALCULO
			REGDES.DUY_DESCRI REGDES_DESCRI,
			REGDES.DUY_EST	REGDES_UF,

			//DADOS DO MANIFESTO
			MANIFE.DTX_MANIFE MANIFE_NUM
			
			
		FROM %table:DT6% CTRC 
			 INNER JOIN %table:SA1% CLIREM ON ( (CLIREM.A1_FILIAL  = %xFilial:SA1% AND CLIREM.%NotDel% ) AND CLIREM.A1_COD = CTRC.DT6_CLIREM AND CLIREM.A1_LOJA = CTRC.DT6_LOJREM ) 
			 INNER JOIN %table:SA1% CLIDES ON ( (CLIDES.A1_FILIAL  = %xFilial:SA1% AND CLIDES.%NotDel%) AND CLIDES.A1_COD = CTRC.DT6_CLIDES AND CLIDES.A1_LOJA = CTRC.DT6_LOJDES )
			 INNER JOIN %table:SA1% CLIDEV ON ( (CLIDEV.A1_FILIAL  = %xFilial:SA1% AND CLIDEV.%NotDel%) AND CLIDEV.A1_COD = CTRC.DT6_CLIDEV AND CLIDEV.A1_LOJA = CTRC.DT6_LOJDEV  )
			 INNER JOIN %table:DUY% REGORI ON ( (REGORI.DUY_FILIAL = %xFilial:DUY% AND REGORI.%NotDel%) AND REGORI.DUY_GRPVEN = CTRC.DT6_CDRORI ) 
			 INNER JOIN %table:DUY% REGDES ON ( (REGDES.DUY_FILIAL = %xFilial:DUY% AND REGDES.%NotDel%) AND REGDES.DUY_GRPVEN = CTRC.DT6_CDRDES ) 
			 INNER JOIN %table:DTC% NFSCTR ON ( (NFSCTR.DTC_FILIAL = %xFilial:DTC% AND NFSCTR.%NotDel%) AND NFSCTR.DTC_FILORI = CTRC.DT6_FILORI AND NFSCTR.DTC_DOC = CTRC.DT6_DOC AND NFSCTR.DTC_SERIE = CTRC.DT6_SERIE )
			 INNER JOIN %table:SB1% PRODUT ON ( (PRODUT.B1_FILIAL  = %xFilial:SB1% AND PRODUT.%NotDel%) AND NFSCTR.DTC_CODPRO = PRODUT.B1_COD)
			        JOIN %table:SB5% PRDCOM ON ( (PRDCOM.B5_FILIAL  = %xFilial:SB5% AND PRDCOM.%NotDel%) AND PRODUT.B1_COD = PRDCOM.B5_COD AND PRDCOM.B5_CARPER = '1' )
			 LEFT  JOIN %table:DY3% CLAPRD ON ( (CLAPRD.DY3_FILIAL = %xFilial:DY3% AND CLAPRD.%NotDel%) AND PRDCOM.B5_ONU = CLAPRD.DY3_ONU)
			 LEFT  JOIN %table:DTQ% VIAGEM ON ( (VIAGEM.DTQ_FILIAL = %xFilial:DTQ% AND VIAGEM.%NotDel%) AND CTRC.DT6_FILVGA = VIAGEM.DTQ_FILORI AND CTRC.DT6_NUMVGA = VIAGEM.DTQ_VIAGEM)
			 LEFT  JOIN %table:DTR% COMVGA ON ( (COMVGA.DTR_FILIAL = %xFilial:DTR% AND COMVGA.%NotDel%) AND VIAGEM.DTQ_FILORI = COMVGA.DTR_FILORI AND VIAGEM.DTQ_VIAGEM = COMVGA.DTR_VIAGEM)
			 LEFT  JOIN %table:DA3% VEICUL ON ( (VEICUL.DA3_FILIAL = %xFilial:DA3% AND VEICUL.%NotDel%) AND COMVGA.DTR_CODVEI = VEICUL.DA3_COD )
			 LEFT  JOIN %table:DUP% MOTVGA ON ( (MOTVGA.DUP_FILIAL = %xFilial:DUP% AND MOTVGA.%NotDel%) AND VIAGEM.DTQ_FILORI = MOTVGA.DUP_FILORI AND VIAGEM.DTQ_VIAGEM = MOTVGA.DUP_VIAGEM)
			 LEFT  JOIN %table:DA4% MOTORI ON ( (MOTORI.DA4_FILIAL = %xFilial:DA4% AND MOTORI.%NotDel%) AND MOTVGA.DUP_CODMOT = MOTORI.DA4_COD )
			 LEFT  JOIN %table:DTX% MANIFE ON ( (MANIFE.DTX_FILIAL = %xFilial:DTX% AND MANIFE.%NotDel%) AND VIAGEM.DTQ_FILORI = MANIFE.DTX_FILORI AND VIAGEM.DTQ_VIAGEM = MANIFE.DTX_VIAGEM)
		
		WHERE 
			CTRC.D_E_L_E_T_ = ' ' 
			AND CTRC.DT6_FILDOC	>= %Exp:mv_par01%
			AND CTRC.DT6_FILDOC	<= %Exp:mv_par02%
			AND CTRC.DT6_DATEMI	>= %Exp:mv_par03%
			AND CTRC.DT6_DATEMI	<= %Exp:mv_par04%
			AND CTRC.DT6_DOC		>= %Exp:mv_par05%
			AND CTRC.DT6_DOC		<= %Exp:mv_par06%
			AND CTRC.DT6_SERIE	>= %Exp:mv_par07%
			AND CTRC.DT6_SERIE	<= %Exp:mv_par08%
			
		UNION		
		SELECT 
			//REMETENTE
			CLIREM.A1_CGC REM_CNPJ,
			CLIREM.A1_NOME REM_NOME, 
			CLIREM.A1_PESSOA REM_PESSOA,
		
			//DESTINATÁRIO
			CLIDES.A1_CGC DES_CNPJ,
			CLIDES.A1_NOME DES_NOME,
			CLIDES.A1_PESSOA DES_PESSOA,
			
			//DEVEDOR DO FRETE
			CLIDEV.A1_CGC DEV_CNPJ,
			CLIDEV.A1_NOME DEV_NOME,
			CLIDEV.A1_PESSOA DEV_PESSOA,
			
			//DADOS CTRC
			CTRC.DT6_FILIAL CTRC_FILIAL,
			CTRC.DT6_FILDOC CTRC_FILDOC,
			CTRC.DT6_DOC CTRC_DOC,
			CTRC.DT6_SERIE CTRC_SERIE,
			CTRC.DT6_DATEMI CTRC_DATEMI,
			CTRC.DT6_CDRCAL CTRC_ORICAL,
			CTRC.DT6_VALTOT CTRC_FRETE,
			CTRC.DT6_STATUS CTRC_STATUS,
			CTRC.DT6_DATENT CTRC_DATENT,
			
			//DADOS NF
			NFSCTR.DY4_NUMNFC NF_NUMNF,
			NFSCTR.DY4_SERNFC NF_SERNF,			
			NFSCTR2.DTC_VALOR NF_VALOR,
			NFSCTR2.DTC_KM NF_KM,
			NFSCTR.DY4_QTDVOL NF_VOL,
			NFSCTR2.DTC_PESO NF_PESO,
			NFSCTR2.DTC_EMINFC NF_DTCOLETA,	
						             
			//PRODUTO DO CTRC
			PRODUT.B1_COD PRODUT_COD,
			PRODUT.B1_DESC PRODUT_DESC,
			
			//COMPLEMENTO DO PRODUTO
			PRDCOM.B5_CEME PRDCOM_NCIENT,
			
			//CLASSICACAO DO PRODUTO ONU
			CLAPRD.DY3_ONU CLAPRD_ONU,
			CLAPRD.DY3_CLASSE CLAPRD_CLASSE,
			CLAPRD.DY3_NRISCO CLAPRD_RISCO,
			CLAPRD.DY3_DESCRI CLAPRD_DESCRI,
						
			//DADOS VEICULO
			VEICUL.DA3_PLACA VEICUL_PLACA,
			VEICUL.DA3_DESC VEICUL_DESC,
			
			//DADOS MOTORISTA
			MOTORI.DA4_NOME MOTORI_NOME,
			MOTORI.DA4_CGC  MOTORI_CNPJ,
			
			//DADOS DA VIAGEM
			VIAGEM.DTQ_VIAGEM VIAGEM_NUM,
			VIAGEM.DTQ_SERTMS VIAGEM_TIPO,
			
			//REGIAO DE ORIGEM CALCULO
			REGORI.DUY_DESCRI REGORI_DESCRI,
			REGORI.DUY_EST	REGORI_UF,
			
			//REGIAO DE DESTINO DO CALCULO
			REGDES.DUY_DESCRI REGDES_DESCRI,
			REGDES.DUY_EST	REGDES_UF,

			//DADOS DO MANIFESTO
			MANIFE.DTX_MANIFE MANIFE_NUM
			
			
		FROM %table:DT6% CTRC 
			 INNER JOIN %table:SA1% CLIREM ON ( (CLIREM.A1_FILIAL  = %xFilial:SA1% AND CLIREM.%NotDel% ) AND CLIREM.A1_COD = CTRC.DT6_CLIREM AND CLIREM.A1_LOJA = CTRC.DT6_LOJREM ) 
			 INNER JOIN %table:SA1% CLIDES ON ( (CLIDES.A1_FILIAL  = %xFilial:SA1% AND CLIDES.%NotDel%) AND CLIDES.A1_COD = CTRC.DT6_CLIDES AND CLIDES.A1_LOJA = CTRC.DT6_LOJDES )
			 INNER JOIN %table:SA1% CLIDEV ON ( (CLIDEV.A1_FILIAL  = %xFilial:SA1% AND CLIDEV.%NotDel%) AND CLIDEV.A1_COD = CTRC.DT6_CLIDEV AND CLIDEV.A1_LOJA = CTRC.DT6_LOJDEV  )
			 INNER JOIN %table:DUY% REGORI ON ( (REGORI.DUY_FILIAL = %xFilial:DUY% AND REGORI.%NotDel%) AND REGORI.DUY_GRPVEN = CTRC.DT6_CDRORI ) 
			 INNER JOIN %table:DUY% REGDES ON ( (REGDES.DUY_FILIAL = %xFilial:DUY% AND REGDES.%NotDel%) AND REGDES.DUY_GRPVEN = CTRC.DT6_CDRDES ) 
			 INNER JOIN %table:DY4% NFSCTR ON ( (NFSCTR.DY4_FILIAL = %xFilial:DY4% AND NFSCTR.%NotDel%) AND NFSCTR.DY4_FILORI = CTRC.DT6_FILORI AND NFSCTR.DY4_DOC = CTRC.DT6_DOC AND NFSCTR.DY4_SERIE = CTRC.DT6_SERIE )
			 		JOIN %table:DTC% NFSCTR2 ON ( (NFSCTR2.DTC_FILIAL = %xFilial:DTC% AND NFSCTR2.%NotDel%) AND NFSCTR2.DTC_FILORI = NFSCTR.DY4_FILORI AND NFSCTR2.DTC_NUMNFC = NFSCTR.DY4_NUMNFC AND NFSCTR2.DTC_SERNFC = NFSCTR.DY4_SERNFC AND NFSCTR2.DTC_CODPRO = NFSCTR.DY4_CODPRO ) 			 
			 INNER JOIN %table:SB1% PRODUT ON ( (PRODUT.B1_FILIAL  = %xFilial:SB1% AND PRODUT.%NotDel%) AND NFSCTR.DY4_CODPRO = PRODUT.B1_COD)
			       JOIN %table:SB5% PRDCOM ON ( (PRDCOM.B5_FILIAL  = %xFilial:SB5% AND PRDCOM.%NotDel%) AND PRODUT.B1_COD = PRDCOM.B5_COD AND PRDCOM.B5_CARPER = '1' )
			 LEFT  JOIN %table:DY3% CLAPRD ON ( (CLAPRD.DY3_FILIAL = %xFilial:DY3% AND CLAPRD.%NotDel%) AND PRDCOM.B5_ONU = CLAPRD.DY3_ONU)
			 LEFT  JOIN %table:DTQ% VIAGEM ON ( (VIAGEM.DTQ_FILIAL = %xFilial:DTQ% AND VIAGEM.%NotDel%) AND CTRC.DT6_FILVGA = VIAGEM.DTQ_FILORI AND CTRC.DT6_NUMVGA = VIAGEM.DTQ_VIAGEM)
			 LEFT  JOIN %table:DTR% COMVGA ON ( (COMVGA.DTR_FILIAL = %xFilial:DTR% AND COMVGA.%NotDel%) AND VIAGEM.DTQ_FILORI = COMVGA.DTR_FILORI AND VIAGEM.DTQ_VIAGEM = COMVGA.DTR_VIAGEM)
			 LEFT  JOIN %table:DA3% VEICUL ON ( (VEICUL.DA3_FILIAL = %xFilial:DA3% AND VEICUL.%NotDel%) AND COMVGA.DTR_CODVEI = VEICUL.DA3_COD )
			 LEFT  JOIN %table:DUP% MOTVGA ON ( (MOTVGA.DUP_FILIAL = %xFilial:DUP% AND MOTVGA.%NotDel%) AND VIAGEM.DTQ_FILORI = MOTVGA.DUP_FILORI AND VIAGEM.DTQ_VIAGEM = MOTVGA.DUP_VIAGEM)
			 LEFT  JOIN %table:DA4% MOTORI ON ( (MOTORI.DA4_FILIAL = %xFilial:DA4% AND MOTORI.%NotDel%) AND MOTVGA.DUP_CODMOT = MOTORI.DA4_COD )
			 LEFT  JOIN %table:DTX% MANIFE ON ( (MANIFE.DTX_FILIAL = %xFilial:DTX% AND MANIFE.%NotDel%) AND VIAGEM.DTQ_FILORI = MANIFE.DTX_FILORI AND VIAGEM.DTQ_VIAGEM = MANIFE.DTX_VIAGEM)
		
		WHERE 
			CTRC.D_E_L_E_T_ = ' ' 
			AND CTRC.DT6_FILDOC	>= %Exp:mv_par01%
			AND CTRC.DT6_FILDOC	<= %Exp:mv_par02%
			AND CTRC.DT6_DATEMI	>= %Exp:mv_par03%
			AND CTRC.DT6_DATEMI	<= %Exp:mv_par04%
			AND CTRC.DT6_DOC		>= %Exp:mv_par05%
			AND CTRC.DT6_DOC		<= %Exp:mv_par06%
			AND CTRC.DT6_SERIE	>= %Exp:mv_par07%
			AND CTRC.DT6_SERIE	<= %Exp:mv_par08%
			

	EndSql

oReport:Section(1):EndQuery()
oReport:Section(1):Print()

Return
