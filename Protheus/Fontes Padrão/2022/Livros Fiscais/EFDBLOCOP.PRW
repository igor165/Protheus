#include "protheus.ch"

/*
  Esta funcao foi criada para que seja possivel visualizar a data deste
  fonte no inspetor de objetos, pois nao eh possivel fazer isso se nao
  houver nenhuma FUNCTION no fonte.
*/
FUNCTION EFDCBLOCOP();RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} EFDCBLOCOP()
@description Classe responsável para geração dos registros do bloco P.
			   Aqui serão tratados os registros P100, P200 e P201.
			   As informações deste bloco não tem relação com as iformações
			   dos demais blocos da EFD Contribuições. Antes de gerar as informações
			   o objeto deverá ser populado antes de adicionar o registro.

@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
CLASS EFDCBLOCOP FROM NOTAEFD

//-----------------------------------------------------
//ATRIBUTOS DA CLASSE
//-----------------------------------------------------
Data cContaCtb		as String		READONLY	//Conta contábil
Data cInfComp		as String		READONLY	//Informação Complementar
Data cCodAtv		as String		READONLY	//Código da atividade
Data cPerRef		as String		READONLY	//Período de referência da apuração
Data cCodRec		as String		READONLY	//Còdigo da receita
Data cIndAju		as String		READONLY	//Indicador de ajuste
Data nValAju		as String		READONLY	//Valor do ajuste
Data cCodAju		as String		READONLY	//Código do ajuste
Data cNumDoc		as String		READONLY	//Número do documento
Data cDescrAju		as String		READONLY	//Descrição ajuste
Data cCNO			as String		READONLY	//Cadastro Nacional de Obra
Data nRecBrut		as Integer		READONLY	//Receita bruta do estabelecimento
Data nVlAtv			as Integer		READONLY	//Valor da atividade
Data nVlExc			as Integer		READONLY	//Valor das exclusões
Data nBasCPRB		as Integer		READONLY	//Base de cálculo CPRB
Data nAlq			as Integer		READONLY	//Alíquota CPRB
Data nVlCPRB		as Integer		READONLY	//Valor da CPRB
Data nTotApu		as Integer		READONLY	//Valor total apurado de CPRB
Data nAjuRed		as Integer		READONLY	//Valor total de ajustes de redução da CPRB
Data nAjuAcr		as Integer		READONLY	//Valor total de ajustes de acréscimo da CPRB
Data nTotCPRB		as Integer		READONLY	//Valor total da CPRB 
Data dDtInicial		as Date			READONLY	//Data Inicial
Data dDtFinal		as Date			READONLY	//Data Final
Data dDtRef			as Date			READONLY	//Data de referência

//-------------------------------------------------------------
//ARRAY DOS REGISTROS DO BLOCO P
//-------------------------------------------------------------
Data aRegP100		as Array		READONLY		
Data aRegP200		as Array		READONLY		
Data aRegP210		as Array		READONLY	
Data aRegP199		as Array		READONLY
Data aRegP001		as Array		READONLY	
Data aRegP990		as Array		READONLY		
	
Data aRegRec		as Array		READONLY //Array com totalizador da receita bruta por P010
//-------------------------------------------------------------
//MÉTODOS DA CLASSE
//-------------------------------------------------------------
Method New()
Method Clear()
Method AddP100()	//Método que adiciona informação no registro P100
Method AddP199()	//Método que adiciona informação no registro P199
Method AddP200()	//Método que adiciona informação no registro P200
Method AddP210()	//Método que adiciona informação no registro P210
Method AddProcRef(cReg) //Método para adicionar processo referenciado
Method AddP001(cIndMovto)
Method AddP990(nQtde)
Method clsP100()
Method ProcRec()
Method AddaRegRec(cGrupoP010,nRecBrut)

