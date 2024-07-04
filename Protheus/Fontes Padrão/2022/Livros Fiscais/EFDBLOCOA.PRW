#include "protheus.ch"

/*
  Esta funcao foi criada para que seja possivel visualizar a data deste
  fonte no inspetor de objetos, pois nao eh possivel fazer isso se nao
  houver nenhuma FUNCTION no fonte.
*/
FUNCTION EFDCBLOCOA();RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} EFDCBLOCOA()
@description Classe que terá as informações específicas para geração dos 
			   registros do bloco A no SPED Contribuições. Esta classe
			   herda as propriedades e métodos da classe NOTAEFD, então aqui
			   teremos somente as propriedades pertinentes ao bloco A, bem
			   como os método para gravação dos registros, respeitando formatos
			   e hierarquia. 

@author Erick G. Dias
@since 17/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
CLASS EFDCBLOCOA FROM NOTAEFD

//-----------------------------------------------------
//ATRIBUTOS REFERENTE AO CABECALHO DO DOCUMENTO FISCAL
//-----------------------------------------------------
Data dnExec		as Date		READONLY		//Data de execução do serviço	
Data nnPisRet		as Integer		READONLY		//Valor do PIS retido na fonte
Data nnCofRet		as Integer		READONLY		//Valor da COFINS retido na fonte
Data nnValIss		as Integer		READONLY		//Valor do ISS
Data cnIndPgto	as String		READONLY		//Indicador da condição de pagamento

//-------------------------------------------------------------
//ATRIBUTOS REFERENTE AO CABECALHO AO ITEM DO DOCUMENTO FISCAL
//-------------------------------------------------------------
Data ciDescri		as String		READONLY		//Descrição complementar do item
Data ciOriCrd		as String		READONLY		//Indicador de origem do crédito
Data cCodInfCom	as String		READONLY		//Código da Informação Complementar

//-------------------------------------------------------------
//ATRIBUTOS REFERENTE AO REGISTRO DE IMPORTAÇÃO
//-------------------------------------------------------------
Data nVlImport	as Integer		READONLY		//Valor do serviço executado na importação		
Data nBsPisImp	as Integer		READONLY		//Base do PIS Importação
Data nBsCofImp	as Integer		READONLY		//Base de COFINS Importação
Data nVlPisImp	as Integer		READONLY		//Valor de PIS Importação
Data nVlCofImp	as Integer		READONLY		//Valor da COFINS importação
Data cLocal		as String		READONLY		//Local de execução do serviço
Data dDtPgPis		as Date		READONLY		//Data de pagamento do PIS Importação
Data dDtPgCof		as Date		READONLY		//Data de pagamento COFINS Importação
Data aRegA100		as Array		READONLY		//Array com informações do registro A100
Data aRegA110		as Array		READONLY		//Array com informações do registro A110
Data aRegA111		as Array		READONLY		//Array com informações do registro A111
Data aRegA120		as Array		READONLY		//Array com informações do registro A120
Data aRegA170		as Array		READONLY		//Array com informações do registro A170
Data aRegA001		as Array		READONLY		//Array com informações do registro A170
Data aRegA990		as Array		READONLY		//Array com informações do registro A170

//-------------------------------------------------------------
//MÉTODOS DA CLASSE
//-------------------------------------------------------------
Method New()
Method Clear()
Method AddA100()
Method AddA110()
Method AddA120()
Method AddA170() 
Method AddProcRef()
Method AddA001(cIndMovto)
Method AddA990(nQtde)

Method setExec( dnExec) 
Method setPisRet( nnPisRet) 
Method setCofRet( nnCofRet) 
Method setValIss( nnValIss) 
Method setIndPgto( cnIndPgto) 
Method setDescri( ciDescri) 
Method setOriCrd( ciOriCrd) 
Method setVImport( nVlImport) 
Method setBPisImp( nBsPisImp) 
Method setBCofImp( nBsCofImp) 
Method setVPisImp( nVlPisImp) 
Method setVCofImp( nVlCofImp) 
Method setLocal( cLocal) 
Method setDtPgPis( dDtPgPis) 
Method setDtPgCof( dDtPgCof) 
Method setCodInfC( cCodInfCom)
Method getA100()
Method getA110()
Method getA111()
Method getA170()
Method getA120()

