#INCLUDE "TOTVS.CH"
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

class CO_Guia
	//metodos de controle em comum a todas as guias.	
	method New() Constructor
	
	method addGuia(aDados,aItens)
	method montaGuia(aDados, aItens)
	method addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes)
	method addProf(cCodOpe, cCodPExe, cEspExe)
	method addBenef(cCodOpe, cMatric, cNomUsr, cPadCon, cAteRn)
	method getLstProcedimentos(cMatric, aItens, objGuia) 
	method getProcOdo(cMatric, aItens) 
	method getProced(cMatric,  aItem, objGuia, objProcOdo)
	method loadIteMod(oModelBD6, aObjProcedimentos, oGuia, lOdonto) 
	method loadCabBD5(oModelBD5, oGuia, lOdonto) 
	method copyIteBD5(oModelBD6, oGuia)
	method grvGuia(oGuia, nOperation, cTipGui, lOdonto)
	method loadGuiaRecno(nRecno, lOdonto)
	method getProcChv( cChaveBD5, lOdonto, lOutrasDesp, lSadt )
	method altGuia(aCamposCabec, aCampoItem)
	method loadOutrasDesp(nRecGuiRef, cNumGuiRef)
	method altItem(aCmpOrg, cRecnoBD5)
	method excIteGuia(cCodTab, cCodProPar, cRecnoBD5)
	method incIteGuia(oGuia, aObjProcedimentos, lOdonto)
	method grvOutDes(nRecGuiRef, aAddItem, aEditItem, aDelItem) 
	method copyIteOutDes(oBD6)
	method grvAltOdon(cRecno, aCampoCabec, aAddItem, aEditItem, aDelItem)
	method grvAltSadt(cRecno, aCampoCabec, aAddItem, aEditItem, aDelItem)
	method baixaLib(aDados,aItens)
	method cntProced(cChave, cTpBusca)
	
endClass

//-------------------------------------------------------------------
/*/{Protheus.doc} new
Metodo construtor da classe
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method new() class CO_Guia
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} addGuia
Metodo que centraliza a montagem das guias
@author Roberto Vanderlei de Arruda
@since 09/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method addGuia(aDados,aItens) class CO_Guia

	LOCAL cTipGui	 := PLSRETDAD( aDados,"TIPGUI","" ) // 1 - Consulta  2 - SADT  3 - Internação  4 - Odonto   5 - Honorário Individual
	LOCAL oObjGui := NIL
	LOCAL lOdonto := PLSRETDAD( aDados,"LODONTO","" )
	
	if cTipGui == "01"
		oObjGui := CO_Consulta():New()
		oObjGui := oObjGui:addGuiaConsulta(aDados,aItens)
	else 
		if cTipGui == "02" .and. !lOdonto
			oObjGui := CO_Sadt():New()
			oObjGui := oObjGui:addGuiaSADT(aDados,aItens)
		else 
			if cTipGui == "02" .and. lOdonto
				oObjGui := CO_Odonto():New()
				oObjGui := oObjGui:addGuiaOdonto(aDados,aItens)
			else
				if cTipGui == "06"
					oObjGui := CO_Honorario():New()
					oObjGui := oObjGui:addGuiaHonorario(aDados,aItens)
				endif
			endif
		endif
	endif
	
	self:baixaLib(aDados,aItens)
	self:grvGuia(oObjGui, 3, cTipGui, lOdonto)	
	
	
return oObjGui

method baixaLib(aDados,aItens) class CO_GUIA

	LOCAL cOrigem    := PLSRETDAD( aDados,"ORIGEM","1" )
	LOCAL cNumLib    := PLSRETDAD( aDados,"NUMLIB","" )
	LOCAL lInter     := PLSRETDAD( aDados,"INTERN",.F. )
	LOCAL lEvolu     := PLSRETDAD( aDados,"EVOLU",.F. )
	LOCAL cMatric    := PLSRETDAD( aDados,"USUARIO","" )
	
	LOCAL cTipo      := PLSRETDAD( aDados,"TIPO","1" )
	LOCAL cCodRda    := PLSRETDAD( aDados,"CODRDA","" )
	LOCAL cCodRdaPro := PLSRETDAD( aDados,"RDAPRO",cCodRda )
	
	LOCAL cCodLoc    := PLSRETDAD( aDados,"CODLOC","" )
	LOCAL cCodLocPro := PLSRETDAD( aDados,"LOCPRO","" )
	
	LOCAL cCodEsp    := PLSRETDAD( aDados,"CODESP","" ) // == cCodEspPro
	LOCAL cCodPRFExe := PLSRETDAD( aDados,"CDPFEX","" )
	
	LOCAL cLocalExec  	:= "1"
	LOCAL cHora      := PLSRETDAD( aDados,"HORAPRO","" )
	LOCAL cViaCartao := PLSRETDAD( aDados,"VIACAR","" )
	LOCAL cTipoMat   := PLSRETDAD( aDados,"TIPOMAT","" )
	LOCAL cNomUsrCar := PLSRETDAD( aDados,"NOMUSR","" )
	LOCAL cTipoGrv	 := PLSRETDAD( aDados,"TPGRV","1" )
	LOCAL dDtIniFat  := PLSRETDAD( aDados,"DTINIFAT",CtoD("") )
	LOCAL dDatPro    := PLSRETDAD( aDados,"DATPRO", dDtIniFat)
	LOCAL dDatNasUsr := PLSRETDAD( aDados,"DATNAS",CtoD("") )
	LOCAL lResInt    := PLSRETDAD( aDados,"RESINT",.F. )
	LOCAL lHonor     := PLSRETDAD( aDados,"HORIND",.F. )
	LOCAL lIncAutIE  := PLSRETDAD( aDados,"INCAUTIE",.F. )
	
	
	LOCAL cOpeMov    := PLSRETDAD( aDados,"OPEMOV","" )
	LOCAL cLibEsp     	:= "0"
	LOCAL cAuditoria  	:= "0"
	LOCAL cNumImp    := PLSRETDAD( aDados,"NUMIMP","" )
	LOCAL lLoadRda   := .F.
	LOCAL lRdaProf	 := ( cCodRda <> cCodRdaPro )
	LOCAL lIncNeg    := NIl
	LOCAL cEspSol 	 := PLSRETDAD( aDados,"ESPSOL","" )
	LOCAL cEspExe	 := PLSRETDAD( aDados,"ESPEXE","" )
	LOCAL lForBlo    := PLSRETDAD( aDados,"FORBLO",.F. )
	LOCAL lNMudFase  := PLSRETDAD( aDados,"LNMUDF", ( GetNewPar("MV_PLMFSG",'1') == '0' )  )
	LOCAL lEvoSADT   := PLSRETDAD( aDados,"EVOSADT",.F. )
	local oBO_Guia       := BO_Guia():New()
	LOCAL cTipGui := PLSRETDAD( aDados,"TIPGUI","" ) // 1 - Consulta  2 - SADT  3 - Internação  4 - Odonto   5 - Honorário Individual
	
	oBO_Guia:baixaLib(aItens, cOrigem,cNumLib, lInter, lEvolu, cMatric, cLocalExec, cHora, cViaCartao, cTipoMat, cNomUsrCar, cTipoGrv,;
			 dDatPro, dDatNasUsr, lResInt, lHonor, lIncAutIE, cOpeMov, cCodRda, cCodRdaPro, cCodLoc, cCodLocPro, cCodEsp,  cLibEsp,;
			 cAuditoria, cNumImp, lLoadRda, lRdaProf, lIncNeg, cTipo, cCodPRFExe, cEspSol, cEspExe, lForBlo, lNMudFase, lEvoSADT, cTipGui)
			 
return

//-------------------------------------------------------------------
/*/{Protheus.doc} montaGuia
Metodo que monta campos comuns entre todas as guias, isto é monta a VO_Guia
@author Karine Riquena Limp
@since 09/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method montaGuia(objGuia, aDados, aItens) class CO_Guia
local cTipGui			:= PLSRETDAD( aDados,"TIPGUI","" ) // 1 - Consulta  2 - SADT  3 - Sol. Internação  4 - Odonto   5 - Res. Internação 6 - Honorarios
local cCodOpe			:= PLSRETDAD( aDados,"OPEMOV","" )
local cNumLib        := PLSRETDAD( aDados,"NUMLIB","" )
local dDatPro 		:= PLSRETDAD( aDados,"DATPRO", PLSRETDAD( aDados,"DTINIFAT",CtoD("") ) )
local cCodLoc 		:= PLSRETDAD( aDados,"CODLOC","" )
local cMatric        := PLSRETDAD( aDados,"USUARIO","" )
local cNomUsr        := PLSRETDAD( aDados,"NOMUSR","" )
local cCodRda        := PLSRETDAD( aDados,"CODRDA","" )
local cCboRda        := PLSRETDAD( aDados,"CBORDA","")  
local cCodLdp			:= PLSRETDAD( aDados,"CODLDP",IIF(RetDigGuia(),GetNewPar("MV_PLSDIGP","9999"),IIF(PLSOBRPRDA(cCodRda),IIF(lImpTxt,PLSRETLDP(3),PLSRETLDP(9)),GetNewPar("MV_PLSPEGE","0000"))) )  
local cCodEsp 		:= iif(!empty(cCboRda),cCboRda,PLSRETDAD( aDados,"CODESP","" ))
local cNraOpe			:= ""
local aLib				:= {}			
local cOpeRDA 		:= ""  
local aRetFun			:= {}   
local oBO_Guia       := BO_Guia():New()
local aBCI           := {}
local cAteRn 		 := IIF(PLSRETDAD( aDados,"ATENRN","0" ) $ "0,2", "0", "1")
local cPadCon		 := PLSRETDAD( aDados,"PADCON","" )
local cTipFat := PLSRETDAD( aDados,"TIPFAT","" ) 

	
	if cTipFat $ "1,3"
		cTipFat := "P"
	elseif cTipFat $ "2,4"
		cTipFat := "T"
	else
		cTipFat := ""
	endif
	
	aRetFun := PLSDADRDA(cCodOpe,cCodRda,"1",dDatPro,cCodLoc,cCodEsp,nil,nil,nil,nil,nil,nil,.T.)

	if aRetFun[1]
		cOpeRDA := PLSGETRDA()[/*28*/14]
	endIf
	
	objGuia:setDadBenef(self:addBenef(cCodOpe, cMatric, cNomUsr, cPadCon, cAteRn))
	
	aBCI := PLSVRPEGOF(cCodOpe, cOpeRDA, cCodRda, alltrim(str(YEAR(dDatPro))) , STRZERO(val(alltrim(str(MONTH(dDatPro)))), 2, 0), cTipGui, /*cSituac*/, /*cLotGui*/,;
						 /*cFase*/, /*cCodLdp*/, /*cOrigem*/,/*cTipoInc*/, /*cNomeArq*/, dDatPro,;
						 /*dDatRecP*/, /*nQtdGuia*/, /*nQtdItens*/, /*nVlrTot*/, .T.)
						
	objGuia:setRegAns(  Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_SUSEP") )
	objGuia:setCodOpe( cCodOpe )                       
	objGuia:setCodLdp( cCodLdp  )
	objGuia:setCodPeg( aBCI[1] )
	objGuia:setNumero( PLSA500NUM("BD5",cCodOpe,cCodLdp,aBCI[1]) )
	
	
	objGuia:setFase  ( /*aBCI[5]*/ "1") 
	objGuia:setSituac( /*aBCI[4]*/ "1")  
	objGuia:setDatPro( dDatPro )	
	objGuia:setHorPro( PLSRETDAD( aDados,"HORAPRO","" )  )
	objGuia:setNumImp( PLSRETDAD( aDados,"NUMIMP","" )  )
	
	cNraOpe := oBO_Guia:preeNraOpe(cNumLib)
	objGuia:setNraOpe(cNraOpe)
	
	objGuia:setLotGui( PLSRETDAD( aDados,"LOTGUI","" ) )
	objGuia:setTipGui( cTipGui )
	objGuia:setGuiOri( PLSRETDAD( aDados,"GUIORI","" ) )
	objGuia:setDtDigi( date() )
	objGuia:setMesPag( aBCI[6] ) 
	objGuia:setAnoPag( aBCI[7] ) 
	
	objGuia:setNumAut(PlNewNAut("BD5",cCodOpe,aBCI[7],aBCI[6],3))
	
	objGuia:setPacote( "0" ) //no plsxmov coloca sempre 0, verificar a utilidade desse campo
	objGuia:setOriMov( "5" ) //Dig. Off-Line Criado para diferenciar as guias off-line para geraçao BCI
	objGuia:setGuiAco( "0" ) //no plsxmov coloca sempre 0, verificar a utilidade desse campo
	objGuia:setLibera( "0" ) //no plsxmov coloca sempre 0, verificar a utilidade desse campo
	objGuia:setRgImp ( "1" ) //no plsxmov coloca sempre 1, verificar a utilidade desse campo
	objGuia:setTpGrv ( "4" ) //no plsxmov coloca sempre 4, verificar a utilidade desse campo
	objGuia:setTipCon( "1" )
	objGuia:setTipAto( PLSRETDAD( aDados,"TIPATO", "") )
	objGuia:setTipAte( Iif( !empty( PLSRETDAD( aDados,"TIPATE","" ) ),StrZero( Val( PLSRETDAD( aDados,"TIPATE","" ) ),2 ),PLSRETDAD( aDados,"TIPATE","" ) ) )
	objGuia:setCid   ( PLSRETDAD( aDados,"CIDPRI","" ) )
	objGuia:setTipFat( cTipFat )
	objGuia:setQtdEve( Len(aItens) )
	objGuia:setIndAci( PLSRETDAD( aDados,"INDACI","" ) )
	objGuia:setTipSai( PLSRETDAD( aDados,"TIPSAI","" ) )
	objGuia:setObs( PLSRETDAD( aDados,"OBSGUI","" ) )
	
	/*if PLSRETDAD( aDados,"TIPADM",Iif(PLSRETDAD( aDados,"CARSOL","" )=="U",SubStr( GetNewPar("MV_PLSCDIU","4,5") ,1,1),GetNewPar("MV_PLSTPAD","CARSOL") ) ) $ "E,1"
		
		objGuia:setTipAdm( GetNewPar("MV_PLSCDEL","0") )
	
	else
			
		objGuia:setTipAdm( GetNewPar("MV_PLSCDUR","0")  )  
	
	endif*/
	objGuia:setTipAdm( PLSRETDAD( aDados,"CARSOL","" )  )  
	objGuia:setMsg01 ( PLSRETDAD( aDados,"MSG01",""  ) )
	objGuia:setMsg02 ( PLSRETDAD( aDados,"MSG02",""  ) )
	objGuia:setUtpDoe( PLSRETDAD( aDados,"UNDDOE","" ) )
	objGuia:setTpOdoe( PLSRETDAD( aDados,"TMPDOE",0  ) )
	objGuia:setTipDoe( PLSRETDAD( aDados,"TIPDOE","" ) )
	
	aLib := oBO_Guia:verificaLib(objGuia, cNumLib, objGuia:getDadBenef():getInterc() == "1")
	objGuia:setNrlBor(aLib[1])
	objGuia:setGuiPri(aLib[2])
	objGuia:setNraOpe(aLib[3]) 
	objGuia:setSenha (aLib[4]) 

return

//-------------------------------------------------------------------
/*/{Protheus.doc} dadRdaCont
Metodo para retornar um contratado de acordo com o PLSGETRDA
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes) class CO_Guia
local oContrat  := VO_Contratado():New()
local aRetFun   := {}
local aDadRda   := {}
default cCodOpe := ""
default cCodRda := ""
default dDatPro := ddatabase
default cCodLoc := ""
default cCodEsp := ""
default cCnes   := ""

aRetFun := PLSDADRDA(cCodOpe,cCodRda,"1",dDatPro,cCodLoc,cCodEsp,nil,nil,nil,nil,nil,nil,.T.)

if aRetFun[1]
	aDadRDA := PLSGETRDA()
	oContrat:setCodRda(aDadRDA[2])
	oContrat:setOpeRda(aDadRDA[14])
	oContrat:setNomRda(aDadRDA[6])
	oContrat:setTipRda(aDadRDA[8])
	oContrat:setCodLoc(aDadRDA[12])
	oContrat:setLocal (aDadRDA[13])
	oContrat:setCodEsp(aDadRDA[15])
	oContrat:setCpfCnpjRda(aDadRDA[16])
	oContrat:setDesLoc(aDadRDA[19])
	oContrat:setEndLoc(aDadRDA[20])
	oContrat:setTipPre(aDadRDA[27])
	oContrat:setCnes  (cCnes)
else
	//VERIFICAR
	/*for nI:=1 To Len(aRetFun[2])
		if !Empty(aRetFun[2,nI,1])
			PLSICRI(@aCriticas,aRetFun[2,nI,1],aRetFun[2,nI,2])
		endIf
	next*/
endif
	
return oContrat

//-------------------------------------------------------------------
/*/{Protheus.doc} addProf
Metodo para retornar um profissional 
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method addProf(cCodOpe, cCodProf, cEspProf) class CO_Guia
local   nRec  := 0
local   oProf := VO_Profissional():New()
default cCodOpe  := ""
default cCodProf := ""
default cEspProf  := ""
 
if !Empty(cCodProf)
	
	nRec := PLSIPRF(cCodOpe,cCodProf)
	
	if nRec > 0

		BB0->(DbGoTo(nRec))
		
		oProf:setCodOpe ( cCodOpe )
		oProf:setEstProf( BB0->BB0_ESTADO )
		oProf:setSigCr  ( BB0->BB0_CODSIG )
		oProf:setNumCr  ( BB0->BB0_NUMCR  )
		oProf:setNomProf( BB0->BB0_NOME   )
		oProf:setCdProf ( BB0->BB0_CODIGO )
		oProf:setEspProf(cEspProf)
			
	endif
	
endIf
	
return oProf

//-------------------------------------------------------------------
/*/{Protheus.doc} addBenef
Metodo para retornar um beneficiario 
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method addBenef(cCodOpe, cMatric, cNomUsr, cPadCon, cAteRn) class CO_Guia
local oBenef  		:= nil
local nTamMat 		:= TamSx3("BA1_CODINT")[1]+TamSx3("BA1_CODEMP")[1]+TamSx3("BA1_MATRIC")[1]+TamSx3("BA1_TIPREG")[1]+TamSx3("BA1_DIGITO")[1]
local nTamAnt 		:= TamSx3("BA1_MATANT")[1]
local cSpaceUsuAtu 	:= Iif(Len(AllTrim(cMatric)) == 16,"",Space(nTamMat - Len(AllTrim(cMatric))))  
local cSpaceMatAnt 	:= Space(nTamAnt - Len(AllTrim(cMatric)))
local aRetFun        := {}
local cMatricXML		:= ""
local lAchou   		:= .F.
local cCodEmp 		:= GetNewPar("MV_PLSGEIN","0001")
local cModulo   		:= Modulo11(cCodOpe+cCodEmp+"99999999")
local cMatrAntGen	   	:= cCodOpe+cCodEmp+"99999999"+cModulo

	BA1->( DbSetOrder(2) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
	BA1->( DbGotop() )

	lAchou := BA1->( MsSeek( xFilial("BA1")+AllTrim(cMatric)+cSpaceUsuAtu))
	
	if !lAchou
	    
	    BA1->( DbSetOrder(5) )//BA1_FILIAL + BA1_MATANT + BA1_TIPANT
	    BA1->( DbGotop() )
	
	    lAchou := BA1->( MsSeek( xFilial("BA1")+AllTrim(cMatric)+cSpaceMatAnt ) )
	    
	endIf
	
	if lAchou
	
		oBenef := VO_Beneficiario():New() 
		oBenef:setOpeUsr(BA1->BA1_CODINT)
		oBenef:setMatAnt(BA1->BA1_MATANT)
		
		If alltrim(BA1->BA1_MATANT) == alltrim(cMatrAntGen)
				oBenef:setNomUsr(cNomUsr)
		Else
				oBenef:setNomUsr(BA1->BA1_NOMUSR)
		Endif
		
		If BA1->BA1_CODEMP == GetNewPar("MV_PLSGEIN","0050")
			oBenef:setInterc("1")
		Endif
		
		If  !Empty(cMatricXML)
			oBenef:setMatXml(cMatricXML)
		Endif
		
		oBenef:setCodEmp(BA1->BA1_CODEMP)
		oBenef:setMatric(BA1->BA1_MATRIC)
		oBenef:setTipReg(BA1->BA1_TIPREG)
		oBenef:setCpfUsr(BA1->BA1_CPFUSR)
		oBenef:setIdUsr(BA1->BA1_DRGUSR)
		oBenef:setDatNas(BA1->BA1_DATNAS)
		oBenef:setDigito(BA1->BA1_DIGITO)
		oBenef:setConEmp(BA1->BA1_CONEMP)
		oBenef:setVerCon(BA1->BA1_VERCON)
		oBenef:setSubCon(BA1->BA1_SUBCON)
		oBenef:setVerSub(BA1->BA1_VERSUB)
		oBenef:setMatVid(BA1->BA1_MATVID)
		oBenef:setTipPac("1")
	  	oBenef:setMatUsa("1")
	  	oBenef:setAteRna(cAteRn)
		//cPadCon := PLSRETDAD( aDados,"PADCON","" )
		
		If !Empty(cPadCon)
			oBenef:setPadCon( cPadCon )
		Else
			oBenef:setPadCon(PLSACOMUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),'2'))
		EndIf
		
		BA3->( DbSetOrder(1) )
		
		if BA3->( MsSeek( xFilial("BA3") + BA1->( BA1_CODINT+BA1_CODEMP+BA1_MATRIC ) ) )
		 	BI3->( DbSetOrder(1) )//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
			BI3->(MsSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO) ) )
			oBenef:setPadInt(BI3->BI3_CODACO)
			
			oBenef:setCodPla(BA3->BA3_CODPLA)
			oBenef:setTipUsr(BA3->BA3_TIPOUS)
			oBenef:setModPag(BA3->BA3_MODPAG)
			oBenef:setOpeOri(BA1->BA1_OPEORI)
			
		endif
		
	endIf
	
