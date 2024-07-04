#Include "Protheus.ch"
#Include 'FWMVCDef.ch'
#Include "XMLXFUN.CH"

Static aRtByIBGE:= {}
Static nSelItem := 0

//-----------------------------------------------------------------
/*/{Protheus.doc} RepGetRot()
Consulta Roteiro da REPOM
Metodo utilizado GetRtByIBGE()  
@param      cCodRota,cCdrOri,aRotPerc01
@author     Katia
@since      22/10/2020
@version    1.0
/*/
//-----------------------------------------------------------------
Function RepGetRot(cCodRota,cCdrOri,aRotPerc01,lF3)
Local lRet		  := .T.
Local aBtn        := {}
Local cLbx        := ''
Local cEstOri   := CriaVar( "CC2_EST", .T. )
Local cEstDes   := CriaVar( "CC2_EST", .T. )
Local cCdMunOri := CriaVar( "CC2_CODMUN", .T. )
Local cCdMunDes := CriaVar( "CC2_CODMUN", .T. )
Local cMunOri   := CriaVar( "CC2_MUN", .T. )
Local cMunDes   := CriaVar( "CC2_MUN", .T. )
Local nAT       := 0
Local aArea     := GetArea()

Private oDlgDsc
Private oLbxEsp
Private oValDco
Private oPerDco

Default cCodRota:= ""
Default cCdrOri := ""
Default aRotPerc01:= {}
Default lF3       := .F.

TMSRSetSt('aRtByIBGE',{})   
TMSRSetSt('nSelItem',nAT)

	AAdd(aBtn,{'ROTEI',{||RepSolicRt( cCodRota,  , , , cEstOri, cCdMunOri, cEstDes, cCdMunDes ) }, 'Incluir Roteiro' , 'Incluir Roteiro' }) //'Atualiza a composicao de frete...'

    AAdd(aRotPerc01, {'','','',''})
	//-- Inicializa Região de Origem
	If !Empty(cCdrOri)
		cEstOri   := Posicione( "DUY", 1, xFilial("DUY") + cCdrOri, "DUY_EST" )
		cCdMunOri := Posicione( "DUY", 1, xFilial("DUY") + cCdrOri, "DUY_CODMUN" )
		cMunOri   := cMunOri := Posicione( "CC2", 1, xFilial("CC2") + cEstOri + cCdMunOri, "CC2_MUN" )
	EndIf
	DEFINE MSDIALOG oDlgDsc TITLE 'Consulta Roteiro' FROM 00,00 TO 390, 770 PIXEL    
 	
	@ 35, 05     SAY 'UF' Of oDlgDsc PIXEL  SIZE 010,009 //-- 'UF'
	@ 45, 05     MsGet cEstOri F3 "12" Valid Empty(cEstOri) .OR. ExistCpo("SX5","12"+cEstOri);
											PICTURE PesqPict('CC2','CC2_EST')    SIZE 020,007 OF oDlgDsc PIXEL

	@ 35, 30 SAY 'Origem' Of oDlgDsc PIXEL  SIZE 020,009 //-- 'Origem'
	@ 45, 30 MsGet cCdMunOri F3 "CC2" Valid Eval({|| Iif(Empty(cCdMunOri) .Or. ExistCpo("CC2",cEstOri+cCdMunOri),;
																(cMunOri := Posicione("CC2",1, xFilial("CC2")+cEstOri+cCdMunOri,"CC2_MUN"), .T.),;
																.F.) });
											PICTURE PesqPict('CC2','CC2_CODMUN') SIZE 035,007 OF oDlgDsc PIXEL

	@ 35, 70 SAY 'Des.Origem' Of oDlgDsc PIXEL  SIZE 060,009 //-- 'Des.Origem''
	@ 45, 70 MsGet cMunOri ;
											PICTURE PesqPict('CC2','CC2_MUN') WHEN .F. SIZE 110,007 OF oDlgDsc PIXEL

	@ 35, 195 SAY 'UF' Of oDlgDsc PIXEL  SIZE 010,009 //-- 'UF'
	@ 45, 195 MsGet cEstDes F3 "12" Valid Empty(cEstDes) .Or. ExistCpo("SX5","12"+cEstDes);
											PICTURE PesqPict('CC2','CC2_EST')    SIZE 020,007 OF oDlgDsc PIXEL

	@ 35, 220 SAY 'Destino' Of oDlgDsc PIXEL  SIZE 020,009 //-- 'Destino'
	@ 45, 220 MsGet cCdMunDes F3 "CC2" Valid VldMunDes(cCodRota, cEstOri, cEstDes, cCdMunOri, cCdMunDes ,@cMunDes,@aRotPerc01) ;
											PICTURE PesqPict('CC2','CC2_CODMUN') SIZE 035,007 OF oDlgDsc PIXEL

	@ 35, 260 SAY 'Des.Destino' Of oDlgDsc PIXEL  SIZE 060,009 //-- 'Des.Destino''
	@ 45, 260 MsGet cMunDes PICTURE PesqPict('CC2','CC2_MUN') WHEN .F. SIZE 110,007 OF oDlgDsc PIXEL

	aListHead:= {'Roteiro','Percurso', 'Nome', 'Distancia'} 
	
	@ 70  , 05   LISTBOX oLbxEsp VAR cLbx FIELDS HEADER "INIT" SIZE 368,120 ON DBLCLICK{nAT:=oLbxEsp:nAT,oDlgDsc:End()} NOSCROLL OF oDlgDsc PIXEL
			
	oLbxEsp:aHeaders := aClone(aListHead)
			
	oLbxEsp:SetArray( aRotPerc01 )
	oLbxEsp:bLine	:= { || {	aRotPerc01[oLbxEsp:nAT,1],;	
								aRotPerc01[oLbxEsp:nAT,2],;
								aRotPerc01[oLbxEsp:nAT,3],;
								aRotPerc01[oLbxEsp:nAT,4] } }
		
				
	ACTIVATE MSDIALOG oDlgDsc CENTERED ON INIT EnchoiceBar(oDlgDsc,{||nAT:=oLbxEsp:nAT, oDlgDsc:End()},{||oDlgDsc:End()},,aBtn)

	If nAT > 1 
		lRet:= .T.
	EndIf

	TMSRSetSt('nSelItem',nAT)