Method clsA100()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe 

@author Erick G. Dias
@since 17/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD New() Class EFDCBLOCOA
Self:cJob	:= '00'
Self:Clear() //Limpa/inicializa todas variaveis
Self:ClsNotaEfd()

Return


Method setExec( dnExec) Class EFDCBLOCOA
	Self:dnExec := dnExec
Return
Method setPisRet( nnPisRet, lAcum) Class EFDCBLOCOA
	Default lAcum := .F.
	If lAcum
		Self:nnPisRet += nnPisRet
	Else
		Self:nnPisRet := nnPisRet
	EndIF
Return
Method setCofRet( nnCofRet, lAcum) Class EFDCBLOCOA
	Default lAcum := .F.
	If lAcum	
		Self:nnCofRet += nnCofRet
	Else
		Self:nnCofRet := nnCofRet	
	EndIF
Return
Method setValIss( nnValIss, lAcum) Class EFDCBLOCOA
	Default lAcum := .F.
	If lAcum		
		Self:nnValIss += nnValIss
	Else
		Self:nnValIss := nnValIss	
	EndIF
Return
Method setIndPgto( cnIndPgto) Class EFDCBLOCOA
	Self:cnIndPgto := cnIndPgto
Return
Method setDescri( ciDescri) Class EFDCBLOCOA
	Self:ciDescri := ciDescri
Return
Method setOriCrd( ciOriCrd) Class EFDCBLOCOA
	Self:ciOriCrd := ciOriCrd
Return
Method setVImport( nVlImport) Class EFDCBLOCOA
	Self:nVlImport := nVlImport
Return
Method setBPisImp( nBsPisImp) Class EFDCBLOCOA
	Self:nBsPisImp := nBsPisImp
Return
Method setBCofImp( nBsCofImp) Class EFDCBLOCOA
	Self:nBsCofImp := nBsCofImp
Return
Method setVPisImp( nVlPisImp) Class EFDCBLOCOA
	Self:nVlPisImp := nVlPisImp
Return
Method setVCofImp( nVlCofImp) Class EFDCBLOCOA
	Self:nVlCofImp := nVlCofImp
Return
Method setLocal( cLocal) Class EFDCBLOCOA
	Self:cLocal := cLocal
Return
Method setDtPgPis( dDtPgPis) Class EFDCBLOCOA
	Self:dDtPgPis := dDtPgPis
Return
Method setDtPgCof( dDtPgCof) Class EFDCBLOCOA
	Self:dDtPgCof := dDtPgCof
Return	
Method setCodInfC( cCodInfCom) Class EFDCBLOCOA
	Self:cCodInfCom	:= cCodInfCom
Return

Method getA100() Class EFDCBLOCOA
Return Self:aRegA100

Method getA110() Class EFDCBLOCOA
Return Self:aRegA110

Method getA111() Class EFDCBLOCOA
Return Self:aRegA111

Method getA170() Class EFDCBLOCOA
Return Self:aRegA170

Method getA120() Class EFDCBLOCOA
Return Self:aRegA120