return oBenef



method getProcOdo(cMatric, aItens, objGuia) class CO_Guia

	local aObjProcedimentosOdonto := {}
	local oObjBoOdonto := BO_Odonto():New()
	local oObjProcedimento := NIL
	local oObjProcedimentoOdonto := NIL
	local nFor
	
	local cDente		//BD6->BD6_DENREG
	local cFace 		//BD6->BD6_FADENT
		
	For nFor := 1 To Len(aItens)
	
		cDente  	:= PLSRETDAD(aItens[nFor],"DENTE","")	//BD6->BD6_DENREG
		cFace   	:= PLSRETDAD(aItens[nFor],"FACE","")	//BD6->BD6_FADENT
				
		oObjProcedimento := self:getProced(cMatric, aItens[nFor], objGuia)
		
		oObjProcedimentoOdonto := VO_ProcOdonto():New()
		oObjProcedimentoOdonto := self:getProced(cMatric, aItens[nFor], objGuia, oObjProcedimentoOdonto)
		
		oObjProcedimentoOdonto:setDenReg(cDente)
		oObjProcedimentoOdonto:setFaDent(cFace)	
		oObjProcedimentoOdonto:setDesReg(oObjBoOdonto:getDente(cDente))
		oObjProcedimentoOdonto:setFacDes(oObjBoOdonto:getFace(cFace))
				
		aadd(aObjProcedimentosOdonto, oObjProcedimentoOdonto) 
		
	next 
	
return aObjProcedimentosOdonto

method getLstProcedimentos(cMatric, aItens, objGuia) class CO_Guia

	local nFor
	local aObjProcedimentos := {}
	local oObj := nil
	
	For nFor := 1 To Len(aItens)
		oObj := self:getProced(cMatric, aItens[nFor], objGuia)
		aadd(aObjProcedimentos, oObj)
	next	

return aObjProcedimentos

//Recupera as informações do procedimento a partir da guia incluida 
method getProced(cMatric, aItem, objGuia, objProcOdo) class CO_Guia

	local objProcedimento
	local oObjBoGuia  := BO_Guia():New() 
	local cSpaceUsuAtu
	local cMatric
	local aCodTab
	LOCAL cGrpEmpInt 
	local cDesPro	
	local aDadInt	
	local aDadTab
	local cSubEsp := ""
	local aTpPar := {}
	
	//quando for ODONTO eu tenho a classe VO_ProcOdonto, entao ja passo o objeto pronto
	if(Empty(objProcOdo))
		objProcedimento := VO_Procedimento():New()
	else
		objProcedimento := objProcOdo
	endIf
	
	objProcedimento:setSeqMov(PLSRETDAD(aItem,"SEQMOV")) //BD6->BD6_SEQUEN
	objProcedimento:setCodPad(PLSRETDAD(aItem,"CODPAD")) //BD6->BD6_CODPAD
	objProcedimento:setSlvPad(PLSRETDAD(aItem,"SLVPAD",'')) //BD6->BD6_SLVPAD
	objProcedimento:setCodPro(PLSRETDAD(aItem,"CODPRO")) // BD6->BD6_CODPRO
	objProcedimento:setSlvPro(PLSRETDAD(aItem,"SLVPRO",'')) //BD6->BD6_SLVPRO
	
	cDesPro := PLSRETDAD(aItem,"DESPRO")
	aTpPar	 := PLSRETDAD(aItem,"ATPPAR",{})    
	
	objProcedimento:setVlrApr(PLSRETDAD(aItem,"VLRAPR",0)) //BD6->BD6_VLRAPR
	objProcedimento:setQtd(PLSRETDAD(aItem,"QTD",0)) //BD6->BD6_QTDPRO - BD6->BD6_QTDAPR	
	objProcedimento:setPerVia(PLSRETDAD(aItem,"PERVIA",0))  //BD6->BD6_PERVIA
	objProcedimento:setCodVia(PLSRETDAD(aItem,"VIAAC",'')) //BD6->BD6_VIA
	objProcedimento:setTecUti(PLSRETDAD(aItem,"TECUT",'')) //BD6->BD6_TECUTI
	objProcedimento:setDtPro(PLSRETDAD(aItem,"DATPRO",Date())) //BD6->BD6_DATPRO
	objProcedimento:setHorIni(PLSRETDAD(aItem,"HORINI",""))   //BD6->BD6_HORPRO
	objProcedimento:setHorFim(PLSRETDAD(aItem,"HORFIM",""))	//BD6->BD6_HORFIM
		
    /*Descrição do Procedimento*/		
    objProcedimento:setDesPro(oObjBoGuia:getDescProcedimento(objProcedimento:getCodPro(), cDesPro, objProcedimento:getCodPad()))
    
	objProcedimento:setNivel(BR8->BR8_NIVEL) // BD6->BD6_NIVEL
	
	If !Empty(objProcedimento:getCodVia()) .and. objProcedimento:getCodVia() >= "1"
	   	objProcedimento:setProcCirurgico("1") 	//BD6->BD6_PROCCI
	Endif
	 	
	/*Dados Intercâmbio*/
	aDadInt := oObjBoGuia:getDadIntercambio(cMatric)
	
	if len(aDadInt) > 0
		objProcedimento:setInterc(aDadInt[1])
	endif
	
	if len(aDadInt) > 1
		objProcedimento:setTipInt(aDadInt[2])
	endif
	
	objProcedimento:setIncAut("")
	objProcedimento:setStatus("1")
	objProcedimento:setChvNiv("")
	objProcedimento:setNivAut("")
									 
	objProcedimento:setBloqPag("0")
	
	//Preenchendo dados da Tabela 
	
	aDadTab := oObjBoGuia:getDadTabela(objProcedimento:getCodPad(),objProcedimento:getCodPro(),;
									   objProcedimento:getDtPro(),objGuia:getCodOpe(), objGuia:getContExec():getCodRda(),;
									   objGuia:getContExec():getCodEsp(),cSubEsp,objGuia:getContExec():getCodLoc(),objGuia:getContExec():getLocal(),; 
									   objGuia:getDadBenef():getOpeOri(), objGuia:getDadBenef():getCodPla(), objGuia:cTipAte)

	if len(aDadTab) > 0
		objProcedimento:setCodTab(aDadTab[1]) //BD6->BD6_CODTAB
	endif
	
	if len(aDadTab) > 1
		objProcedimento:setAliaTb(aDadTab[2]) //BD6->BD6_ALIATB
	endif
	
	objProcedimento:setPart(oObjBoGuia:getPartic(aTpPar, objProcedimento:getSeqMov(), objProcedimento:getCodPad(), objProcedimento:getCodPro(), objProcedimento:getVlrApr()))
	
return objProcedimento



method loadIteMod(oModelBD6, aObjProcedimentos, oGuiaConsulta, lOdonto) class CO_Guia

	local nFor
	default lOdonto := .F.
	
	For nFor := 1 To Len(aObjProcedimentos)
		
		if (nFor <> 1 .or. ;
			(oGuiaConsulta:getTipGui() == "02" .and. !lOdonto .and. !Empty(oModelBD6:getValue("BD6_CODPRO")))) 			
			oModelBD6:AddLine()
		endif
		
		//oModelBD6:GoLine(nFor)
				
		oModelBD6:LoadValue("BD6_SEQUEN", aObjProcedimentos[nFor]:getSeqMov())
		oModelBD6:LoadValue("BD6_CODPAD", aObjProcedimentos[nFor]:getCodPad())
		
		if oGuiaConsulta:getDadBenef() <> NIL
			oModelBD6:LoadValue("BD6_TIPUSR",oGuiaConsulta:getDadBenef():getTipUsr())
			oModelBD6:LoadValue("BD6_MODCOB",left(alltrim(oGuiaConsulta:getDadBenef():getModPag()), TamSx3("BD6_MODCOB")[1]))
			oModelBD6:LoadValue("BD6_CODPLA",oGuiaConsulta:getDadBenef():getCodPla())
			oModelBD6:LoadValue("BD6_OPEORI",oGuiaConsulta:getDadBenef():getOpeOri())
		endif
		
		oModelBD6:LoadValue("BD6_SLVPAD", aObjProcedimentos[nFor]:getSlvPad())
		oModelBD6:LoadValue("BD6_CODPRO", aObjProcedimentos[nFor]:getCodPro())
		oModelBD6:LoadValue("BD6_SLVPRO", aObjProcedimentos[nFor]:getSlvPro())
		oModelBD6:LoadValue("BD6_DESPRO", left(aObjProcedimentos[nFor]:getDesPro(), TamSx3("BD6_DESPRO")[1])) 
		oModelBD6:LoadValue("BD6_NIVEL" , aObjProcedimentos[nFor]:getNivel())
		oModelBD6:LoadValue("BD6_VLRAPR", aObjProcedimentos[nFor]:getVlrApr())
			
		oModelBD6:LoadValue("BD6_QTDPRO", aObjProcedimentos[nFor]:getQtd())
		oModelBD6:LoadValue("BD6_QTDAPR", aObjProcedimentos[nFor]:getQtd())
			
		oModelBD6:LoadValue("BD6_PERVIA", aObjProcedimentos[nFor]:getPerVia())
		oModelBD6:LoadValue("BD6_VIA"   , aObjProcedimentos[nFor]:getCodVia())
		oModelBD6:LoadValue("BD6_PROCCI", aObjProcedimentos[nFor]:getProcCirurgico())
		oModelBD6:LoadValue("BD6_DATPRO", aObjProcedimentos[nFor]:getDtPro())
		oModelBD6:LoadValue("BD6_HORPRO", aObjProcedimentos[nFor]:getHorIni())
		oModelBD6:LoadValue("BD6_HORFIM", aObjProcedimentos[nFor]:getHorFim())
				
		oModelBD6:LoadValue("BD6_INCAUT", aObjProcedimentos[nFor]:getIncAut())
		oModelBD6:LoadValue("BD6_STATUS", aObjProcedimentos[nFor]:getStatus())
		oModelBD6:LoadValue("BD6_CHVNIV", aObjProcedimentos[nFor]:getChvNiv())
		oModelBD6:LoadValue("BD6_NIVAUT", aObjProcedimentos[nFor]:getNivAut())
		oModelBD6:LoadValue("BD6_CODTAB", aObjProcedimentos[nFor]:getCodTab())
		oModelBD6:LoadValue("BD6_ALIATB", aObjProcedimentos[nFor]:getAliaTb())
		oModelBD6:LoadValue("BD6_BLOPAG", aObjProcedimentos[nFor]:getBloqPag())
		oModelBD6:LoadValue("BD6_INTERC", aObjProcedimentos[nFor]:getInterc())
		oModelBD6:LoadValue("BD6_TIPINT", aObjProcedimentos[nFor]:getTipInt())
		
		if lOdonto
			if(!empty(aObjProcedimentos[nFor]:getDenReg()))
				oModelBD6:LoadValue("BD6_DENREG", left(aObjProcedimentos[nFor]:getDenReg(), TamSX3("BD6_DENREG")[1]))
				oModelBD6:LoadValue("BD6_DESREG", left(aObjProcedimentos[nFor]:getDesReg(), TamSX3("BD6_DESREG")[1]))
			endIf
			
			if(!empty(aObjProcedimentos[nFor]:getFaDent()))
				oModelBD6:LoadValue("BD6_FADENT", left(aObjProcedimentos[nFor]:getFaDent(), TamSX3("BD6_FADENT")[1]))
				oModelBD6:LoadValue("BD6_FACDES", left(aObjProcedimentos[nFor]:getFacDes(), TamSX3("BD6_DESREG")[1]))
			endIf
		endif
		
		oModelBD6 := self:copyIteBD5(oModelBD6, oGuiaConsulta)
		
		oModelBD6:LoadValue("BD6_ORIMOV", oGuiaConsulta:getOriMov()) 
		//COLOQUEI AQUI POIS POR ALGUM MOTIVO ELE GRAVAVA SEMPRE VAZIO NO PRIMEIRO PROCEDIMENTO, DANDO ERRO NO SEEK DEPOIS
		
		//Armazena a linha atual do model BD6 que é correspondente ao item do objeto procedimento
		aObjProcedimentos[nFor]:setSeqModel(oModelBD6:nLine)
	next
	
