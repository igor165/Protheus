#Include 'Protheus.ch'

#DEFINE	DF_CAMPO	1
#DEFINE	DF_CONTEUDO	2

//------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_GTP()
Funções de compatibilização e/ou conversão de dados para as tabelas do sistema.
@sample		RUP_GTP("12", "2", "003", "005", "BRA")
@param		cVersion	- Versão do Protheus 
@param		cMode		- Modo de execução	- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente está)
@param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualização)
@param		cLocaliz	- Localização (país)	- Ex. "BRA"
@return		Nil
@author		jacomo.fernandes
@since		31/03/2017
@version	12
/*/
//------------------------------------------------------------------------------
Function RUP_GTP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

Local aArea		:= GetArea()
Local aAreaSX2  := SX2->(GetArea())
Local aAreaSX3  := SX3->(GetArea())
Local aAreaSX7	:= SX7->(GetArea())
Local aSX3		:= {}
Local aDelSx2   := {}
Local aDelSx3	:= {}
Local aDelSx7	:= {}
Local aDelSx9	:= {}
Local aDelSix	:= {}

Default cMode	:= "1"

If cMode == "1"
	aAdd(aDelSX7, {'GI2_CATEG ','002'})
	aAdd(aDelSX7, {'G56_CODVEI','001'})
	aAdd(aDelSX7, {'G56_SGSEGU','001'})
	aAdd(aDelSX7, {'G56_SGTIPO','001'})
	aAdd(aDelSX7, {'G56_VITIPO','001'})
	aAdd(aDelSX7, {'GI5_MOTORI','001'})
	aAdd(aDelSX7, {'GIB_AGENCI','001'})
	aAdd(aDelSX7, {'GIB_FILIAL','001'})
	aAdd(aDelSX7, {'GIB_LINHA ','001'})
	aAdd(aDelSX7, {'GIH_CODTER','001'})
	aAdd(aDelSX7, {'GIH_TPDOC ','001'})
	aAdd(aDelSX7, {'GIJ_CLICAR','001'})
	aAdd(aDelSX7, {'GIJ_LOJCAR','001'})
	aAdd(aDelSX7, {'GIS_CODREQ','001'})
	aAdd(aDelSX7, {'GIU_CODREQ','001'})
	aAdd(aDelSX7, {'GIY_VEICUL','001'})
	aAdd(aDelSX7, {'GIY_VEICUL','001'})
	aAdd(aDelSX7, {'GIZ_COD'   ,'001'})
	aAdd(aDelSX7, {'GIZ_VEICUL','001'})
	aAdd(aDelSX7, {'GQA_CODVEI','002'})

	//Adicionado para ajuste de dicionário base congelada - inicio
	aAdd(aDelSX7, {'GI2_LINHA' ,'001'})
	aAdd(aDelSX7, {'GIE_LINHA' ,'001'})
	aAdd(aDelSX7, {'GIE_LOCHOR','001'})
	aAdd(aDelSX7, {'GIN_DCHEGA','001'})
	aAdd(aDelSX7, {'GIN_HCHEGA','001'})
	aAdd(aDelSX7, {'GIO_CUSTO' ,'001'})
	aAdd(aDelSX7, {'GIO_CUSTO' ,'002'})
	aAdd(aDelSX7, {'GIO_CUSUNI','001'})
	aAdd(aDelSX7, {'GIO_FILIAL','001'})
	aAdd(aDelSX7, {'GIO_QUANT' ,'001'})
	aAdd(aDelSX7, {'GIO_UM'    ,'001'})
	aAdd(aDelSX7, {'GIP_CODBEM','001'})
	aAdd(aDelSX7, {'GIP_CODBEM','002'})
	aAdd(aDelSX7, {'GIP_CONFIG','001'})
	aAdd(aDelSX7, {'GIQ_TRECHO','001'})
	
	//Adicionado para ajuste de dicionário base congelada - fim
	aAdd(aDelSX7, {'GQ8_CODLOC','001'})
	
	//tabelas que não precisam de validação de dicionário
	aAdd(aDelSX7, {'GY9_CODCAT','001'})
	aAdd(aDelSX7, {'GYY_CODACS','001'})

	IF Len(aDelSx7) > 0
		DelSx7(aDelSx7)
	Endif
	
	aAdd(aSx3,{"G6X_DESCAG"	,{ {'X3_INIBRW','POSICIONE("GI6",1,XFILIAL("GI6")+G6X->G6X_AGENCI,"GI6_DESCRI")'} } })
	aAdd(aSx3,{"GYT_DESCRI"	,{ {'X3_INIBRW','POSICIONE("GI1",1,XFILIAL("GI1")+GYT->GYT_LOCALI,"GI1_DESCRI")'} } })
	aAdd(aSx3,{"G6T_DESCRI"	,{ {'X3_INIBRW','fDesc("GI6",G6T->G6T_AGENCI,"GI6_DESCRI")'} } })
	aAdd(aSx3,{"GIC_NLOCOR"	,{ {'X3_INIBRW','fDesc("GI1", XFILIAL("GIC")+GIC->GIC_LOCORI,"GI1_DESCRI")'} } })    
	aAdd(aSx3,{"GIC_NLOCDE"	,{ {'X3_INIBRW','fDesc("GI1", XFILIAL("GIC")+GIC->GIC_LOCDES,"GI1_DESCRI")'} } })    
	aAdd(aSx3,{"G99_NOMREM"	,{ {'X3_INIBRW','fDesc("SA1", G99->G99_CLIREM+G99->G99_LOJREM,"A1_NOME") '} } })    
	aAdd(aSx3,{"G99_NOMDES"	,{ {'X3_INIBRW','fDesc("SA1", G99->G99_CLIDES+G99->G99_LOJDES,"A1_NOME") '} } })    
	aAdd(aSx3,{"G99_DESEMI"	,{ {'X3_INIBRW','fDesc("GI6", G99->G99_CODEMI,"GI6_DESCRI")              '} } })    
	aAdd(aSx3,{"G99_DESREC"	,{ {'X3_INIBRW','fDesc("GI6", G99->G99_CODREC,"GI6_DESCRI")              '} } })    
	aAdd(aSx3,{"G99_DESPRO"	,{ {'X3_INIBRW','fDesc("SB1", G99->G99_CODPRO,"B1_DESC")                 '} } })  
	aAdd(aSx3,{"GQH_TPDESC"	,{ {'X3_INIBRW','POSICIONE("GYA",1,XFILIAL("GYA")+GQH->GQH_TIPO,"GYA_DESCRI") '} } })
	aAdd(aSx3,{"GQH_TPDESC"	,{ {'X3_RELACAO','IIF(!INCLUI,POSICIONE("GYA",1,XFILIAL("GYA")+GQH->GQH_TIPO,"GYA_DESCRI"),"")'} } })
	aAdd(aSx3,{"GQP_DEPART"	,{ {'X3_VISUAL','A'} } })
	aAdd(aSx3,{"GYN_CONF"	,{ {'X3_RELACAO','2'} } })
	aAdd(aSx3,{"GQS_AGENCI"	,{ {'X3_VISUAL','A'} } })
	aAdd(aSx3,{"GIC_AGENCI"	,{ {'X3_VISUAL','A'} } })
	aAdd(aSx3,{"GYG_CPF"	,{ {'X3_VALID',''} } })


	//Adicionado para ajuste de dicionário base congelada - inicio
	aAdd(aSx3,{"G57_CODIGO"	,{ {'X3_F3','GIIFIL'} } })
	aAdd(aSx3,{"GI2_KMTOTA"	,{ {'X3_TAMANHO', 9} } }) 
	aAdd(aSx3,{"GI2_KMTOTA"	,{ {'X3_PICTURE', '@E 999,999.99'} } })
	aAdd(aSx3,{"GI8_AGENCI" ,{ {'X3_TAMANHO', 8} } }) 
	aAdd(aSx3,{"GI2_NUMMOV"	,{ {'X3_PICTURE', '999999999999'} } })
	aAdd(aSx3,{"GIE_NLOCHR"	,{ {'X3_INIBRW','POSICIONE("GI1",1,XFILIAL("GI1")+GIE->GIE_LOCHOR,"GI1_DESCRI"),"")'} } })
	aAdd(aSx3,{"GQL_CODIGO"	,{ {'X3_VISUAL','V'} } })

	// Ajuste para não gerar erro de tamnho de campo (Tarifa - GIC_TAR) na ficha de remessa
	aAdd(aSx3,{"GIC_TAR"	,{ {'X3_TAMANHO', 14} } }) 
	aAdd(aSx3,{"GIC_TAR"	,{ {'X3_PICTURE', '@E 99,999,999,999.99'} } })

	//Adicionado para ajuste de dicionário base congelada - fim
	aAdd(aSx3,{"GY6_NOMEN1"	,{ {'X3_RELACAO',''} } })
	aAdd(aSx3,{"GY6_NOMEN2"	,{ {'X3_RELACAO',''} } })

	If Len(aSX3) > 0
		AjustaSx3(aSX3)
	Endif

	//Tabelas não utilizadas
	AADD(aDelSx2,"GY9")

	IF Len(aDelSx2) > 0
		DelSx2(aDelSx2)
	Endif

	aAdd(aDelSX9, {'G56','CAX'})
	aAdd(aDelSX9, {'G56','DA3'})
	aAdd(aDelSX9, {'G56','G57'})
	aAdd(aDelSX9, {'G56','G58'})
	aAdd(aDelSX9, {'G56','G59'})
	aAdd(aDelSX9, {'GI5','GYG'})
	aAdd(aDelSX9, {'GIB','GI2'})
	aAdd(aDelSX9, {'GIB','GI5'})
	aAdd(aDelSX9, {'GIB','GI6'})
	aAdd(aDelSX9, {'GIF','GI2'})
	aAdd(aDelSX9, {'GIH','GI7'})
	aAdd(aDelSX9, {'GIS','GIR'})
	aAdd(aDelSX9, {'GIT','GIR'})
	aAdd(aDelSX9, {'GIU','GIR'})
	aAdd(aDelSX9, {'GIW','DA4'})
	aAdd(aDelSX9, {'GIX','GI5'})
	aAdd(aDelSX9, {'GIY','DA3'})
	aAdd(aDelSX9, {'GIZ','DA3'})
	
	//Adicionado para ajuste de dicionário base congelada - inicio
	aAdd(aDelSX9, {'GYU','DA3'})
	aAdd(aDelSX9, {'GI8','GI7'})
	aAdd(aDelSX9, {'GI2','GY9'})
	aAdd(aDelSX9, {'GYI','GYG'})
	aAdd(aDelSX9, {'GIC','GZ2'})
	aAdd(aDelSX9, {'GIJ','SA1'})
	aAdd(aDelSX9, {'GIK','SA6'})
	aAdd(aDelSX9, {'GQG','GI1'})
	aAdd(aDelSX9, {'GQW','SQB'})
	aAdd(aDelSX9, {'G56','SX5'})
	
	//Adicionado para ajuste de dicionário base congelada - fim
	aAdd(aDelSX9, {'GQB','SX5'})
	aAdd(aDelSX9, {'GQZ','SA1'})
	aAdd(aDelSX9, {'GQI','GI4'})
	aAdd(aDelSX9, {'GYD','GYA'})
	aAdd(aDelSX9, {'GYD','GYG'})
	
	//tabelas que não precisam de validação de dicionário
	aAdd(aDelSX9, {'GY9','GYR'})
	aAdd(aDelSX9, {'GYY','GYV'})
	aAdd(aDelSX9, {'GY9','GYR'})

	IF Len(aDelSx9) > 0
		DelSx9(aDelSx9)
	Endif

	aAdd(aDelSx3, {'G56' ,'G56_CHANOM'})
	aAdd(aDelSx3, {'G56' ,'G56_CHCAMB'})
	aAdd(aDelSx3, {'G56' ,'G56_CHCOMB'})
	aAdd(aDelSx3, {'G56' ,'G56_CHCOMP'})
	aAdd(aDelSx3, {'G56' ,'G56_CHEIXO'})
	aAdd(aDelSx3, {'G56' ,'G56_CHMAPL'})
	aAdd(aDelSx3, {'G56' ,'G56_CHMARC'})
	aAdd(aDelSx3, {'G56' ,'G56_CHMDIF'})
	aAdd(aDelSx3, {'G56' ,'G56_CHMEDP'})
	aAdd(aDelSx3, {'G56' ,'G56_CHMODE'})
	aAdd(aDelSx3, {'G56' ,'G56_CHMODM'})
	aAdd(aDelSx3, {'G56' ,'G56_CHMORI'})
	aAdd(aDelSx3, {'G56' ,'G56_CHNUME'})
	aAdd(aDelSx3, {'G56' ,'G56_CHPOTM'})
	aAdd(aDelSx3, {'G56' ,'G56_CHQTPN'})
	aAdd(aDelSx3, {'G56' ,'G56_CHRDIF'})
	aAdd(aDelSx3, {'G56' ,'G56_CHRODA'})
	aAdd(aDelSx3, {'G56' ,'G56_CODVEI'})
	aAdd(aDelSx3, {'G56' ,'G56_CRACES'})
	aAdd(aDelSx3, {'G56' ,'G56_CRANO '})
	aAdd(aDelSx3, {'G56' ,'G56_CRBANH'})
	aAdd(aDelSx3, {'G56' ,'G56_CREMPE'})
	aAdd(aDelSx3, {'G56' ,'G56_CRMARC'})
	aAdd(aDelSx3, {'G56' ,'G56_CRMODE'})
	aAdd(aDelSx3, {'G56' ,'G56_CRNUME'})
	aAdd(aDelSx3, {'G56' ,'G56_CRSENT'})
	aAdd(aDelSx3, {'G56' ,'G56_CRTANQ'})
	aAdd(aDelSx3, {'G56' ,'G56_CRTIPO'})
	aAdd(aDelSx3, {'G56' ,'G56_CRVIDR'})
	aAdd(aDelSx3, {'G56' ,'G56_DCODVE'})
	aAdd(aDelSx3, {'G56' ,'G56_EPCATE'})
	aAdd(aDelSx3, {'G56' ,'G56_EPCERT'})
	aAdd(aDelSx3, {'G56' ,'G56_EPESTA'})
	aAdd(aDelSx3, {'G56' ,'G56_EPPLAC'})
	aAdd(aDelSx3, {'G56' ,'G56_EPRENA'})
	aAdd(aDelSx3, {'G56' ,'G56_SGABRA'})
	aAdd(aDelSx3, {'G56' ,'G56_SGAPOL'})
	aAdd(aDelSx3, {'G56' ,'G56_SGDSEG'})
	aAdd(aDelSx3, {'G56' ,'G56_SGDTIP'})
	aAdd(aDelSx3, {'G56' ,'G56_SGSEGU'})
	aAdd(aDelSx3, {'G56' ,'G56_SGTIPO'})
	aAdd(aDelSx3, {'G56' ,'G56_SGVENC'})
	aAdd(aDelSx3, {'G56' ,'G56_UTILIZ'})
	aAdd(aDelSx3, {'G56' ,'G56_VIDTIN'})
	aAdd(aDelSx3, {'G56' ,'G56_VIDTIP'})
	aAdd(aDelSx3, {'G56' ,'G56_VIDTVC'})
	aAdd(aDelSx3, {'G56' ,'G56_VINUME'})
	aAdd(aDelSx3, {'G56' ,'G56_VITIPO'})
	aAdd(aDelSx3, {'G5B' ,'G5B_ALIAS'})
	aAdd(aDelSx3, {'G5B' ,'G5B_CODIGO'})
	aAdd(aDelSx3, {'G5B' ,'G5B_DESCRI'})
	aAdd(aDelSx3, {'GI5' ,'GI5_CPF'})
	aAdd(aDelSx3, {'GI5' ,'GI5_MOTORI'})
	aAdd(aDelSx3, {'GI5' ,'GI5_NMOTOR'})
	aAdd(aDelSx3, {'GI5' ,'GI5_NOME  '})
	aAdd(aDelSx3, {'GI5' ,'GI5_STATUS'})
	aAdd(aDelSx3, {'GI7' ,'GI7_DESCRI'})
	aAdd(aDelSx3, {'GI7' ,'GI7_DTALT '})
	aAdd(aDelSx3, {'GI7' ,'GI7_DTINC '})
	aAdd(aDelSx3, {'GI7' ,'GI7_TIPO  '})
	aAdd(aDelSx3, {'GI9' ,'GI9_AGENCI'})
	aAdd(aDelSx3, {'GI9' ,'GI9_ITEM  '})
	aAdd(aDelSx3, {'GI9' ,'GI9_PERPED'})
	aAdd(aDelSx3, {'GI9' ,'GI9_PERSEG'})
	aAdd(aDelSx3, {'GI9' ,'GI9_PERTAR'})
	aAdd(aDelSx3, {'GI9' ,'GI9_PERTAX'})
	aAdd(aDelSx3, {'GI9' ,'GI9_VIGFIM'})
	aAdd(aDelSx3, {'GI9' ,'GI9_VIGINI'})
	aAdd(aDelSx3, {'GIA' ,'GIA_AGENCI'})
	aAdd(aDelSx3, {'GIA' ,'GIA_DATA  '})
	aAdd(aDelSx3, {'GIA' ,'GIA_DESCRI'})
	aAdd(aDelSx3, {'GIA' ,'GIA_DESFOR'})
	aAdd(aDelSx3, {'GIA' ,'GIA_DOC'})
	aAdd(aDelSx3, {'GIA' ,'GIA_FORNEC'})
	aAdd(aDelSx3, {'GIA' ,'GIA_LOJA'})
	aAdd(aDelSx3, {'GIA' ,'GIA_NUMTIT'})
	aAdd(aDelSx3, {'GIA' ,'GIA_PARCEL'})
	aAdd(aDelSx3, {'GIA' ,'GIA_PREFIX'})
	aAdd(aDelSx3, {'GIA' ,'GIA_VALPED'})
	aAdd(aDelSx3, {'GIA' ,'GIA_VALSEG'})
	aAdd(aDelSx3, {'GIA' ,'GIA_VALTAR'})
	aAdd(aDelSx3, {'GIA' ,'GIA_VALTAX'})
	aAdd(aDelSx3, {'GIA' ,'GIA_VALTOT'})
	aAdd(aDelSx3, {'GIB' ,'GIB_AGENCI'})
	aAdd(aDelSx3, {'GIB' ,'GIB_BILOK '})
	aAdd(aDelSx3, {'GIB' ,'GIB_BILTOT'})
	aAdd(aDelSx3, {'GIB' ,'GIB_DATA  '})
	aAdd(aDelSx3, {'GIB' ,'GIB_DESCRI'})
	aAdd(aDelSx3, {'GIB' ,'GIB_DTVIAG'})
	aAdd(aDelSx3, {'GIB' ,'GIB_HORAR '})
	aAdd(aDelSx3, {'GIB' ,'GIB_LINHA '})
	aAdd(aDelSx3, {'GIB' ,'GIB_LOTE  '})
	aAdd(aDelSx3, {'GIB' ,'GIB_MOTCOB'})
	aAdd(aDelSx3, {'GIB' ,'GIB_NLINHA'})
	aAdd(aDelSx3, {'GIB' ,'GIB_NUMFIM'})
	aAdd(aDelSx3, {'GIB' ,'GIB_NUMINI'})
	aAdd(aDelSx3, {'GIB' ,'GIB_OK'})
	aAdd(aDelSx3, {'GIB' ,'GIB_SENTID'})
	aAdd(aDelSx3, {'GIB' ,'GIB_SERIE '})
	aAdd(aDelSx3, {'GIB' ,'GIB_TPLOTE'})
	aAdd(aDelSx3, {'GIF' ,'GIF_CARRO '})
	aAdd(aDelSx3, {'GIF' ,'GIF_DATA  '})
	aAdd(aDelSx3, {'GIF' ,'GIF_DCHEGD'})
	aAdd(aDelSx3, {'GIF' ,'GIF_DCHERD'})
	aAdd(aDelSx3, {'GIF' ,'GIF_DCHERO'})
	aAdd(aDelSx3, {'GIF' ,'GIF_DSAIGO'})
	aAdd(aDelSx3, {'GIF' ,'GIF_HCHEGD'})
	aAdd(aDelSx3, {'GIF' ,'GIF_HCHERD'})
	aAdd(aDelSx3, {'GIF' ,'GIF_HCHERO'})
	aAdd(aDelSx3, {'GIF' ,'GIF_HORCAB'})
	aAdd(aDelSx3, {'GIF' ,'GIF_HSAIGO'})
	aAdd(aDelSx3, {'GIF' ,'GIF_LINHA '})
	aAdd(aDelSx3, {'GIF' ,'GIF_NLINHA'})
	aAdd(aDelSx3, {'GIF' ,'GIF_SENTID'})
	aAdd(aDelSx3, {'GIF' ,'GIF_SERVIC'})
	aAdd(aDelSx3, {'GIF' ,'GIF_TPVIA '})
	aAdd(aDelSx3, {'GIG' ,'GIG_AGENC '})
	aAdd(aDelSx3, {'GIG' ,'GIG_BILFIM'})
	aAdd(aDelSx3, {'GIG' ,'GIG_BILINI'})
	aAdd(aDelSx3, {'GIG' ,'GIG_DTFIM '})
	aAdd(aDelSx3, {'GIG' ,'GIG_DTINI '})
	aAdd(aDelSx3, {'GIG' ,'GIG_SERIE '})
	aAdd(aDelSx3, {'GIG' ,'GIG_TERCEI'})
	aAdd(aDelSx3, {'GIG' ,'GIG_TOTAL '})
	aAdd(aDelSx3, {'GIJ' ,'GIJ_CARTAO'})
	aAdd(aDelSx3, {'GIJ' ,'GIJ_CLICAR'})
	aAdd(aDelSx3, {'GIJ' ,'GIJ_DESCRI'})
	aAdd(aDelSx3, {'GIJ' ,'GIJ_LOJCAR'})
	aAdd(aDelSx3, {'GIJ' ,'GIJ_MVBCO '})
	aAdd(aDelSx3, {'GIJ' ,'GIJ_NCLICA'})
	aAdd(aDelSx3, {'GIK' ,'GIK_OK'})
	aAdd(aDelSx3, {'GIK' ,'GIK_VALOR '})
	aAdd(aDelSx3, {'GIK' ,'GIK_AGE'})
	aAdd(aDelSx3, {'GIK' ,'GIK_AGENCI'})
	aAdd(aDelSx3, {'GIK' ,'GIK_BCO'})
	aAdd(aDelSx3, {'GIK' ,'GIK_CTA'})
	aAdd(aDelSx3, {'GIK' ,'GIK_DATA'})
	aAdd(aDelSx3, {'GIK' ,'GIK_DTMOV'})
	aAdd(aDelSx3, {'GIK' ,'GIK_FORPAG'})
	aAdd(aDelSx3, {'GIK' ,'GIK_LOTE'})
	aAdd(aDelSx3, {'GIL' ,'GIL_AGE   '})
	aAdd(aDelSx3, {'GIL' ,'GIL_AGENCI'})
	aAdd(aDelSx3, {'GIL' ,'GIL_BCO   '})
	aAdd(aDelSx3, {'GIL' ,'GIL_CTA   '})
	aAdd(aDelSx3, {'GIL' ,'GIL_DATA  '})
	aAdd(aDelSx3, {'GIL' ,'GIL_LOTE  '})
	aAdd(aDelSx3, {'GIL' ,'GIL_NATURE'})
	aAdd(aDelSx3, {'GIL' ,'GIL_OK    '})
	aAdd(aDelSx3, {'GIL' ,'GIL_RECPAG'})
	aAdd(aDelSx3, {'GIL' ,'GIL_VALOR '})
	aAdd(aDelSx3, {'GIR' ,'GIR_APLIC '})
	aAdd(aDelSx3, {'GIR' ,'GIR_COD   '})
	aAdd(aDelSx3, {'GIR' ,'GIR_DESCRI'})
	aAdd(aDelSx3, {'GIR' ,'GIR_LINHAS'})
	aAdd(aDelSx3, {'GIS' ,'GIS_CODREQ'})
	aAdd(aDelSx3, {'GIS' ,'GIS_DESREQ'})
	aAdd(aDelSx3, {'GIS' ,'GIS_ITEM  '})
	aAdd(aDelSx3, {'GIS' ,'GIS_LINHA '})
	aAdd(aDelSx3, {'GIT' ,'GIT_CODREQ'})
	aAdd(aDelSx3, {'GIT' ,'GIT_DESREQ'})
	aAdd(aDelSx3, {'GIT' ,'GIT_DTFIM '})
	aAdd(aDelSx3, {'GIT' ,'GIT_DTINIC'})
	aAdd(aDelSx3, {'GIT' ,'GIT_VEICUL'})
	aAdd(aDelSx3, {'GIU' ,'GIU_CODREQ'})
	aAdd(aDelSx3, {'GIU' ,'GIU_DESREQ'})
	aAdd(aDelSx3, {'GIU' ,'GIU_DTFIM '})
	aAdd(aDelSx3, {'GIU' ,'GIU_DTINIC'})
	aAdd(aDelSx3, {'GIU' ,'GIU_ITEM  '})
	aAdd(aDelSx3, {'GIU' ,'GIU_MOTORI'})
	aAdd(aDelSx3, {'GIV' ,'GIV_COD   '})
	aAdd(aDelSx3, {'GIV' ,'GIV_DESCRI'})
	aAdd(aDelSx3, {'GIW' ,'GIW_ITEM  '})
	aAdd(aDelSx3, {'GIW' ,'GIW_LINHA '})
	aAdd(aDelSx3, {'GIW' ,'GIW_MOTORI'})
	aAdd(aDelSx3, {'GIW' ,'GIW_NMOTOR'})
	aAdd(aDelSx3, {'GIX' ,'GIX_COBRAD'})
	aAdd(aDelSx3, {'GIX' ,'GIX_ITEM  '})
	aAdd(aDelSx3, {'GIX' ,'GIX_LINHA '})
	aAdd(aDelSx3, {'GIX' ,'GIX_NCOBR '})
	aAdd(aDelSx3, {'GIY' ,'GIY_DESVEI'})
	aAdd(aDelSx3, {'GIY' ,'GIY_ITEM  '})
	aAdd(aDelSx3, {'GIY' ,'GIY_LINHA '})
	aAdd(aDelSx3, {'GIY' ,'GIY_VEICUL'})
	aAdd(aDelSx3, {'GIZ' ,'GIZ_COD'})
	aAdd(aDelSx3, {'GIZ' ,'GIZ_DESLOC'})
	aAdd(aDelSx3, {'GIZ' ,'GIZ_DESVEI'})
	aAdd(aDelSx3, {'GIZ' ,'GIZ_DTFIM '})
	aAdd(aDelSx3, {'GIZ' ,'GIZ_DTINIC'})
	aAdd(aDelSx3, {'GIZ' ,'GIZ_HORAEN'})
	aAdd(aDelSx3, {'GIZ' ,'GIZ_HORASA'})
	aAdd(aDelSx3, {'GIZ' ,'GIZ_KMENTR'})
	aAdd(aDelSx3, {'GIZ' ,'GIZ_KMSAID'})
	aAdd(aDelSx3, {'GIZ' ,'GIZ_LOCAL '})
	aAdd(aDelSx3, {'GIZ' ,'GIZ_VEICUL'})
	aAdd(aDelSx3, {'G9P' ,'G9P_CODG6X'})
	aAdd(aDelSx3, {'G9P' ,'G9P_NUMDOC'})
	aAdd(aDelSx3, {'G9P' ,'G9P_SERIE'})
	aAdd(aDelSx3, {'G9P' ,'G9P_VALOR'})
	aAdd(aDelSx3, {'GQJ' ,'GQJ_DESCRI'})
	aAdd(aDelSx3, {'GQJ' ,'GQJ_CLASSI'})
	aAdd(aDelSx3, {'GYX' ,'GYX_USER'})
	aAdd(aDelSx3, {'GYX' ,'GYX_HRCANC'})
	aAdd(aDelSx3, {'GYX' ,'GYX_DTCANC'})
	aAdd(aDelSx3, {'GYX' ,'GYX_STATUS'})
	aAdd(aDelSx3, {'GYX' ,'GYX_MOTOR2'})
	aAdd(aDelSx3, {'GYX' ,'GYX_MOTOR1'})
	aAdd(aDelSx3, {'GYX' ,'GYX_VEIC'})
	aAdd(aDelSx3, {'GYX' ,'GYX_HRPREV'})
	aAdd(aDelSx3, {'GYX' ,'GYX_DTPREV'})
	aAdd(aDelSx3, {'GYX' ,'GYX_HRVIAG'})
	aAdd(aDelSx3, {'GYX' ,'GYX_DTVIAG'})
	aAdd(aDelSx3, {'GYX' ,'GYX_KMREAL'})
	aAdd(aDelSx3, {'GYX' ,'GYX_KMPROV'})
	aAdd(aDelSx3, {'GYX' ,'GYX_INTFIM'})
	aAdd(aDelSx3, {'GYX' ,'GYX_LOCDES'})
	aAdd(aDelSx3, {'GYX' ,'GYX_INTINI'})
	aAdd(aDelSx3, {'GYX' ,'GYX_LOCOR'})
	aAdd(aDelSx3, {'GYX' ,'GYX_MOTIVO'})
	aAdd(aDelSx3, {'GYX' ,'GYX_LOCINT'})
	aAdd(aDelSx3, {'GYX' ,'GYX_HRINT'})
	aAdd(aDelSx3, {'GYX' ,'GYX_LININT'})
	aAdd(aDelSx3, {'GYX' ,'GYX_LOCTER'})
	aAdd(aDelSx3, {'GYX' ,'GYX_CONTRA'})
	aAdd(aDelSx3, {'GYX' ,'GYX_LINHA'})
	aAdd(aDelSx3, {'GYX' ,'GYX_IDENT'})
	aAdd(aDelSx3, {'GYX' ,'GYX_CODSER'})

	//Adicionado para ajuste de dicionário base congelada - inicio
	aAdd(aDelSx3, {'G99' ,'G99_CODLAN'})
	aAdd(aDelSx3, {'GI5' ,'GI5_MSBLQL'})
	aAdd(aDelSx3, {'GIO' ,'GIO_PLAN'})
	aAdd(aDelSx3, {'GIQ' ,'GIQ_DESLMT'})
	aAdd(aDelSx3, {'GZN' ,'GZN_ASSOCI'})
	aAdd(aDelSx3, {'GZN' ,'GZN_ORIGEM'})
	aAdd(aDelSx3, {'GZN' ,'GZN_VARIAV'})
	aAdd(aDelSx3, {'GZR' ,'GZR_CODGYG'})
	aAdd(aDelSx3, {'GZR' ,'GZR_CODGYQ'})
	aAdd(aDelSx3, {'GZR' ,'GZR_DTREF'})
	aAdd(aDelSx3, {'GZR' ,'GZR_SITRH'})
	aAdd(aDelSx3, {'GZR' ,'GZR_TPDIA'})
	
	//Adicionado para ajuste de dicionário base congelada - fim
	aAdd(aDelSx3, {'GQ8' ,'GQ8_CODLOC'})
	aAdd(aDelSx3, {'GQ8' ,'GQ8_DESCLO'})
	aAdd(aDelSx3, {'GQ8' ,'GQ8_QTDTXE'})
	aAdd(aDelSx3, {'GQ8' ,'GQ8_TOTTXE'})
	aAdd(aDelSx3, {'GQ8' ,'GQ8_QTDTAR'})
	aAdd(aDelSx3, {'GQ8' ,'GQ8_TOTTAR'})
	aAdd(aDelSx3, {'GQ8' ,'GQ8_QTDSEG'})
	aAdd(aDelSx3, {'GQ8' ,'GQ8_TOTSEG'})
	aAdd(aDelSx3, {'GQ8' ,'GQ8_QTDPED'})
	aAdd(aDelSx3, {'GQ8' ,'GQ8_TOTPED'})
	aAdd(aDelSx3, {'GQ8' ,'GQ8_TOTOUT'})
	aAdd(aDelSx3, {'GQ8' ,'GQ8_TOTGER'})
	aAdd(aDelSx3, {'GQ8' ,'GQ8_TIPO'})
	aAdd(aDelSx3, {'GQ8' ,'GQ8_TIPOAG'})
	aAdd(aDelSx3, {'GQB' ,'GQB_SERVIC'})
	aAdd(aDelSx3, {'GQB' ,'GQB_DESCRI'})
	aAdd(aDelSx3, {'GQZ' ,'GQZ_CODCLI'})
	aAdd(aDelSx3, {'GQZ' ,'GQZ_CODLOJ'})
	aAdd(aDelSx3, {'GQZ' ,'GQZ_NOMCLI'})
	aAdd(aDelSx3, {'GQZ' ,'GQZ_INIVIG'})
	aAdd(aDelSx3, {'GQZ' ,'GQZ_FIMVIG'})
	aAdd(aDelSx3, {'GQZ' ,'GQZ_TPDESC'})
	aAdd(aDelSx3, {'GQZ' ,'GQZ_VALOR '})
	aAdd(aDelSx3, {'GQI' ,'GQI_CODGI4'})
	aAdd(aDelSx3, {'GQI' ,'GQI_LOCORI'})
	aAdd(aDelSx3, {'GQI' ,'GQI_NLOCO'})
	aAdd(aDelSx3, {'GQI' ,'GQI_LOCDES'})
	aAdd(aDelSx3, {'GQI' ,'GQI_NLOCD'})
	aAdd(aDelSx3, {'GQI' ,'GQI_SENTID'})
	aAdd(aDelSx3, {'GQI' ,'GQI_VALOR'})
	aAdd(aDelSx3, {'GYD' ,'GYD_CODIGO'})
	aAdd(aDelSx3, {'GYD' ,'GYD_CODLOT'})
	aAdd(aDelSx3, {'GYD' ,'GYD_CODLOT'})
	aAdd(aDelSx3, {'GYD' ,'GYD_CODTPD'})
	aAdd(aDelSx3, {'GYD' ,'GYD_TDDESC'})
	aAdd(aDelSx3, {'GYD' ,'GYD_VALOR'})
	aAdd(aDelSx3, {'GYD' ,'GYD_DATA'})
	aAdd(aDelSx3, {'GYD' ,'GYD_JUSTIF'})
	aAdd(aDelSx3, {'GYD' ,'GYD_LANCAM'})
	aAdd(aDelSx3, {'GYD' ,'GYD_CODAGE'})
	aAdd(aDelSx3, {'GYD' ,'GYD_STATUS'})
	aAdd(aDelSx3, {'GYD' ,'GYD_CODJUS'})
	aAdd(aDelSx3, {'GYD' ,'GYD_EMISSO'})
	aAdd(aDelSx3, {'GYD' ,'GYD_NEMISS'})
	aAdd(aDelSx3, {'GYD' ,'GYD_AGEDES'})
	aAdd(aDelSx3, {'GYD' ,'GYD_CODG6X'})

	//tabelas que não precisam de validação de dicionario
	aAdd(aDelSx3, {'GY9' ,'GY9_CODCAT'})
	aAdd(aDelSx3, {'GY9' ,'GY9_CODIGO'})
	aAdd(aDelSx3, {'GY9' ,'GY9_CODORG'})
	aAdd(aDelSx3, {'GY9' ,'GY9_DESCRI'})
	aAdd(aDelSx3, {'GYV' ,'GYV_DESCRI'})
	aAdd(aDelSx3, {'GYV' ,'GYV_MODELO'})
	aAdd(aDelSx3, {'GYV' ,'GYV_OBSERV'})
	aAdd(aDelSx3, {'GYY' ,'GYY_CODACS'})
	aAdd(aDelSx3, {'GYY' ,'GYY_CODVEI'})
	aAdd(aDelSx3, {'GYY' ,'GYY_DESACS'})
	aAdd(aDelSx3, {'GYY' ,'GYY_QTDACS'})
	aAdd(aDelSx3, {'GYS' ,'GYS_CODCAT'})
	aAdd(aDelSx3, {'GYS' ,'GYS_CODORG'})
	aAdd(aDelSx3, {'GYS' ,'GYS_COEFI '})
	aAdd(aDelSx3, {'GYS' ,'GYS_KMMAX '})
	aAdd(aDelSx3, {'GYS' ,'GYS_KMMIN '})
	aAdd(aDelSx3, {'GYS' ,'GYS_TIPO  '})
	aAdd(aDelSx3, {'GYS' ,'GYS_VALOR '})

	If Len(aDelSx3) > 0
		DelSx3(aDelSx3)
	Endif

	aAdd(aDelSix, {'GI5','GI5_FILIAL+GI5_CPF'})
	aAdd(aDelSix, {'GIA','GIA_FILIAL+GIA_AGENCI'})
	aAdd(aDelSix, {'GIA','GIA_FILIAL+GIA_PREFIX+GIA_NUMTIT+GIA_PARCEL+GIA_FORNEC+GIA_LOJA'})
	aAdd(aDelSix, {'GIB','GIB_FILIAL+GIB_AGENCI'})
	aAdd(aDelSix, {'GIT','GIT_FILIAL+GIT_CODREQ'})
	aAdd(aDelSix, {'GIV','GIV_FILIAL+GIV_DESCRI'})
	aAdd(aDelSix, {'GQ8','GQ8_FILIAL+GQ8_CODIGO+GQ8_CODLOC+GQ8_TIPO+GQ8_TIPOAG'})
	aAdd(aDelSix, {'GQB','GQB_FILIAL+GQB_CODIGO+GQB_ITEM+GQB_SERVIC'})
	aAdd(aDelSix, {'GYD','GYD_FILIAL+GYD_CODLOT+GYD_CODTPD'})
	aAdd(aDelSix, {'GYD','GYD_FILIAL+GYD_CODIGO'})
	

	//tabelas que não precisam de validação de dicionário
	aAdd(aDelSix, {'GY9','GY9_FILIAL+GY9_CODIGO+GY9_CODORG+GY9_CODCAT'})
	aAdd(aDelSix, {'GY9','GY9_FILIAL+GY9_CODORG+GY9_CODCAT'})
	aAdd(aDelSix, {'GYY','GYY_FILIAL+GYY_CODVEI+GYY_CODACS'})
	aAdd(aDelSix, {'GYS','GYS_FILIAL+GYS_CODCAT+GYS_CODORG'})
	aAdd(aDelSix, {'GYS','GYS_FILIAL+GYS_CODIGO+GYS_CODORG'})

	IF Len(aDelSix) > 0
		DelSix(aDelSix)
	Endif

EndIf

RestArea(aAreaSX2)
RestArea(aAreaSX3)
RestArea(aAreaSX7)
RestArea(aArea)


aSize(aSX3,0)
aSX3 := Nil

aSize(aDelSx7,0)
aDelSx7 := Nil

aSize(aDelSx3,0)
aDelSx3 := Nil

aSize(aDelSx9,0)
aDelSx9 := Nil

aSize(aDelSix,0)
aDelSix := Nil

Return Nil

/*/{Protheus.doc} AjustaSx3
Ajusta o Dicionário SX3
@type function
@author jacomo.fernandes
@since 11/04/2017
@version 1.0
@param aSx3, array, Array contendo os campos a serem alterados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function AjustaSx3(aSx3)
Local nInd1 := 0
Local nInd2 := 0
Local nTamX3CPO	:= Len(SX3->X3_CAMPO)