Method setContCtb( cContaCtb) 	
Method setInfComp( cInfComp) 	
Method setCodAtv( cCodAtv) 	
Method setPerRef( cPerRef) 	
Method setCodRec( cCodRec) 	
Method setIndAju( cIndAju) 	
Method setValAju( nValAju) 	
Method setCodAju( cCodAju) 	
Method setNumDoc( cNumDoc) 	
Method setDescAju( cDescrAju) 	
Method setRecBrut( nRecBrut) 	
Method setVlAtv( nVlAtv) 	
Method setVlExc( nVlExc) 
Method setBasCPRB( nBasCPRB) 	
Method setAlq( nAlq) 	
Method setVlCPRB( nVlCPRB) 	
Method setTotApu( nTotApu) 	
Method setAjuRed( nAjuRed) 	
Method setAjuAcr( nAjuAcr) 	
Method setTotCPRB( nTotCPRB) 	
Method setDtIni( dDtInicial) 
Method setDtFinal( dDtFinal) 	
Method setDtRef( dDtRef)
Method setValCNO(cCNO)

Method getP100()
Method getP200()
Method getP210()
Method getP199()
	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe 

@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD New() Class EFDCBLOCOP
Self:cJob	:= '00'
Self:Clear()
Self:ClsNotaEfd()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Clear()
@description Método que inicializa as propriedades da classe

@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Method Clear() Class EFDCBLOCOP

//-----------------------------------------------------
Self:cContaCtb		:= ''	//Conta contábil
Self:cInfComp		:= ''	//Informação Complementar
Self:cCodAtv		:= ''	//Código da atividade
Self:cPerRef		:= ''	//Período de referência da apuração
Self:cCodRec		:= ''	//Còdigo da receita
Self:cIndAju		:= ''	//Indicador de ajuste
Self:nValAju		:= ''	//Valor do ajuste
Self:cCodAju		:= ''	//Código do ajuste
Self:cNumDoc		:= ''	//Número do documento
Self:cDescrAju		:= ''	//Descrição ajuste
Self:nRecBrut		:= 0	//Receita bruta do estabelecimento
Self:nVlAtv			:= 0	//Valor da atividade
Self:nVlExc			:= 0	//Valor das exclusões
Self:nBasCPRB		:= 0	//Base de cálculo CPRB
Self:nAlq			:= 0	//Alíquota CPRB
Self:nVlCPRB		:= 0	//Valor da CPRB
Self:nTotApu		:= 0	//Valor total apurado de CPRB
Self:nAjuRed		:= 0	//Valor total de ajustes de redução da CPRB
Self:nAjuAcr		:= 0	//Valor total de ajustes de acréscimo da CPRB
Self:nTotCPRB		:= 0	//Valor total da CPRB 
Self:dDtInicial		:= CTod("  /  /    ")	//Self:Inicial
Self:dDtFinal		:= CTod("  /  /    ")	//Self:Final
Self:dDtRef			:= CTod("  /  /    ")	//Self:de referência
Self:cCNO			:= ''	//Cadastro Nacional de Obra

//-------------------------------------------------------------
//ARRAY DOS REGISTROS DO BLOCO P
//-------------------------------------------------------------
Self:aRegP100		:= {}		
Self:aRegP200		:= {}		
Self:aRegP210		:= {}
Self:aRegP199		:= {}
Self:aRegP001		:= {}	
Self:aRegP990		:= {}			
Self:aRegRec		:= {}

Return

Method setContCtb( cContaCtb) Class EFDCBLOCOP
	Self:cContaCtb := cContaCtb
Return
Method setInfComp( cInfComp) Class EFDCBLOCOP
	Self:cInfComp := cInfComp
Return
Method setCodAtv( cCodAtv) Class EFDCBLOCOP
	Self:cCodAtv := cCodAtv
Return
Method setPerRef( cPerRef) Class EFDCBLOCOP
	Self:cPerRef := cPerRef
Return
Method setCodRec( cCodRec) Class EFDCBLOCOP
	Self:cCodRec := cCodRec
Return
Method setIndAju( cIndAju) Class EFDCBLOCOP
	Self:cIndAju := cIndAju
Return
Method setValAju( nValAju) Class EFDCBLOCOP
	Self:nValAju := nValAju
Return
Method setCodAju( cCodAju) Class EFDCBLOCOP
	Self:cCodAju := cCodAju
Return
Method setNumDoc( cNumDoc) Class EFDCBLOCOP
	Self:cNumDoc := cNumDoc
Return
Method setDescAju( cDescrAju) Class EFDCBLOCOP
	Self:cDescrAju := cDescrAju
Return
Method setRecBrut( nRecBrut) Class EFDCBLOCOP
	Self:nRecBrut := nRecBrut
Return
Method setVlAtv( nVlAtv) Class EFDCBLOCOP
	Self:nVlAtv := nVlAtv