return oModelBD6

method loadCabBD5(oModelBD5, oGuia, lOdonto) class CO_Guia
default lOdonto := .F.
	//dados do beneficiario
	oModelBD5:LoadValue("BD5_OPEUSR",oGuia:getDadBenef():getOpeUsr())
	oModelBD5:LoadValue("BD5_MATANT",oGuia:getDadBenef():getMatAnt())
  	oModelBD5:LoadValue("BD5_NOMUSR",oGuia:getDadBenef():getNomUsr())  	
  	oModelBD5:LoadValue("BD5_MATXML",oGuia:getDadBenef():getMatXml())
	oModelBD5:LoadValue("BD5_CODEMP",oGuia:getDadBenef():getCodEmp())
  	oModelBD5:LoadValue("BD5_MATRIC",oGuia:getDadBenef():getMatric())  	
  	oModelBD5:LoadValue("BD5_TIPREG",oGuia:getDadBenef():getTipReg())
	oModelBD5:LoadValue("BD5_CPFUSR",oGuia:getDadBenef():getCpfUsr())
  	oModelBD5:LoadValue("BD5_IDUSR",oGuia:getDadBenef():getIdUsr())  	
  	oModelBD5:LoadValue("BD5_DATNAS",oGuia:getDadBenef():getDatNas())
	oModelBD5:LoadValue("BD5_DIGITO",oGuia:getDadBenef():getDigito())
  	oModelBD5:LoadValue("BD5_CONEMP",oGuia:getDadBenef():getConEmp())  	
  	oModelBD5:LoadValue("BD5_VERCON",oGuia:getDadBenef():getVerCon())
	oModelBD5:LoadValue("BD5_SUBCON",oGuia:getDadBenef():getSubCon())
  	oModelBD5:LoadValue("BD5_VERSUB",oGuia:getDadBenef():getVerSub())  	
  	oModelBD5:LoadValue("BD5_MATVID",oGuia:getDadBenef():getMatVid())
	oModelBD5:LoadValue("BD5_TIPPAC",oGuia:getDadBenef():getTipPac())
  	oModelBD5:LoadValue("BD5_MATUSA",oGuia:getDadBenef():getMatUsa())  	
  	oModelBD5:LoadValue("BD5_ATERNA",oGuia:getDadBenef():getAteRna())
	oModelBD5:LoadValue("BD5_PADCON",oGuia:getDadBenef():getPadCon())
  	oModelBD5:LoadValue("BD5_PADINT",oGuia:getDadBenef():getPadInt())
  	  	  	
	oModelBD5:LoadValue("BD5_CODOPE",oGuia:getCodOpe())
	oModelBD5:LoadValue("BD5_OPEMOV",oGuia:getCodOpe())
	oModelBD5:LoadValue("BD5_CODLDP",oGuia:getCodLdp())
	oModelBD5:LoadValue("BD5_CODPEG",oGuia:getCodPeg())
	oModelBD5:LoadValue("BD5_NUMERO",left(oGuia:getNumero(), TamSx3("BD5_NUMERO")[1])) 
	oModelBD5:LoadValue("BD5_FASE",oGuia:getFase())
	oModelBD5:LoadValue("BD5_SITUAC",oGuia:getSituac())
	oModelBD5:LoadValue("BD5_DATPRO",oGuia:getDatPro())
	oModelBD5:LoadValue("BD5_HORPRO",oGuia:getHorPro())
	oModelBD5:LoadValue("BD5_NUMIMP",oGuia:getNumImp())
	oModelBD5:LoadValue("BD5_NRAOPE",oGuia:getNraOpe())
	oModelBD5:LoadValue("BD5_LOTGUI",oGuia:getLotGui())
	oModelBD5:LoadValue("BD5_TIPGUI",oGuia:getTipGui())
	oModelBD5:LoadValue("BD5_GUIORI",oGuia:getGuiOri())
	oModelBD5:LoadValue("BD5_DTDIGI",oGuia:getDtDigi())
	oModelBD5:LoadValue("BD5_MESPAG",STRZERO(val(oGuia:getMesPag()), 2, 0))
	oModelBD5:LoadValue("BD5_ANOPAG",oGuia:getAnoPag())
	oModelBD5:LoadValue("BD5_MESAUT",STRZERO(val(oGuia:getMesPag()), 2, 0))
	oModelBD5:LoadValue("BD5_ANOAUT",oGuia:getAnoPag())
	oModelBD5:LoadValue("BD5_NUMAUT",oGuia:getNumAut())
	oModelBD5:LoadValue("BD5_PACOTE",oGuia:getPacote())
	oModelBD5:LoadValue("BD5_ORIMOV",oGuia:getOriMov())
	oModelBD5:LoadValue("BD5_GUIACO",oGuia:getGuiAco())
	oModelBD5:LoadValue("BD5_LIBERA",oGuia:getLibera())
	oModelBD5:LoadValue("BD5_RGIMP",oGuia:getRgImp())
	oModelBD5:LoadValue("BD5_TPGRV",oGuia:getTpGrv())
	oModelBD5:LoadValue("BD5_TIPATE",oGuia:getTipAte())
	oModelBD5:LoadValue("BD5_CID",oGuia:getCid())
	oModelBD5:LoadValue("BD5_TIPFAT",oGuia:getTipFat())
	oModelBD5:LoadValue("BD5_QTDEVE",oGuia:getQtdEve())
	oModelBD5:LoadValue("BD5_INDACI",oGuia:getIndAci())
	oModelBD5:LoadValue("BD5_TIPSAI",left(alltrim(oGuia:getTipSai()), TamSx3("BD5_TIPSAI")[1]))
	oModelBD5:LoadValue("BD5_TIPADM",oGuia:getTipAdm())
	oModelBD5:LoadValue("BD5_UTPDOE",oGuia:getUtpDoe())
	oModelBD5:LoadValue("BD5_TPODOE",oGuia:getTpOdoe())
	oModelBD5:LoadValue("BD5_TIPDOE",oGuia:getTipDoe())
	oModelBD5:LoadValue("BD5_NRLBOR",oGuia:getNrlBor())
	oModelBD5:LoadValue("BD5_GUIPRI",oGuia:getGuiPri())
	oModelBD5:LoadValue("BD5_SENHA",oGuia:getSenha())
	
	//Consulta (Herança)
	oModelBD5:LoadValue("BD5_TIPCON",oGuia:getTipCon())
	oModelBD5:LoadValue("BD5_TIPATO",oGuia:getTipAto())
	oModelBD5:LoadValue("BD5_OBSGUI",oGuia:getObs())
	
	//Contratado
	oModelBD5:LoadValue("BD5_CODRDA",oGuia:getContExec():getCodRda())
	oModelBD5:LoadValue("BD5_OPERDA",oGuia:getContExec():getOpeRda())
	oModelBD5:LoadValue("BD5_NOMRDA",left(oGuia:getContExec():getNomRda(), TamSx3("BD5_NOMRDA")[1])) //oGuia:getContExec():getNomRda())
	oModelBD5:LoadValue("BD5_TIPRDA",oGuia:getContExec():getTipRda())
	oModelBD5:LoadValue("BD5_CODLOC",oGuia:getContExec():getCodLoc())
	oModelBD5:LoadValue("BD5_LOCAL",oGuia:getContExec():getLocal())
	oModelBD5:LoadValue("BD5_CODESP",oGuia:getContExec():getCodEsp())
	oModelBD5:LoadValue("BD5_CPFRDA",oGuia:getContExec():getCpfCnpjRda())
	oModelBD5:LoadValue("BD5_DESLOC",oGuia:getContExec():getDesLoc())
	oModelBD5:LoadValue("BD5_ENDLOC",oGuia:getContExec():getEndLoc())	
	oModelBD5:LoadValue("BD5_TIPPRE",oGuia:getContExec():getTipPre())
	oModelBD5:LoadValue("BD5_CNES",oGuia:getContExec():getCnes())	
	//Profissional Executante
	if oGuia:getProfExec() <> NIL
		oModelBD5:LoadValue("BD5_OPEEXE",oGuia:getProfExec():getCodOpe())
		oModelBD5:LoadValue("BD5_ESTEXE",oGuia:getProfExec():getEstProf())
		oModelBD5:LoadValue("BD5_SIGEXE",oGuia:getProfExec():getSigCr())
		oModelBD5:LoadValue("BD5_REGEXE",oGuia:getProfExec():getNumCr())
		oModelBD5:LoadValue("BD5_NOMEXE",left(oGuia:getProfExec():getNomProf(), TamSx3("BD5_NOMEXE")[1])) 
		oModelBD5:LoadValue("BD5_CDPFRE",oGuia:getProfExec():getCdProf())
		oModelBD5:LoadValue("BD5_ESPEXE",oGuia:getProfExec():getEspProf())
	endif
	//Profissional Solicitante
	if oGuia:getProfSol() <> NIL
		oModelBD5:LoadValue("BD5_OPESOL",oGuia:getProfSol():getCodOpe())
		oModelBD5:LoadValue("BD5_ESTSOL",oGuia:getProfSol():getEstProf())
		oModelBD5:LoadValue("BD5_SIGLA",oGuia:getProfSol():getSigCr())
		oModelBD5:LoadValue("BD5_REGSOL",oGuia:getProfSol():getNumCr())
		oModelBD5:LoadValue("BD5_NOMSOL",left(oGuia:getProfSol():getNomProf(), TamSx3("BD5_NOMSOL")[1])) 
		oModelBD5:LoadValue("BD5_CDPFSO",oGuia:getProfSol():getCdProf())
		oModelBD5:LoadValue("BD5_ESPSOL",oGuia:getProfSol():getEspProf())
	endif
	
	if oGuia:getTipGui() == "06"
		oModelBD5:LoadValue("BD5_REGFOR",oGuia:getRegFor())
		oModelBD5:LoadValue("BD5_DTFTIN",oGuia:getDtIniFat())
		oModelBD5:LoadValue("BD5_DTFTFN",oGuia:getDtFimFat())
	elseif oGuia:getTipGui() == "02" .and. !lOdonto
		oModelBD5:LoadValue("BD5_INDCLI",oGuia:getIndCli())
		oModelBD5:LoadValue("BD5_DATSOL",oGuia:getDatSol())
	endIf
		
return oModelBD5

method copyIteBD5(oBD6, oGuia) class CO_Guia

	oBD6:LoadValue("BD6_CODESP", oGuia:getContExec():getCodEsp())
	


	oBD6:LoadValue("BD6_NRAOPE", oGuia:getNraOpe())
	//oBD6:LoadValue("BD6_OPEORI", aObjProcedimentos[nFor]:getSeqMov())
	//oBD6:LoadValue("BD6_CODPLA", aObjProcedimentos[nFor]:getSeqMov())
	//oBD6:LoadValue("BD6_MODCOB", aObjProcedimentos[nFor]:getSeqMov())
	//oBD6:LoadValue("BD6_TIPUSR", aObjProcedimentos[nFor]:getSeqMov())
				
	oBD6:LoadValue("BD6_CODOPE", oGuia:getCodOpe())
	oBD6:LoadValue("BD6_CODLDP",oGuia:getCodLdp())
	oBD6:LoadValue("BD6_CODPEG",oGuia:getCodPeg())
	oBD6:LoadValue("BD6_NUMERO",left(oGuia:getNumero(), TamSx3("BD6_NUMERO")[1])) 
	
	if oGuia:getProfSol() <> NIL
		oBD6:LoadValue("BD6_ESPSOL",oGuia:getProfSol():getEspProf())
		oBD6:LoadValue("BD6_ESTSOL",oGuia:getProfSol():getEstProf())
		oBD6:LoadValue("BD6_SIGLA",oGuia:getProfSol():getSigCr())
		oBD6:LoadValue("BD6_REGSOL",oGuia:getProfSol():getNumCr())
		oBD6:LoadValue("BD6_NOMSOL",left(oGuia:getProfSol():getNomProf(), TamSx3("BD6_NOMSOL")[1])) 
		oBD6:LoadValue("BD6_CDPFSO",oGuia:getProfSol():getCdProf())
	endif
	
	if(oGuia:getProfExec() <> NIL)
		oBD6:LoadValue("BD6_ESPEXE",oGuia:getProfExec():getEspProf())
		oBD6:LoadValue("BD6_ESTEXE",oGuia:getProfExec():getEstProf())
		oBD6:LoadValue("BD6_SIGEXE",oGuia:getProfExec():getSigCr())
		oBD6:LoadValue("BD6_REGEXE",oGuia:getProfExec():getNumCr())
		oBD6:LoadValue("BD6_CDPFRE",oGuia:getProfExec():getCdProf())
		oBD6:LoadValue("BD6_OPEEXE",oGuia:getProfExec():getCodOpe())		
	endif
	
	oBD6:LoadValue("BD6_CODRDA",oGuia:getContExec():getCodRda())
	oBD6:LoadValue("BD6_NOMRDA",left(oGuia:getContExec():getNomRda(), TamSx3("BD6_NOMRDA")[1])) //oGuia:getContExec():getNomRda())
	oBD6:LoadValue("BD6_TIPRDA",oGuia:getContExec():getTipRda())
	oBD6:LoadValue("BD6_CODLOC",oGuia:getContExec():getCodLoc())
	oBD6:LoadValue("BD6_LOCAL",oGuia:getContExec():getLocal())
	oBD6:LoadValue("BD6_CPFRDA",oGuia:getContExec():getCpfCnpjRda())
	oBD6:LoadValue("BD6_DESLOC",oGuia:getContExec():getDesLoc())
	oBD6:LoadValue("BD6_ENDLOC",oGuia:getContExec():getEndLoc())
	oBD6:LoadValue("BD6_OPEUSR",oGuia:getDadBenef():getOpeUsr())
	oBD6:LoadValue("BD6_MATANT",oGuia:getDadBenef():getMatAnt())
	oBD6:LoadValue("BD6_NOMUSR",oGuia:getDadBenef():getNomUsr())
	oBD6:LoadValue("BD6_CODEMP",oGuia:getDadBenef():getCodEmp())
	oBD6:LoadValue("BD6_MATRIC",oGuia:getDadBenef():getMatric())
	oBD6:LoadValue("BD6_TIPREG",oGuia:getDadBenef():getTipReg())
	oBD6:LoadValue("BD6_IDUSR",oGuia:getDadBenef():getIdUsr())
	oBD6:LoadValue("BD6_DATNAS",oGuia:getDadBenef():getDatNas())
	oBD6:LoadValue("BD6_DIGITO",oGuia:getDadBenef():getDigito())
	oBD6:LoadValue("BD6_CONEMP",oGuia:getDadBenef():getConEmp())
	oBD6:LoadValue("BD6_VERCON",oGuia:getDadBenef():getVerCon())
	oBD6:LoadValue("BD6_SUBCON",oGuia:getDadBenef():getSubCon())
	oBD6:LoadValue("BD6_VERSUB",oGuia:getDadBenef():getVerSub())
	oBD6:LoadValue("BD6_MATVID",oGuia:getDadBenef():getMatVid())
	oBD6:LoadValue("BD6_FASE",oGuia:getFase())
	oBD6:LoadValue("BD6_SITUAC",oGuia:getSituac())
	oBD6:LoadValue("BD6_NUMIMP",oGuia:getNumImp())
	oBD6:LoadValue("BD6_NRAOPE",oGuia:getNraOpe())
	oBD6:LoadValue("BD6_LOTGUI",oGuia:getLotGui())
	oBD6:LoadValue("BD6_TIPGUI",oGuia:getTipGui())
	oBD6:LoadValue("BD6_GUIORI",oGuia:getGuiOri())
	oBD6:LoadValue("BD6_DTDIGI",oGuia:getDtDigi())
	oBD6:LoadValue("BD6_MESPAG",oGuia:getMesPag())
	oBD6:LoadValue("BD6_ANOPAG",oGuia:getAnoPag())
	oBD6:LoadValue("BD6_MATUSA",oGuia:getDadBenef():getMatUsa())
	oBD6:LoadValue("BD6_PACOTE",oGuia:getPacote())
	oBD6:LoadValue("BD6_ORIMOV",oGuia:getOriMov())
	oBD6:LoadValue("BD6_GUIACO",oGuia:getGuiAco())
	oBD6:LoadValue("BD6_LIBERA",oGuia:getLibera())
	oBD6:LoadValue("BD6_RGIMP",oGuia:getRgImp())
	oBD6:LoadValue("BD6_TPGRV",oGuia:getTpGrv())
	oBD6:LoadValue("BD6_CID",oGuia:getCid())
	oBD6:LoadValue("BD6_TIPCON",left(oGuia:getTipCon(), TamSx3("BD6_TIPCON")[1])) 

	oBD6:LoadValue("BD6_NRLBOR",oGuia:getNrlBor())
	//oBD6:LoadValue("BD6_GUIPRI",oGuia:getGuiPri())
	oBD6:LoadValue("BD6_NRAOPE",oGuia:getNraOpe())