SX3->(DbSetOrder(2))//X3_CAMPO
For nInd1 := 1 to Len(aSx3)// Seleciona Campo
	If	SX3->( DbSeek( PadR( aSx3[nInd1][DF_CAMPO], nTamX3CPO ) ) )
		SX3->(RecLock("SX3",.F.))	
		For nInd2 := 1 to Len(aSx3[nInd1][2]) //Ajustes do Sx3

			//Macro Substituição dos campos do Sx3 
			SX3->&(aSx3[nInd1][2][nInd2][DF_CAMPO]) := aSx3[nInd1][2][nInd2][DF_CONTEUDO]
		
		Next
		SX3->(MSUnlock())
	EndIf
Next
Return

/*/{Protheus.doc} GTPRUP
(long_description)
@type function
@author jacom
@since 11/04/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPRUP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

Default cVersion		:= "12"
Default cMode			:= "1"
Default cRelStart		:= "014"
Default cRelFinish	    := "099"
Default cLocaliz		:= "BRA"

FwMsgRun( ,{||RUP_GTP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)},,"Executando RUP...")

Return()

/*/{Protheus.doc} DelSx7
Função para deletar relacionamento de tabela
@type function
@author jacom
@since 11/04/2017
@version 1.0
@param aDelSx9, array, Array contendo os dados a serem deletados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DelSx7(aDelSx7)
Local nInd1 := 0
Local nTamX7CPO	:= Len(SX7->X7_CAMPO)
Local nTamX7SEQ	:= Len(SX7->X7_SEQUENC)