RestArea(aArea)				
Return( lRet )

//----------------------------------------------------------------------------
/*/{Protheus.doc} VldMunDes()
Validação do Municipio de Destino e Chamada do Metodo GetRtByIBGE
@param      cCodRota, cEstOri, cEstDes, cCdMunOri, cCdMunDes,cMunDes,aRotPerc01
@author     Katia
@since      22/10/2020
@version    1.0
/*/
//----------------------------------------------------------------------------
Static Function VldMunDes(cCodRota, cEstOri, cEstDes, cCdMunOri, cCdMunDes,cMunDes,aRotPerc01)
Local lRet := .F.
Local nAux := 0
Local aArea:= GetArea()

Default cCodrota := ""
Default cCdMunDes:= ""

 lRet:= Empty(cCdMunDes) .Or. ExistCpo("CC2",cEstDes+cCdMunDes)
 If lRet .And. !Empty(cCdMunDes)
   cMunDes := Posicione("CC2",1, xFilial("CC2")+cEstDes+cCdMunDes,"CC2_MUN")
EndIf

If lRet
	TMSRSetSt('aRtByIBGE',{}) 
    TMSRSetSt('nSelItem',0)

    aRotRep:= GetRotRep(cEstOri, cEstDes, cCdMunOri, cCdMunDes)

	If  Len(aRotRep) > 0 .And.  Valtype(aRotRep[1][1]) = "A"  //Diferente de Array (Erro exemplo: 404 Not Found)
		aRotPerc01:={}
		For nAux := 1 To Len( aRotRep )
				AAdd( aRotPerc01, {	cValToChar(aRotRep[nAux][2][2]),;		//Route_RouteCode
									cValToChar(aRotRep[nAux][1][2]),;		//Route_TraceCode
									aRotRep[nAux][5][2],;		//Route_Name
									aRotRep[nAux][3][2]}) 		//Route_Distance
									//aRoteiro[nAux][4][2],;	//Route_RoundTrip
									//aRoteiro[nAux][7][2] } )	//Route_TraceIdentifier	
		Next nAux

		If Len(aRotPerc01) > 0
			OLbxEsp:SetArray( aRotPerc01 )

			If Type('oLbxEsp') == 'O'
				oLbxEsp:bLine	:= { || {	aRotPerc01[oLbxEsp:nAT, 1],;
											aRotPerc01[oLbxEsp:nAT, 2],;
											aRotPerc01[oLbxEsp:nAT, 3],;
											aRotPerc01[oLbxEsp:nAT, 4] } }
					
				oLbxEsp:Refresh()
				oLbxEsp:SetFocus()
			EndIf
		EndIf

		TMSRSetSt('aRtByIBGE',aRotPerc01)   //Seta Variavel Statica 
	Else
		RepSolicRt( cCodRota, , , , cEstOri, cCdMunOri, cEstDes, cCdMunDes )
	EndIf