return oBD6

//-------------------------------------------------------------------
/*/{Protheus.doc} grvGuia
Metodo para gravar a consulta
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method grvGuia(oGuia, nOperation, cTipGui, lOdonto) class CO_Guia
	local oObjBoGuia := BO_Guia():New()
	local aPartic := {}
	local oModel := FWLoadModel("PLBD5MODEL")
	local oBD5 := oModel:GetModel("BD5Cab")
	local oBD6 := oModel:GetModel("BD6Proc")
	//local oBD7 := oModel:GetModel("BD7Part")
	local nFor
	local aObjProcedimentos := oGuia:getProcedimentos()
	default lOdonto := .F.
	
	oModel:SetOperation(nOperation)
	
	oModel:Activate()
	oBD5 := self:loadCabBD5(oBD5, oGuia, lOdonto)	
	oBD6 := self:loadIteMod(oBD6, aObjProcedimentos, oGuia, lOdonto)
	
	PLSCriaUnd()
	                     						                        							
	IF oModel:VldData()
		Begin Transaction
			oModel:CommitData()
			
			BD6->(dbSetOrder(1))
			For nFor := 1 To Len(aObjProcedimentos)
			
				oBD6:GoLine(nFor)
				// preciso posicionar na BD6 pois a função abaixo utiliza ela posicionada e desta 
				// forma que fizemos utilizando o model, a BD6 posicionada é sempre a ultima que foi gravada
				// portanto gravava apenas a composição do ultimo procedimento
				if BD6->(msSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+oBD6:GetValue("BD6_SEQUEN")+oBD6:GetValue("BD6_CODPAD")+oBD6:GetValue("BD6_CODPRO")))
				
						PLS720IBD7({},oBD6:GetValue("BD6_VLPGMA"),oBD6:GetValue("BD6_CODPAD"),oBD6:GetValue("BD6_CODPRO"),oBD6:GetValue("BD6_CODTAB"),;
				  									       oBD6:GetValue("BD6_CODOPE"),oBD6:GetValue("BD6_CODRDA"),oBD6:GetValue("BD6_REGEXE"),oBD6:GetValue("BD6_SIGEXE"),;
													       oBD6:GetValue("BD6_ESTEXE"),oBD6:GetValue("BD6_CDPFRE"),oBD6:GetValue("BD6_CODESP"),;
													       oBD6:GetValue("BD6_CODLOC")+oBD6:GetValue("BD6_LOCAL"),"1", oBD6:GetValue("BD6_SEQUEN"),;
		                     						       '5' /*Para internação e Honorario 2*/,cTipGui,oBD6:GetValue("BD6_DATPRO"),,,,,,,,,aObjProcedimentos[nFor]:getPart(),,IIF(cTipGui == "06",.T.,.F.)/*lHonor*/)
		       endif
		    next nFor
		End Transaction
	Else		
		VarInfo("",oModel:GetErrorMessage())
	endif
	oModel:DeActivate()
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} loadGuiaRecno
Metodo para preencher uma classe a partir do recno 
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method loadGuiaRecno(nRecno,lOdonto, lProc) class CO_Guia

local cCodOpe := ""
local cTipGui := ""
local objGuia
local cCodRda := ""
local cCodPExe := ""
local cCodPSol := ""
local dDatPro := ""
local cCodLoc := ""
local cCodEsp := ""
local cCnes := ""
local cEspExe := ""                        
local cEspSol := ""                         
local cMatric := ""
local cNomUsr := ""
local cPadCon := ""
local cAteRn := ""
local oBoHon := NIL
local aRdaInt := {}

default lOdonto := .F.
default lProc := .T.

BD5->(dbGoto(nRecno))
cTipGui := BD5->BD5_TIPGUI

	DO CASE
		CASE cTipGui == "01"
			objGuia := VO_Consulta():New()
		CASE cTipGui == "02" .and. !lOdonto
			objGuia := VO_SADT():New()
		CASE cTipGui == "06"
			objGuia := VO_Honorario():New()
		CASE lOdonto
			objGuia := VO_Odonto():New()
	ENDCASE
   
   //contratado
   //solicitante
   //executante
   	cCodOpe  := BD5->BD5_CODOPE
	cCodRda  := BD5->BD5_CODRDA
	cCodPExe := BD5->BD5_CDPFRE
	cCodPSol := BD5->BD5_CDPFSO
	dDatPro  := BD5->BD5_DATPRO
	cCodLoc  := BD5->BD5_CODLOC
	cCodEsp  := BD5->BD5_CODESP
	cCnes    := BD5->BD5_CNES
	cEspExe  := BD5->BD5_ESPEXE                   
	cEspSol  := BD5->BD5_ESPSOL   
	cMatric  := BD5->(BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO)
	cNomUsr  := BD5->BD5_NOMUSR
	cPadCon  := BD5->BD5_PADCON
	cAteRn   := BD5->BD5_ATERNA
	cTipAto  := BD5->BD5_TIPATO
   	
   	objGuia:setRegAns(  Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_SUSEP") )
   	objGuia:setCodOpe( cCodOpe )                       
  	objGuia:setCodLdp( BD5->BD5_CODLDP )
	objGuia:setCodPeg( BD5->BD5_CODPEG )
	objGuia:setNumero( BD5->BD5_NUMERO )
	
	
	objGuia:setFase  ( BD5->BD5_FASE ) 
	objGuia:setSituac( BD5->BD5_SITUAC )  
	objGuia:setDatPro( BD5->BD5_DATPRO )	
	objGuia:setHorPro( BD5->BD5_HORPRO )
	objGuia:setNumImp( BD5->BD5_NUMIMP )
		
	objGuia:setLotGui( BD5->BD5_LOTGUI )
	objGuia:setTipGui( BD5->BD5_TIPGUI )
	objGuia:setGuiOri( BD5->BD5_GUIORI )
	objGuia:setDtDigi( BD5->BD5_DTDIGI )
	objGuia:setMesPag( BD5->BD5_MESPAG ) 
	objGuia:setAnoPag( BD5->BD5_ANOPAG ) 
	
	objGuia:setNumAut( BD5->BD5_NUMAUT )
	
	objGuia:setPacote( BD5->BD5_PACOTE )
	objGuia:setOriMov( BD5->BD5_ORIMOV )
	objGuia:setGuiAco( BD5->BD5_GUIACO )
	objGuia:setLibera( BD5->BD5_LIBERA )
	objGuia:setRgImp ( BD5->BD5_RGIMP )
	objGuia:setTpGrv ( BD5->BD5_TPGRV )
	objGuia:setTipCon( BD5->BD5_TIPCON )
	objGuia:setTipAte( BD5->BD5_TIPATE )
	objGuia:setCid   ( BD5->BD5_CID )
	objGuia:setTipFat( BD5->BD5_TIPFAT )
	objGuia:setQtdEve( BD5->BD5_QTDEVE )
	objGuia:setIndAci( BD5->BD5_INDACI )
	objGuia:setTipSai( BD5->BD5_TIPSAI )	
	objGuia:setTipAdm( BD5->BD5_TIPADM )  
		  
	//objGuia:setMsg01 ( BD5->BD5_MSG01 )
	//objGuia:setMsg02 ( BD5->BD5_MSG02 )
	
	objGuia:setUtpDoe( BD5->BD5_UTPDOE )
	objGuia:setTpOdoe( BD5->BD5_TPODOE )
	objGuia:setTipDoe( BD5->BD5_TIPDOE )
	
	objGuia:setNrlBor( BD5->BD5_NRLBOR )
	objGuia:setGuiPri( BD5->BD5_GUIPRI )
	objGuia:setNraOpe( BD5->BD5_NRAOPE ) 
	objGuia:setSenha ( BD5->BD5_SENHA ) 
	objGuia:setTipAto( BD5->BD5_TIPATO )
	objGuia:setObs( BD5->BD5_OBSGUI )
	
	objGuia:setDadBenef(self:addBenef(cCodOpe, cMatric, cNomUsr, cPadCon, cAteRn))
	objGuia:setContExec(self:addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes))
	objGuia:setProfExec(self:addProf(cCodOpe, cCodPExe, cEspExe))
	objGuia:setProfSol (self:addProf(cCodOpe, cCodPSol, cEspSol))
	
	if(cTipGui == "02" .and. !lOdonto)
		objGuia:setIndCli( BD5->BD5_INDCLI )
		objGuia:setDatSol( BD5->BD5_DATSOL )
	endif
	
	//Honorarios
	if(cTipGui == "06")
		objGuia:setDtIniFat(BD5->BD5_DTFTIN)
		objGuia:setDtFimFat(BD5->BD5_DTFTFN)
		objGuia:setDtEmiGui(BD5->BD5_DATPRO)
		objGuia:setRegFor(BD5->BD5_REGFOR)
		
		oBoHon := BO_Honorario():New()
		aRdaInt := oBoHon:getRdaInt(BD5->BD5_GUIPRI)
		
		if(Len(aRdaInt) = 3)
			objGuia:setCnpjRdaInt(aRdaInt[1])
			objGuia:setNomeRdaInt(aRdaInt[2])
			objGuia:setCnesRdaInt(aRdaInt[3])
		endif
	endif
	
	if lProc
		objGuia:setProcedimentos(self:getProcChv(BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV), lOdonto, .F., cTipGui == "02" .and. !lOdonto))
	endif

return objGuia

//-------------------------------------------------------------------
/*/{Protheus.doc} getProcChv
Metodo para preencher os procedimentos da guia pela chave da BD5
@author Karine Riquena Limp
@since 17/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProcChv( cChaveBD5, lOdonto, lOutrasDesp, lSadt ) class CO_Guia
local aObjProc := {}
local oProc 
local cChaveBX6 := ""
default lOdonto := .F.
default lOutrasDesp := .F.
default lSadt		   := .F.
	BD6->(DbSetorder(1))
	If BD6->(msSeek(xFilial("BD6")+cChaveBD5))

		while BD6->(!EOF()) .AND. BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == cChaveBD5
    
			if lOdonto
					oProc := VO_ProcOdonto():New()
					oProc:setDenReg(BD6->BD6_DENREG)
					oProc:setDesReg(BD6->BD6_DESREG)
					oProc:setFaDent(BD6->BD6_FADENT)
					oProc:setFacDes(BD6->BD6_FACDES)
			else
					oProc := VO_Procedimento():New()
			endif
			
			oProc:setSeqMov(BD6->BD6_SEQUEN)
			oProc:setCodPad(BD6->BD6_CODPAD)
		
			//BD6->BD6_TIPUSR,oGuiaConsulta:getDadBenef():getTipUsr()
			//BD6->BD6_MODCOB,left(alltrim(oGuiaConsulta:getDadBenef():getModPag()), TamSx3("BD6_MODCOB")[1])
			//BD6->BD6_CODPLA,oGuiaConsulta:getDadBenef():getCodPla()
			//BD6->BD6_OPEORI,oGuiaConsulta:getDadBenef():getOpeOri()
		
			oProc:setSlvPad(BD6->BD6_SLVPAD)
			oProc:setCodPro(BD6->BD6_CODPRO)
			oProc:setSlvPro(BD6->BD6_SLVPRO)
			oProc:setDesPro(BD6->BD6_DESPRO)
			oProc:setNivel(BD6->BD6_NIVEL)
			oProc:setVlrApr(BD6->BD6_VLRAPR)
			oProc:setVlrMan(BD6->BD6_VLRMAN)
			
			oProc:setQtd(BD6->BD6_QTDPRO)
			
			oProc:setPerVia(BD6->BD6_PERVIA)
			oProc:setCodVia(BD6->BD6_VIA)
			oProc:setProcCirurgico(BD6->BD6_PROCCI)
			oProc:setDtPro(BD6->BD6_DATPRO)
			oProc:setHorIni(BD6->BD6_HORPRO)
			oProc:setHorFim(BD6->BD6_HORFIM)
			
			oProc:setIncAut(BD6->BD6_INCAUT)
			oProc:setStatus(BD6->BD6_STATUS)
			oProc:setChvNiv(BD6->BD6_CHVNIV)
			oProc:setNivAut(BD6->BD6_NIVAUT)
			oProc:setCodTab(BD6->BD6_CODTAB)
			oProc:setAliaTb(BD6->BD6_ALIATB)
			oProc:setBloqPag(BD6->BD6_BLOPAG)
			oProc:setInterc(BD6->BD6_INTERC)
			oProc:setTipInt(BD6->BD6_TIPINT)
			oProc:setTecUti(BD6->BD6_TECUTI)
			oProc:setRefMatFab(BD6->BD6_REFFED)
			
			if lSadt .or. lOutrasDesp
				cChaveBX6 := BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO)	                    
				BX6->(DbSetOrder(1))
				if ( BX6->(msSeek(xFilial("BX6")+cChaveBX6)))
					if(BX6->BX6_AODESP .and. lOutrasDesp)
						oProc:setAoDesp(BX6->BX6_AODESP)
						oProc:setCodDes(BX6->BX6_CODDES)
						oProc:setRegAnvisa(BX6->BX6_REGANV)
						oProc:setUniMedida(BX6->BX6_CODUNM)
						oProc:setAutFun(BX6->BX6_AUTFUN)
						aAdd(aObjProc, oProc)
					elseif(!BX6->BX6_AODESP .and. lSadt)
						aAdd(aObjProc, oProc)
					else
						BD6->(dbSkip())
						Loop	
					endif
				elseif lSadt
					aAdd(aObjProc, oProc)
				endIf
			else
				aAdd(aObjProc, oProc)	
			endIf						
				
			
			BD6->(dbSkip())

		endDo
		
	Endif

return aObjProc

//-------------------------------------------------------------------
/*/{Protheus.doc} altGuia
Metodo para Alterar as guias
@author Roberto Vanderlei
@since 21/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method altGuia(aCamposCabec, aCampoItem, cRecnoBD5) class CO_Guia
	local oModel := FWLoadModel("PLBD5MODEL")
	local oBD5 := oModel:GetModel("BD5Cab")
	local oBD6 := oModel:GetModel("BD6Proc")
	local nFor
	local lRet := .T.
	
	
	if(val(cRecnoBD5) != BD5->(recno()))
		BD5->(DbGoTo(val(cRecnoBD5)))
	endif
	
	oModel:SetOperation(4)
	
	oModel:Activate()
	
	for nFor := 1 to len(aCamposCabec)
		oBD5:LoadValue(aCamposCabec[nFor][1],aCamposCabec[nFor][2])
	next 
	
	for nFor := 1 to len(aCampoItem)
		oBD6:LoadValue(aCampoItem[nFor][1],aCampoItem[nFor][2])
	next 
	
	IF oModel:VldData()	
		oModel:CommitData()
	Else		
		VarInfo("",oModel:GetErrorMessage())	
		lRet := .F.
	endif
	
	oModel:DeActivate()

return {lRet, alltrim(BD5->BD5_CODOPE) + alltrim(BD5->BD5_ANOAUT) + alltrim(BD5->BD5_MESAUT) + alltrim(BD5->BD5_NUMAUT)}