//Mata os relacionamentos
DbSelectArea("SX7")
SX7->(DbSetOrder(1)) //X7_CAMPO+X7_SEQUENC
For nInd1 := 1 To Len(aDelSX7)


	If SX7->(DbSeek(PadR(aDelSX7[nInd1][1],nTamX7CPO)+(PadR(aDelSX7[nInd1][2],nTamX7SEQ))))
		If AllTrim(SX7->X7_CAMPO) == Alltrim(aDelSX7[nInd1][1]) .AND. AllTrim(SX7->X7_SEQUENC) == Alltrim(aDelSX7[nInd1][2])
			Reclock("SX7",.F.)
			SX7->( DbDelete() )
			SX7->(MsUnlock())
		EndIf
	EndIf
NEXT
Return

/*/{Protheus.doc} DelSx2
Função para deletar Tabela do dicionário
@type function
@author gtp
@since 18/06/2020
@version 1.0
@param aDelSx2, array, Array contendo os dados a serem deletados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DelSx2(aDelSx2)
Local nInd1 	:= 0

dbSelectArea("SX2")
SX2->(dbSetOrder(1)) 

For nInd1 := 1 To Len(aDelSX2)

	If SX2->(dbSeek(aDelSX2[nInd1]))
		If AllTrim(SX2->X2_CHAVE) == Alltrim(aDelSX2[nInd1])
			Reclock("SX2",.F.)
			SX2->( dbDelete() )
			SX2->(MsUnlock())
		EndIf
	EndIf

Next

Return

/*/{Protheus.doc} DelSx3
Função para deletar campos do dicionário
@type function
@author flavio.martins
@since 22/01/2020
@version 1.0
@param aDelSx3, array, Array contendo os dados a serem deletados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DelSx3(aDelSx3)
Local nInd1 	:= 0
Local nTamX3CPO	:= Len(SX3->X3_CAMPO)