EndIf

RestArea(aArea)
Return lRet

//------------------------------------------------------
/*/{Protheus.doc} GetRotRep()
Executa a Chamada do Metodo GetRtByIBGE
@param      cEstOri, cEstDes, cCdMunOri, cCdMunDes
@author     Katia
@since      22/10/2020
@version    1.0
/*/
//------------------------------------------------------
Static Function GetRotRep(cEstOri, cEstDes, cCdMunOri, cCdMunDes)
Local oRepom   := Nil
Local cEixos   := '2'   //Parametro obrigatorio 
Local aRotRep  := {}

Default cEstOri   := ""
Default cEstDes   := ""
Default cCdMunOri := ""
Default cCdMunDes := ""

oRepom := TMSBCARepomFrete():New()
oRepom:Auth()

aRotRep:= oRepom:GetRtByIBGE( cEstOri, cEstDes, cCdMunOri, cCdMunDes, cEixos )

oRepom:Destroy()
FwFreeObj(oRepom)
Return aRotRep


//------------------------------------------------------
/*/{Protheus.doc} TMSRSetSt()
Seta Variavel Statica da Rotina
Utilizado no Cadastro de Rotas (OMSA100)
@param      cVar,xCont
@author     Katia
@since      27/10/2020
@version    1.0
/*/
//------------------------------------------------------
Function TMSRSetSt(cVar,xCont)

&(cVar) := xCont

Return


//------------------------------------------------------
/*/{Protheus.doc} TMSRGetSt()
Retorna a Variavel Statica da Rotina
Utilizado no Cadastro de Rotas (OMSA100)
@param      cVar
@author     Katia
@since      27/10/2020
@version    1.0
/*/
//------------------------------------------------------
Function TMSRGetSt(cVar)	

Return &(cVar)

//------------------------------------------------------
/*/{Protheus.doc} RepGetId()
Consulta do Roteiro x Percurso 
@param      cVar
@author     Katia
@since      27/10/2020
@version    1.0
/*/
//------------------------------------------------------
Function RepGetId(cCodRota,aRotPerc01)
Local oRepom   := Nil
Local cEixos   := '2'   //Parametro obrigatorio 
Local aRotRep  := {}
Local nAux     := 0

oRepom := TMSBCARepomFrete():New()
oRepom:Auth()

aRotRep:= oRepom:GetRtByTrcId( cCodRota, cEixos )

If  Len(aRotRep) > 0 .And.  Valtype(aRotRep[1][1]) = "A"  //Diferente de Array (Erro exemplo: 404 Not Found)
		aRotPerc01:={}
		For nAux := 1 To Len( aRotRep )
            //-- Retorna somente percursos da Rota
            //If AllTrim(aRotRep[nAux][7][2]) == AllTrim(cCodRota) 
				AAdd( aRotPerc01, {	cValToChar(aRotRep[nAux][2][2]),;		//Route_RouteCode
									cValToChar(aRotRep[nAux][1][2]),;		//Route_TraceCode
									aRotRep[nAux][5][2],;		//Route_Name
									aRotRep[nAux][3][2]}) 		//Route_Distance
									//aRoteiro[nAux][4][2],;	//Route_RoundTrip
									//aRoteiro[nAux][7][2] } )	//Route_TraceIdentifier	
            //EndIf
		Next nAux
    EndIf