//-------------------------------------------------------------------
/*/{Protheus.doc} loadOutrasDesp
Metodo para preencher uma classe de outras despesas a partir do recno da guia referenciada
@author Karine Riquena Limp
@since 30/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method loadOutrasDesp(nRecGuiRef,cNumGuiRef) class CO_Guia

local cCodOpe := ""
local objGuia := VO_OutrasDesp():New()
local cCodRda := ""
local dDatPro := ""
local cCodLoc := ""
local cCodEsp := ""
local cCnes := ""                                             
local cAteRn := ""
local cCid := ""

BD5->(dbGoto(nRecGuiRef))
cTipGui := BD5->BD5_TIPGUI
  

   	cCodOpe  := BD5->BD5_CODOPE
	cCodRda  := BD5->BD5_CODRDA
	dDatPro  := BD5->BD5_DATPRO
	cCodLoc  := BD5->BD5_CODLOC
	cCodEsp  := BD5->BD5_CODESP
	cCnes    := BD5->BD5_CNES
	
	//ESSES CAMPOS SÃO NECESSÁRIOS PARA VALIDAÇÃO DO PROCEDIMENTO
	cAteRn   := BD5->BD5_ATERNA
	cCid     := BD5->BD5_CID
   	
   	objGuia:setRegAns   (  Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_SUSEP") )
   	objGuia:setNumGuiRef(  cNumGuiRef )
   	objGuia:setAteRn( cAteRn )
   	objGuia:setCid( cCid )
	objGuia:setContExec (self:addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes))	
	
	objGuia:setProcedimentos(self:getProcChv(BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV), .F., .T.))

return objGuia

//-------------------------------------------------------------------
/*/{Protheus.doc} excIteGuia
Metodo para gravar a consulta
@author Roberto Vanderlei
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method excIteGuia(cCodTab, cCodProPar, cRecnoBD5) class CO_Guia

	//local oModel := FWLoadModel("PLBD5MODEL")
	//local oBD5 := oModel:GetModel("BD5Cab")
	//local oBD6 := oModel:GetModel("BD6Proc")
	local nFor
	local cCodPad
	local cCodPro
	local lRet := .T.
	
	
	if(val(cRecnoBD5) != BD5->(recno()))
		BD5->(DbGoTo(val(cRecnoBD5)))
	endif
	
	cCodPad := AllTrim(cCodTab)+Space(TamSX3("BD6_CODPAD")[1]-Len(AllTrim(cCodTab))) 
	cCodPro := AllTrim(cCodProPar)+Space(TamSX3("BD6_CODPRO")[1]-Len(AllTrim(cCodProPar))) 
	
	//Posiciona na BD6
	
	BD6->(DbSetorder(6))
	If BD6->(msSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+cCodPad+cCodPro))
		If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
			While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
									xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)      
				                                        
				BD7->(Reclock("BD7",.F.))
				BD7->(DbDelete())
				BD7->(MsUnlock())
				BD7->(DbSkip())
			End
			
		EndIf         
		RecLock( "BD6" , .F. )
		DBDelete() 
		BD6->(MsUnLock())
		 
	else
		lRet := .F.
	endif
	
return {lRet, alltrim(BD5->BD5_CODOPE) + alltrim(BD5->BD5_ANOAUT) + alltrim(BD5->BD5_MESAUT) + alltrim(BD5->BD5_NUMAUT)}

//-------------------------------------------------------------------
/*/{Protheus.doc} altItem
Metodo para Alterar as guias
@author Roberto Vanderlei
@since 21/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method altItem(aCmpOrg, cRecnoBD5) class CO_Guia
	local oModel := FWLoadModel("PLBD5MODEL")
	local oBD5 := oModel:GetModel("BD5Cab")
	local oBD6 := oModel:GetModel("BD6Proc")
	local nFor
	local cCodPad
	local cCodPro
	local lRet := .T.
	local nM := 1
	local cOriMov := ""
	
	if(val(cRecnoBD5) != BD5->(recno()))
		BD5->(DbGoTo(val(cRecnoBD5)))
	endif
	
	//Para pegar o local correto da origem, pois posso ter guias da Off-Line ou autorização.
	cOrimov := BD5->BD5_ORIMOV

	cCodPad := AllTrim(aCmpOrg[2][2])+Space(TamSX3("BD6_CODPAD")[1]-Len(AllTrim(aCmpOrg[2][2]))) 
	cCodPro := AllTrim(aCmpOrg[1][2])+Space(TamSX3("BD6_CODPRO")[1]-Len(AllTrim(aCmpOrg[1][2]))) 
	
	//Posiciona na BD6
	
	BD6->(DbSetorder(6))
	If BD6->(msSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+cCodPad+cCodPro))
		oModel:SetOperation(4)
	
		oModel:Activate()
	
		//Posiciona corretamente na model pois, caso não seja feito, a alteração será efetuada sempre no primeiro registro existente na model
		for nM := 1 to oBD6:Length()
			//Posiciona em cada linha do model
			oBD6:goLine(nM)
						
			//São verificados os códigos de tabela e procedimento da linha posicionada da model com os valores do item alterado.
			if alltrim(cCodPad) == alltrim(oBD6:getValue("BD6_CODPAD")) .and. alltrim(cCodPro) == alltrim(oBD6:getValue("BD6_CODPRO"))
				//Caso os valores sejam encontrados, os campos na model são alterados.
				for nFor := 3 to len(aCmpOrg)
					oBD6:LoadValue(aCmpOrg[nFor][1],aCmpOrg[nFor][2])
				next				
				//Encontrou a linha esperada, sai do laço for
				exit
			endif
		next nM 
	
		IF oModel:VldData()
			oModel:CommitData()
		Else		
			VarInfo("",oModel:GetErrorMessage())
			lRet := .F.	
		endif
				
		oModel:DeActivate()
		
		//Deleta os registros da BD7 vinculados ao procedimento
		If lRet
			If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
				While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
										xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)      
					                                        
					BD7->(Reclock("BD7",.F.))
					BD7->(DbDelete())
					BD7->(MsUnlock())
					BD7->(DbSkip())
				End
				PLS720IBD7("0",BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODTAB,BD6->BD6_CODOPE,BD6->BD6_CODRDA,BD6->BD6_REGEXE,BD6->BD6_SIGEXE,BD6->BD6_ESTEXE,;
						BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->BD6_CODLOC+BD6->BD6_LOCAL,"1",BD6->BD6_SEQUEN,;
	                  	cOrimov ,BD5->BD5_TIPGUI,BD6->BD6_DATPRO,,,,,,,,,,,IiF(BD5->BD5_TIPGUI == "06",.T.,.F.)/*lHonor*/)
			EndIf  
		EndIf                 			
	EndIf
	
return {lRet, alltrim(BD5->BD5_CODOPE) + alltrim(BD5->BD5_ANOAUT) + alltrim(BD5->BD5_MESAUT) + alltrim(BD5->BD5_NUMAUT)}

//-------------------------------------------------------------------
/*/{Protheus.doc} incIteGuia
Metodo para incluir item na guia (procedimento)
@author Roberto Vanderlei
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method incIteGuia(oGuia, aObjProcedimentos, lOdonto) class CO_Guia
	local oObjBoGuia := BO_Guia():New()
	local aPartic := {}
	local oModel := FWLoadModel("PLBD5MODEL")
	local oBD5 := oModel:GetModel("BD5Cab")
	local oBD6 := oModel:GetModel("BD6Proc")
	local nFor
	local lRet := .T.
	default lOdonto := .F.
		
	oModel:SetOperation(4)	
	oModel:Activate()
		
	oBD5:LoadValue("BD5_CODOPE",oGuia:getCodOpe())
	oBD5:LoadValue("BD5_CODLDP",oGuia:getCodLdp())
	oBD5:LoadValue("BD5_CODPEG",oGuia:getCodPeg())
	oBD5:LoadValue("BD5_NUMERO",left(oGuia:getNumero(), TamSx3("BD5_NUMERO")[1])) 
	
	oBD6 := self:loadIteMod(oBD6, aObjProcedimentos, oGuia, lOdonto)
	
	PLSCriaUnd()
                     						                        							
	IF oModel:VldData()	
		oModel:CommitData()		
		BD6->(dbSetOrder(1))
		For nFor := 1 To Len(aObjProcedimentos)		
			//Posiciona no registro correto no model da BD6
			oBD6:GoLine(IIF(aObjProcedimentos[nFor]:getSeqModel() > 0, aObjProcedimentos[nFor]:getSeqModel(), nFor))
			
			// preciso posicionar na BD6 pois a função abaixo utiliza ela posicionada e desta 
			// forma que fizemos utilizando o model, a BD6 posicionada é sempre a ultima que foi gravada
			// portanto gravava apenas a composição do ultimo procedimento
			if BD6->(msSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+oBD6:GetValue("BD6_SEQUEN")+oBD6:GetValue("BD6_CODPAD")+oBD6:GetValue("BD6_CODPRO")))
					PLS720IBD7({},oBD6:GetValue("BD6_VLPGMA"),oBD6:GetValue("BD6_CODPAD"),oBD6:GetValue("BD6_CODPRO"),oBD6:GetValue("BD6_CODTAB"),;
			  									       oBD6:GetValue("BD6_CODOPE"),oBD6:GetValue("BD6_CODRDA"),oBD6:GetValue("BD6_REGEXE"),oBD6:GetValue("BD6_SIGEXE"),;
												       oBD6:GetValue("BD6_ESTEXE"),oBD6:GetValue("BD6_CDPFRE"),oBD6:GetValue("BD6_CODESP"),;
												       oBD6:GetValue("BD6_CODLOC")+oBD6:GetValue("BD6_LOCAL"),"1", oBD6:GetValue("BD6_SEQUEN"),;
	                     						       BD6->BD6_ORIMOV /*Para internação e Honorario 2*/,oBD6:GetValue("BD6_TIPGUI"),oBD6:GetValue("BD6_DATPRO"),,,,,,,,,aObjProcedimentos[nFor]:getPart(),,IIF(oBD6:GetValue("BD6_TIPGUI") == "06",.T.,.F.)/*lHonor*/)
	   		endif       	       
	    next nFor	    
	Else		
		VarInfo("",oModel:GetErrorMessage())
		lRet := .F.	
	endif
		
	oModel:DeActivate()
	
return {lRet, oGuia:getCodOpe() + oGuia:getAnoPag() + oGuia:getMesPag() + oGuia:getNumAut()}   

//-------------------------------------------------------------------
/*/{Protheus.doc} CO_Guia
Método para gravar outras despesas
@author Karine Riquena Limp
@since 07/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method grvOutDes(nRecGuiRef, aAddItem, aEditItem, aDelItem) class CO_Guia
local lRet := .T.
local oModel := FWLoadModel("PLBD5MODEL")
local oBD5 := oModel:GetModel("BD5Cab")
local oBD6 := oModel:GetModel("BD6Proc")
local oObjBoGuia := BO_Guia():New()
local nI := 1
local nJ := 1
local nW := 1
local nX := 1
local nPosCodPad := 0
local nPosCodPro := 0
local nPosSeqMov := 0
local nPosCodDes := 0
local nPosCodUnm := 0
local nPosRegAnv := 0
local nPosAutFun := 0
local aBX6 := {}
local aAuxBX6 := {}
local aAuxBD7 := {}
local aPartic := {}
local aKeyDel := {}
local aDadTab := {}
local cSql		:= ""
local cSeq		:= ""
Local lRetMudFase	:= .F.
Local nRecnoBCI := 0
Local aEditBX6 := {}
Local aObEditBX6 := {}
Local aCriticas := {}
Local cOriMov		:= ""

	BD5->(DbGoTo(nRecGuiRef))
	BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO                                                                                                                                                                                   
	BA1->(DbSeek(xFilial("BD5")+BD5->(BD5_CODOPE+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO)))
	BA3->(DbSetOrder(1))//BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB                                                                         
	BA3->(DbSeek(xFilial("BA3")+BD5->BD5_CODOPE+BD5->BD5_CODEMP+BD5->BD5_MATRIC+BA1->BA1_CONEMP+BA1->BA1_VERCON+BA1->BA1_SUBCON+BA1->BA1_VERSUB))
	//Se diferente de status Digitação de Guias, muda a fase
	If BD5->BD5_FASE <> "1"
		lRetMudFase := PLSBACKGUI(Str(nRecGuiRef), Val(BD5->BD5_TIPGUI))
	EndIf
	
	//Para garantir pegar o local de origem correto conforme a guia
	cOrimov := BD5->BD5_ORIMOV

	oModel:SetOperation(4)
	oModel:Activate()
	
	//Faço primeiro a edição e deleção dos itens para percorrer uma model de bd6 menor
	
	for nI := 1 to len(aDelItem)
	    //pego a chave do procedimento
		nPosCodPad := aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPAD" } )
		nPosCodPro := aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPRO" } )
		nPosSeqMov := aScan( aDelItem[nI], { |x| x[1] == "BD6_SEQUEN" } ) 
		if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0)	
		
			for nJ := 1 to oBD6:Length()
					
				oBD6:GoLine( nJ ) 
				
				if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aDelItem[nI][nPosCodPad][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aDelItem[nI][nPosCodPro][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aDelItem[nI][nPosSeqMov][2]) 
					
						oBD6:DeleteLine()
						aAdd(aKeyDel, BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+;
										aDelItem[nI][nPosSeqMov][2])
				
				endIf
				
			next nJ
		
		endIf
	
	next nI
	
	for nI := 1 to len(aEditItem)
	    //pego a chave do procedimento, que é sempre a primeira posição do item editado
		nPosCodPad := aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPAD" } )
		nPosCodPro := aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPRO" } )
		nPosSeqMov := aScan( aEditItem[nI][1], { |x| x[1] == "BD6_SEQUEN" } ) 
		if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0)	
		
			for nJ := 1 to oBD6:Length()
					
				oBD6:GoLine( nJ ) 
				
				if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aEditItem[nI][1][nPosCodPad][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aEditItem[nI][1][nPosCodPro][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aEditItem[nI][1][nPosSeqMov][2]) 
					
					//Preciso saber se o usuário editou o código do procedimento ou a tabela
					//pois nesse caso, é necessário excluir e inserir um novo
					if(aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPAD" } ) > 0 .or. ;
					   aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPRO" } ) > 0)	
					
						oBD6:DeleteLine()
						//adiciono no array de addedItems para ser incluido um BD6 novo
						aAdd(aAddItem, aEditItem[nI][2])
						//guardo a chave para excluir a BX6 e a BD7 referenciada
						aAdd(aKeyDel, BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+;
										aEditItem[nI][1][nPosSeqMov][2])
							
					else 
								 
						for nW := 1 to len(aEditItem[nI][2])
																		
							if(!("BX6" $ aEditItem[nI][2][nW][1]))
								oBD6:LoadValue(aEditItem[nI][2][nW][1], aEditItem[nI][2][nW][2])
							else
								//Adicionar campos
								aadd(aEditBX6, {aEditItem[nI][2][nW][1],  aEditItem[nI][2][nW][2]})
							endif
							
						next nW
						
						//Existe item para edição na BX6
						if len(aEditBX6) > 0
							aadd(aObEditBX6, { BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+aEditItem[1][1][3][2]+aEditItem[1][1][1][2]+aEditItem[1][1][2][2],aEditBX6 })
							aEditBX6 := {}
						endif
						
					endIf
				
				endIf
				
			next nJ
		
		endIf
	
	next nI
	
	for nI := 1 to len(aAddItem)
		
		oBD6:AddLine()
		
		aAuxBX6 := {}
		aAuxBD7 := {}
		for nJ := 1 to len(aAddItem[nI])
			//garanto que o campo não é da BX6, pois não temos ela dentro da model
			if(!("BX6" $ aAddItem[nI][nJ][1]))
				oBD6:LoadValue(aAddItem[nI][nJ][1], aAddItem[nI][nJ][2])
				//verifico se o campo é o CODPAD ou CODPRO para gravar a BX6
				if("BD6_CODPAD" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BD6_CODPAD",aAddItem[nI][nJ][2] })
				elseif("BD6_CODPRO" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BD6_CODPRO",aAddItem[nI][nJ][2] })
				endif
			else
				if("BX6_CODDES" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BX6_CODDES",aAddItem[nI][nJ][2] })
				elseif("BX6_CODUNM" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BX6_CODUNM",aAddItem[nI][nJ][2] })
				elseif("BX6_REGANV" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BX6_REGANV",aAddItem[nI][nJ][2] })
				elseif("BX6_AUTFUN" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BX6_AUTFUN",aAddItem[nI][nJ][2] })
				endif 
			endIf
					
		next nJ
		
		 /*Descrição do Procedimento*/		
	    oBD6:LoadValue("BD6_DESPRO",subStr(oObjBoGuia:getDescProcedimento(oBD6:getValue("BD6_CODPRO"), "",oBD6:getValue("BD6_CODPAD")),1,50))	
    		
		self:copyIteOutDes(oBD6)
		
		if(len(aAuxBX6) > 0)
			//garanto o sequen correto
			//não considero o D_E_L_E_T_ na query para nao dar problema no X2_UNICO que foi colocado na BD6 
			//para o primeiro item incluido ainda, os demais precisam seguir o primeiro+1
			if(nI == 1)
				cSql := "SELECT MAX(BD6_SEQUEN) AS MAXSEQ FROM " + RetSqlName("BD6") 
				cSql += " WHERE BD6_FILIAL 	= '" + xFilial("BD6")  + "'"
				cSql += " AND BD6_CODOPE 	= '" + BD5->BD5_CODOPE + "'"
				cSql += " AND BD6_CODLDP 	= '" + BD5->BD5_CODLDP + "'"
				cSql += " AND BD6_CODPEG 	= '" + BD5->BD5_CODPEG + "'"
				cSql += " AND BD6_NUMERO 	= '" + BD5->BD5_NUMERO + "'"
				cSql += " AND BD6_ORIMOV 	= '" + BD5->BD5_ORIMOV + "'"
				
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRBBD6",.T.,.F.)
				oBD6:LoadValue("BD6_SEQUEN", iif( TRBBD6->(!EOF()) ,Soma1( TRBBD6->MAXSEQ ), "001"))
								
				TRBBD6->(dbCloseArea())
			else
				cSeq := Soma1( cSeq )
				oBD6:LoadValue("BD6_SEQUEN", cSeq)
			endif
			
			cSeq := oBD6:GetValue("BD6_SEQUEN")
			aAdd(aAuxBX6, {"BD6_SEQUEN", oBD6:GetValue("BD6_SEQUEN") })
			
			aDadTab := oObjBoGuia:getDadTabela(oBD6:GetValue("BD6_CODPAD"),oBD6:GetValue("BD6_CODPRO"),;
									   oBD6:GetValue("BD6_DATPRO"),oBD6:GetValue("BD6_CODOPE"), oBD6:GetValue("BD6_CODRDA"),;
									   oBD6:GetValue("BD6_CODESP"),"",oBD6:GetValue("BD6_CODLOC"),oBD6:GetValue("BD6_LOCAL"),; 
									   oBD6:GetValue("BD6_OPEORI"), oBD6:GetValue("BD6_CODPLA"))

			if len(aDadTab) > 0
				oBD6:LoadValue("BD6_CODTAB",aDadTab[1])
			endif
	
			if len(aDadTab) > 1
				oBD6:LoadValue("BD6_ALIATB", aDadTab[2])
			endif
			
			aAdd(aAuxBD7,{;
				oBD6:GetValue("BD6_VLPGMA"),;	
				oBD6:GetValue("BD6_CODPAD"),;	
				oBD6:GetValue("BD6_CODPRO"),;	
				oBD6:GetValue("BD6_CODTAB"),;	
			 	oBD6:GetValue("BD6_CODOPE"),;	
			 	oBD6:GetValue("BD6_CODRDA"),;	
			 	oBD6:GetValue("BD6_REGEXE"),;	
			 	oBD6:GetValue("BD6_SIGEXE"),;	
				oBD6:GetValue("BD6_ESTEXE"),;	
				oBD6:GetValue("BD6_CDPFRE"),;	
				oBD6:GetValue("BD6_CODESP"),;	
				oBD6:GetValue("BD6_CODLOC"),;	
				oBD6:GetValue("BD6_LOCAL"),;	
				oBD6:GetValue("BD6_SEQUEN"),;	
	          	oBD6:GetValue("BD6_DATPRO")})
	
			aAdd(aBX6, {aAuxBX6, aAuxBD7})
		endIf
    				
	next nI

	if oModel:VldData()
		oModel:CommitData()
		Begin Transaction
					
			//Inclusão da BX6
			for nI := 1 to len(aBX6)
			   nPosCodPad := aScan( aBX6[nI][1], { |x| x[1] == "BD6_CODPAD" } )
			   nPosCodPro := aScan( aBX6[nI][1], { |x| x[1] == "BD6_CODPRO" } )
			   nPosSeqMov := aScan( aBX6[nI][1], { |x| x[1] == "BD6_SEQUEN" } ) 
			   nPosCodDes := aScan( aBX6[nI][1], { |x| x[1] == "BX6_CODDES" } ) 
			   nPosCodUnm := aScan( aBX6[nI][1], { |x| x[1] == "BX6_CODUNM" } )
			   nPosRegAnv := aScan( aBX6[nI][1], { |x| x[1] == "BX6_REGANV" } )
			   nPosAutFun := aScan( aBX6[nI][1], { |x| x[1] == "BX6_AUTFUN" } )
			   			   
				if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0 .and. nPosCodDes)
					BX6->(RecLock("BX6", .T.))
						BX6->BX6_FILIAL := xFilial("BX6")
						BX6->BX6_CODOPE := BD5->BD5_CODOPE
						BX6->BX6_CODLDP := BD5->BD5_CODLDP
						BX6->BX6_CODPEG := BD5->BD5_CODPEG
						BX6->BX6_NUMERO := BD5->BD5_NUMERO
						BX6->BX6_ORIMOV := BD5->BD5_ORIMOV
						BX6->BX6_SEQUEN := aBX6[nI][1][nPosSeqMov][2]
						BX6->BX6_CODPAD := aBX6[nI][1][nPosCodPad][2]
						BX6->BX6_CODPRO := aBX6[nI][1][nPosCodPro][2]
						BX6->BX6_CODDES := aBX6[nI][1][nPosCodDes][2]
						BX6->BX6_CODUNM := aBX6[nI][1][nPosCodUnm][2]
						BX6->BX6_REGANV := aBX6[nI][1][nPosRegAnv][2]
						BX6->BX6_AUTFUN := aBX6[nI][1][nPosAutFun][2]
						BX6->BX6_AODESP := .T.				
					BX6->(MsUnlock())
					BD6->(DbSetOrder(1))
					BD6->(msSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+aBX6[nI][1][nPosSeqMov][2]+aBX6[nI][1][nPosCodPad][2]+aBX6[nI][1][nPosCodPro][2]))
					
					PLS720IBD7({},aBX6[nI][2][1][1],aBX6[nI][2][1][2],aBX6[nI][2][1][3],aBX6[nI][2][1][4],;
			  									       aBX6[nI][2][1][5],aBX6[nI][2][1][6],aBX6[nI][2][1][7],aBX6[nI][2][1][8],;
												       aBX6[nI][2][1][9],aBX6[nI][2][1][10],aBX6[nI][2][1][11],;
												       aBX6[nI][2][1][12]+aBX6[nI][2][1][13],"1", aBX6[nI][2][1][14],;
	                     						       cOriMov,BD5->BD5_TIPGUI,aBX6[nI][2][1][15],,,,,,,,,{},,.F.)
	                     						       
				endIf
								
			next nI
			
			BX6->(DbSetOrder(1))
			BD7->(DbSetOrder(1))
			for nI := 1 to Len(aKeyDel)
			
				if(BX6->(msSeek(xFilial("BX6")+aKeyDel[nI])))
					BX6->(Reclock("BX6",.F.))
						BX6->(DbDelete())
					BX6->(MsUnlock())
				endIf
				
				If BD7->(MsSeek(xFilial("BD7")+aKeyDel[nI]))
					While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
						xFilial("BD7")+aKeyDel[nI]      
				                                        
						BD7->(Reclock("BD7",.F.))
							BD7->(DbDelete())
						BD7->(MsUnlock())
						
						BD7->(DbSkip())
					EndDo	
				EndIf  
				
			next nI
			
			//Edição da BX6 quando o item for editado
			BX6->(DbSetOrder(1))
			for nI := 1 to Len(aObEditBX6)
				if(BX6->(msSeek(xFilial("BX6")+aObEditBX6[nI][1]))) .and. len(aObEditBX6[1][2]) > 0
					
					BX6->(Reclock("BX6",.F.))										
					
					for nX := 1 to len(aObEditBX6[1][2])
						&("BX6->" + aObEditBX6[1][2][nX][1] ) := aObEditBX6[1][2][nX][2]
					next nX
					
					BX6->(MsUnlock())		
				endIf
			next nI
			
		End Transaction
		
		If lRetMudFase

			BCI->(DbSetOrder(1)) 
			If BCI->( MsSeek(xFilial("BCI")+ BD5->BD5_CODOPE + BD5->BD5_CODLDP + BD5->BD5_CODPEG) )
				nRecnoBCI := BCI->(RECNO())
			EndIf			
			aCriticas := PLSMFMTOF("BD5", nRecGuiRef, "", nRecnoBCI, "C", BD5->BD5_CODRDA)
			
			if (len(aCriticas) > 0)
				lRet := aCriticas[1]
			endif
			
		EndIf
		
	else	
		lRet := .F.	
		VarInfo("",oModel:GetErrorMessage())	
	endif
	
	oModel:DeActivate()