dbSelectArea("SX3")
SX3->(dbSetOrder(2)) 

For nInd1 := 1 To Len(aDelSX3)

	If SX3->(dbSeek(Padr(aDelSX3[nInd1][2],nTamX3CPO)))
		If AllTrim(SX3->X3_CAMPO) == Alltrim(aDelSX3[nInd1][2])
			Reclock("SX3",.F.)
			SX3->( dbDelete() )
			SX3->(MsUnlock())
		EndIf
	EndIf

Next

Return

/*/{Protheus.doc} DelSIX
Função para deletar relacionamento de tabela
@type function
@author jacom
@since 11/04/2017
@version 1.0
@param aDelSIX, array, Array contendo os dados a serem deletados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DelSIX(aDelSIX)
Local nInd1 	:= 0

//Mata os relacionamentos
DbSelectArea("SIX")
SIX->(DbSetOrder(1)) // INDICE+ORDEM
For nInd1 := 1 To Len(aDelSIX)
	If SIX->(DbSeek(aDelSIX[nInd1][1]))
		While SIX->(!Eof()) .and. SIX->INDICE = aDelSIX[nInd1][1] 
			If AllTrim(SIX->CHAVE) == aDelSIX[nInd1][2]
				Reclock("SIX",.F.)
				SIX->( DbDelete() )
				SIX->(MsUnlock())
				Exit
			Endif
			SIX->(DbSkip())
		End
	EndIf
Next

Return

/*/{Protheus.doc} DelSx9
Função para deletar relacionamento de tabela
@type function
@author jacom
@since 11/04/2017
@version 1.0
@param aDelSx9, array, Array contendo os dados a serem deletados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DelSx9(aDelSx9)
Local nInd1 := 0

//Mata os relacionamentos
DbSelectArea("SX9")
SX9->(DbSetOrder(2)) // X9_CDOM+X9_DOM
For nInd1 := 1 To Len(aDelSX9)
	If SX9->(DbSeek(aDelSX9[nInd1][1]+aDelSX9[nInd1][2] ))
		While SX9->(!Eof()) .and. SX9->X9_CDOM == aDelSX9[nInd1][1] .and. SX9->X9_DOM == aDelSX9[nInd1][2]
			//If SX9->X9_EXPCDOM == Padr(aDelSX9[nInd1][3] ,Len(SX9->X9_EXPCDOM)) .and. SX9->X9_EXPDOM == Padr(aDelSX9[nInd1][4] ,Len(SX9->X9_EXPDOM)) 
				Reclock("SX9",.F.)
				SX9->( DbDelete() )
				SX9->(MsUnlock())
				Exit
			//Endif
			SX9->(DbSkip())
		End
	EndIf
Next

Return
