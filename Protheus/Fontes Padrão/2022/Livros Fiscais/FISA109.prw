#INCLUDE "FWMBROWSE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH" 

Function FISA109(); RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} TABCLP
Classe que será responsável por realizar a gravação na tabela CLP
Tabela CLP terá as informações de identificação do participante na CAT83

@author Erick G. Dias
@since 27/03/2015
@version 11.80 
/*/
//-------------------------------------------------------------------
CLASS TABCLP

	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------	
	Data dPer			As Date	
	Data cIdPart		As String
	Data cFilPart		As String
	Data cCodPart		As String
	Data cLoja			As String
	Data cTpPart		As String
	Data cCnpj        	As String 
	Data cAliasTmp		As String
			
	Method New()
	Method Insert()
	Method Clear()
	Method Save() 
	Method SetParam(cCampo,Value)
	Method setAlsTmp()
	Method getAlsTmp()
ENDCLASS


//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 27/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABCLP

Self:Clear()
Self:cAliasTmp	:= ''

Return  Self

Method setAlsTmp(value) Class TABCLP
	Self:cAliasTmp	:= value
Return

Method getAlsTmp(value) Class TABCLP		
Return Self:cAliasTmp
Method Clear() Class TABCLP

Self:dPer		:= CTod("  /  /    ")
Self:cIdPart	:= ''
Self:cFilPart	:= ''
Self:cCodPart	:= ''
Self:cLoja		:= ''
Self:cTpPart	:= ''
Self:cCnpj    	:= ''

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 27/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABCLP

Do Case				
	Case cCampo == 'CLP_PERIOD'
		Self:dPer	:= Value
	Case cCampo == 'CLP_IDPART'
		Self:cIdPart := Value
	Case cCampo == 'CLP_FLPART'
		Self:cFilPart	:= Value		
	Case cCampo == 'CLP_COD'
		Self:cCodPart	:= Value
	Case cCampo == 'CLP_LOJA'
		Self:cLoja		:= Value
	Case cCampo == 'CLP_TPPART'
		Self:cTpPart	:= Value
   Case cCampo == 'CLP_CNPJ'
        Self:cCnpj    := Value	

EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá salvar as informações na tabela considerando as inormações 
passadas para classe.  

@author Erick G. Dias
@since 27/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save(lExterior) Class TABCLP

Local cIdPart	:= ''
Local cRet		:= ''

//Se for exterior não posso verificar por CNPJ, pois não existe essa informação. No entanto precisa inserir na tabela CLP
IF lExterior

	CLP->(dbSetOrder(1))
	IF CLP->(MSSEEK( xFilial('CLP')+dTos(Self:dPer)+Self:cIdPart))
		 cIdPart := CLP->CLP_IDPART
	Else
		RecLock('CLP',.T.)  
	    CLP->CLP_IDPART     :=  Self:cIdPart
	    CLP->CLP_FILIAL     :=  xFilial('CLP')
	    CLP->CLP_PERIOD     :=  Self:dPer
	    CLP->CLP_FLPART     :=  Self:cFilPart
	    CLP->CLP_COD        :=  Self:cCodPart
	    CLP->CLP_LOJA       :=  Self:cLoja
	    CLP->CLP_TPPART     :=  Self:cTpPart
	    CLP->CLP_CNPJ       :=  Self:cCnpj
	    CLP->(MsUnLock())		 
	EndIf
Else 
	CLP->(dbSetOrder(3))
	IF CLP->(MSSEEK( xFilial('CLP')+dTos(Self:dPer)+Self:cCnpj))
        cId := CLP->CLP_IDPART
	Else
	    RecLock('CLP',.T.)  
	    CLP->CLP_IDPART     :=  Self:cIdPart
	    CLP->CLP_FILIAL     :=  xFilial('CLP')
	    CLP->CLP_PERIOD     :=  Self:dPer
	    CLP->CLP_FLPART     :=  Self:cFilPart
	    CLP->CLP_COD        :=  Self:cCodPart
	    CLP->CLP_LOJA       :=  Self:cLoja
	    CLP->CLP_TPPART     :=  Self:cTpPart
	    CLP->CLP_CNPJ       :=  Self:cCnpj
	    CLP->(MsUnLock())
	EndIF
EndIf	

IF !Empty(Self:cCnpj)
    cRet:= Self:cCnpj
Else
    cRet:=  cvaltochar(Val(Self:cIdPart)) 
EndIf

Self:Clear()

Return cRet




//-------------------------------------------------------------------
/*/{Protheus.doc} TABF04
Classe que irá alimentar os cabecalhos das fichas

@author Erick G. Dias
@since 11/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABF04

	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------	
	Data dData		As Date
	Data cProd		As String
	Data cFicha		As String
	Data cStatus	As String
	Data cAliasTmp	As String
		
	Method New()
	Method Insert()
	Method Clear()
	Method Save()
	Method SetParam(cCampo,Value)
	Method setAlsTmp()
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 27/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABF04

Self:Clear()
Self:cAliasTmp		:= ''
Return  Self


Method setAlsTmp(value) Class TABF04
	Self:cAliasTmp	:= value
Return

Method Clear() Class TABF04

Self:dData		:= CTod("  /  /    ")
Self:cProd		:= ''
Self:cFicha	:= ''
Self:cStatus	:= 2

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 27/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABF04

Do Case				
	Case cCampo == 'F04_PERIOD'
		Self:dData	:= Value
	Case cCampo == 'F04_PROD'
		Self:cProd := Value	
	Case cCampo == 'F04_FICHA'
		Self:cFicha	:=  Value	
	Case cCampo == 'F04_STATUS'
		Self:cStatus	:= Value			
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá salvar as informações na tabela considerando as inormações 
passadas para classe.  

@author Erick G. Dias
@since 27/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save() Class TABF04
Local cId	:= ''

F04->(dbSetOrder(1))

//Verrificar antes se a nota já existe
IF F04->(MSSEEK( xFilial('F04')+dTos(Self:dData)+Padr(Self:cProd,TAMSX3("F04_PROD")[1]) +Self:cFicha))
	cId	:= F04->F04_ID	
Else	
	cId	:= cvaltochar(FSA108Seq('CB',Self:cAliasTmp)) //CB = Cabecalho
	RecLock('F04',.T.)
	F04->F04_FILIAL		:=	xFilial('F04')
	F04->F04_PERIOD		:=	Self:dData
	F04->F04_PROD		:=	Self:cProd
	F04->F04_FICHA		:=	Self:cFicha
	F04->F04_ID			:=	cId
	F04->F04_STATUS		:=	Self:cStatus
	F04->F04_PROC		:= '2' //Por padrão cria com indicador de processamento = 2-Não
	F04->(MsUnLock())
EndIF

Self:Clear()

Return cId


//-------------------------------------------------------------------
/*/{Protheus.doc} TABF01
Classe que irá alimentar a tabela de rateios

@author Graziele Paro
@since 11/08/2015
@version 11.80
/*/

//-------------------------------------------------------------------
CLASS TABF01

    //--------------------------------------------------------
    //Variáveis com os campos da tabela
    //--------------------------------------------------------  
    Data dPeriod    As Date
    Data cFicha 	As String
    Data cProdut    As String
    Data nPerRat    As String
    Data cAliasTmp  As String
        
    Method New()
    Method Insert()
    Method Clear()
    Method Save()
    Method SetParam(cCampo,Value)
    Method setAlsTmp()
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Graziele Paro
@since 11/08/2015
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABF01

Self:Clear()
Self:cAliasTmp	:= ''
Return  Self


Method setAlsTmp(value) Class TABF01
    Self:cAliasTmp  := value
Return

Method Clear() Class TABF01

Self:dPeriod    := ''       
Self:cFicha     := ''       
Self:cProdut    := ''   
Self:nPerRat    := ''   


//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Graziele Paro
@since 11/08/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABF01

Do Case             
    Case cCampo == 'F01_PERIOD'
        Self:dPeriod    := Value
    Case cCampo == 'F01_FICHA'
        Self:cFicha := Value    
    Case cCampo == 'F01_PRODUT'
        Self:cProdut    :=  Value   
    Case cCampo == 'F01_PERRAT'
        Self:nPerRat    := Value            
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá salvar as informações na tabela considerando as inormações 
passadas para classe.  

@author Graziele Paro
@since 11/08/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save() Class TABF01


F01->(dbSetOrder(1))

//Verrificar antes se a nota já existe
IF F01->(MSSEEK( xFilial('F01')+(Self:dPeriod)+Padr(Self:cProdut,TAMSX3("F01_PRODUT")[1]) +Self:cFicha))
    RecLock('F01',.F.)
    F01->F01_FILIAL     :=  xFilial('F01')
    F01->F01_PERIOD     :=  Self:dPeriod
    F01->F01_FICHA      :=  Self:cFicha
    F01->F01_PRODUT     :=  Self:cProdut
    F01->F01_PERRAT     :=  Self:nPerRat
    F01->(MsUnLock())
Else    
    RecLock('F01',.T.)
    F01->F01_FILIAL     :=  xFilial('F01')
    F01->F01_PERIOD     :=  Self:dPeriod
    F01->F01_FICHA      :=  Self:cFicha
    F01->F01_PRODUT     :=  Self:cProdut
    F01->F01_PERRAT     :=  Self:nPerRat
    F01->(MsUnLock())
EndIF

Self:Clear()

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} TABCLQ
Classe que será responsável por realizar a gravação na tabela CLQ
Tabela CLQ terá as informações de identificação do documento nas operações
das fichas da cat83

@author Erick G. Dias
@since 27/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABCLQ

	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------	
	Data dData		As Date
	Data cTpDoc		As String
	Data cCFOP		As String
	Data cTpMov		As String	
	Data cTipo		As String
	Data cSerie		As String
	Data cNumero	As String
	Data cItem		As String
	Data nTamNF		As Integer
	Data nTamSer	As Integer
	Data nTamItem	As Integer	
	Data dDataOri	As Date
	Data cNumOri	As String
	Data cSerOri	As String
	Data cItemOri	As String
	Data cTpDocOri	As String
	Data cAliasTmp	As String
		
	Method New()
	Method Insert()
	Method Clear()
	Method Save()
	Method SetParam(cCampo,Value)
	Method setAlsTmp()

	Method getData()
	Method getTpDoc()
	Method getCFOP()
	Method getTpMov()
	Method getTipo()
	Method getSerie()
	Method getNumero()
	Method getItem()
	Method getTamNF()
	Method getTamSer()
	Method getTamItem()
	Method getDataOri()
	Method getNumOri()	
	Method getSerOri()	
	Method getItemOri()
	Method getTpDocOri()
	Method getAliasTmp()
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 27/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABCLQ

Self:Clear()
Self:cAliasTmp		:= ''
Return  Self

Method setAlsTmp(value) Class TABCLQ
	Self:cAliasTmp	:= value
Return

Method Clear() Class TABCLQ

Self:dData		:= CTod("  /  /    ")
Self:dDataOri	:= CTod("  /  /    ")
Self:cTpDoc		:= ''
Self:cCFOP		:= ''
Self:cTpMov		:= ''
Self:cTipo		:= ''
Self:cSerie		:= ''
Self:cNumero	:= ''
Self:cItem		:= ''
Self:cNumOri	:= ''
Self:cSerOri	:= ''
Self:cItemOri	:= ''
Self:cTpDocOri	:= ''
Self:nTamNF		:= TamSx3("CLQ_NRDOC")[1]
Self:nTamSer	:= TamSx3("CLQ_SERIE")[1]
Self:nTamItem	:= TamSx3("CLQ_ITEM")[1]

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 27/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABCLQ

Do Case				
	Case cCampo == 'CLQ_DATA'
		Self:dData	:= Value
	Case cCampo == 'CLQ_TPDOC'
		Self:cTpDoc := Padr(Value,1)	
	Case cCampo == 'CLQ_CFOP'
		Self:cCFOP	:=  Padr(Value,4)		
	Case cCampo == 'CLQ_TPMOV'
		Self:cTpMov	:= Padr(Value,1)		
	Case cCampo == 'CLQ_TIPO'
		Self:cTipo	:= Padr(Value,1)		
	Case cCampo == 'CLQ_SERIE'
		Self:cSerie := Padr(Value,Self:nTamSer)				
	Case cCampo == 'CLQ_NRDOC'
		Self:cNumero 	:= Padr(Value,Self:nTamNF)	
	Case cCampo == 'CLQ_ITEM'
		Self:cItem	 := Padr(Value,Self:nTamItem)
	Case cCampo == 'CLQ_DTORI'
		Self:dDataOri	 := Value
	Case cCampo == 'CLQ_TPDCOR'
		Self:cTpDocOri	 := Padr(Value,1)					
	Case cCampo == 'CLQ_SERORI'
		Self:cSerOri	 := Padr(Value,Self:nTamSer)	
	Case cCampo == 'CLQ_DOCORI'
		Self:cNumOri	 := Padr(Value,Self:nTamNF)
	Case cCampo == 'CLQ_ITEORI'
		Self:cItemOri	 := Padr(Value,Self:nTamItem)			
				
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá salvar as informações na tabela considerando as inormações 
passadas para classe.  

@author Erick G. Dias
@since 27/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save() Class TABCLQ
Local cId	:= ''

CLQ->(dbSetOrder(2))

//Verrificar antes se a nota já existe
IF CLQ->(MSSEEK( xFilial('CLQ')+dTos(Self:dData)+Self:cTpMov+Self:cNumero+Self:cSerie+Self:cItem))
	cId	:= CLQ->CLQ_IDNF	
Else	
	cId					:= cvaltochar(FSA108Seq('NF',Self:cAliasTmp)) //NF = nota fisca
	RecLock('CLQ',.T.)
	CLQ->CLQ_FILIAL		:=	xFilial('CLQ')
	CLQ->CLQ_IDNF		:=	cId
	CLQ->CLQ_DATA		:=	Self:dData
	CLQ->CLQ_TPDOC		:=	Self:cTpDoc
	CLQ->CLQ_CFOP		:=	Self:cCFOP
	CLQ->CLQ_TPMOV		:=	Self:cTpMov
	CLQ->CLQ_SERIE		:=	Self:cSerie
	CLQ->CLQ_NRDOC		:=	Self:cNumero
	CLQ->CLQ_ITEM		:=	Self:cItem
	CLQ->CLQ_TIPO		:=	Self:cTipo	
	CLQ->CLQ_DTORI		:=	Self:dDataOri
	CLQ->CLQ_TPDCOR		:=	Self:cTpDocOri
	CLQ->CLQ_SERORI		:=	Self:cSerOri
	CLQ->CLQ_DOCORI		:=	Self:cNumOri
	CLQ->CLQ_ITEORI		:=	Self:cItemOri	
	CLQ->(MsUnLock())
EndIF

//Self:Clear() 

Return cId

/*Gets CLQ*/
Method GetData(value) Class TABCLQ	
Return Self:dData

Method GetTpDoc(value) Class TABCLQ	
Return Self:cTpDoc

Method GetCFOP(value) Class TABCLQ
Return Self:cCFOP
	
Method GetTpMov(value) Class TABCLQ	
Return Self:cTpMov
	
Method GetTipo(value) Class TABCLQ
Return Self:cTipo

Method GetSerie(value) Class TABCLQ
Return Self:cSerie

Method GetNumero(value) Class TABCLQ	
Return Self:cNumero

Method GetItem(value) Class TABCLQ
Return Self:cItem
	
Method GetTamNF(value) Class TABCLQ
Return Self:nTamNF
		
Method GetTamSer(value) Class TABCLQ
Return Self:nTamSer
	
Method GetTamItem(value) Class TABCLQ
Return Self:nTamItem
		
Method GetDataOri(value) Class TABCLQ
Return Self:dDataOri
	
Method GetNumOri(value) Class TABCLQ	
Return Self:cNumOri

Method GetSerOri(value) Class TABCLQ
Return Self:cSerOri
	
Method GetItemOri(value) Class TABCLQ
Return Self:cItemOri
	
Method GetTpDocOri(value) Class TABCLQ
Return Self:cTpDocOri
	
Method GetAliasTmp(value) Class TABCLQ
Return Self:cAliasTmp