//-------------------------------------------------------------------
/*/{Protheus.doc} Clear()
Método que inicializa as variáveis da classe. 

@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD Clear() Class EFDCBLOCOA

Self:dnExec		:= CTod("  /  /    ")		//Self:de execução do serviço	
Self:nnPisRet		:= 0		//Valor do PIS retido na fonte
Self:nnCofRet		:= 0		//Valor da COFINS retido na fonte
Self:nnValIss		:= 0		//Valor do ISS
Self:cnIndPgto	:= ''		//Indicador da condição de pagamento
Self:ciDescri		:= ''		//Descrição complementar do item
Self:ciOriCrd		:= ''		//Indicador de origem do crédito
Self:nVlImport	:= 0		//Valor do serviço executado na importação		
Self:nBsPisImp	:= 0		//Base do PIS Importação
Self:nBsCofImp	:= 0		//Base de COFINS Importação
Self:nVlPisImp	:= 0		//Valor de PIS Importação
Self:nVlCofImp	:= 0		//Valor da COFINS importação
Self:cLocal		:= ''		//Local de execução do serviço
Self:dDtPgPis		:= CTod("  /  /    ")		//Self:de pagamento do PIS Importação
Self:dDtPgCof		:= CTod("  /  /    ")		//Self:de pagamento COFINS Importação
Self:aRegA100		:= {}		//Array com informações do registro A100
Self:aRegA110		:= {}		//Array com informações do registro A111
Self:aRegA111		:= {}		//Array com informações do registro A111
Self:aRegA120		:= {}		//Array com informações do registro A120
Self:aRegA170		:= {}		//Array com informações do registro A170
Self:aRegA001		:= {}		//Array com informações do registro A001
Self:aRegA990		:= {}		//Array com informações do registro A990

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddA100()
@description Método que inclui novo registro A100, considerando as informações
			   já passadas para objeto.
@author Erick G. Dias
@since 17/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddA100(lNew, nPosAcum,lMT) Class EFDCBLOCOA

Local nPos	:= 0

Default lMT := .F.

If Self:cnSitDoc == '02'
	//Para documento cancelado, os campos de valores deverão estar com vazio pois causa eror no validador.

	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'A100')
	aAdd(Self:aRegA100, {})
	nPos	:=	Len (Self:aRegA100)
	aAdd (Self:aRegA100[nPos], Self:cGrupoReg) 	//01-RELACIONAMENTO
	aAdd (Self:aRegA100[nPos], "A100") 	  		//01-REG
	aAdd (Self:aRegA100[nPos], Self:cnIndOper)	//02-IND_OPER
	aAdd (Self:aRegA100[nPos], Self:cnIndEmit)	//03-IND_EMIT
	aAdd (Self:aRegA100[nPos], '') 					//04-COD_PART
	aAdd (Self:aRegA100[nPos], Self:cnSitDoc) 	//05-COD_SIT
	aAdd (Self:aRegA100[nPos], Self:cnSerie) 	    //06-SER
	aAdd (Self:aRegA100[nPos], '') 					//07-SUB
	aAdd (Self:aRegA100[nPos], Self:cnNumNf)		//08-NUM_DOC
	aAdd (Self:aRegA100[nPos], '') 					//09-CHV_NFSE
	aAdd (Self:aRegA100[nPos], '')					//10-DT_DOC
	aAdd (Self:aRegA100[nPos], '')	  				//11-DT_EXE_SERV
	aAdd (Self:aRegA100[nPos], '') 					//12-VL_DOC
	aAdd (Self:aRegA100[nPos], '')					//13-IND_PAGTO 				
	aAdd (Self:aRegA100[nPos], '') 					//14-VL_DESC
	aAdd (Self:aRegA100[nPos], '')					//15-VL_BC_PIS
	aAdd (Self:aRegA100[nPos], '')					//16-VL_PIS
	aAdd (Self:aRegA100[nPos], '')					//17-VL_BC_COFINS
	aAdd (Self:aRegA100[nPos], '')					//18-VL_COFINS
	aAdd (Self:aRegA100[nPos], '')					//19-VL_PIS_RET
	aAdd (Self:aRegA100[nPos], '') 					//20-VL_COFINS_RET
	aAdd (Self:aRegA100[nPos], '') 					//21-VL_ISS	

ElseIF lNew
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'A100')
	aAdd(Self:aRegA100, {})
	nPos	:=	Len (Self:aRegA100)
	aAdd (Self:aRegA100[nPos], Self:cGrupoReg) 		//01-RELACIONAMENTO
	aAdd (Self:aRegA100[nPos], "A100") 	  		//01-REG
	aAdd (Self:aRegA100[nPos], Self:cnIndOper)	//02-IND_OPER
	aAdd (Self:aRegA100[nPos], Self:cnIndEmit)	//03-IND_EMIT
	aAdd (Self:aRegA100[nPos], Self:cnCodPart) 	//04-COD_PART
	aAdd (Self:aRegA100[nPos], Self:cnSitDoc) 	//05-COD_SIT
	aAdd (Self:aRegA100[nPos], Self:cnSerie) 	    //06-SER
	aAdd (Self:aRegA100[nPos], '') 					//07-SUB
	aAdd (Self:aRegA100[nPos], Self:cnNumNf)		//08-NUM_DOC
	aAdd (Self:aRegA100[nPos], Self:cnChaveNfe) 	//09-CHV_NFSE
	aAdd (Self:aRegA100[nPos], Self:dnEmissao)	//10-DT_DOC
	aAdd (Self:aRegA100[nPos], Self:dnExec)	  	//11-DT_EXE_SERV
	aAdd (Self:aRegA100[nPos], if(lMT,0,Self:nnValorNf)) 	//12-VL_DOC*
	aAdd (Self:aRegA100[nPos], Self:cnIndPgto)	//13-IND_PAGTO 				
	aAdd (Self:aRegA100[nPos], if(lMT,0,Self:nnValDesc)) 	//14-VL_DESC*
	aAdd (Self:aRegA100[nPos], if(lMT,0,Self:nnBasePis))	//15-VL_BC_PIS*
	aAdd (Self:aRegA100[nPos], if(lMT,0,Self:nnValPis))		//16-VL_PIS*
	aAdd (Self:aRegA100[nPos], if(lMT,0,Self:nnBaseCof))	//17-VL_BC_COFINS*
	aAdd (Self:aRegA100[nPos], if(lMT,0,Self:nnValCof))		//18-VL_COFINS*
	aAdd (Self:aRegA100[nPos], if(lMT,0,Self:nnPisRet))		//19-VL_PIS_RET*
	aAdd (Self:aRegA100[nPos], if(lMT,0,Self:nnCofRet)) 	//20-VL_COFINS_RET*
	aAdd (Self:aRegA100[nPos], if(lMT,0,Self:nnValIss)) 	//21-VL_ISS	*
Else
	nPos	:= nPosAcum
	Self:aRegA100[nPos][13] += Self:nnValorNf 	//12-VL_DOC	
	Self:aRegA100[nPos][15] += Self:nnValDesc 	//14-VL_DESC
	Self:aRegA100[nPos][16] += Self:nnBasePis		//15-VL_BC_PIS
	Self:aRegA100[nPos][17] += Self:nnValPis		//16-VL_PIS
	Self:aRegA100[nPos][18] += Self:nnBaseCof		//17-VL_BC_COFINS
	Self:aRegA100[nPos][19] += Self:nnValCof		//18-VL_COFINS
	Self:aRegA100[nPos][20] += Self:nnPisRet		//19-VL_PIS_RET
	Self:aRegA100[nPos][21] += Self:nnCofRet 		//20-VL_COFINS_RET
	Self:aRegA100[nPos][22] += Self:nnValIss 		//21-VL_ISS	
	
EndIF

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} AddA110()
@description Método que gera registros de informação complementar dodocumento 
			   fiscal, registro A110. 		   

@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddA110() Class EFDCBLOCOA

Local nPos	:= 0

nPos := aScan (Self:aRegA110, {|aX| aX[3] == Self:cCodInfCom })

If nPos	 == 0
	aAdd(Self:aRegA110, {})
	nPos :=	Len (Self:aRegA110)
	aAdd (Self:aRegA110[nPos], Self:cRelac)  		//RELACIONAMENTO
	aAdd (Self:aRegA110[nPos], 'A110')				//01 - REG
	aAdd (Self:aRegA110[nPos], Self:cCodInfCom) 	//02 - COD_INF
	aAdd (Self:aRegA110[nPos], Self:ciDescri)     //03 - TXT_COMPL
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddProcRef()
@description Método que inclui novo registro A111 processo referenciado			   
			   Utiliza método herdado da classe NOTAEFD
@author Erick G. Dias
@since14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddProcRef(cReg) Class EFDCBLOCOA

If cReg == 'A111'	
	Self:ProcRef('A111',@Self:aRegA111)	
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddA120()
@description Método que inclui novo registro A100, considerando as informações
			   já passadas para objeto. Este registro trata das informações
			   complementares das operações de importação.
@author Erick G. Dias
@since 17/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddA120() Class EFDCBLOCOA

Local nPos	:= 0

aAdd(Self:aRegA120, {})
nPos := Len(Self:aRegA120)
aAdd (Self:aRegA120[nPos], Self:cRelac)  		//01-RELACIONAMENTO
aAdd (Self:aRegA120[nPos], "A120")				//01 - REG
aAdd (Self:aRegA120[nPos], Self:nVlImport)	//02 - VL_TOT_SERV
aAdd (Self:aRegA120[nPos], Self:nBsPisImp)	//03 - VL_BC_PIS
aAdd (Self:aRegA120[nPos], Self:nVlPisImp)	//04 - VL_PISIMP
aAdd (Self:aRegA120[nPos], Self:dDtPgPis)		//05 - DT_PAG_PIS
aAdd (Self:aRegA120[nPos], Self:nBsCofImp)	//06 - VL_BC_CONFINS
aAdd (Self:aRegA120[nPos], Self:nVlCofImp)	//07 - VL_COFINS_IMP
aAdd (Self:aRegA120[nPos], Self:dDtPgCof)		//08 - DT_PAG_COFINS
aAdd (Self:aRegA120[nPos], Self:cLocal)		//09 - LOC_EXE_SERV

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddA170()
@description Método que inclui novo registro A170, considerando as informações
			   já passadas para objeto. Este registro trata das informações
			   dos itens do documento fiscal de serviço.
@author Erick G. Dias
@since 17/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------

METHOD AddA170(lNew) Class EFDCBLOCOA

Local nPos	:= 0
Local nPosIt:= 1

Default lNew:=.T.

Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'A170')

aAdd(Self:aRegA170, {}) 
nPos := Len(Self:aRegA170)
if lNew
	nPosIt:=nPos
else
	nPosIt := val(Self:ciNumitem)
endif

aAdd (Self:aRegA170[nPos], Self:cGrupoReg)			//01-RELACIONAMENTO
aAdd (Self:aRegA170[nPos], "A170")					//01 - REG
aAdd (Self:aRegA170[nPos], Alltrim(STR(nPosIt)))	   	//02 - NUM_ITEM
aAdd (Self:aRegA170[nPos], Self:ciCodItem)			//03 - COD_ITEM
aAdd (Self:aRegA170[nPos], Self:ciDescri)			//04 - DESCR_COMPL
aAdd (Self:aRegA170[nPos], Self:niValItem)			//05 - VL_ITEM
aAdd (Self:aRegA170[nPos], Self:niValDesc)			//06 - VL_DESC
aAdd (Self:aRegA170[nPos], Self:ciCodBcc)				//07 - NAT_BC_CRED
aAdd (Self:aRegA170[nPos], Self:ciOriCrd)			   	//08 - IND_ORIG_CRED
aAdd (Self:aRegA170[nPos], Self:ciCSTPis)				//09 - CST_PIS
aAdd (Self:aRegA170[nPos], Self:niBasePis)			//10 - VL_BC_PIS
aAdd (Self:aRegA170[nPos], Self:niAlqPis)				//11 - ALIQ_PIS
aAdd (Self:aRegA170[nPos], Self:niValPis)				//12 - VL_PIS
aAdd (Self:aRegA170[nPos], Self:ciCSTCof)				//13 - CST_COFINS
aAdd (Self:aRegA170[nPos], Self:niBaseCof)			//14 - VL_BC_COFINS
aAdd (Self:aRegA170[nPos], Self:niAlqCof)				//15 - ALIQ_COFINS
aAdd (Self:aRegA170[nPos], Self:niValCof)				//16 - VL_COFINS
aAdd (Self:aRegA170[nPos], Self:ciContaCtb)			//17 - COD_CTA
aAdd (Self:aRegA170[nPos], Self:ciCCusto)				//18 - COD_CCUS

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddA001()
@description Método para geração do registro de abertura do bloco
@param cIndMovto,String,Indicador de movimento de abertura do bloco
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddA001(cIndMovto) Class EFDCBLOCOA

Self:AbreBloco('A001',@Self:aRegA001,cIndMovto)

Return Self:aRegA001

//-------------------------------------------------------------------
/*/{Protheus.doc} AddA990()
@description Método para geração do registro de encerramento do bloco
@param nQtde,Integer,Número de quantidade de linhas
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddA990(nQtde) Class EFDCBLOCOA

Self:FechaBloco('A990',@Self:aRegA990, nQtde) 

Return Self:aRegA990


//-------------------------------------------------------------------
/*/{Protheus.doc} clsA100()
@description Método para limpar variáveis utilizadas no registro A100
@author Erick G. Dias
@since 02/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsA100() Class EFDCBLOCOA

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)
Self:aRegA100	:= {}
Self:aRegA170	:= {}
Self:aRegA111	:= {}
Self:aRegA110	:= {}
Self:aRegA120	:= {}

Return

  