return ({lRet, aCriticas})

//-------------------------------------------------------------------
/*/{Protheus.doc} copyIteOutDes
Método para copiar os itens da outras despesas com a BD5 posicionada
@author Karine Riquena Limp
@since 08/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method copyIteOutDes(oBD6, oBD5) class CO_Guia
Local cGrpEmpInt := GetNewPar("MV_PLSGEIN","0050")
	if Empty(oBD5)
		oBD6:LoadValue("BD6_CODESP", BD5->BD5_CODESP )
		oBD6:LoadValue("BD6_NRAOPE", BD5->BD5_NRAOPE )				
		oBD6:LoadValue("BD6_CODOPE", BD5->BD5_CODOPE )
		oBD6:LoadValue("BD6_CODLDP", BD5->BD5_CODLDP )
		oBD6:LoadValue("BD6_CODPEG", BD5->BD5_CODPEG )
		oBD6:LoadValue("BD6_NUMERO", BD5->BD5_NUMERO ) 	
		oBD6:LoadValue("BD6_ESPSOL", BD5->BD5_ESPSOL )
		oBD6:LoadValue("BD6_ESTSOL", BD5->BD5_ESTSOL )
		oBD6:LoadValue("BD6_SIGLA" , BD5->BD5_SIGLA  )
		oBD6:LoadValue("BD6_REGSOL", BD5->BD5_REGSOL )
		oBD6:LoadValue("BD6_NOMSOL", BD5->BD5_NOMSOL ) 
		oBD6:LoadValue("BD6_CDPFSO", BD5->BD5_CDPFSO )
		oBD6:LoadValue("BD6_ESPEXE", BD5->BD5_ESPEXE )
		oBD6:LoadValue("BD6_ESTEXE", BD5->BD5_ESTEXE )
		oBD6:LoadValue("BD6_SIGEXE", BD5->BD5_SIGEXE )
		oBD6:LoadValue("BD6_REGEXE", BD5->BD5_REGEXE )
		oBD6:LoadValue("BD6_CDPFRE", BD5->BD5_CDPFRE )
		oBD6:LoadValue("BD6_OPEEXE", BD5->BD5_OPEEXE )	
		oBD6:LoadValue("BD6_CODRDA", BD5->BD5_CODRDA )
		oBD6:LoadValue("BD6_NOMRDA", left(BD5->BD5_NOMRDA, TamSx3("BD6_NOMRDA")[1])) //BD5->BD5_NOMRDA )
		oBD6:LoadValue("BD6_TIPRDA", BD5->BD5_TIPRDA )
		oBD6:LoadValue("BD6_CODLOC", BD5->BD5_CODLOC )
		oBD6:LoadValue("BD6_LOCAL" , BD5->BD5_LOCAL  )
		oBD6:LoadValue("BD6_CPFRDA", BD5->BD5_CPFRDA )
		oBD6:LoadValue("BD6_DESLOC", BD5->BD5_DESLOC )
		oBD6:LoadValue("BD6_ENDLOC", BD5->BD5_ENDLOC )
		oBD6:LoadValue("BD6_OPEUSR", BD5->BD5_OPEUSR )
		oBD6:LoadValue("BD6_MATANT", BD5->BD5_MATANT )
		oBD6:LoadValue("BD6_NOMUSR", BD5->BD5_NOMUSR )
		oBD6:LoadValue("BD6_CODEMP", BD5->BD5_CODEMP )
		oBD6:LoadValue("BD6_MATRIC", BD5->BD5_MATRIC )
		oBD6:LoadValue("BD6_TIPREG", BD5->BD5_TIPREG )
		oBD6:LoadValue("BD6_IDUSR" , BD5->BD5_IDUSR  )
		oBD6:LoadValue("BD6_DATNAS", BD5->BD5_DATNAS )
		oBD6:LoadValue("BD6_DIGITO", BD5->BD5_DIGITO )
		oBD6:LoadValue("BD6_CONEMP", BD5->BD5_CONEMP )
		oBD6:LoadValue("BD6_VERCON", BD5->BD5_VERCON )
		oBD6:LoadValue("BD6_SUBCON", BD5->BD5_SUBCON )
		oBD6:LoadValue("BD6_VERSUB", BD5->BD5_VERSUB )
		oBD6:LoadValue("BD6_MATVID", BD5->BD5_MATVID )
		oBD6:LoadValue("BD6_FASE"  , BD5->BD5_FASE   )
		oBD6:LoadValue("BD6_SITUAC", BD5->BD5_SITUAC )
		oBD6:LoadValue("BD6_NUMIMP", BD5->BD5_NUMIMP )
		oBD6:LoadValue("BD6_LOTGUI", BD5->BD5_LOTGUI )
		oBD6:LoadValue("BD6_TIPGUI", BD5->BD5_TIPGUI )
		oBD6:LoadValue("BD6_GUIORI", BD5->BD5_GUIORI )
		oBD6:LoadValue("BD6_DTDIGI", BD5->BD5_DTDIGI )
		oBD6:LoadValue("BD6_MESPAG", BD5->BD5_MESPAG )
		oBD6:LoadValue("BD6_ANOPAG", BD5->BD5_ANOPAG )
		oBD6:LoadValue("BD6_MATUSA", BD5->BD5_MATUSA )
		oBD6:LoadValue("BD6_PACOTE", BD5->BD5_PACOTE )
		oBD6:LoadValue("BD6_ORIMOV", BD5->BD5_ORIMOV )
		oBD6:LoadValue("BD6_GUIACO", BD5->BD5_GUIACO )
		oBD6:LoadValue("BD6_LIBERA", BD5->BD5_LIBERA )
		oBD6:LoadValue("BD6_RGIMP" , BD5->BD5_RGIMP  )
		oBD6:LoadValue("BD6_TPGRV" , BD5->BD5_TPGRV  )
		oBD6:LoadValue("BD6_CID"   , BD5->BD5_CID    )
		oBD6:LoadValue("BD6_TIPCON", BD5->BD5_TIPCON ) 
		oBD6:LoadValue("BD6_NRLBOR", BD5->BD5_NRLBOR )
		oBD6:LoadValue("BD6_INTERC", If(BA3->BA3_CODEMP==cGrpEmpInt,"1","0") )
		oBD6:LoadValue("BD6_TIPUSR", BA3->BA3_TIPOUS )
		oBD6:LoadValue("BD6_MODCOB", Left(alltrim(BA3->BA3_MODPAG), TamSx3("BD6_MODCOB")[1])) 
		oBD6:LoadValue("BD6_CODPLA", BA3->BA3_CODPLA )
		oBD6:LoadValue("BD6_OPEORI", BA1->BA1_OPEORI )
	Else
		oBD6:LoadValue("BD6_CODESP", oBD5:getValue("BD5_CODESP"))
		oBD6:LoadValue("BD6_NRAOPE", oBD5:getValue("BD5_NRAOPE"))				
		oBD6:LoadValue("BD6_CODOPE", oBD5:getValue("BD5_CODOPE"))
		oBD6:LoadValue("BD6_CODLDP", oBD5:getValue("BD5_CODLDP"))
		oBD6:LoadValue("BD6_CODPEG", oBD5:getValue("BD5_CODPEG"))
		oBD6:LoadValue("BD6_NUMERO", oBD5:getValue("BD5_NUMERO")) 	
		oBD6:LoadValue("BD6_ESPSOL", oBD5:getValue("BD5_ESPSOL"))
		oBD6:LoadValue("BD6_ESTSOL", oBD5:getValue("BD5_ESTSOL"))
		oBD6:LoadValue("BD6_SIGLA" , oBD5:getValue("BD5_SIGLA"))
		oBD6:LoadValue("BD6_REGSOL", oBD5:getValue("BD5_REGSOL"))
		oBD6:LoadValue("BD6_NOMSOL", oBD5:getValue("BD5_NOMSOL")) 
		oBD6:LoadValue("BD6_CDPFSO", oBD5:getValue("BD5_CDPFSO"))
		oBD6:LoadValue("BD6_ESPEXE", oBD5:getValue("BD5_ESPEXE"))
		oBD6:LoadValue("BD6_ESTEXE", oBD5:getValue("BD5_ESTEXE"))
		oBD6:LoadValue("BD6_SIGEXE", oBD5:getValue("BD5_SIGEXE"))
		oBD6:LoadValue("BD6_REGEXE", oBD5:getValue("BD5_REGEXE"))
		oBD6:LoadValue("BD6_CDPFRE", oBD5:getValue("BD5_CDPFRE"))
		oBD6:LoadValue("BD6_OPEEXE", oBD5:getValue("BD5_OPEEXE"))	
		oBD6:LoadValue("BD6_CODRDA", oBD5:getValue("BD5_CODRDA"))
		oBD6:LoadValue("BD6_NOMRDA", left(oBD5:getValue("BD5_NOMRDA"), TamSx3("BD6_NOMRDA")[1])) //oBD5:getValue("BD5_NOMRDA"))
		oBD6:LoadValue("BD6_TIPRDA", oBD5:getValue("BD5_TIPRDA"))
		oBD6:LoadValue("BD6_CODLOC", oBD5:getValue("BD5_CODLOC"))
		oBD6:LoadValue("BD6_LOCAL" , oBD5:getValue("BD5_LOCAL"))
		oBD6:LoadValue("BD6_CPFRDA", oBD5:getValue("BD5_CPFRDA"))
		oBD6:LoadValue("BD6_DESLOC", oBD5:getValue("BD5_DESLOC"))
		oBD6:LoadValue("BD6_ENDLOC", oBD5:getValue("BD5_ENDLOC"))
		oBD6:LoadValue("BD6_OPEUSR", oBD5:getValue("BD5_OPEUSR"))
		oBD6:LoadValue("BD6_MATANT", oBD5:getValue("BD5_MATANT"))
		oBD6:LoadValue("BD6_NOMUSR", oBD5:getValue("BD5_NOMUSR"))
		oBD6:LoadValue("BD6_CODEMP", oBD5:getValue("BD5_CODEMP"))
		oBD6:LoadValue("BD6_MATRIC", oBD5:getValue("BD5_MATRIC"))
		oBD6:LoadValue("BD6_TIPREG", oBD5:getValue("BD5_TIPREG"))
		oBD6:LoadValue("BD6_IDUSR" , oBD5:getValue("BD5_IDUSR"))
		oBD6:LoadValue("BD6_DATNAS", oBD5:getValue("BD5_DATNAS"))
		oBD6:LoadValue("BD6_DIGITO", oBD5:getValue("BD5_DIGITO"))
		oBD6:LoadValue("BD6_CONEMP", oBD5:getValue("BD5_CONEMP"))
		oBD6:LoadValue("BD6_VERCON", oBD5:getValue("BD5_VERCON"))
		oBD6:LoadValue("BD6_SUBCON", oBD5:getValue("BD5_SUBCON"))
		oBD6:LoadValue("BD6_VERSUB", oBD5:getValue("BD5_VERSUB"))
		oBD6:LoadValue("BD6_MATVID", oBD5:getValue("BD5_MATVID"))
		oBD6:LoadValue("BD6_FASE"  , oBD5:getValue("BD5_FASE"))
		oBD6:LoadValue("BD6_SITUAC", oBD5:getValue("BD5_SITUAC"))
		oBD6:LoadValue("BD6_NUMIMP", oBD5:getValue("BD5_NUMIMP"))
		oBD6:LoadValue("BD6_LOTGUI", oBD5:getValue("BD5_LOTGUI"))
		oBD6:LoadValue("BD6_TIPGUI", oBD5:getValue("BD5_TIPGUI"))
		oBD6:LoadValue("BD6_GUIORI", oBD5:getValue("BD5_GUIORI"))
		oBD6:LoadValue("BD6_DTDIGI", oBD5:getValue("BD5_DTDIGI"))
		oBD6:LoadValue("BD6_MESPAG", oBD5:getValue("BD5_MESPAG"))
		oBD6:LoadValue("BD6_ANOPAG", oBD5:getValue("BD5_ANOPAG"))
		oBD6:LoadValue("BD6_MATUSA", oBD5:getValue("BD5_MATUSA"))
		oBD6:LoadValue("BD6_PACOTE", oBD5:getValue("BD5_PACOTE"))
		oBD6:LoadValue("BD6_ORIMOV", oBD5:getValue("BD5_ORIMOV"))
		oBD6:LoadValue("BD6_GUIACO", oBD5:getValue("BD5_GUIACO"))
		oBD6:LoadValue("BD6_LIBERA", oBD5:getValue("BD5_LIBERA"))
		oBD6:LoadValue("BD6_RGIMP" , oBD5:getValue("BD5_RGIMP"))
		oBD6:LoadValue("BD6_TPGRV" , oBD5:getValue("BD5_TPGRV"))
		oBD6:LoadValue("BD6_CID"   , oBD5:getValue("BD5_CID"))
		oBD6:LoadValue("BD6_TIPCON", oBD5:getValue("BD5_TIPCON")) 
		oBD6:LoadValue("BD6_NRLBOR", oBD5:getValue("BD5_NRLBOR"))
	EndIf	
return

//-------------------------------------------------------------------
/*/{Protheus.doc} grvAltOdon
Metodo para gravação de alteração das guias odontologicas