//-------------------------------------------------------------------
/*/{Protheus.doc} TABCLR
Classe que será responsável por realizar a gravação na tabela CLR
A tabela CLR terá as movimentações das fichas da CAT83.

@author Erick G. Dias
@since 27/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABCLR

	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------	
	Data dPeriodo			As Date
	Data cProd				As String	
	Data cInsumo			As String
	Data cIdFicha			As String
	Data cFicha				As String	
	Data cIdNota			As String
	Data cIdTomador			As String
	Data cIdRemet			As String
	Data cIdDest			As String
	Data cIdDet				As String
	Data nNrLanc			As Integer
	Data cHist				As String
	Data cFilMov			As String
	Data cArmazem			As String
	Data cNumSeq			As String
	Data cUfIni				As String
	Data cUfDest			As String
	Data cTpReq				As String
	Data cNumDiDsi			As String
	Data cCodLancto			As String
	Data cTabMovto			As String
	Data cCodOrigem			As String	
	Data cEnqLegal			As String
	Data cDespacho			As String
	Data cComprov			As String
	Data cCodVeic			As String
	Data nKm				As Integer
	Data nIndRat			As Integer
	Data cFchaPerda			As String	
	Data cUnidade			As String
	Data cTpDoc				As String
	Data cTpMov				As String
	Data nNrOrd				As Integer
	Data cIdCab				As String		
	Data cOriDest			As String
	Data cExpInd         	As String
	Data cPerRat         	As Integer
	//Antigos campos da CLS
	Data nVlICMS			As Integer
	Data nVlCusto			As Integer
	Data nUnitICMS			As Integer
	Data nUnitCusto			As Integer
	Data nVlIPI				As Integer
	Data nVlOutros			As Integer
	Data nQtde				As Integer
	Data nPerCusto			As Integer
	Data nQtdeCOO			As Integer
	Data nSaida				As Integer
	Data nCrdOutor			As Integer
	Data nCrdOper			As Integer
	Data nCrdComu			As Integer
	Data nIcmsComp			As Integer
	Data nIcmsDev			As Integer
	Data nTotNaoGe			As Integer
	Data nICMSNaoGe			As Integer
	Data nTotGerad			As Integer
	Data nICMSST			As Integer
	Data nOutProp			As Integer
	Data nOutST				As Integer
	Data nBaseItem			As Integer
	Data nPerOutor			As Integer
	Data nTotICMS			As Integer
	Data nCrdAcum			As Integer
	Data nAliq				As Integer


		
	Method New()
	Method Insert()
	Method Clear()
	Method Save()
	Method SetParam(cCampo,Value)
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 27/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABCLR

Self:Clear()

Return  Self

Method Clear() Class TABCLR

Self:dPeriodo			:=CTod("  /  /    ")
Self:cProd				:= ''
Self:cInsumo			:= ''	
Self:cIdFicha			:= ''
Self:cFicha				:= ''	
Self:cIdNota			:= ''
Self:cIdTomador			:= ''
Self:cIdRemet			:= ''
Self:cIdDest			:= ''
Self:cIdDet				:= ''
Self:nNrLanc			:= 0
Self:cHist				:= ''
Self:cFilMov			:= ''
Self:cArmazem			:= ''
Self:cNumSeq			:= ''
Self:cUfIni				:= ''
Self:cUfDest			:= ''
Self:cTpReq				:= ''
Self:cNumDiDsi			:= ''
Self:cCodLancto			:= ''
Self:cTabMovto			:= ''
Self:cCodOrigem			:= ''
Self:cEnqLegal			:= ''
Self:cDespacho			:= ''
Self:cComprov			:= ''
Self:cCodVeic			:= ''
Self:nKm				:= 0
Self:nIndRat			:= 0
Self:cFchaPerda			:= ''	
Self:cUnidade			:= ''
Self:cTpDoc				:= ''
Self:cTpMov				:= ''
Self:nNrOrd				:= 0
Self:cIdCab				:= ''
Self:cOriDest			:= ''
Self:cExpInd         	:= ''
Self:cPerRat         	:= 0

//Antigos campos da cls
self:nVlICMS			:= 0
self:nVlCusto			:= 0
self:nUnitICMS			:= 0
self:nUnitCusto			:= 0
self:nVlIPI				:= 0
self:nVlOutros			:= 0
self:nQtde				:= 0
self:nPerCusto			:= 0
self:nQtdeCOO			:= 0
self:nSaida				:= 0
self:nCrdOutor			:= 0
self:nCrdOper			:= 0
self:nCrdComu			:= 0
self:nIcmsComp			:= 0
self:nIcmsDev			:= 0
self:nTotNaoGe			:= 0
self:nICMSNaoGe			:= 0
self:nTotGerad			:= 0
self:nICMSST			:= 0
self:nOutProp			:= 0
self:nOutST				:= 0
self:nBaseItem			:= 0
self:nPerOutor			:= 0
self:nTotICMS			:= 0
self:nCrdAcum			:= 0
self:nAliq				:= 0

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 27/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABCLR

Do Case				
	Case cCampo == 'CLR_PERIOD'
		Self:dPeriodo	:= Value
	Case cCampo == 'CLR_PROD'
		Self:cProd 	:= Value
	Case cCampo == 'CLR_PRDMOV'
		Self:cInsumo	:= Value
	Case cCampo == 'CLR_FICHA'
		Self:cFicha	:= Value
	Case cCampo == 'CLR_IDNF'
		Self:cIdNota := Value			
	Case cCampo == 'CLR_PART'
		Self:cIdTomador 	:= Value	
	Case cCampo == 'CLR_CODREM'
		Self:cIdRemet	 := Value			
	Case cCampo == 'CLR_CODDST'
		Self:cIdDest	 := Value	
	Case cCampo == 'CLR_IDDET'
		Self:cIdDet	 := Value
	Case cCampo == 'CLR_NRLAN'
		Self:nNrLanc	 := Value	
	Case cCampo == 'CLR_HIST'
		Self:cHist	 := Value			
	Case cCampo == 'CLR_FILMOV'
		Self:cFilMov	 := Value	
	Case cCampo == 'CLR_ARMAZ'
		Self:cArmazem	 := Value
	Case cCampo == 'CLR_NUMSEQ'
		Self:cNumSeq	 := Value	
	Case cCampo == 'CLR_UFINI'
		Self:cUfIni	 := Value				
	Case cCampo == 'CLR_UFDST'
		Self:cUfDest	 := Value	
	Case cCampo == 'CLR_TPRD'
		Self:cTpReq	 := Value
	Case cCampo == 'CLR_NRDI'
		Self:cNumDiDsi	 := Value	
	Case cCampo == 'CLR_CODLAN'
		Self:cCodLancto	 := Value			
	Case cCampo == 'CLR_TABMOV'
		Self:cTabMovto	 := Value	
	Case cCampo == 'CLR_CODORI'
		Self:cCodOrigem	 := Value		
	Case cCampo == 'CLR_ENQLEG'
		Self:cEnqLegal	 := Value	
	Case cCampo == 'CLR_DESPAC'
		Self:cDespacho	 := Value	
	Case cCampo == 'CLR_COMOPE'
		Self:cComprov	 := Value
	Case cCampo == 'CLR_VEICUL'
		Self:cCodVeic	 := Value	
	Case cCampo == 'CLR_KM'
		Self:nKm	 := Value			
	Case cCampo == 'CLR_INDRAT'
		Self:nIndRat	 := Value	
	Case cCampo == 'CLR_FOCORR'
		Self:cFchaPerda	 := Value	
	Case cCampo == 'CLR_UNID'
		Self:cUnidade	 := Value	
	Case cCampo == 'CLR_TPDOC'
		Self:cTpDoc	 := Value	
	Case cCampo == 'CLR_NRORD'
		Self:nNrOrd	 := Value
	Case cCampo == 'CLR_TPMOV'
		Self:cTpMov	 := Value
	Case cCampo == 'CLR_IDCAB'		
		Self:cIdCab	 := Value
	Case cCampo == 'CLR_ORIDES'		
		Self:cOriDest	 := Value		
   	Case cCampo == 'CLR_EXPIND'     
       Self:cExpInd   := Value
   Case cCampo == 'CLR_PERRAT'     
       Self:cPerRat   := Value       	
		
//Antigos campos da CLS
	Case cCampo == 'CLR_ICMS'
		Self:nVlICMS 	:= Value
	Case cCampo == 'CLR_CUSTO'
		Self:nVlCusto 	:= Value
	Case cCampo == 'CLR_UICMS'
		Self:nUnitICMS	:= Value
	Case cCampo == 'CLR_UCUSTO'
		Self:nUnitCusto 	:= Value
	Case cCampo == 'CLR_IPI'
		Self:nVlIPI 	:= Value
	Case cCampo == 'CLR_OUTROS'
		Self:nVlOutros 	:= Value				
	Case cCampo == 'CLR_QTDE'
		Self:nQtde	:= Value
	Case cCampo == 'CLR_PERCCJ'
		Self:nPerCusto 	:= Value
	Case cCampo == 'CLR_QTDECP'
		Self:nQtdeCOO 	:= Value
	Case cCampo == 'CLR_SAIDA'
		Self:nSaida 	:= Value	
	Case cCampo == 'CLR_VCROUT'
		Self:nCrdOutor	:= Value
	Case cCampo == 'CLR_VCRDSP'
		Self:nCrdOper 	:= Value
	Case cCampo == 'CLR_VCRCOM'
		Self:nCrdComu 	:= Value
	Case cCampo == 'CLR_ICMCMP'
		Self:nIcmsComp 	:= Value	
	Case cCampo == 'CLR_ICMSDE'
		Self:nIcmsDev	:= Value
	Case cCampo == 'CLR_VPRENG'
		Self:nTotNaoGe 	:= Value
	Case cCampo == 'CLR_ICMDEB'
		Self:nICMSNaoGe 	:= Value
	Case cCampo == 'CLR_VPREGE'
		Self:nTotGerad 	:= Value	
	Case cCampo == 'CLR_ICMST'
		Self:nICMSST	:= Value
	Case cCampo == 'CLR_VCROUT'
		Self:nOutProp 	:= Value
	Case cCampo == 'CLR_CROUST'
		Self:nOutST 	:= Value
	Case cCampo == 'CLR_VALBC'
		Self:nBaseItem 	:= Value	
	Case cCampo == 'CLR_PCROUT'
		Self:nPerOutor	:= Value
	Case cCampo == 'CLR_TOTICM'
		Self:nTotICMS 	:= Value
	Case cCampo == 'CLR_CREDAC'
		Self:nCrdAcum 	:= Value
	Case cCampo == 'CLR_ALIQ'
		Self:nAliq 	:= Value		

EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá salvar as informações na tabela considerando as inormações 
passadas para classe.  

@author Erick G. Dias
@since 27/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save() Class TABCLR

RecLock('CLR',.T.)
CLR->CLR_FILIAL		:=	xFilial('CLR')
CLR->CLR_PERIOD		:=	Self:dPeriodo
CLR->CLR_PROD		:=	Self:cProd
CLR->CLR_PRDMOV		:=	Self:cInsumo
CLR->CLR_FICHA		:=	Self:cFicha
CLR->CLR_IDNF		:=	Self:cIdNota
CLR->CLR_PART		:=	Self:cIdTomador
CLR->CLR_CODREM		:=	Self:cIdRemet
CLR->CLR_CODDST		:=	Self:cIdDest
CLR->CLR_IDDET		:=	Self:cIdDet
CLR->CLR_NRLAN		:=	Self:nNrLanc
CLR->CLR_HIST		:=	Self:cHist
CLR->CLR_FILMOV		:=	Self:cFilMov
CLR->CLR_ARMAZ		:=	Self:cArmazem
CLR->CLR_NUMSEQ		:=	Self:cNumSeq
CLR->CLR_UFINI		:=	Self:cUfIni
CLR->CLR_UFDST		:=	Self:cUfDest
CLR->CLR_TPRD		:=	Self:cTpReq
CLR->CLR_NRDI		:=	Self:cNumDiDsi
CLR->CLR_CODLAN		:=	Self:cCodLancto
CLR->CLR_TABMOV		:=	Self:cTabMovto
CLR->CLR_CODORI		:=	Self:cCodOrigem
CLR->CLR_ENQLEG		:=	Self:cEnqLegal
CLR->CLR_DESPAC		:=	Self:cDespacho
CLR->CLR_COMOPE		:=	Self:cComprov
CLR->CLR_VEICUL		:=	Self:cCodVeic
CLR->CLR_KM			:=	Self:nKm
CLR->CLR_INDRAT		:=	Self:nIndRat
CLR->CLR_UNID		:=	Self:cUnidade
CLR->CLR_FOCORR		:=	Self:cFchaPerda
CLR->CLR_TPDOC		:=	Self:cTpDoc
CLR->CLR_TPMOV		:=	Self:cTpMov
CLR->CLR_NRORD		:=	Self:nNrOrd
CLR->CLR_IDCAB		:=	Self:cIdCab
CLR->CLR_ORIDES		:=	Self:cOriDest
CLR->CLR_EXPIND     := Self:cExpInd
CLR->CLR_PERRAT     := Self:cPerRat
CLR->CLR_ICMS		:=	Self:nVlICMS
CLR->CLR_CUSTO		:=	Self:nVlCusto
CLR->CLR_UICMS		:=	Self:nUnitICMS
CLR->CLR_UCUSTO		:=	Self:nUnitCusto
CLR->CLR_IPI		:=	Self:nVlIPI
CLR->CLR_OUTROS		:=	Self:nVlOutros
CLR->CLR_QTDE		:=	Self:nQtde
CLR->CLR_PERCCJ		:=	Self:nPerCusto
CLR->CLR_QTDECP		:=	Self:nQtdeCOO
CLR->CLR_SAIDA		:=	Self:nSaida
CLR->CLR_VCROUT		:=	Self:nCrdOutor
CLR->CLR_VCRDSP		:=	Self:nCrdOper
CLR->CLR_VCRCOM		:=	Self:nCrdComu
CLR->CLR_ICMCMP		:=	Self:nIcmsComp
CLR->CLR_ICMSDE		:=	Self:nIcmsDev
CLR->CLR_VPRENG		:=	Self:nTotNaoGe
CLR->CLR_ICMDEB		:=	Self:nICMSNaoGe
CLR->CLR_VPREGE		:=	Self:nTotGerad
CLR->CLR_ICMST		:=	Self:nICMSST
CLR->CLR_VCROUT		:=	Self:nOutProp
CLR->CLR_CROUST		:=	Self:nOutST
CLR->CLR_VALBC		:=	Self:nBaseItem
CLR->CLR_PCROUT		:=	Self:nPerOutor
CLR->CLR_TOTICM		:=	Self:nTotICMS
CLR->CLR_CREDAC		:=	Self:nCrdAcum
CLR->CLR_ALIQ		:=	Self:nAliq
CLR->(MsUnLock())

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} TABCLS
Classe que será responsável por realizar a gravação na tabela CLS
A tabela CLS terá os valores das movimentações das fichas da CAT83.

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABCLS

	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------	
	Data dPeriodo		As Date
	Data cProd			As String	
	Data cIdMov			As String
	Data nVlICMS		As Integer
	Data nVlCusto		As Integer
	Data nUnitICMS		As Integer
	Data nUnitCusto		As Integer
	Data nVlIPI			As Integer
	Data nVlOutros		As Integer
	Data nQtde			As Integer
	Data nPerCusto		As Integer
	Data nQtdeCOO		As Integer
	Data nSaida			As Integer
	Data nCrdOutor		As Integer
	Data nCrdOper		As Integer
	Data nCrdComu		As Integer
	Data nIcmsComp		As Integer
	Data nIcmsDev		As Integer
	Data nTotNaoGe		As Integer
	Data nICMSNaoGe		As Integer
	Data nTotGerad		As Integer
	Data nICMSST		As Integer
	Data nOutProp		As Integer
	Data nOutST			As Integer
	Data nBaseItem		As Integer
	Data nPerOutor		As Integer
	Data nTotICMS		As Integer
	Data nCrdAcum		As Integer
	Data nAliq			As Integer
	Data nOrdem			As Integer
	Data nLancto		As Integer
	Data cFicha			As String	
				
	Method New()
	Method Insert()
	Method Clear()
	Method Save()
	Method SetParam(cCampo,Value)
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABCLS

Self:Clear()

Return  Self

Method Clear() Class TABCLS

Self:dPeriodo		:= CTod("  /  /    ")	
Self:cIdMov			:= ''
Self:nVlICMS		:= 0
Self:nVlCusto		:= 0
Self:nUnitICMS		:= 0
Self:nUnitCusto		:= 0
Self:nVlIPI			:= 0
Self:nVlOutros		:= 0
Self:nQtde			:= 0
Self:nPerCusto		:= 0
Self:nQtdeCOO		:= 0
Self:nSaida			:= 0
Self:nCrdOutor		:= 0
Self:nCrdOper		:= 0
Self:nCrdComu		:= 0
Self:nIcmsComp		:= 0
Self:nIcmsDev		:= 0
Self:nTotNaoGe		:= 0
Self:nICMSNaoGe		:= 0
Self:nTotGerad		:= 0
Self:nICMSST		:= 0
Self:nOutProp		:= 0
Self:nOutST			:= 0
Self:nBaseItem		:= 0
Self:nPerOutor		:= 0
Self:nTotICMS		:= 0
Self:nCrdAcum		:= 0
Self:nAliq			:= 0
Self:nOrdem			:= 0
Self:nLancto		:= 0
Self:cFicha			:= ''

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABCLS

Do Case				
	Case cCampo == 'CLS_PERIOD'
		Self:dPeriodo	:= Value
	Case cCampo == 'CLS_IDMOV'
		Self:cIdMov 	:= Value
	Case cCampo == 'CLS_ICMS'
		Self:nVlICMS 	:= Value
	Case cCampo == 'CLS_CUSTO'
		Self:nVlCusto 	:= Value
	Case cCampo == 'CLS_UICMS'
		Self:nUnitICMS	:= Value
	Case cCampo == 'CLS_UCUSTO'
		Self:nUnitCusto 	:= Value
	Case cCampo == 'CLS_IPI'
		Self:nVlIPI 	:= Value
	Case cCampo == 'CLS_OUTROS'
		Self:nVlOutros 	:= Value				
	Case cCampo == 'CLS_QTDE'
		Self:nQtde	:= Value
	Case cCampo == 'CLS_PERCCJ'
		Self:nPerCusto 	:= Value
	Case cCampo == 'CLS_QTDECP'
		Self:nQtdeCOO 	:= Value
	Case cCampo == 'CLS_SAIDA'
		Self:nSaida 	:= Value	
	Case cCampo == 'CLS_VCROUT'
		Self:nCrdOutor	:= Value
	Case cCampo == 'CLS_VCRDSP'
		Self:nCrdOper 	:= Value
	Case cCampo == 'CLS_VCRCOM'
		Self:nCrdComu 	:= Value
	Case cCampo == 'CLS_ICMCMP'
		Self:nIcmsComp 	:= Value	
	Case cCampo == 'CLS_ICMSDE'
		Self:nIcmsDev	:= Value
	Case cCampo == 'CLS_VPRENG'
		Self:nTotNaoGe 	:= Value
	Case cCampo == 'CLS_ICMDEB'
		Self:nICMSNaoGe 	:= Value
	Case cCampo == 'CLS_VPREGE'
		Self:nTotGerad 	:= Value	
	Case cCampo == 'CLS_ICMST'
		Self:nICMSST	:= Value
	Case cCampo == 'CLS_VCROUT'
		Self:nOutProp 	:= Value
	Case cCampo == 'CLS_CROUST'
		Self:nOutST 	:= Value
	Case cCampo == 'CLS_VALBC'
		Self:nBaseItem 	:= Value	
	Case cCampo == 'CLS_PCROUT'
		Self:nPerOutor	:= Value
	Case cCampo == 'CLS_TOTICM'
		Self:nTotICMS 	:= Value
	Case cCampo == 'CLS_CREDAC'
		Self:nCrdAcum 	:= Value
	Case cCampo == 'CLS_ALIQ'
		Self:nAliq 	:= Value			
	Case cCampo == 'CLS_NRORD'
		Self:nOrdem 	:= Value		
	Case cCampo == 'CLS_NRLAN'
		Self:nLancto 	:= Value		
	Case cCampo == 'CLS_FICHA'
		Self:cFicha 	:= Value	
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá salvar as informações na tabela considerando as inormações 
passadas para classe.  

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save() Class TABCLS


RecLock('CLS',.T.)
CLS->CLS_FILIAL		:=	xFilial('CLS')
CLS->CLS_PERIOD		:=	Self:dPeriodo
CLS->CLS_IDMOV		:=	Self:cIdMov
CLS->CLS_ICMS		:=	Self:nVlICMS
CLS->CLS_CUSTO		:=	Self:nVlCusto
CLS->CLS_UICMS		:=	Self:nUnitICMS
CLS->CLS_UCUSTO		:=	Self:nUnitCusto
CLS->CLS_IPI		:=	Self:nVlIPI
CLS->CLS_OUTROS		:=	Self:nVlOutros
CLS->CLS_QTDE		:=	Self:nQtde
CLS->CLS_PERCCJ		:=	Self:nPerCusto
CLS->CLS_QTDECP		:=	Self:nQtdeCOO
CLS->CLS_SAIDA		:=	Self:nSaida
CLS->CLS_VCROUT		:=	Self:nCrdOutor
CLS->CLS_VCRDSP		:=	Self:nCrdOper
CLS->CLS_VCRCOM		:=	Self:nCrdComu
CLS->CLS_ICMCMP		:=	Self:nIcmsComp
CLS->CLS_ICMSDE		:=	Self:nIcmsDev
CLS->CLS_VPRENG		:=	Self:nTotNaoGe
CLS->CLS_ICMDEB		:=	Self:nICMSNaoGe
CLS->CLS_VPREGE		:=	Self:nTotGerad
CLS->CLS_ICMST		:=	Self:nICMSST
CLS->CLS_VCROUT		:=	Self:nOutProp
CLS->CLS_CROUST		:=	Self:nOutST
CLS->CLS_VALBC		:=	Self:nBaseItem
CLS->CLS_PCROUT		:=	Self:nPerOutor
CLS->CLS_TOTICM		:=	Self:nTotICMS
CLS->CLS_CREDAC		:=	Self:nCrdAcum
CLS->CLS_ALIQ		:=	Self:nAliq
CLS->CLS_NRORD		:=	Self:nOrdem
CLS->CLS_NRLAN		:=	Self:nLancto
CLS->CLS_FICHA		:=	Self:cFicha

CLS->(MsUnLock())


Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} TABCLT
Classe que será responsável por realizar a gravação na tabela CLT
A tabela CLT terá os valores das movimentações das fichas da CAT83.

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABCLT

	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------	
	Data dPeriodo		As Date
	Data cProdDest		As String	
	Data cFicha			As String
	Data nPerRat		As Integer
	Data nValCusto		As Integer
	Data nValICMS		As Integer
	Data cCodInsumo		As String
	Data nQtde			As Integer
	Data nPrcMed		As Integer
	Data nVlProjSai		As Integer
	Data nPercInsu		As Integer	
			
	Method New()
	Method Insert()
	Method Clear()
	Method Save()
	Method SetParam(cCampo,Value)
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABCLT

Self:Clear()

Return  Self

Method Clear() Class TABCLT

Self:dPeriodo		:= CTod("  /  /    ")
Self:cProdDest		:= ''	
Self:cFicha			:= ''
Self:nPerRat		:= 0
Self:nValCusto		:= 0
Self:nValICMS		:= 0
Self:cCodInsumo		:= ''
Self:nQtde			:= 0
Self:nPrcMed		:= 0
Self:nVlProjSai		:= 0
Self:nPercInsu		:= 0	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABCLT

Do Case				
	Case cCampo == 'CLT_PERIOD'
		Self:dPeriodo	:= Value
	Case cCampo == 'CLT_PRDDST'
		Self:cProdDest 	:= Value
	Case cCampo == 'CLT_FICHA'
		Self:cFicha 	:= Value
	Case cCampo == 'CLT_PERRAT'
		Self:nPerRat 	:= Value
	Case cCampo == 'CLT_VALCUS'
		Self:nValCusto 	:= Value
	Case cCampo == 'CLT_VALICM'
		Self:nValICMS 	:= Value
	Case cCampo == 'CLT_INSUMO'
		Self:cCodInsumo 	:= Value	
	Case cCampo == 'CLT_QTDE'
		Self:nQtde 	:= Value
	Case cCampo == 'CLT_PRCUNI'
		Self:nPrcMed 	:= Value			
	Case cCampo == 'CLT_VLPRJS'
		Self:nVlProjSai 	:= Value
	Case cCampo == 'CLT_PEATIC'
		Self:nPercInsu 	:= Value																	
		
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá salvar as informações na tabela considerando as inormações 
passadas para classe.  

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save() Class TABCLT

RecLock('CLT',.T.)
CLT->CLT_FILIAL		:=	xFilial('CLT')
CLT->CLT_PRDDST		:=	Self:cProdDest
CLT->CLT_PERIOD		:=	Self:dPeriodo
CLT->CLT_FICHA		:=	Self:cFicha
CLT->CLT_PERRAT		:=	Self:nPerRat
CLT->CLT_VALCUS		:=	Self:nValCusto
CLT->CLT_VALICM		:=	Self:nValICMS
CLT->CLT_INSUMO		:=	Self:cCodInsumo
CLT->CLT_QTDE		:=	Self:nQtde
CLT->CLT_PRCUNI		:=	Self:nPrcMed
CLT->CLT_VLPRJS		:=	Self:nVlProjSai
CLT->CLT_PEATIC		:=	Self:nPercInsu

CLT->(MsUnLock())

Self:Clear()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TABCLU
Classe que será responsável por realizar a gravação na tabela CLU
A tabela CLU terá os valores das movimentações das fichas da CAT83.

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABCLU

	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------	
	Data dPeriodo		As Date
	Data cProd			As String
	Data cProdIns		As String
	Data cUnid			As String
	Data nQtdeProd		As integer
	Data nQtdeInsu		As integer
	Data nQtdUnit		As integer
	Data nCustoUnit		As integer
	Data nValCusto		As integer
	Data nUnitICMS		As integer
	Data nValICMS		As integer
	Data nPerda			As integer
	Data nTamProd		As integer
	Data cApProd		As string
	Data cFicha         As string
			
	Method New()
	Method Insert()
	Method Clear()
	Method Save()
	Method SetParam(cCampo,Value)
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABCLU

Self:Clear()

Return  Self

Method Clear() Class TABCLU

Self:dPeriodo		:= CTod("  /  /    ")
Self:cProd			:= ''
Self:cProdIns		:= ''
Self:cUnid			:= ''
Self:nQtdeProd		:= 0
Self:nQtdeInsu		:= 0
Self:nQtdUnit		:= 0
Self:nCustoUnit		:= 0
Self:nValCusto		:= 0
Self:nUnitICMS		:= 0
Self:nValICMS		:= 0
Self:nPerda			:= 0	
Self:nTamProd		:= TamSx3("CLU_PROD")[1]
Self:cApProd		:= '2'
Self:cFicha         := ''

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABCLU

Do Case				
	Case cCampo == 'CLU_PERIOD'
		Self:dPeriodo	:= Value
	Case cCampo == 'CLU_PROD'
		Self:cProd 	:= Padr(Value,Self:nTamProd)
	Case cCampo == 'CLU_PRDINS'
		Self:cProdIns 	:= Padr(Value,Self:nTamProd)
	Case cCampo == 'CLU_UNID'
		Self:cUnid 	:= Value		
	Case cCampo == 'CLU_QUANT'
		Self:nQtdeProd 	:= Value
	Case cCampo == 'CLU_QTDINS'
		Self:nQtdeInsu 	:= Value
	Case cCampo == 'CLU_QTDUNT'
		Self:nQtdUnit 	:= Value	
	Case cCampo == 'CLU_UNTCUS'
		Self:nCustoUnit 	:= Value		
	Case cCampo == 'CLU_VALCUS'
		Self:nValCusto 	:= Value			
	Case cCampo == 'CLU_UNTICM'
		Self:nUnitICMS 	:= Value
	Case cCampo == 'CLU_VALICM'
		Self:nValICMS 	:= Value	
	Case cCampo == 'CLU_PERDA'
		Self:nPerda 	:= Value
	Case cCampo == 'CLU_APPROD'
		Self:cApProd 	:= Value		
   Case cCampo == 'CLU_FICHA'
        Self:cFicha    := Value    		
		
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá salvar as informações na tabela considerando as inormações 
passadas para classe.  

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save(lSobrePoe) Class TABCLU

Default lSobrePoe	:= .F.

IF CLU->(MSSEEK( xFilial('CLU')+dTos(Self:dPeriodo)+Self:cProd+Self:cProdIns+Self:cFicha))
	If lSobrePoe
		RecLock('CLU',.F.)
		CLU->CLU_QUANT		:=	Self:nQtdeProd
		CLU->CLU_QTDINS		:=	Self:nQtdeInsu
		CLU->CLU_QTDUNT		:=	Self:nQtdUnit
		CLU->CLU_UNTCUS		:=	Self:nCustoUnit
		CLU->CLU_VALCUS		:=	Self:nValCusto
		CLU->CLU_UNTICM		:=	Self:nUnitICMS
		CLU->CLU_VALICM		:=	Self:nValICMS
		CLU->CLU_PERDA		:=	Self:nPerda		
		IF CLU->(ColumnPos("CLU_APPROD"))>0
			CLU->CLU_APPROD		:=	Self:cApProd
		EndIF
		CLU->CLU_FICHA        :=  Self:cFicha
	Else
	
		RecLock('CLU',.F.)
		CLU->CLU_QUANT		+=	Self:nQtdeProd
		CLU->CLU_QTDINS		+=	Self:nQtdeInsu
		CLU->CLU_QTDUNT		+=	Self:nQtdUnit
		CLU->CLU_UNTCUS		+=	Self:nCustoUnit
		CLU->CLU_VALCUS		+=	Self:nValCusto
		CLU->CLU_UNTICM		+=	Self:nUnitICMS
		CLU->CLU_VALICM		+=	Self:nValICMS
		CLU->CLU_PERDA		+=	Self:nPerda
	EndIF

Else
	RecLock('CLU',.T.)
	CLU->CLU_FILIAL		:=	xFilial('CLU')
	CLU->CLU_PERIOD		:=	Self:dPeriodo
	CLU->CLU_PROD		:=	Self:cProd
	CLU->CLU_PRDINS		:=	Self:cProdIns
	CLU->CLU_UNID		:=	Self:cUnid
	CLU->CLU_QUANT		:=	Self:nQtdeProd
	CLU->CLU_QTDINS		:=	Self:nQtdeInsu
	CLU->CLU_QTDUNT		:=	Self:nQtdUnit
	CLU->CLU_UNTCUS		:=	Self:nCustoUnit
	CLU->CLU_VALCUS		:=	Self:nValCusto
	CLU->CLU_UNTICM		:=	Self:nUnitICMS
	CLU->CLU_VALICM		:=	Self:nValICMS
	CLU->CLU_PERDA		:=	Self:nPerda	
	
	IF CLU->(ColumnPos("CLU_APPROD"))>0
		CLU->CLU_APPROD		:=	Self:cApProd
	EndIF
	
	CLU->CLU_FICHA       := Self:cFicha
	
EndIF
CLU->(MsUnLock())

Self:Clear()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TABCLV
Classe que será responsável por realizar a gravação na tabela CLV
A tabela CLV terá os valores das movimentações das fichas da CAT83.

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABCLV

	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------	
	Data dPeriodo		As Date
	Data cProd			As String
	Data cCodInsumo		As String
	Data nQtdeInsu		As Integer
	Data nValCusto		As Integer
	Data nIcmsInsu		As Integer
		
	Method New()
	Method Insert()
	Method Clear()
	Method Save()
	Method SetParam(cCampo,Value)
ENDCLASS


//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABCLV

Self:Clear()

Return  Self

Method Clear() Class TABCLV

Self:dPeriodo		:= CTod("  /  /    ")
Self:cProd			:= ''
Self:cCodInsumo		:= ''
Self:nQtdeInsu		:= 0
Self:nValCusto		:= 0
Self:nIcmsInsu		:= 0	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABCLV

Do Case
	Case cCampo == 'CLV_PERIOD'
		Self:dPeriodo 	:= Value
	Case cCampo == 'CLV_PROD'
		Self:cProd 	:= Value
	Case cCampo == 'CLV_PRDINS'
		Self:cCodInsumo := Value		 
	Case cCampo == 'CLV_QUANT'
		Self:nQtdeInsu 	:= Value
	Case cCampo == 'CLV_VALCUS'
		Self:nValCusto 	:= Value
	Case cCampo == 'CLV_VALICM'
		Self:nIcmsInsu 	:= Value		
		
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá salvar as informações na tabela considerando as inormações 
passadas para classe.  

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save() Class TABCLV

RecLock('CLV',.T.)
CLV->CLV_FILIAL		:=	xFilial('CLV')
CLV->CLV_PERIOD		:=	Self:dPeriodo
CLV->CLV_PROD		:=	Self:cProd
CLV->CLV_PRDINS		:=	Self:cCodInsumo
CLV->CLV_QUANT		:=	Self:nQtdeInsu
CLV->CLV_VALCUS		:=	Self:nValCusto
CLV->CLV_VALICM		:=	Self:nIcmsInsu

CLV->(MsUnLock())

ConfirmSX8()
Self:Clear()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TABCLW
Classe que será responsável por realizar a gravação na tabela CLV
A tabela CLV terá os valores das movimentações das fichas da CAT83.

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABCLW

	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------	
	Data dPeriodo		As Date
	Data cProd			As String
	Data nNrLanc		As String
	Data cNrDoc			As String
	Data cSerie			As String
	Data dDtDocExp		As String
	Data cNrDocExp		As String
	Data cSerDocExp		As String	
	Data cNrDespach		As String
				
	Method New()
	Method Insert()
	Method Clear()
	Method Save()
	Method SetParam(cCampo,Value)
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABCLW

Self:Clear()

Return  Self

Method Clear() Class TABCLW

Self:dPeriodo		:= CTod("  /  /    ")
Self:cProd			:= ''
Self:nNrLanc		:= 0
Self:cNrDoc			:= ''
Self:cSerie			:= ''
Self:dDtDocExp		:= ''
Self:cNrDocExp		:= ''
Self:cSerDocExp		:= ''
Self:cNrDespach		:= ''	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABCLW

Do Case	
	Case cCampo == 'CLW_PERIOD'
		Self:dPeriodo 	:= Value
	Case cCampo == 'CLW_PROD'
		Self:cProd 		:= Value		 
	Case cCampo == 'CLW_NRLAN'
		Self:nNrLanc 	:= Value
	Case cCampo == 'CLW_NRDOC'
		Self:cNrDoc 	:= Value
	Case cCampo == 'CLW_SERIE'
		Self:cSerie 	:= Value	
	Case cCampo == 'CLW_DTDCEX'
		Self:dDtDocExp 	:= Value		 
	Case cCampo == 'CLW_NRDCEX'
		Self:cNrDocExp 	:= Value
	Case cCampo == 'CLW_SRDCEX'
		Self:cSerDocExp := Value
	Case cCampo == 'CLW_NRDESP'
		Self:cNrDespach := Value			
		
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá salvar as informações na tabela considerando as inormações 
passadas para classe.  

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save() Class TABCLW

RecLock('CLW',.T.)
CLW->CLW_FILIAL		:=	xFilial('CLW')
CLW->CLW_PERIOD		:=	Self:dPeriodo
CLW->CLW_PROD		:=	Self:cProd
CLW->CLW_NRLAN		:=	Self:nNrLanc
CLW->CLW_NRDOC		:=	Self:cNrDoc
CLW->CLW_SERIE		:=	Self:cSerie
CLW->CLW_DTDCEX		:=	Self:dDtDocExp
CLW->CLW_NRDCEX		:=	Self:cNrDocExp
CLW->CLW_SRDCEX		:=	Self:cSerDocExp
CLW->CLW_NRDESP		:=	Self:cNrDespach

CLW->(MsUnLock())

ConfirmSX8()
Self:Clear()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TABCLX
Classe que será responsável por realizar a gravação na tabela CLV
A tabela CLV terá os valores das movimentações das fichas da CAT83.

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABCLX

	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------	
	Data dPeriodo		As Date
	Data cCodVeic		As String
	Data cPlaca			As String
	Data cCnpj			As String
	Data cUF			As String
	Data cMunicipio		As String
	Data cRenavam		As String
	Data cMarca			As String
	Data cModelo		As String
	Data cAno			As String
	Data nRendComb		As Integer
				
	Method New()
	Method Insert()
	Method Clear()
	Method Save()
	Method SetParam(cCampo,Value)
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABCLX

Self:Clear()

Return  Self

Method Clear() Class TABCLX

Self:dPeriodo		:= CTod("  /  /    ")
Self:cCodVeic		:= ''
Self:cPlaca			:= ''
Self:cCnpj			:= ''
Self:cUF			:= ''
Self:cMunicipio		:= ''
Self:cRenavam		:= ''
Self:cMarca			:= ''
Self:cModelo		:= ''
Self:cAno			:= ''
Self:nRendComb		:= 0

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABCLX

Do Case
	Case cCampo == 'CLX_PERIOD'
		Self:dPeriodo 	:= Value		 
	Case cCampo == 'CLX_CODVCL'
		Self:cCodVeic 	:= Value
	Case cCampo == 'CLX_PLACA'
		Self:cPlaca 	:= Value
	Case cCampo == 'CLX_CNPJ'
		Self:cCnpj 	:= Value	
	Case cCampo == 'CLX_UF'
		Self:cUF 	:= Value		 
	Case cCampo == 'CLX_MUN'
		Self:cMunicipio 	:= Value
	Case cCampo == 'CLX_RENAV'
		Self:cRenavam 	:= Value
	Case cCampo == 'CLX_MARCA'
		Self:cMarca 	:= Value		
	Case cCampo == 'CLX_MOD'
		Self:cModelo 	:= Value		
	Case cCampo == 'CLX_ANO'
		Self:cAno 	:= Value			
	Case cCampo == 'CLX_RCOMB'
		Self:nRendComb 	:= Value							
		
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá salvar as informações na tabela considerando as inormações 
passadas para classe.  

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save() Class TABCLX


RecLock('CLX',.T.)
CLX->CLX_FILIAL		:=	xFilial('CLX')
CLX->CLX_PERIOD		:=	Self:dPeriodo
CLX->CLX_CODVCL		:=	Self:cCodVeic
CLX->CLX_PLACA		:=	Self:cPlaca
CLX->CLX_CNPJ		:=	Self:cCnpj
CLX->CLX_UF			:=	Self:cUF
CLX->CLX_MUN		:=	Self:cMunicipio
CLX->CLX_RENAV		:=	Self:cRenavam
CLX->CLX_MARCA		:=	Self:cMarca
CLX->CLX_MOD		:=	Self:cModelo
CLX->CLX_ANO		:=	Self:cAno
CLX->CLX_RCOMB		:=	Self:nRendComb

CLX->(MsUnLock())

ConfirmSX8()
Self:Clear()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MOD6XCAT83
Classe com o resumo dos valores do módulo 6  da CAT83

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS MOD6XCAT83

	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------	
	Data dDtDe			As Date
	Data dDtAte			As Date
	Data nTot6A			As Integer
	Data nTot6B			As Integer
	Data nTot6C			As Integer
	Data nTot6D			As Integer
	Data nTot6E			As Integer
	Data nTot6F			As Integer
	Data nTot6G			As Integer
	Data nTot6H			As Integer
				
	Method New()	
	Method setDtDe()
	Method setDtAte()
	Method Clear()
	Method getValor(value)
	Method ProcMod6()
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class MOD6XCAT83

Self:Clear()

Return  Self

Method Clear() Class MOD6XCAT83

Self:dDtDe			:= CTod("  /  /    ")
Self:dDtAte			:= CTod("  /  /    ")
Self:nTot6A			:= 0
Self:nTot6B			:= 0
Self:nTot6C			:= 0
Self:nTot6D			:= 0
Self:nTot6E			:= 0
Self:nTot6F			:= 0
Self:nTot6G			:= 0
Self:nTot6H			:= 0

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} dDtDe()
Set do período para processamento do módulo 6 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method setDtDe(value) Class MOD6XCAT83
	Self:dDtDe	:= value
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} dDtAte()
Set do período para processamento do módulo 6 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method setDtAte(value) Class MOD6XCAT83
	Self:dDtAte	:= value
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} getValor()
Set do período para processamento do módulo 6 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method getValor(cFicha) Class MOD6XCAT83
Local nValRet	:= 0

Do Case
	Case cFicha == '6A'
		nValRet	:= Self:nTot6A
	Case cFicha == '6B'
		nValRet	:= Self:nTot6B
	Case cFicha == '6C'
		nValRet	:= Self:nTot6C
	Case cFicha == '6D'
		nValRet	:= Self:nTot6D		
	Case cFicha == '6E'
		nValRet	:= Self:nTot6E		
	Case cFicha == '6F'
		nValRet	:= Self:nTot6F		
	Case cFicha == '6G'
		nValRet	:= Self:nTot6G		
	Case cFicha == '6H'
		nValRet	:= Self:nTot6H	
EndCase				
		
Return nValRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcMod6()
Método que irá processar os valores totais do módulo 6 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method ProcMod6(value) Class MOD6XCAT83

Local cAliasCLR	:= ''
Local cSelect		:= ''
Local cWhere		:= ''

//Query para buscar os valores da tabela CKR e CKS somente do módulo 6

cAliasCLR	:=	GetNextAlias()
cSelect 	:=	"SUM(clr.clr_CREDAC) AS clr_CREDAC, SUM(clr.clr_ICMSDE) as clr_ICMSDE, CLR.CLR_FICHA"
cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(Self:dDtDe)+"' AND "
cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(Self:dDtAte)+"' AND "
cWhere		+=  "CLR.CLR_FICHA IN ('61','62','63','64','65','66','67','68') AND"

cGroupBy	:="GROUP BY CLR.CLR_FICHA "

cSelect	:= '%'+cSelect+'%'
cWhere		:= '%'+cWhere+'%'
cGroupBy	:= '%'+cGroupBy+'%'

BeginSql Alias cAliasCLR
	SELECT			    	 
		%Exp:cSelect%		

	FROM 
		%Table:CLR% CLR
	WHERE
		%Exp:cWhere%
		CLR.%NotDel%
	%Exp:cGroupBy%		
	
EndSql

DbSelectArea (cAliasCLR)
(cAliasCLR)->(DbGoTop ())

Do While !(cAliasCLR)->(Eof ())
	
	//Laço para pegar os valores do módulo 6
	
	Do Case
		Case (cAliasCLR)->CLR_FICHA == '61'
			Self:nTot6A	+= (cAliasCLR)->CLR_CREDAC
		Case (cAliasCLR)->CLR_FICHA == '62'
			Self:nTot6B	+= (cAliasCLR)->CLR_CREDAC		
		Case (cAliasCLR)->CLR_FICHA == '63'
			Self:nTot6C	+= (cAliasCLR)->CLR_CREDAC		
		Case (cAliasCLR)->CLR_FICHA == '64'
			Self:nTot6D	+= (cAliasCLR)->CLR_CREDAC		
		Case (cAliasCLR)->CLR_FICHA == '65'
			Self:nTot6E	+= (cAliasCLR)->CLR_CREDAC		
		Case (cAliasCLR)->CLR_FICHA == '66'
			Self:nTot6F	+= (cAliasCLR)->CLR_ICMSDE		
		Case (cAliasCLR)->CLR_FICHA == '67'
			Self:nTot6G	+= (cAliasCLR)->CLR_ICMSDE		
		Case (cAliasCLR)->CLR_FICHA == '68'
			Self:nTot6H	+= (cAliasCLR)->CLR_ICMSDE		
	EndCase

	(cAliasCLR)->(DbSkip ())			
EndDo

DbSelectArea (cAliasCLR)
(cAliasCLR)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAT83ESTR
Classe que terá todas as propriedades necessárias para a gravação das fichas
utilizando a classe de persistência da respectiva tabela. O objetivo desta classe
é para que possa ser populada, independente da ficha, e utilizada por qualquer
outro método ou função, para deixar a gravação e processamento apenas em um lugar,
independente da origem da iformação.

@author Erick G. Dias
@since 01/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS CAT83ESTR

	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------	
	//Propriedades da movimentação 
	Data dPeriodo		As Date
	Data cProd			As String		
	Data cInsumo		As String
	Data cFicha			As String	
	Data cIdNota		As String
	Data cIdTomador		As String
	Data cIdRemet		As String
	Data cIdDest		As String
	Data cIdDet			As String
	Data nNrLanc		As String
	Data cHist			As String
	Data cFilMov		As String
	Data cArmazem		As String
	Data cNumSeq		As String
	Data cUfIni			As String
	Data cUfDest		As String
	Data cTpReq			As String
	Data cNumDiDsi		As String
	Data cCodLancto		As String
	Data cTabMovto		As String
	Data cCodOrigem		As String	
	Data cEnqLegal		As String
	Data cDespacho		As String
	Data cComprov		As String
	Data cCodVeic		As String
	Data nKm			As Integer
	Data nIndRat		As String
	Data cFchaPerda		As String
	Data cUnidade		As String	
	Data nNrOrd			As String
	Data cTpDoc			As String
	Data cAliasTmp		As String
	Data cCodDes		As String
	Data cCodRem		As String
	Data cExpInd         As String
	Data cProdRes        As String
	
	//Propriedades do detalhe da movimentação		
	Data cIdMov			As String
	Data nVlICMS		As Integer
	Data nVlCusto		As Integer
	Data nUnitICMS		As Integer
	Data nUnitCusto		As Integer
	Data nVlIPI			As Integer
	Data nVlOutros		As Integer
	Data nQtde			As Integer
	Data nPerCusto		As Integer
	Data nQtdeCOO		As Integer
	Data nSaida			As Integer
	Data nCrdOutor		As Integer
	Data nCrdOper		As Integer
	Data nCrdComu		As Integer
	Data nIcmsComp		As Integer
	Data nIcmsDev		As Integer
	Data nTotNaoGe		As Integer
	Data nICMSNaoGe		As Integer
	Data nTotGerad		As Integer
	Data nICMSST		As Integer
	Data nOutProp		As Integer
	Data nOutST			As Integer
	Data nBaseItem		As Integer
	Data nPerOutor		As Integer
	Data nTotICMS		As Integer
	Data nCrdAcum		As Integer
	Data nAliq			As Integer	
	Data cNOrdOri		As String
	Data cNOrdDest		As String
	Data lDev			As Boolean
	Data cTpMOv			As String
	Data lEstorno		As Boolean
	Data nPerRat        As Integer           
			
	Method New()	
	Method Clear()	
	
	//Sets		
	Method setPeriodo(value) 
	Method setCodProd(value)
	Method setInsumo(value)
	Method setFicha(value)
	Method setIdNf(value)
	Method setCodPart(value) 
	Method setIdRemet(value) 
	Method setIdDest(value) 
	Method setIdDetal(value) 
	Method setNrLanc(value) 
	Method setHist(value)
	Method setFilMov(value)
	Method setArmazem(value)
	Method setNumSeq(value) 
	Method setUfIni(value) 
	Method setUfDest(value) 
	Method setTpReq(value) 
	Method setNDIDSI(value) 
	Method setCdLanto(value)
	Method setTabMov(value) 
	Method setCodOrig(value) 
	Method setLocal(value) 
	Method setEnqLeg(value)
	Method setDespach(value)
	Method setComprov(value)
	Method setExpInd(value)
	Method setCodRes(value)
	Method setCodVeic(value) 
	Method setKM(value)
	Method setIndRat(value) 
	Method setFPerda(value)
	Method setIdMov(value)
	Method setVICMS(value) 
	Method setVCusto(value) 
	Method setUniICMS(value)
	Method setUniCust(value) 
	Method setVIPI(value)
	Method setVOutros(value)
	Method setQtde(value) 
	Method setPerCust(value)
	Method setQtdeCOO(value)
	Method setVSaida(value) 
	Method setCrdOuto(value)
	Method setCrdOper(value)
	Method setCrdComu(value) 
	Method setIcmsCom(value)
	Method setIcmsDev(value) 
	Method setTotNGe(value) 
	Method setIcmsNGE(value) 
	Method setTotGer(value) 
	Method setIcmsST(value)
	Method setOutProp(value) 
	Method setOutST(value)
	Method setBasItem(value) 
	Method setPerOuto(value) 
	Method setTotICMS(value)
	Method setCrdAcum(value) 
	Method setAliq(value) 	
	Method setUnidade(value)
	Method setNrOrd(value)
	Method setTpDoc(value)
	Method setAlsTmp(value)
	Method setNrdOri()
	Method setNrdDest()
	Method setDev()
	Method setTpMov()
	Method setEstorno()
	Method setCodDes()
	Method setCodRem()
	Method setPerRat()
	
	
	//gets
	Method getPeriodo() 
	Method getCodProd()
	Method getInsumo()
	Method getFicha()
	Method getIdNf()
	Method getCodPart() 
	Method getIdRemet() 
	Method getIdDest() 
	Method getIdDetal() 
	Method getNrLanc() 
	Method getHist()
	Method getFilMov()
	Method getArmazem()
	Method getNumSeq() 
	Method getUfIni() 
	Method getUfDest() 
	Method getTpReq() 
	Method getNDIDSI() 
	Method getCdLanto()
	Method getTabMov() 
	Method getCodOrig() 
	Method getLocal() 
	Method getEnqLeg()
	Method getDespach()
	Method getComprov()
	Method getExpInd()
	Method getCodRes()
	Method getCodVeic() 
	Method getKM()
	Method getIndRat() 
	Method getFPerda()
	Method getIdMov()
	Method getVICMS() 
	Method getVCusto() 
	Method getUniICMS()
	Method getUniCust() 
	Method getVIPI()
	Method getVOutros()
	Method getQtde() 
	Method getPerCust()
	Method getQtdeCOO()
	Method getVSaida() 
	Method getCrdOuto()
	Method getCrdOper()
	Method getCrdComu() 
	Method getIcmsCom()
	Method getIcmsDev() 
	Method getTotNGe() 
	Method getIcmsNGE() 
	Method getTotGer() 
	Method getIcmsST()
	Method getOutProp() 
	Method getOutST()
	Method getBasItem() 
	Method getPerOuto() 
	Method getTotICMS()
	Method getCrdAcum() 
	Method getAliq() 	
	Method getUnidade()
	Method getNrOrd()
	Method getTpDoc()	
	Method getAlsTmp()
	Method getNrdOri()
	Method getNrdDest()
	Method getDev()
	Method getTpMOv()
	Method getEstorno()
	Method getCodDes()	
	Method getCodRem()	
	Method getPerRat()	
	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 30/03/2015
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class CAT83ESTR

Self:Clear()
Self:cAliasTmp	:= ''

Return  Self

Method Clear() Class CAT83ESTR

Self:dPeriodo		:= CTod("  /  /    ")
Self:cProd			:= ''		
Self:cInsumo		:= ''
Self:cFicha			:= ''	
Self:cIdNota		:= ''
Self:cIdTomador		:= ''
Self:cIdRemet		:= ''
Self:cIdDest		:= ''
Self:cIdDet			:= ''
Self:nNrLanc		:= 0
Self:cHist			:= ''
Self:cFilMov		:= ''
Self:cArmazem		:= ''
Self:cNumSeq		:= ''
Self:cUfIni			:= ''
Self:cUfDest		:= ''
Self:cTpReq			:= ''
Self:cNumDiDsi		:= ''
Self:cCodLancto		:= ''
Self:cTabMovto		:= ''
Self:cCodOrigem		:= ''
Self:cEnqLegal		:= ''
Self:cDespacho		:= ''
Self:cComprov		:= ''
Self:cCodVeic		:= ''
Self:nNrOrd			:= 0
Self:cTpDoc			:= ''
Self:nKm			:= 0
Self:nIndRat		:= 0
Self:cFchaPerda		:= ''
Self:cIdMov			:= ''
Self:nVlICMS		:= 0
Self:nVlCusto		:= 0
Self:nUnitICMS		:= 0
Self:nUnitCusto		:= 0
Self:nVlIPI			:= 0
Self:nVlOutros		:= 0
Self:nQtde			:= 0
Self:nPerCusto		:= 0
Self:nQtdeCOO		:= 0
Self:nSaida			:= 0
Self:nCrdOutor		:= 0
Self:nCrdOper		:= 0
Self:nCrdComu		:= 0
Self:nIcmsComp		:= 0
Self:nIcmsDev		:= 0
Self:nTotNaoGe		:= 0
Self:nICMSNaoGe		:= 0
Self:nTotGerad		:= 0
Self:nICMSST		:= 0
Self:nOutProp		:= 0
Self:nOutST			:= 0
Self:nBaseItem		:= 0
Self:nPerOutor		:= 0
Self:nTotICMS		:= 0
Self:nCrdAcum		:= 0
Self:nAliq			:= 0	
Self:cUnidade		:= ''
Self:cNOrdOri		:= ''
Self:cNOrdDest		:= ''
Self:lDev			:= .F.
Self:cTpMov			:= ''
Self:lEstorno		:= .F.
Self:cCodDes		:= ''
Self:cCodRem		:= ''
Self:cProdRes		:= '' //Produto resultante da perda

Return

//SETS
Method setPeriodo(value) Class CAT83ESTR
	Self:dPeriodo	:= value
Return

Method setCodProd(value) Class CAT83ESTR
	Self:cProd	:= value
Return

Method setInsumo(value) Class CAT83ESTR
	Self:cInsumo	:= value
Return

Method setFicha(value) Class CAT83ESTR
	Self:cFicha	:= value
Return

Method setIdNf(value) Class CAT83ESTR
	Self:cIdNota	:= value
Return

Method setCodPart(value) Class CAT83ESTR
	Self:cIdTomador	:= value
Return

Method setIdRemet(value) Class CAT83ESTR
	Self:cIdRemet	:= value
Return

Method setIdDest(value) Class CAT83ESTR
	Self:cIdDest	:= value
Return

Method setIdDetal(value) Class CAT83ESTR
	Self:cIdDet	:= value
Return

Method setNrLanc(value) Class CAT83ESTR
	Self:nNrLanc	:= value
Return

Method setHist(value) Class CAT83ESTR
	Self:cHist	:= value
Return

Method setFilMov(value) Class CAT83ESTR
	Self:cFilMov	:= value
Return

Method setArmazem(value) Class CAT83ESTR
	Self:cArmazem	:= value
Return

Method setNumSeq(value) Class CAT83ESTR
	Self:cNumSeq	:= value
Return

Method setUfIni(value) Class CAT83ESTR
	Self:cUfIni	:= value
Return

Method setUfDest(value) Class CAT83ESTR
	Self:cUfDest	:= value
Return

Method setTpReq(value) Class CAT83ESTR
	Self:cTpReq	:= value
Return

Method setNDIDSI(value) Class CAT83ESTR
	Self:cNumDiDsi	:= value
Return

Method setCdLanto(value) Class CAT83ESTR
	Self:cCodLancto	:= value
Return

Method setTabMov(value) Class CAT83ESTR
	Self:cTabMovto	:= value
Return

Method setCodOrig(value) Class CAT83ESTR
	Self:cCodOrigem	:= value
Return

Method setEnqLeg(value) Class CAT83ESTR
	Self:cEnqLegal	:= value
Return

Method setDespach(value) Class CAT83ESTR
	Self:cDespacho	:= value
Return

Method setComprov(value) Class CAT83ESTR
	Self:cComprov	:= value
Return

Method setExpInd(value) Class CAT83ESTR
    Self:cExpInd   := value
Return

Method setCodRes(value) Class CAT83ESTR
    Self:cProdRes   := value
Return
Method setCodVeic(value) Class CAT83ESTR
	Self:cCodVeic	:= value
Return

Method setKM(value) Class CAT83ESTR
	Self:nKm	:= value
Return

Method setIndRat(value) Class CAT83ESTR
	Self:nIndRat	:= value
Return

Method setFPerda(value) Class CAT83ESTR
	Self:cFchaPerda	:= value
Return

Method setIdMov(value) Class CAT83ESTR
	Self:cIdMov	:= value
Return

Method setVICMS(value) Class CAT83ESTR
	Self:nVlICMS	:= value
Return

Method setVCusto(value) Class CAT83ESTR
	Self:nVlCusto	:= value
Return

Method setUniICMS(value) Class CAT83ESTR
	Self:nUnitICMS	:= value
Return

Method setUniCust(value) Class CAT83ESTR
	Self:nUnitCusto	:= value
Return

Method setVIPI(value) Class CAT83ESTR
	Self:nVlIPI	:= value
Return

Method setVOutros(value) Class CAT83ESTR
	Self:nVlOutros	:= value
Return

Method setQtde(value) Class CAT83ESTR
	Self:nQtde	:= value
Return

Method setPerCust(value) Class CAT83ESTR
	Self:nPerCusto	:= value
Return

Method setQtdeCOO(value) Class CAT83ESTR
	Self:nQtdeCOO	:= value
Return

Method setVSaida(value) Class CAT83ESTR
	Self:nSaida	:= value
Return

Method setCrdOuto(value) Class CAT83ESTR
	Self:nCrdOutor	:= value
Return

Method setCrdOper(value) Class CAT83ESTR
	Self:nCrdOper	:= value
Return

Method setCrdComu(value) Class CAT83ESTR
	Self:nCrdComu	:= value
Return

Method setIcmsCom(value) Class CAT83ESTR
	Self:nIcmsComp	:= value
Return

Method setIcmsDev(value) Class CAT83ESTR
	Self:nIcmsDev	:= value
Return

Method setTotNGe(value) Class CAT83ESTR
	Self:nTotNaoGe	:= value
Return

Method setIcmsNGE(value) Class CAT83ESTR
	Self:nICMSNaoGe	:= value
Return

Method setTotGer(value) Class CAT83ESTR
	Self:nTotGerad	:= value
Return

Method setIcmsST(value) Class CAT83ESTR
	Self:nICMSST	:= value
Return

Method setOutProp(value) Class CAT83ESTR
	Self:nOutProp	:= value
Return

Method setOutST(value) Class CAT83ESTR
	Self:nOutST	:= value
Return

Method setBasItem(value) Class CAT83ESTR
	Self:nBaseItem	:= value
Return

Method setPerOuto(value) Class CAT83ESTR
	Self:nPerOutor	:= value
Return

Method setTotICMS(value) Class CAT83ESTR
	Self:nTotICMS	:= value
Return

Method setCrdAcum(value) Class CAT83ESTR
	Self:nCrdAcum	:= value
Return

Method setAliq(value) Class CAT83ESTR
	Self:nAliq	:= value
Return

Method setNrdOri(value) Class CAT83ESTR
	Self:cNOrdOri	:= value
Return

Method setNrdDest(value) Class CAT83ESTR
	Self:cNOrdDest	:= value
Return

Method setDev(value) Class CAT83ESTR
	Self:lDev	:= value
Return


Method setTpMov(value) Class CAT83ESTR
	Self:cTpMov	:= value
Return

Method setEstorno(value) Class CAT83ESTR
	Self:lEstorno	:= value
Return

Method setUnidade(value) Class CAT83ESTR
	Self:cUnidade	:= value
Return

Method setNrOrd(value) Class CAT83ESTR		
	Self:nNrOrd	:= value
Return

Method setTpDoc(value) Class CAT83ESTR		
	Self:cTpDoc	:= value
Return 

Method setAlsTmp(value) Class CAT83ESTR		
	Self:cAliasTmp	:= value
Return 

Method setCodDes(value) Class CAT83ESTR		
	Self:cCodDes	:= value
Return 

Method setCodRem(value) Class CAT83ESTR		
	Self:cCodRem	:= value
Return 

Method setPerRat(value) Class CAT83ESTR     
    Self:nPerRat    := value
Return 


//GETS
Method getPeriodo(value) Class CAT83ESTR	
Return Self:dPeriodo

Method getCodProd(value) Class CAT83ESTR	
Return Self:cProd

Method getinsumo(value) Class CAT83ESTR	
Return Self:cInsumo

Method getFicha(value) Class CAT83ESTR	
Return Self:cFicha

Method getIdNf(value) Class CAT83ESTR	
Return Self:cIdNota

Method getCodPart(value) Class CAT83ESTR	
Return Self:cIdTomador

Method getIdRemet(value) Class CAT83ESTR	
Return Self:cIdRemet

Method getIdDest(value) Class CAT83ESTR	
Return Self:cIdDest

Method getIdDetal(value) Class CAT83ESTR	 
Return Self:cIdDet

Method getNrLanc(value) Class CAT83ESTR	
Return Self:nNrLanc

Method getHist(value) Class CAT83ESTR	
Return Self:cHist

Method getFilMov(value) Class CAT83ESTR	
Return Self:cFilMov

Method getArmazem(value) Class CAT83ESTR	
Return Self:cArmazem

Method getNumSeq(value) Class CAT83ESTR	
Return Self:cNumSeq

Method getUfIni(value) Class CAT83ESTR
Return Self:cUfIni

Method getUfDest(value) Class CAT83ESTR	
Return Self:cUfDest

Method getTpReq(value) Class CAT83ESTR	
Return Self:cTpReq

Method getNDIDSI(value) Class CAT83ESTR	
Return Self:cNumDiDsi

Method getCdLanto(value) Class CAT83ESTR	
Return Self:cCodLancto

Method getTabMov(value) Class CAT83ESTR	
Return Self:cTabMovto

Method getCodOrig(value) Class CAT83ESTR	
Return Self:cCodOrigem

Method getEnqLeg(value) Class CAT83ESTR	
Return Self:cEnqLegal

Method getDespach(value) Class CAT83ESTR	
Return Self:cDespacho

Method getComprov(value) Class CAT83ESTR	
Return Self:cComprov

Method getExpInd(value) Class CAT83ESTR    
Return Self:cExpInd

Method getCodRes(value) Class CAT83ESTR       
Return Self:cProdRes
Method getCodVeic(value) Class CAT83ESTR	
Return Self:cCodVeic

Method getKM(value) Class CAT83ESTR	
Return Self:nKm

Method getIndRat(value) Class CAT83ESTR	
Return Self:nIndRat

Method getFPerda(value) Class CAT83ESTR	
Return Self:cFchaPerda

Method getIdMov(value) Class CAT83ESTR	
Return Self:cIdMov

Method getVICMS(value) Class CAT83ESTR	
Return Self:nVlICMS

Method getVCusto(value) Class CAT83ESTR	
Return Self:nVlCusto

Method getUniICMS(value) Class CAT83ESTR	
Return Self:nUnitICMS

Method getUniCust(value) Class CAT83ESTR	
Return Self:nUnitCusto

Method getVIPI(value) Class CAT83ESTR	
Return Self:nVlIPI

Method getVOutros(value) Class CAT83ESTR	
Return Self:nVlOutros

Method getQtde(value) Class CAT83ESTR	
Return Self:nQtde

Method getPerCust(value) Class CAT83ESTR	
Return Self:nPerCusto

Method getQtdeCOO(value) Class CAT83ESTR	
Return Self:nQtdeCOO

Method getVSaida(value) Class CAT83ESTR	
Return Self:nSaida

Method getCrdOuto(value) Class CAT83ESTR	
Return Self:nCrdOutor

Method getCrdOper(value) Class CAT83ESTR	
Return Self:nCrdOper

Method getCrdComu(value) Class CAT83ESTR	
Return Self:nCrdComu

Method getIcmsCom(value) Class CAT83ESTR	
Return Self:nIcmsComp

Method getIcmsDev(value) Class CAT83ESTR	
Return Self:nIcmsDev

Method getTotNGe(value) Class CAT83ESTR	
Return Self:nTotNaoGe

Method getIcmsNGE(value) Class CAT83ESTR	
Return Self:nICMSNaoGe

Method getTotGer(value) Class CAT83ESTR	
Return Self:nTotGerad

Method getIcmsST(value) Class CAT83ESTR	
Return Self:nICMSST

Method getOutProp(value) Class CAT83ESTR	
Return Self:nOutProp

Method getOutST(value) Class CAT83ESTR	
Return Self:nOutST

Method getBasItem(value) Class CAT83ESTR	
Return Self:nBaseItem

Method getPerOuto(value) Class CAT83ESTR	
Return Self:nPerOutor

Method getTotICMS(value) Class CAT83ESTR	
Return Self:nTotICMS

Method getCrdAcum(value) Class CAT83ESTR	
Return Self:nCrdAcum

Method getAliq(value) Class CAT83ESTR	
Return Self:nAliq

Method getUnidade(value) Class CAT83ESTR		
Return Self:cUnidade

Method getNrOrd(value) Class CAT83ESTR		
Return Self:nNrOrd

Method getTpDoc(value) Class CAT83ESTR		
Return Self:cTpDoc

Method getAlsTmp(value) Class CAT83ESTR		
Return Self:cAliasTmp

Method getNrdOri(value) Class CAT83ESTR		
Return Self:cNOrdOri

Method getNrdDest(value) Class CAT83ESTR		
Return Self:cNOrdDest

Method getDev(value) Class CAT83ESTR		
Return Self:lDev

Method getTpMov(value) Class CAT83ESTR		
Return Self:cTpMov

Method getEstorno(value) Class CAT83ESTR	
Return Self:lEstorno

Method getCodDes(value) Class CAT83ESTR	
Return Self:cCodDes

Method getCodRem(value) Class CAT83ESTR	
Return Self:cCodRem

Method getPerRat(value) Class CAT83ESTR 
Return Self:nPerRat