oRepom:Destroy()
FwFreeObj(oRepom)

Return 

//---------------------------------------------------
/*/{Protheus.doc} TMVlPdgRep
Pesquisa o Valor do Pedagio na Operadora REPOM
@type Function
@author Katia
@version 12.1.31
@since 23/11/2020
@return nValPdg
/*/
//---------------------------------------------------	
Function  TMVlPdgRep(cRoteir, cPercur, nQtEixVeic, lFailPdg, aMsgErr)
Local oRepom := Nil
Local nPos   := 0
Local aRtCode:= {}
Local nX     := 0
Local nValPdg:= 0
Local cCodOpe	:= "01"

Default cRoteir   := ""
Default cPercur   := ""
Default nQtEixVeic:= 0

oRepom := TMSBCARepomFrete():New()
If oRepom:Auth()
	aRtCode:= oRepom:GetByRtCode(cPercur, cRoteir, nQtEixVeic)
	nX:= Len(aRtCode)
	lFailPdg:= .T.
	If nX > 0
		If Len(aRtCode[1]) > 0 .And. Valtype(aRtCode[1][1]) == "A"
			nPos:= aScan(aRtCode[nX], {|x| x[1] $ "Route_TotalVPRValue" } )
			If nPos > 0 
				nValPdg:= Round(aRtCode[nX][nPos][2],TamSX3('DTR_VALPDG')[2])
				lFailPdg:= .F.
			EndIf
		EndIf
	EndIf

	If lFailPdg
		aMsgErr := TMSErrOper(cCodOpe,, '2')
	EndIf

	oRepom:Destroy()
	FwFreeObj(oRepom)
EndIf

Return nValPdg



//---------------------------------------------------
/*/{Protheus.doc} TM15DesPer
Retorna a Descrição do Roteiro/Percurso
@type Function
@author Katia
@version 12.1.31
@since 23/11/2020
@return cDesc
/*/
//---------------------------------------------------	
Function  TM15DesPer(cRota, cRoteir, cPercur)
Local oRepom    := Nil
Local nPos      := 0
Local aRtCode   := {}
Local nX        := 0
Local cDesc     := " "
Local lRet      := .F.

Default cRota   := ""
Default cRoteir := ""
Default cPercur := ""

oRepom := TMSBCARepomFrete():New()
If oRepom:Auth()
	aRtCode:= oRepom:GetByRtCode( AllTrim(cPercur), AllTrim(cRoteir), 2)
	nX:= Len(aRtCode)
	If nX > 0 
		If  ValType(aRtCode[1][1]) == "A"
			nPos:= aScan(aRtCode[nX], {|x| AllTrim(x[1]) == "Route_Name" } )
			If nPos > 0 
				cDesc:= Padr(aRtCode[nX][nPos][2],TamSX3('DEK_DESPER')[1])			
				lRet:= .T.
			EndIf
		EndIf
	EndIf

	oRepom:Destroy()
	FwFreeObj(oRepom)
EndIf

FwFreeArray(aRtCode)
Return cDesc

//---------------------------------------------------
/*/{Protheus.doc} TM15RotPer
Valida o Roteiro e Percurso na Operadora REPOM
@type Function
@author Katia
@version 12.1.31
@since 23/11/2020
@return lRet
/*/
//---------------------------------------------------	
Function  TM15RotPer(cRoteir, cPercur)
Local oRepom    := Nil
Local aRtCode   := {}
Local nX        := 0
Local lRet      := .F.

Default cRoteir := ""
Default cPercur := ""

oRepom := TMSBCARepomFrete():New()
If oRepom:Auth()
	aRtCode:= oRepom:GetByRtCode(AllTrim(cPercur), AllTrim(cRoteir), 2)	
	nX:= Len(aRtCode)
	If nX > 0 .And.  ValType(aRtCode[1][1]) == "A"
		lRet:= .T.
	EndIf

	oRepom:Destroy()
	FwFreeObj(oRepom)
Else
	lFalha:= .T.
EndIf

FwFreeArray(aRtCode)
Return lRet