@author Rodrigo Morgon
@since 11/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method grvAltOdon(cRecno, aCamposCabec, aAddItem, aEditItem, aDelItem) class CO_Guia

	local oModel := FWLoadModel("PLBD5MODEL")
	local oBD5 := oModel:GetModel("BD5Cab")
	local oBD6 := oModel:GetModel("BD6Proc")
	local nFor
	local lRet := .T.
	local oObjBoGuia := BO_Guia():New()
	local nI := 1
	local nJ := 1
	local nW := 1
	local nPosCodPad := 0
	local nPosCodPro := 0
	local nPosSeqMov := 0
	local nPosDentReg := 0
	local nPosFace := 0
	local aAuxBD7 := {}
	local aPartic := {}
	local aKeyDel := {}
	local aDadTab := {}
	local cSql		:= ""
	local cSeq		:= ""
	local oBO_Guia       := BO_Guia():New()
	local aItens 	:= {}
	local cCodPro
	local cCodPad
	local cSequen
	local cOriMov := ""
	
	//Posiciona na BD5, caso ainda não esteja posicionado.
	if(cRecno != BD5->(recno()))
		BD5->(DbGoTo(cRecno))
	endif

	cOriMov := BD5->BD5_ORIMOV

	//Define a opção 4 para o model - alteração
	oModel:SetOperation(4)
	
	//Ativa o modelo
	oModel:Activate()
	
	//Para cada campo do cabecalho, carrega o valor na BD5
	for nFor := 1 to len(aCamposCabec)
		oBD5:LoadValue(aCamposCabec[nFor][1],aCamposCabec[nFor][2])
	next

	//------------------------------------------------
	//Faço primeiro a edição e deleção dos itens para percorrer uma model de bd6 menor
	//------------------------------------------------
	for nI := 1 to len(aDelItem)
	    //pego a chave do procedimento
		nPosCodPad 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPAD" } )
		nPosCodPro 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPRO" } )
		nPosDentReg	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_DENREG" } )
		nPosFace	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_FADENT" } )
		nPosSeqMov 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_SEQUEN" } ) 		
					
		if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0)		
			for nJ := 1 to oBD6:Length()					
				oBD6:GoLine( nJ ) 				
				if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aDelItem[nI][nPosCodPad][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aDelItem[nI][nPosCodPro][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_DENREG")) == alltrim(aDelItem[nI][nPosDentReg][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_FADENT")) == alltrim(aDelItem[nI][nPosFace][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aDelItem[nI][nPosSeqMov][2])
					
					oBD6:DeleteLine()
					aAdd(aKeyDel, BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+aDelItem[nI][nPosSeqMov][2])
				endIf				
			next nJ		
		endIf	
	next nI
	
	for nI := 1 to len(aEditItem)
	    //pego a chave do procedimento, que é sempre a primeira posição do item editado
		nPosCodPad 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPAD" } )
		nPosCodPro 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPRO" } )
		nPosDentReg	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_DENREG" } )
		nPosFace	 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_FADENT" } )
		nPosSeqMov 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_SEQUEN" } )
		
		if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosDentReg > 0 .and. nPosFace > 0 .and. nPosSeqMov > 0)		
			for nJ := 1 to oBD6:Length()					
				oBD6:GoLine( nJ )
								
				if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aEditItem[nI][1][nPosCodPad][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aEditItem[nI][1][nPosCodPro][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_DENREG")) == alltrim(aEditItem[nI][1][nPosDentReg][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_FADENT")) == alltrim(aEditItem[nI][1][nPosFace][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aEditItem[nI][1][nPosSeqMov][2]) 
					
					//Preciso saber se o usuário editou o código do procedimento ou a tabela
					//pois nesse caso, é necessário excluir e inserir um novo
					if(aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPAD" } ) > 0 .or. ;
					   aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPRO" } ) > 0)
					
						oBD6:DeleteLine()
						//adiciono no array de addedItems para ser incluido um BD6 novo
						aAdd(aAddItem, aEditItem[nI][2])
						//guardo a chave para excluir a BD7 referenciada
						aAdd(aKeyDel, BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+aEditItem[nI][1][nPosSeqMov][2])
					else 								 
						for nW := 1 to len(aEditItem[nI][2])
							oBD6:LoadValue(aEditItem[nI][2][nW][1], aEditItem[nI][2][nW][2])	
						next nW
						
						self:copyIteOutDes(oBD6,oBD5)
					endIf
				endIf		
				
				if oObjBoGuia:verificaProc(aItens, cCodPad, cCodPro)
					aadd(aItens,  {{ "SEQMOV"	    ,  cSequen},;											
								   { "CODPAD"		,  cCodPad},;
								   { "CODPRO"		,  cCodPro},;
								   { "DESCRI"		, .F. 		 },;
								   { "QTD"		, oBD6:GetValue("BD6_QTDPRO") },;
								   { "QTDAUT"		, oBD6:GetValue("BD6_QTDAPR") },;
								   { "DENTE"		, oBD6:GetValue("BD6_DENREG") },;
								   { "FACE"		, oBD6:GetValue("BD6_FADENT") },;
								   { "STPROC"		, oBD6:GetValue("BD6_STATUS") }})
								   
					aItens[nJ] := WsAutoOpc(aItens[nJ])
				endif			   
														
			next nJ
		endIf
	next nI
	
	for nI := 1 to len(aAddItem)
		if oBD6:length() > 1 .or. !Empty(oBD6:getValue("BD6_CODPRO")) //Se o registro atual da model tiver o procedimento preenchido, adiciona novo.
			oBD6:AddLine()
		endif
		
		aAuxBD7 := {}
		
		for nJ := 1 to len(aAddItem[nI])
			oBD6:LoadValue(aAddItem[nI][nJ][1], aAddItem[nI][nJ][2])
		next nJ
			
    	oBD6:LoadValue("BD6_DESPRO",subStr(oObjBoGuia:getDescProcedimento(oBD6:getValue("BD6_CODPRO"), "",oBD6:getValue("BD6_CODPAD")),1,50))
    	self:copyIteOutDes(oBD6,oBD5)
		
		//garanto o sequen correto
		//não considero o D_E_L_E_T_ na query para nao dar problema no X2_UNICO que foi colocado na BD6 
		//para o primeiro item incluido ainda, os demais precisam seguir o primeiro+1
		if(nI == 1)
			cSql := "SELECT MAX(BD6_SEQUEN) AS MAXSEQ FROM " + RetSqlName("BD6") 			
			cSql += " WHERE BD6_FILIAL 	= '" + xFilial("BD6")  + "'"
			cSql += " AND BD6_CODOPE 	= '" + BD5->BD5_CODOPE + "'"
			cSql += " AND BD6_CODLDP 	= '" + BD5->BD5_CODLDP + "'"
			cSql += " AND BD6_CODPEG 	= '" + BD5->BD5_CODPEG + "'"
			cSql += " AND BD6_NUMERO 	= '" + BD5->BD5_NUMERO + "'"
			cSql += " AND BD6_ORIMOV 	= '" + BD5->BD5_ORIMOV + "'"

			cSql := ChangeQuery(cSql)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRBBD6",.T.,.F.)
			
			oBD6:LoadValue("BD6_SEQUEN", iif( TRBBD6->(!EOF()) ,Soma1( TRBBD6->MAXSEQ ), "001"))
			
			TRBBD6->(dbCloseArea())
		else
			cSeq := Soma1( cSeq )
			oBD6:LoadValue("BD6_SEQUEN", cSeq)
		endif
			
		cSeq := oBD6:GetValue("BD6_SEQUEN")
			
		aDadTab := oObjBoGuia:getDadTabela(oBD6:GetValue("BD6_CODPAD"),oBD6:GetValue("BD6_CODPRO"),;
								   oBD6:GetValue("BD6_DATPRO"),oBD6:GetValue("BD6_CODOPE"), oBD6:GetValue("BD6_CODRDA"),;
								   oBD6:GetValue("BD6_CODESP"),"",oBD6:GetValue("BD6_CODLOC"),oBD6:GetValue("BD6_LOCAL"),; 
								   oBD6:GetValue("BD6_OPEORI"), oBD6:GetValue("BD6_CODPLA"))

		if len(aDadTab) > 0
			oBD6:LoadValue("BD6_CODTAB",aDadTab[1])
		endif
	
		if len(aDadTab) > 1
			oBD6:LoadValue("BD6_ALIATB", aDadTab[2])
		endif
			
		aAdd(aAuxBD7,{;
			oBD6:GetValue("BD6_VLPGMA"),;	
			oBD6:GetValue("BD6_CODPAD"),;	
			oBD6:GetValue("BD6_CODPRO"),;	
			oBD6:GetValue("BD6_CODTAB"),;	
		 	oBD6:GetValue("BD6_CODOPE"),;	
		 	oBD6:GetValue("BD6_CODRDA"),;	
		 	oBD6:GetValue("BD6_REGEXE"),;	
		 	oBD6:GetValue("BD6_SIGEXE"),;	
			oBD6:GetValue("BD6_ESTEXE"),;	
			oBD6:GetValue("BD6_CDPFRE"),;	
			oBD6:GetValue("BD6_CODESP"),;	
			oBD6:GetValue("BD6_CODLOC"),;	
			oBD6:GetValue("BD6_LOCAL"),;	
			oBD6:GetValue("BD6_SEQUEN"),;	
	      	oBD6:GetValue("BD6_DATPRO")})	   
			
		if oObjBoGuia:verificaProc(aItens, cCodPad, cCodPro)
			aadd(aItens,  {{ "SEQMOV"	    , oBD6:GetValue("BD6_SEQUEN") },;											
						   { "CODPAD"		, oBD6:GetValue("BD6_CODPAD") },;
						   { "CODPRO"		, oBD6:GetValue("BD6_CODPRO") },;
						   { "DESCRI"		, .F. 		 },;
						   { "QTD"		, oBD6:GetValue("BD6_QTDPRO") },;
						   { "QTDAUT"		, oBD6:GetValue("BD6_QTDAPR") },;
						   { "DENTE"		, oBD6:GetValue("BD6_DENREG") },;
						   { "FACE"		, oBD6:GetValue("BD6_FADENT") },;
						   { "STPROC"		, oBD6:GetValue("BD6_STATUS") }})	
						   
			aItens[nI] := WsAutoOpc(aItens[nI])
		endif    						
	next nI
	
	if len(aItens) > 0 
		oBO_Guia:addExcLib(BD5->(BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_ORIMOV), BD5->BD5_NRLBOR)
		
		oBO_Guia:baixaLib(aItens, "1",BD5->BD5_NRLBOR, .F., .F., BD5->(BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG), BD5->BD5_CODLOC, BD5->BD5_HORPRO, "", "", BD5->BD5_NOMUSR, "2",;
			 BD5->BD5_DATPRO, BD5->BD5_DATNAS, .F., .F., .F., BD5->BD5_OPEMOV, BD5->BD5_CODRDA, BD5->BD5_CODRDA, BD5->BD5_CODLOC, BD5->BD5_CODLOC, BD5->BD5_CODESP,  "",;
			 .F., "", .F., .F., .F., alltrim(str(val(BD5->BD5_TIPGUI))), "", BD5->BD5_CODESP, BD5->BD5_CODESP, .F., .F., .F., BD5->BD5_TIPGUI)
		
	endif

	if oModel:VldData()
		oModel:CommitData()
		Begin Transaction			
			for nI := 1 to len(aAuxBD7)		
					
					PLS720IBD7({},aAuxBD7[nI][1],aAuxBD7[nI][2],aAuxBD7[nI][3],aAuxBD7[nI][4],;
			  									       aAuxBD7[nI][5],aAuxBD7[nI][6],aAuxBD7[nI][7],aAuxBD7[nI][8],;
												       aAuxBD7[nI][9],aAuxBD7[nI][10],aAuxBD7[nI][11],;
												       aAuxBD7[nI][12]+aAuxBD7[nI][13],"1", aAuxBD7[nI][14],;
													cOriMov,BD5->BD5_TIPGUI,aAuxBD7[nI][15],,,,,,,,,{},,.F.)
			next nI
			
			BD7->(DbSetOrder(1))
			for nI := 1 to Len(aKeyDel)			
				If BD7->(MsSeek(xFilial("BD7")+aKeyDel[nI]))
					While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
						xFilial("BD7")+aKeyDel[nI]      
				                                        
						BD7->(Reclock("BD7",.F.))
							BD7->(DbDelete())
						BD7->(MsUnlock())
						
						BD7->(DbSkip())
					EndDo	
				EndIf			
			next nI			
		End Transaction
	else	
		lRet := .F.	
		VarInfo("",oModel:GetErrorMessage())	
	endif
	
	oModel:DeActivate()
	
return IIF(lRet,alltrim(BD5->BD5_CODOPE) + alltrim(BD5->BD5_ANOAUT) + alltrim(BD5->BD5_MESAUT) + alltrim(BD5->BD5_NUMERO),"")

//-------------------------------------------------------------------
/*/{Protheus.doc} grvAltSadt
Metodo para gravação de alteração das guias sadt

@author Karine Riquena Limp
@since 28/08/2016
@version P12
/*/
//-------------------------------------------------------------------
method grvAltSadt(cRecno, aCamposCabec, aAddItem, aEditItem, aDelItem) class CO_Guia

	local oModel := FWLoadModel("PLBD5MODEL")
	local oBD5 := oModel:GetModel("BD5Cab")
	local oBD6 := oModel:GetModel("BD6Proc")
	local nFor
	local lRet := .T.
	local oObjBoGuia := BO_Guia():New()
	local nI := 1
	local nJ := 1
	local nW := 1
	local nPosCodPad := 0
	local nPosCodPro := 0
	local nPosSeqMov := 0
	local nPosDentReg := 0
	local nPosFace := 0
	local aAuxBD7 := {}
	local aPartic := {}
	local aKeyDel := {}
	local aDadTab := {}
	local cSql		:= ""
	local cSeq		:= ""
	local oBO_Guia       := BO_Guia():New()
	local aItens 	:= {}
	local cCodPro
	local cCodPad
	local cSequen
	local cOriMov := ""
	
	//Posiciona na BD5, caso ainda não esteja posicionado.
	if(cRecno != BD5->(recno()))
		BD5->(DbGoTo(cRecno))
	endif

	//Para garantir o local correto de origem por causa das guias
	cOriMov := BD5->BD5_ORIMOV
	
	//Define a opção 4 para o model - alteração
	oModel:SetOperation(4)
	
	//Ativa o modelo
	oModel:Activate()
	
	//Para cada campo do cabecalho, carrega o valor na BD5
	for nFor := 1 to len(aCamposCabec)
		if(valtype(aCamposCabec[nFor][2]) == "C")
			aCamposCabec[nFor][2] := left(alltrim(aCamposCabec[nFor][2]), TamSx3(aCamposCabec[nFor][1])[1])
		endIf
		oBD5:LoadValue(aCamposCabec[nFor][1],aCamposCabec[nFor][2])
	next

	//------------------------------------------------
	//Faço primeiro a edição e deleção dos itens para percorrer uma model de bd6 menor
	//------------------------------------------------
	for nI := 1 to len(aDelItem)
	    //pego a chave do procedimento
		nPosCodPad 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPAD" } )
		nPosCodPro 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPRO" } )
		nPosSeqMov 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_SEQUEN" } ) 		
					
		if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0)		
			for nJ := 1 to oBD6:Length()					
				oBD6:GoLine( nJ ) 				
				if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aDelItem[nI][nPosCodPad][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aDelItem[nI][nPosCodPro][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aDelItem[nI][nPosSeqMov][2])
					
					oBD6:DeleteLine()
					aAdd(aKeyDel, BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+aDelItem[nI][nPosSeqMov][2])
				endIf				
			next nJ		
		endIf	
	next nI
	
	for nI := 1 to len(aEditItem)
	    //pego a chave do procedimento, que é sempre a primeira posição do item editado
		nPosCodPad 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPAD" } )
		nPosCodPro 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPRO" } )
		nPosSeqMov 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_SEQUEN" } )
		
		if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0)		
			for nJ := 1 to oBD6:Length()					
				oBD6:GoLine( nJ )
								
				if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aEditItem[nI][1][nPosCodPad][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aEditItem[nI][1][nPosCodPro][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aEditItem[nI][1][nPosSeqMov][2]) 
					
					cCodPro := oBD6:GetValue("BD6_CODPRO")
					cCodPad := oBD6:GetValue("BD6_CODPAD")
					cSequen := oBD6:GetValue("BD6_SEQUEN")
					//Preciso saber se o usuário editou o código do procedimento ou a tabela
					//pois nesse caso, é necessário excluir e inserir um novo
					if(aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPAD" } ) > 0 .or. ;
					   aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPRO" } ) > 0)
										
					    nPosCodPad2 	:= aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPAD" } )
					    nPosCodPro2 	:= aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPRO" } )
					    //nPosSeqMov2 	:= aScan( aEditItem[nI][2], { |x| x[1] == "BD6_SEQUEN" } )
		
					    cCodPro := aEditItem[nI][2][nPosCodPro2][2]
					    cCodPad := aEditItem[nI][2][nPosCodPad2][2]
					    //cSequen := aEditItem[nI][2][nPosSeqMov2][2]

						oBD6:DeleteLine()
						//adiciono no array de addedItems para ser incluido um BD6 novo
						aAdd(aAddItem, aEditItem[nI][2])
						//guardo a chave para excluir a BD7 referenciada
						aAdd(aKeyDel, BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+aEditItem[nI][1][nPosSeqMov][2])
					else 								 
						for nW := 1 to len(aEditItem[nI][2])
							if aEditItem[nI][2][nW][1] <> "TELA_SEQ"
								oBD6:LoadValue(aEditItem[nI][2][nW][1], aEditItem[nI][2][nW][2])
							endif	
						next nW
						
						self:copyIteOutDes(oBD6,oBD5)
					endIf
				endIf	

				if oObjBoGuia:verificaProc(aItens, cCodPad, cCodPro)
					aadd(aItens,  {{ "SEQMOV"	    ,  cSequen},;											
								   { "CODPAD"		,  cCodPad},;
								   { "CODPRO"		,  cCodPro},;
								   { "DESCRI"		, .F. 		 },;
								   { "QTD"		, oBD6:GetValue("BD6_QTDPRO") },;
								   { "QTDAUT"		, oBD6:GetValue("BD6_QTDAPR") },;
								   { "DENTE"		, oBD6:GetValue("BD6_DENREG") },;
								   { "FACE"		, oBD6:GetValue("BD6_FADENT") },;
								   { "STPROC"		, oBD6:GetValue("BD6_STATUS") }})
								   
					aItens[nJ] := WsAutoOpc(aItens[nJ])
				endif			   
										
			next nJ
		endIf
	next nI
	
	//Isso é uma solução temporária!!
	//Os valores dos campos abaixo estão chegando em branco na gravação, o que faz dar a crítica 540 (erro controlado)
	//Estamos pegando os alores do primeiro procediemento (que sempre vai existir na alteração) para replicar nos registros que forem adicionados
	//quando encontrarmos um lugar melhor para aplicar esse tratamento, remover ele daqui
	nBkpLinZZ	:= oBD6:GetLine()
	oBD6:GoLine(1)
	aBkpZZZ :=	{oBD6:GetValue("BD6_INTERC"), oBD6:getValue("BD6_TIPUSR"), oBD6:getValue("BD6_MODCOB"), oBD6:getValue("BD6_CODPLA"), oBD6:getValue("BD6_OPEORI")}	
	oBD6:GoLine(nBkpLinZZ)
	//Fim da solução temporária
	
	aAuxBD7 := {}
	
	for nI := 1 to len(aAddItem)
		if oBD6:length() > 1 .or. !Empty(oBD6:getValue("BD6_CODPRO")) //Se o registro atual da model tiver o procedimento preenchido, adiciona novo.
			oBD6:AddLine()
		endif
		
		for nJ := 1 to len(aAddItem[nI])
			if aAddItem[nI][nJ][1] <> "TELA_SEQ"
				oBD6:LoadValue(aAddItem[nI][nJ][1], aAddItem[nI][nJ][2])
			endif
		next nJ
			
    	oBD6:LoadValue("BD6_DESPRO",subStr(oObjBoGuia:getDescProcedimento(oBD6:getValue("BD6_CODPRO"), "",oBD6:getValue("BD6_CODPAD")),1,50))
    	
    	self:copyIteOutDes(oBD6,oBD5)
		
		//garanto o sequen correto
		//não considero o D_E_L_E_T_ na query para nao dar problema no X2_UNICO que foi colocado na BD6 
		//para o primeiro item incluido ainda, os demais precisam seguir o primeiro+1
		if(nI == 1)
			cSql := "SELECT MAX(BD6_SEQUEN) AS MAXSEQ FROM " + RetSqlName("BD6") 
			cSql += " WHERE BD6_FILIAL 	= '" + xFilial("BD6")  + "'"
			cSql += " AND BD6_CODOPE 	= '" + BD5->BD5_CODOPE + "'"
			cSql += " AND BD6_CODLDP 	= '" + BD5->BD5_CODLDP + "'"
			cSql += " AND BD6_CODPEG 	= '" + BD5->BD5_CODPEG + "'"
			cSql += " AND BD6_NUMERO 	= '" + BD5->BD5_NUMERO + "'"
			cSql += " AND BD6_ORIMOV 	= '" + BD5->BD5_ORIMOV + "'"
			
			cSql := ChangeQuery(cSql)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRBBD6",.T.,.F.)
			
			oBD6:LoadValue("BD6_SEQUEN", iif( TRBBD6->(!EOF()) ,Soma1( TRBBD6->MAXSEQ ), "001"))
			
			TRBBD6->(dbCloseArea())
		else
			cSeq := Soma1( cSeq )
			oBD6:LoadValue("BD6_SEQUEN", cSeq)
		endif
			
		cSeq := oBD6:GetValue("BD6_SEQUEN")
			
		aDadTab := oObjBoGuia:getDadTabela(oBD6:GetValue("BD6_CODPAD"),oBD6:GetValue("BD6_CODPRO"),;
								   oBD6:GetValue("BD6_DATPRO"),oBD6:GetValue("BD6_CODOPE"), oBD6:GetValue("BD6_CODRDA"),;
								   oBD6:GetValue("BD6_CODESP"),"",oBD6:GetValue("BD6_CODLOC"),oBD6:GetValue("BD6_LOCAL"),; 
								   oBD6:GetValue("BD6_OPEORI"), oBD6:GetValue("BD6_CODPLA"))

		if len(aDadTab) > 0
			oBD6:LoadValue("BD6_CODTAB",aDadTab[1])
		endif
	
		if len(aDadTab) > 1
			oBD6:LoadValue("BD6_ALIATB", aDadTab[2])
		endif
			
		aAdd(aAuxBD7,{;
			oBD6:GetValue("BD6_VLPGMA"),;	
			oBD6:GetValue("BD6_CODPAD"),;	
			oBD6:GetValue("BD6_CODPRO"),;	
			oBD6:GetValue("BD6_CODTAB"),;	
		 	oBD6:GetValue("BD6_CODOPE"),;	
		 	oBD6:GetValue("BD6_CODRDA"),;	
		 	oBD6:GetValue("BD6_REGEXE"),;	
		 	oBD6:GetValue("BD6_SIGEXE"),;	
			oBD6:GetValue("BD6_ESTEXE"),;	
			oBD6:GetValue("BD6_CDPFRE"),;	
			oBD6:GetValue("BD6_CODESP"),;	
			oBD6:GetValue("BD6_CODLOC"),;	
			oBD6:GetValue("BD6_LOCAL"),;	
			oBD6:GetValue("BD6_SEQUEN"),;	
	      	oBD6:GetValue("BD6_DATPRO")})	      		
	      	
//	      	if nI > 1
				oBD6:LoadValue("BD6_INTERC", aBkpZZZ[1])
				oBD6:LoadValue("BD6_TIPUSR", aBkpZZZ[2])
				oBD6:LoadValue("BD6_MODCOB", aBkpZZZ[3])
				oBD6:LoadValue("BD6_CODPLA", aBkpZZZ[4])
				oBD6:LoadValue("BD6_OPEORI", aBkpZZZ[5])
//	      	EndIf

			if oObjBoGuia:verificaProc(aItens, cCodPad, cCodPro)
				aadd(aItens,  {{ "SEQMOV"	    , oBD6:GetValue("BD6_SEQUEN") },;											
							   { "CODPAD"		, oBD6:GetValue("BD6_CODPAD") },;
							   { "CODPRO"		, oBD6:GetValue("BD6_CODPRO") },;
							   { "DESCRI"		, .F. 		 },;
							   { "QTD"		, oBD6:GetValue("BD6_QTDPRO") },;
							   { "QTDAUT"		, oBD6:GetValue("BD6_QTDAPR") },;
							   { "DENTE"		, oBD6:GetValue("BD6_DENREG") },;
							   { "FACE"		, oBD6:GetValue("BD6_FADENT") },;
							   { "STPROC"		, oBD6:GetValue("BD6_STATUS") }})	
							   
			   aItens[nI] := WsAutoOpc(aItens[nI])
			endif					
	next nI
	
		//self:baixaLib(aDados,aItens)
		//Atualiza Quantidade Liberação
	if len(aItens) > 0 
		oBO_Guia:addExcLib(BD5->(BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_ORIMOV), BD5->BD5_NRLBOR)
		
		oBO_Guia:baixaLib(aItens, "1",BD5->BD5_NRLBOR, .F., .F., BD5->(BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG), BD5->BD5_CODLOC, BD5->BD5_HORPRO, "", "", BD5->BD5_NOMUSR, "2",;
			 BD5->BD5_DATPRO, BD5->BD5_DATNAS, .F., .F., .F., BD5->BD5_OPEMOV, BD5->BD5_CODRDA, BD5->BD5_CODRDA, BD5->BD5_CODLOC, BD5->BD5_CODLOC, BD5->BD5_CODESP,  "",;
			 .F., "", .F., .F., .F., alltrim(str(val(BD5->BD5_TIPGUI))), "", BD5->BD5_CODESP, BD5->BD5_CODESP, .F., .F., .F., BD5->BD5_TIPGUI)
		
	endif

	if oModel:VldData()
		oModel:CommitData()
		Begin Transaction			
			for nI := 1 to len(aAuxBD7)		
				
				//seekar por cada item da bd6
				BD6->(DbSetOrder(1))
				if BD6->(msSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+aAuxBD7[nI][14]+aAuxBD7[nI][2]+aAuxBD7[nI][3]))							
					PLS720IBD7({},aAuxBD7[nI][1],aAuxBD7[nI][2],aAuxBD7[nI][3],aAuxBD7[nI][4],;
							       aAuxBD7[nI][5],aAuxBD7[nI][6],aAuxBD7[nI][7],aAuxBD7[nI][8],;
							       aAuxBD7[nI][9],aAuxBD7[nI][10],aAuxBD7[nI][11],;
							       aAuxBD7[nI][12]+aAuxBD7[nI][13],"1", aAuxBD7[nI][14],;
	     						  	cOriMov,BD5->BD5_TIPGUI,aAuxBD7[nI][15],,,,,,,,,{},,.F.)
	     		endif				  	
			next nI
			
			BD7->(DbSetOrder(1))
			for nI := 1 to Len(aKeyDel)			
				If BD7->(MsSeek(xFilial("BD7")+aKeyDel[nI]))
					While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
						xFilial("BD7")+aKeyDel[nI]      
				                                        
						BD7->(Reclock("BD7",.F.))
							BD7->(DbDelete())
						BD7->(MsUnlock())
						
						BD7->(DbSkip())
					EndDo	
				EndIf			
			next nI			
		End Transaction
	else	
		lRet := .F.	
		VarInfo("",oModel:GetErrorMessage())	
	endif
	
	oModel:DeActivate()
	
return IIF(lRet,alltrim(BD5->BD5_CODOPE) + "." + alltrim(BD5->BD5_ANOAUT) + "." + alltrim(BD5->BD5_MESAUT) + "-" + alltrim(BD5->BD5_NUMAUT),"")


//-------------------------------------------------------------------
/*/{Protheus.doc} cntProced
Metodo para contar quantidade de guias

@author Renan Martins
@since 04/2017
@version P12
/*/
//-------------------------------------------------------------------
method cntProced (cChave, cTpBusca) class CO_Guia
Local cSql 		:= ""
Local nQtdProc	:= 0
Local lPosic		:= .F.

Default cTpBusca	:= "0"  //Recno

//Posiciona na BD5, caso ainda não esteja posicionado.
If (cTpBusca == "0")
	if(cChave != BD5->(recno()))
		BD5->(DbGoTo(cRecno))
	endif
Else
	BD5->(DbSetOrder(17))//BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_SITUAC + BD5_FASE + dtos(BD5_DATPRO) + BD5_OPERDA + BD5_CODRDA
	If BD5->(DbSeek(xFilial("BD5")+cChave))	
		lPosic := .T.
	EndIf
EndIf

//Query para contar quantos procedimentos tenho para a guia em questão, para saber se iremos usar a Multithread ou não na MF
cSql := "SELECT COUNT(*) AS QTD FROM " + RetSqlName("BD6") 
cSql += " WHERE BD6_FILIAL 	= '" + xFilial("BD6")  + "'"
cSql += " AND BD6_CODOPE 	= '" + BD5->BD5_CODOPE + "'"
cSql += " AND BD6_CODLDP 	= '" + BD5->BD5_CODLDP + "'"
cSql += " AND BD6_CODPEG 	= '" + BD5->BD5_CODPEG + "'"
cSql += " AND BD6_NUMERO 	= '" + BD5->BD5_NUMERO + "'"
cSql += " AND BD6_ORIMOV 	= '" + BD5->BD5_ORIMOV + "'"

cSql := ChangeQuery(cSql)	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"QtdProc",.T.,.F.)

nQtdProc :=  QtdProc->QTD 

QtdProc->(dbCloseArea())

Return nQtdProc


//-------------------------------------------------------------------
/*/{Protheus.doc} CO_Guia
Somente para compilar a classe
@author Karine Riquena Limp
@since 25/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function CO_Guia
Return