Return
Method setVlExc( nVlExc) Class EFDCBLOCOP
	Self:nVlExc := nVlExc
Return
Method setBasCPRB( nBasCPRB) Class EFDCBLOCOP
	Self:nBasCPRB := nBasCPRB
Return
Method setAlq( nAlq) Class EFDCBLOCOP
	Self:nAlq := nAlq
Return
Method setVlCPRB( nVlCPRB) Class EFDCBLOCOP
	Self:nVlCPRB := nVlCPRB
Return
Method setTotApu( nTotApu) Class EFDCBLOCOP
	Self:nTotApu := nTotApu
Return
Method setAjuRed( nAjuRed) Class EFDCBLOCOP
	Self:nAjuRed := nAjuRed
Return
Method setAjuAcr( nAjuAcr) Class EFDCBLOCOP
	Self:nAjuAcr := nAjuAcr
Return
Method setTotCPRB( nTotCPRB) Class EFDCBLOCOP
	Self:nTotCPRB := nTotCPRB
Return
Method setDtIni( dDtInicial) Class EFDCBLOCOP
	Self:dDtInicial := dDtInicial
Return
Method setDtFinal( dDtFinal) Class EFDCBLOCOP
	Self:dDtFinal := dDtFinal
Return
Method setDtRef( dDtRef) Class EFDCBLOCOP
	Self:dDtRef := dDtRef
Return
Method setValCNO( cCNO) Class EFDCBLOCOP
	Self:cCNO := cCNO
Return
Method getP100() Class EFDCBLOCOP
Return Self:aRegP100

Method getP200() Class EFDCBLOCOP
Return Self:aRegP200

Method getP210() Class EFDCBLOCOP
Return Self:aRegP210

Method getP199() Class EFDCBLOCOP
Return Self:aRegP199

Method AddaRegRec(cGrupoP010,nRecBrut) Class EFDCBLOCOP	
	Local nPos := 0
	nPos := aScan(Self:aRegRec, {|aX| aX[1]== cGrupoP010})
	If nPos == 0
		aAdd(Self:aRegRec, {})
		nPos :=	Len(Self:aRegRec)
		aAdd(Self:aRegRec[nPos],cGrupoP010)
		aAdd(Self:aRegRec[nPos],nRecBrut)
	Else
		Self:aRegRec[nPos][2] += nRecBrut
	Endif	
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} AddP100()
@description Método que inclui novo registro P100. Neste registro teremos
			   a Contribuição Orevidenciária sobre Receita Bruta, agrupada 
			   por código de atividade.
@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddP100(lCNO) Class EFDCBLOCOP

Local nPos	:= 0

	nPos := aScan (Self:aRegP100, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac	.AND. ;
											aX[6]==Self:cCodAtv .AND. aX[12]==Self:cContaCtb })

DEFAULT lCNO := .F.

If !lCNO
	
	If nPos == 0
		Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'P100')
		aAdd(Self:aRegP100, {})
		nPos	:=	Len (Self:aRegP100)	
		aAdd (Self:aRegP100[nPos], Self:cGrupoReg)		//RELACIONAMENTO
		aAdd (Self:aRegP100[nPos], 'P100')					//01-REG
		aAdd (Self:aRegP100[nPos], Self:dDtInicial) 		//02-DT_INI
		aAdd (Self:aRegP100[nPos], Self:dDtFinal) 		//03-DT_FIN	
		aAdd (Self:aRegP100[nPos], Self:nRecBrut)  		//04-VL_REC_TOT_EST	
		aAdd (Self:aRegP100[nPos], Self:cCodAtv)			//05-COD_ATIV_ECON	
		aAdd (Self:aRegP100[nPos], Self:nVlAtv)			//06-VL_REC_ATIV_ESTAB	
		aAdd (Self:aRegP100[nPos], Self:nVlExc)			//07-VL_EXC
		aAdd (Self:aRegP100[nPos], Self:nBasCPRB) 		//08-VL_BC_CONT
		aAdd (Self:aRegP100[nPos], {Self:nAlq,4}) 		//09-ALIQ_CONT
		aAdd (Self:aRegP100[nPos], Self:nVlCPRB) 			//10-VL_CONT_APU
		aAdd (Self:aRegP100[nPos], Self:cContaCtb) 		//11-COD_CTA	
		aAdd (Self:aRegP100[nPos], Self:cInfComp) 		//12-INFO_COMPL
	Else
		Self:aRegP100[nPos][05]	+= Self:nRecBrut			//04-VL_REC_TOT_EST
		Self:aRegP100[nPos][07]	+= Self:nVlAtv			//06-VL_REC_ATIV_ESTAB	
		Self:aRegP100[nPos][08]	+= Self:nVlExc			//07-VL_EXC
		Self:aRegP100[nPos][09]	+= Self:nBasCPRB			//08-VL_BC_CONT
		Self:aRegP100[nPos][11]	+= Self:nVlCPRB			//10-VL_CONT_APU
	EndIf
Else
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'P199') 
	aAdd(Self:aRegP100, {})
	nPos	:=	Len (Self:aRegP100)	
	aAdd (Self:aRegP100[nPos], Self:cGrupoReg)		//RELACIONAMENTO
	aAdd (Self:aRegP100[nPos], 'P199_2')			//01-REG
	aAdd (Self:aRegP100[nPos], Self:dDtInicial) 	//02-DT_INI
	aAdd (Self:aRegP100[nPos], Self:dDtFinal) 		//03-DT_FIN	
	aAdd (Self:aRegP100[nPos], Self:nRecBrut)  		//04-VL_REC_TOT_EST	
	aAdd (Self:aRegP100[nPos], Self:cCodAtv)		//05-COD_ATIV_ECON	
	aAdd (Self:aRegP100[nPos], Self:nVlAtv)			//06-VL_REC_ATIV_ESTAB	
	aAdd (Self:aRegP100[nPos], Self:nVlExc)			//07-VL_EXC
	aAdd (Self:aRegP100[nPos], Self:nBasCPRB) 		//08-VL_BC_CONT
	aAdd (Self:aRegP100[nPos], {Self:nAlq,4}) 		//09-ALIQ_CONT
	aAdd (Self:aRegP100[nPos], Self:nVlCPRB) 		//10-VL_CONT_APU
	aAdd (Self:aRegP100[nPos], Self:cContaCtb) 		//11-COD_CTA	
	aAdd (Self:aRegP100[nPos], Self:cCNO)	 		//12-COD_CNO
EndIf	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddP199()
@description Método que inclui novo registro P199. Neste registro teremos
			   o Detalhamento das exclusões de receitas. Gravação da Tabela T082AC
			   
@author Vogas Júnior
@since 20/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
METHOD AddP199() Class EFDCBLOCOP

Local nPos	:= 0

nPos := aScan (Self:aRegP199, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac	.AND. aX[4]==Self:cCodAju  })

If nPos == 0
	Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'P199')
	aAdd(Self:aRegP199, {})
	nPos:=	Len (Self:aRegP199)	
	aAdd (Self:aRegP199[nPos], Self:cGrupoReg)	//RELACIONAMENTO
	aAdd (Self:aRegP199[nPos], 'P199_1')		//01-REG
	aAdd (Self:aRegP199[npos], Self:cIndAju)	//02-TIPO DO DETALHE
	aAdd (Self:aRegP199[nPos], Self:cCodAju)	//03-CÓDIGO DO DETALHE
	aAdd (Self:aRegP199[nPos], Self:nValAju)	//04-VALOR DO DETALHE	
	aAdd (Self:aRegP199[nPos], Self:cDescrAju)	//05-DESCRIÇÃO DO DETALHE
	aAdd (Self:aRegP199[nPos], Self:dDtRef) 	//06-DATA DE REFERÊNCIA
Else
	Self:aRegP199[nPos][05]	+= Self:nValAju		//03-VALOR DO AJUSTE	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddP200()
@description Método que inclui novo registro P200. Será demonstrada a
			  Consolidação da Contribuição Previdencária Sobre a Receita Bruta.			  
@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddP200() Class EFDCBLOCOP

Local nPos	:= 0

nPos := aScan (Self:aRegP200, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac 	.AND. ;
										 aX[8]==Self:cCodRec})
If nPos == 0
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'P200')
	aAdd(Self:aRegP200, {})
	nPos	:=	Len (Self:aRegP200)	
	aAdd (Self:aRegP200[nPos], Self:cGrupoReg)		//RELACIONAMENTO
	aAdd (Self:aRegP200[nPos],'P200')				//01-REG
	aAdd (Self:aRegP200[nPos], Self:cPerRef)		//02-CNPJ		
	aAdd (Self:aRegP200[nPos], Self:nTotApu) 		//03-VL_TOT_CONT_APU	
	aAdd (Self:aRegP200[nPos], Self:nAjuRed)		//04-VL_TOT_AJ_REDUC		
	aAdd (Self:aRegP200[nPos], Self:nAjuAcr)		//05-VL_TOT_AJ_ACRES		
	aAdd (Self:aRegP200[nPos], Self:nTotCPRB) 	//06-VL_TOT_CONT_DEV		
	aAdd (Self:aRegP200[nPos], Self:cCodRec)		//07-COD_REC		

Else
	Self:aRegP200[nPos][04] +=	Self:nTotApu		//03-VL_TOT_CONT_APU	
	Self:aRegP200[nPos][05] +=	Self:nAjuRed		//04-VL_TOT_AJ_REDUC
	Self:aRegP200[nPos][06] +=	Self:nAjuAcr		//05-VL_TOT_AJ_ACRES
	Self:aRegP200[nPos][07] +=	Self:nTotCPRB		//06-VL_TOT_CONT_DEV
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddP210()
@description Método que inclui novo registro P210. Este registro é referente
			   o Ajuste de redução e ajuste de acréscimo da CPRB. Registro 
			   filho do registro P200.
@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//------------------------------------------------------------------- 
METHOD AddP210() Class EFDCBLOCOP

Local nPos	:= 0

Self:cGrupoReg	:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'P210')

aAdd(Self:aRegP210, {})
nPos	:=	Len (Self:aRegP210)
aAdd (Self:aRegP210[nPos], Self:cGrupoReg)	//RELACIONAMENTO
aAdd (Self:aRegP210[nPos],'P210')			//01 - Reg
aAdd (Self:aRegP210[nPos],Self:cIndAju)	//02 - IND_AJ	
aAdd (Self:aRegP210[nPos],Self:nValAju)	//03 - VL_AJ				
aAdd (Self:aRegP210[nPos],Self:cCodAju)	//04 - COD_AJ	
aAdd (Self:aRegP210[nPos],Self:cNumDoc)	//05 - NUM_DOC	
aAdd (Self:aRegP210[nPos],Self:cDescrAju)	//06 - DESCR_AJ																
aAdd (Self:aRegP210[nPos],Self:dDtRef)		//07 - DT_REF	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddProcRef()
@description Método que inclui novo registro P199
			   Registro de Processo referenciado			   			  
@author Erick G. Dias
@since14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddProcRef(cReg) Class EFDCBLOCOP

If cReg == 'P199'	
	Self:ProcRef('P199',@Self:aRegP199)
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddP001()
@description Método para geração do registro de abertura do bloco
@param cIndMovto,String,Indicador de movimento de abertura do bloco
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddP001(cIndMovto) Class EFDCBLOCOP

Self:AbreBloco('P001',@Self:aRegP001,cIndMovto)

Return Self:aRegP001

//-------------------------------------------------------------------
/*/{Protheus.doc} AddP990()
@description Método para geração do registro de encerramento do bloco
@param nQtde,Integer,Número de quantidade de linhas
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddP990(nQtde) Class EFDCBLOCOP

Self:FechaBloco('P990',@Self:aRegP990, nQtde) 

Return Self:aRegP990
//-------------------------------------------------------------------
/*/{Protheus.doc} clsP100()
@description Método que limpa variáveis do F100
@author Rafael S Oliverira
@since 10/10/2016
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsP100() Class EFDCBLOCOP

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcRec()
@description Método que gerar campo Valor da Receita Bruta Total do Estabelecimento no
Período por P010
@author Rafael S Oliverira
@since 10/10/2016
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD ProcRec() Class EFDCBLOCOP

Local nPos	:= 0
Local Nx	:= 0

For Nx := 1 To Len(Self:aRegP100)

	nPos := aScan (Self:aRegRec, {|aX| aX[1]==SubStr(Self:aRegP100[Nx][1],1,Len(Self:cRelac ))})

	IF nPos > 0
		Self:aRegP100[Nx][05]	:= Self:aRegRec[nPos][2]			//04-VL_REC_TOT_EST
	Endif
	
Next

Return
 