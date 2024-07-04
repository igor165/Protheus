#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMSA146.CH"

Static oDadosTPR:= Nil          

/* {Protheus.doc} TMS146ATPR
Integra dados da Programação com Totvs Planejamento de Rotas
@author		Katia
@since		16/08/2021
@version	12.1.35
@type function
*/
Function TMS146ATPR()
Local oModelPrg   := FwModelActive()
Local oMdlGridDoc := oModelPrg:GetModel("MdGridDoc")
Local oMdlGridDF8 := oModelPrg:GetModel("MdGridDF8")
Local oMdlGridDA3 := oModelPrg:GetModel("MdGridDA3")
Local lRet        := .F.
Local aArea       := GetArea()
Local aDoctosTPR  := {}
Local aPesqDoc    := {}
Local cError        := ""
Local cResult       := "" 
Local cJson         := "" 
Local cIdRot        := "" 
Local lContinua     := .T.
Local aSaveLine     := FWSaveRows()

If !Empty(oMdlGridDoc)  
    //--- Valida se ja não existe um carregamento para um veiculo
    If oMdlGridDF8:Length() > 0 .And. !oMdlGridDF8:IsEmpty() .And. !oMdlGridDF8:IsDeleted()
        lContinua:= .F.
        Help('',1,'TMSA14653') //Não é  possível enviar os dados para integração, pois existe Programação de Carregamento já incluída e pendente de confirmação.
    EndIf

    If lContinua
        aPesqDoc :=  { { 'T01_MARK', .T. }, { 'T01_SERTMS', '2' } }   //Transferencia
        If oMdlGridDoc:SeekLine( aPesqDoc )
            lContinua:= .F.
            Help('',1,'TMSA14654') //A roteirização está disponivel somente para o Serviço de Transporte de Coleta e Entrega.                                        
        EndIf
    EndIf

    If lContinua     
        Pergunte('TMSA146TPR',.T.)   

        //--- Envia a Roteirização de Transferencia e depois os de Coleta/Entrega
        aPesqDoc :=  { { 'T01_MARK', .T. } }   //Coleta e Entrega
   
        lRet:= oMdlGridDoc:SeekLine( aPesqDoc )
        If lRet
            oDadosTPR:= TMSBCATPRNeolog():New()	
            If oDadosTPR:Auth()
                //---- Prepara os objetos para envio a TPR
                lRet:= T146AddOrd(oMdlGridDoc,@aDoctosTPR,aPesqDoc)     //Orders
                If lRet
                    T146AddVei(oMdlGridDA3)     //Vehicles
                    T146AddRes()                //Restrictions
                    T146AddOpc()                //Options
                
                    If lRet
                        //---- Envia objetos para integração TPR
                        cIdRot  := GetSxENum("DMR","DMR_IDROT") 
                        oDadosTPR:SetRoutID( cFilAnt + cIdRot )
                        FwMsgRun( ,{|| lRet	:= oDadosTPR:PostRouting() } ,'Comunicação Neolog' , 'Comunicação Neolog' ) 
                            
                        If !lRet   
                            RollBackSX8()
                            oDadosTPR:ShowError()
                            cJson   := oDadosTPR:GetJsonEnv()
                            cError  := oDadosTPR:GetError() 
                        Else 
                            ConfirmSX8()
                            cResult := oDadosTPR:GetResult() 
                            cJson   := oDadosTPR:GetJsonEnv()
                        EndIf 

                        //--- Grava Tabela Genérica DMS/DMR
                        If lRet
                            T146GrvRot( cIdRot , aDoctosTPR ,cJson , cResult , cError)                    
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
        Pergunte('TMSA146',.F.)   
    EndIf
EndIf

If lRet
    MsgInfo(STR0251) //"Dados enviados para o Planejamento de Rotas (TPR) com sucesso!"
    If oModelPrg <> Nil
	    FwModelActive(oModelPrg)
    EndIf
Else
    If lContinua 
        Help('',1,'TMSA14652') //Integração não realizada. 
    EndIf
EndIf

//---- Limpa Objeto da integração
FwFreeObj(oDadosTPR)    
oDadosTPR:= Nil 

FWRestRows( aSaveLine )
RestArea(aArea)
FwFreeArray(aArea)
FwFreeArray(aSaveLine)
Return lRet

/* {Protheus.doc} T146AddOrd
//Adiciona dados dos Documentos para Roteirização (TPRRoutingOrders)
@author		Katia
@since		16/08/2021
@version	12.1.35
*/
Function T146AddOrd(oMdlGridDoc,aDoctosTPR,aPesqDoc)
Local aDadosEnd   := {}
Local cIdentifier := ""
Local cEntidade   := ""
Local nIndiceEnt  := 0
Local dIniCar     := ""
Local dFimCar     := Nil
Local dIniEnt     := Nil
Local dFimEnt     := ""
Local nTmpCar     := Nil
Local nTmpDesCar  := Nil
Local lRet        := .F.
Local cChvEnt     := ""
Local aDataDoc    := {}

Default oMdlGridDoc:= Nil
Default aPesqDoc    := NIL

    //--- Calcula a Data de Inicio de Carregamento
    dIniCar:= TMSTPRDtIn(MV_PAR03,MV_PAR02)   //Horario de Carregamento, Planejamento para

    //---
    If !Empty(oMdlGridDoc)
        While oMdlGridDoc:SeekLine( aPesqDoc )  //T01_MARK 
            //--- Prepara os registros para integração         

            aRet:= T146Ident(oMdlGridDoc:GetValue('T01_FILORI'), ;
  	          		oMdlGridDoc:GetValue('T01_LOTNFC') ,;    
   	         		oMdlGridDoc:GetValue('T01_CLIREM'),;    
    		        oMdlGridDoc:GetValue('T01_LOJREM'),;    
            		oMdlGridDoc:GetValue('T01_CLIDES'),;    
            		oMdlGridDoc:GetValue('T01_LOJDES'),; 
            		oMdlGridDoc:GetValue('T01_SERVIC'),;   
            		oMdlGridDoc:GetValue('T01_CODPRO'),;                          
            		oMdlGridDoc:GetValue('T01_NUMNFC'),;    
            		oMdlGridDoc:GetValue('T01_SERNFC'),;
					oMdlGridDoc:GetValue('T01_FILDOC'),;
				  	oMdlGridDoc:GetValue('T01_DOC') ,;
				  	oMdlGridDoc:GetValue('T01_SERIE'))	

            lRet:= Len(aRet) > 0 .And. !Empty(aRet[1])
            If lRet
                cChvEnt    := aRet[1]
                cEntidade  := aRet[2]
                nIndiceEnt := aRet[3]   
                cIdentifier:= aRet[4]
                     
                aDadosEnd:= TMSA146End(cEntidade,cChvEnt,nIndiceEnt)
                If Len(aDadosEnd) > 0
                    lRet:= VldGeoDAR(aDadosEnd)   //Valid Geolocalização e seta os endereços
                EndIf
            EndIf

            If lRet   //Data Inicio e Fim de Entrega
                aDataDoc := TMSA146Dat(cEntidade, nIndiceEnt, cChvEnt)
                If Len(aDataDoc) > 0
                    //dIniEnt:= aDataDoc[1]
                    dFimEnt:= aDataDoc[2]
                EndIf
            EndIf

            If lRet
                oDadosTPR:AddOrders(cIdentifier, oMdlGridDoc:GetValue('T01_PESO'), oMdlGridDoc:GetValue('T01_PESOM3'),;
                dIniCar, dFimCar, dIniEnt, dFimEnt, nTmpCar, nTmpDesCar)

                //---Guarda os Documentos integrados
                aAdd(aDoctosTPR,{cEntidade,cChvEnt,nIndiceEnt})

            EndIf
  
            oMdlGridDoc:LoadValue("T01_MARK",.F.) 
        EndDo
    EndIf

FwFreeArray(aDataDoc)    
Return lRet


/*/{Protheus.doc} T146AddVei
//Adiciona dados dos Veiculos para Roteirização (TPRRoutingVehicles)
@author Katia
@since 16/08/2021
@version 12.1.33
@type function
/*/
Function T146AddVei(oMdlGridDA3)
Local cQuery   := ""
Local cAliasQry:=  GetNextAlias()
Local n1       := 0
Local nquantity:= 1   //Qtde de veiculos semelhantes
Local lMarkVei := .F.
Local lOk      := .F.
Local lCmpDA3  := DA3->(ColumnPos("DA3_VELOC")) > 0

Default oMdlGridDA3:= Nil

If Valtype(oMdlGridDA3) == Nil
	cQuery := " SELECT DA3_COD, DA3_PLACA, DA3_CAPACM, DA3_VOLMAX, DA3_COD "
    If lCmpDA3
        cQuery += ", DA3_VELOC "
    EndIf
	cQuery +=  "FROM " + RetSqlName("DA3") + " DA3 "
    cQuery += " LEFT JOIN " + RetSqlName("DUT") + " DUT "
	cQuery += " ON DUT.DUT_FILIAL = '" + xFilial("DUT") + "' "
	cQuery += " AND DUT.DUT_TIPVEI = DA3.DA3_TIPVEI  "
    cQuery += " AND DUT.DUT_CATVEI <> '2' "
    cQuery += " AND DUT.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DA3.DA3_FILIAL = '" + xFilial("DA3") + "' "
    cQuery += " AND DA3.DA3_ATIVO = '1' "
    cQuery += " AND DA3.DA3_STATUS = '2' "  //Em Filial
	cQuery += " AND DA3.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
    While (cAliasQry)->(!Eof())
        If (cAliasQry)->DA3_CAPACM > 0 //.Or. (cAliasQry)->DA3_VOLMAX > 0
            oDadosTPR:AddVehicles((cAliasQry)->DA3_COD,;
                                  (cAliasQry)->DA3_CAPACM,;
                                  (cAliasQry)->DA3_VOLMAX,;
                                  Iif(lCmpDA3,(cAliasQry)->DA3_VELOC,0),;
                                  nquantity)
        EndIf

        (cAliasQry)->(dbSkip())
    EndDo
    
    (cAliasQry)->(dbCloseArea())
Else
    //--- Veiculos baseados no Filtro da programação de veiculo. 
    //--- Todos- Somente status em Filial ou Somente os veiculos selecionados
    lMarkVei:= oMdlGridDA3:SeekLine( {{ "DA3_MARK", .T.}} )    

    For n1:= 1 to oMdlGridDA3:Length()
        oMdlGridDA3:GoLine(n1)
	    If !oMdlGridDA3:IsDeleted() .And. !oMdlGridDA3:IsEmpty()        
            If lMarkVei 
                lOk:= oMdlGridDA3:GetValue('DA3_MARK')
            Else
                lOk:= oMdlGridDA3:GetValue("DA3_STATUS") == "2"    //1-Não disponivel, 2-Em Filial, 3-Em viagem
            EndIf

            If lOk
                oDadosTPR:AddVehicles(oMdlGridDA3:GetValue('DA3_COD'),;
                                      oMdlGridDA3:GetValue('DA3_CAPACM'),;
                                      oMdlGridDA3:GetValue('DA3_VOLMAX'),;
                                      Iif(lCmpDA3,oMdlGridDA3:GetValue('DA3_VELOC'),0),;
                                      nquantity)
            EndIf
        EndIf
    Next n1

EndIf    

Return Nil


/*/{Protheus.doc} T146AddRes
//Adiciona dados das Restrições para Roteirização (TPRRoutingRestrictions)
@author Katia
@since 16/08/2021
@version 12.1.33
@type function
/*/
Function T146AddRes()
Local nMaxLoad       := MV_PAR05    //Qtd Maxima Carregamentos
Local nMaxUnload     := MV_PAR06    //Qtd Maxima Descarregamentos
Local lInter         := .F.
Local nMaxDistLoad   := MV_PAR07    //Km Maxima Carregamentos
Local nMaxDistUnload := MV_PAR08    //Km Maxima Descarregamentos

oDadosTPR:AddRestriction( Iif(nMaxLoad > 0, nMaxLoad, Nil)  ,;
                          Iif(nMaxUnload > 0, nMaxUnload, Nil),;  
                          lInter,;
                          Iif(nMaxDistLoad > 0, nMaxDistLoad, Nil)  ,;
                          Iif(nMaxDistUnload > 0, nMaxDistUnload, Nil) )

Return Nil


/*/{Protheus.doc} T146AddOpc
//Adiciona dados das Opções  para Roteirização (TPRRoutingOptions)
@author Katia
@since 16/08/2021
@version 12.1.33
@type function
/*/
Function T146AddOpc()
Local cCapCriteria:= ""   //WEIGHT, VOLUME OU BOTH
Local cRoutInstant:= ""   //D+1 , NOW
Local lReturnDist := ""   //True ou False
Local nMinServDur := 0
Local nMaxServDur := 0
Local cDriverRest := "Default"
Local lTollCalc   := .T.

//--- capacityCriteria
If MV_PAR01 == 1  //1-Peso
    cCapCriteria:= 'WEIGHT'
ElseIf MV_PAR01 == 2  //2-Volume
    cCapCriteria:= 'VOLUME'
Else   //3-Ambos
    cCapCriteria:= 'BOTH'
EndIf

//--- routingInstantType
If MV_PAR02 == 1  //1-Agora
    cRoutInstant:= 'NOW'
ElseIf MV_PAR02 == 2  //2- D+1
    cRoutInstant:= 'D+1'
Else //3-Ambos
    cRoutInstant:= 'BOTH'
EndIf

//--- considerReturnDistance
lReturnDist := Iif(MV_PAR04 == 1, .T., .F.)

//---- minServiceDuration / maxServiceDuration
If !Empty(MV_PAR09) .And. MV_PAR09 <> "  :  " .And. MV_PAR09 <> "00:00"
	nMinServDur := TMSTPRMili(MV_PAR09)
EndIf

If !Empty(MV_PAR10) .And. MV_PAR10 <> "  :  " .And. MV_PAR10 <> "00:00"
	nMaxServDur := TMSTPRMili(MV_PAR10)
EndIf

oDadosTPR:AddOption(cCapCriteria, cRoutInstant, lReturnDist, nMinServDur, nMaxServDur, cDriverRest, lTollCalc)
    
Return Nil


/* {Protheus.doc} T146AddDAR
Grava Coordenada Geográfica - DAR
@author		Katia
@since		17/08/2021
@version	12.1.34
*/
Function T146AddDAR(cFilEnt, cEntida, cCodEnt, cLatitude, cLongitude)
Local lRet         := .T.

Private lMsErroAuto:= .F.

FWMsgRun(,{|| lRet:= TMSROT015(cFilEnt,cEntida,cCodEnt,cLatitude,cLongitude) },,'Atualizando Referencia Geografica...' )

If lMsErroAuto .And. !lRet
    MostraErro()
EndIf

Return lRet


/*/{Protheus.doc} TMSA146End
//Pesquisa dados do Cliente Remetente e Destinatário
@author Katia
@since 23/08/2021
@version 12.1.35
@type function
/*/
Function TMSA146End(cEntidade,cIdent,nIndiceEnt)

Local aRegOri:= {}
Local aRegDes:= {}
Local aAreas := {DUE->(GetArea()),DUL->(GetArea()),DT5->(GetArea()),DTC->(GetArea()),SA1->(GetArea()),GetArea()}
Local aRet   := {}
 
    If cEntidade == "DT5"
        DT5->(DbSetOrder(nIndiceEnt))   //4
        If DT5->(DbSeek(cIdent))
            
            //--------- Dados do Cliente REMETENTE -------------//
            If DT5->DT5_LOCCOL == '1' //--Remetente
                If Empty(DT5->DT5_SEQEND)	
                    aRegOri:= DadosDUE(DT5->DT5_CODSOL)
                Else
                    aRegOri:= DadosDUL(DT5->DT5_SEQEND)
                EndIf
            Else
                aRegOri:= DadosSA1(DT5->DT5_CLIREM, DT5->DT5_LOJREM)
            EndIf

            //--------- Dados do Cliente DESTINATÁRIO -------------//
            If !Empty(DT5->DT5_CLIDES)
                If !Empty(DT5->DT5_SQEDES)
                    aRegDes:= DadosDUL(DT5->DT5_SQEDES)
                Else
                    aRegDes:= DadosSA1(DT5->DT5_CLIDES, DT5->DT5_LOJDES)
                EndIf
            Else
                aRegDes:= DadosSM0(DT5->DT5_FILORI)
            EndIf
        EndIf
    
    Else
        If cEntidade == "DTC"
            cSeekDTC:= cIdent   
        Else
            DT6->(DbSetOrder(nIndiceEnt))
            If DT6->(DbSeek(cIdent))           
                cSeekDTC:= xFilial("DTC") + DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE) 
                If !Empty(DT6->DT6_DOCDCO)
                    cSeekDTC:= xFilial("DTC") + DT6->(DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO)
                EndIf
                nIndiceEnt:= 3
            EndIf
        EndIf

        DTC->(DbSetOrder(nIndiceEnt))
        If DTC->(DbSeek( cSeekDTC ))           
            //--------- Dados do Cliente REMETENTE -------------//
            If DTC->DTC_SELORI == "1"	//-- Transportadora
                aRegOri:= DadosSM0(DTC->DTC_FILORI)
                    
            ElseIf DTC->DTC_SELORI == "2"	//-- Cliente Remetente
                aRegOri:= DadosSA1(DTC->DTC_CLIREM, DTC->DTC_LOJREM)

            Else	//-- Local de Coleta ou Expedidor
                If !Empty(DTC->DTC_CLIEXP) .AND. !Empty(DTC->DTC_LOJEXP)
                    aRegori := DadosSa1(DTC->DTC_CLIEXP, DTC->DTC_LOJEXP)
                Else
                    DT5->(DbSetOrder(1))
                        If DT5->(DbSeek(xFilial("DT5") + DTC->DTC_FILCFS + DTC->DTC_NUMSOL))
                            If Empty(DT5->DT5_SEQEND)	//-- Não Possui Sequencia de Endereço
                                aRegOri:= DadosDUE(DT5->DT5_CODSOL)
                            Else
                                aRegOri:= DadosDUL(DT5->DT5_SEQEND)
                            EndIf
                        EndIf
                EndIf    
            EndIf

            //--------- Dados do Cliente DESTINATARIO -------------//
            If Empty(DTC->DTC_SQEDES)	//-- Não Possui Endereço de Entrega na Nota Fiscal
                aRegDes:= DadosSA1(DTC->DTC_CLIDES, DTC->DTC_LOJDES)            
            Else
                aRegDes:= DadosDUL(DTC->DTC_SQEDES) 
            EndIf
        EndIf
    EndIf

aRet:= {}
aAdd(aRet,aClone(aRegOri))
aAdd(aRet,aClone(aRegDes))

AEval(aAreas,{|x,y| RestArea(x)})
FwFreeArray(aRegOri)
FwFreeArray(aRegDes)
Return aRet

/*/{Protheus.doc} DadosSA1
//Pesquisa dados do Cliente (SA1)
@author Katia
@since 23/08/2021
@version 12.1.35
@type function
/*/
Static Function DadosSA1(cCodCli, cLojCli)
Local aRet := {}
Local cSigla:= Posicione('SYA',1,xFilial('SYA')+'105','YA_SIGLA')

SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1") + cCodCli + cLojCli))
    Aadd(aRet, xFilial("SA1") + "SA1" + SA1->(A1_COD+A1_LOJA))
    Aadd(aRet, SA1->A1_END     )
	Aadd(aRet, SA1->A1_BAIRRO  )
    Aadd(aRet, SA1->A1_MUN     )
    Aadd(aRet, SA1->A1_EST     )
    Aadd(aRet, SA1->A1_CEP     )
    Aadd(aRet, Iif(AllTrim(cSigla) == "*", "BRA", cSigla) ) 
    Aadd(aRet, AllTrim(SA1->A1_NOME) ) 
EndIf

Return aRet

/*/{Protheus.doc} DadosDUE
//Pesquisa dados do Solicitante (DUE)
@author Katia
@since 23/08/2021
@version 12.1.35
@type function
/*/
Static Function DadosDUE(cCodSol)
Local aRet:= {}
	
DUE->(DbSetOrder(1))
If DUE->(DbSeek(xFilial("DUE") + cCodSol ))
	Aadd(aRet, xFilial("DUE")+ "DUE" + DT5->DT5_CODSOL )
    Aadd(aRet, DUE->DUE_END    )
    Aadd(aRet, DUE->DUE_BAIRRO )
    Aadd(aRet, DUE->DUE_MUN   )
    Aadd(aRet, DUE->DUE_EST   )
    Aadd(aRet, DUE->DUE_CEP   )
    Aadd(aRet, "BRA") 
    Aadd(aRet, AllTrim(DUE->DUE_NOME) ) 
EndIf        

Return aRet

/*/{Protheus.doc} DadosDUL
//Pesquisa dados da Sequencia de Endereco (DUL)
@author Katia
@since 23/08/2021
@version 12.1.35
@type function
/*/
Static Function DadosDUL(cSeqEnd)
Local aRet  := {}
Local aArea := GetArea()

DUL->(DbSetOrder(1))
If DUL->(DbSeek(xFilial("DUL") + cSeqEnd)) 	
    If Empty(DUL->DUL_CODRED) .And. Empty(DUL->DUL_LOJRED)
        Aadd(aRet, xFilial("DUL")+ "DUL" + DUL->DUL_SEQEND)
        Aadd(aRet, DUL->DUL_END    )
        Aadd(aRet, DUL->DUL_BAIRRO )
        Aadd(aRet, DUL->DUL_MUN    )
        Aadd(aRet, DUL->DUL_EST    )
        Aadd(aRet, DUL->DUL_CEP    )
        Aadd(aRet, "BRA")          
        If !Empty(DUL->DUL_CODCLI) .And. !Empty(DUL->DUL_LOJCLI) 
            Aadd(aRet, Posicione('SA1',1,xFilial('SA1')+DUL->DUL_CODCLI+DUL->DUL_LOJCLI,'A1_NOME') )
        Else
            Aadd(aRet, Posicione('DUE',1,xFilial('DUE')+DUL->DUL_CODSOL,'DUE_NOME') )
        EndIf

    Else
        aRet:= DadosSA1(DUL->DUL_CODRED, DUL->DUL_LOJRED)
    EndIf
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return aRet


/*/{Protheus.doc} DadosSM0
//Pesquisa dados da Filial (SM0)
@author Katia
@since 23/08/2021
@version 12.1.35
@type function
/*/
Static Function DadosSM0(cFilOri)
Local aRet   := {}
Local aFilSM0:= {}

aFilSM0 := FWSM0Util():GetSM0Data( cEmpAnt , cFilOri, {"M0_CODFIL","M0_NOME","M0_NOMECOM", "M0_ENDENT",;
				                                  "M0_BAIRENT","M0_CIDENT", "M0_ESTENT", "M0_CEPENT"} ) 
					
    Aadd(aRet, Space(TamSx3("DAR_FILENT")[1])  + 'SM0' +  aFilSM0[1][2] )
    Aadd(aRet, aFilSM0[4][2] ) //M0_ENDENT 
    Aadd(aRet, aFilSM0[5][2] ) //M0_BAIRENT
    Aadd(aRet, aFilSM0[6][2] ) //M0_CIDENT  
    Aadd(aRet, aFilSM0[7][2] ) //M0_ESTENT 
    Aadd(aRet, aFilSM0[8][2] ) //M0_CEPENT 
    Aadd(aRet, "BRA" )
    Aadd(aRet, aFilSM0[2][2] ) //M0_NOMECOM 

FwFreeArray(aFilSM0)
Return aRet

/*/{Protheus.doc} VldGeoDAR
//Pesquisa dados da Geolocalização DAR
@author Katia
@since 23/08/2021
@version 12.1.35
@type function
/*/
Function VldGeoDAR(aDadosEnd)
Local cOperation := "UNRESTRICTED"
Local lRet       := .T.
Local n1         := 0
Local cLatitude  := ""
Local cLongitude := ""
Local cIdent     := ""
Local cEnd       := ""
Local cBairro    := ""
Local cMunic     := ""
Local cEstado    := ""
Local cCep       := ""
Local cPais      := ""
Local aRet       := {}
Local cName      := ""

Default aDadosEnd:= {}

    For n1:= 1 To Len(aDadosEnd)    //n1:= 1-Origem, 2-Destino
        If Len(aDadosEnd[n1]) > 0
            cIdent := aDadosEnd[n1][1]    
            cEnd   := aDadosEnd[n1][2]
            cBairro:= aDadosEnd[n1][3]
            cMunic := aDadosEnd[n1][4]
            cEstado:= aDadosEnd[n1][5]
            cCep   := aDadosEnd[n1][6]
            cPais  := aDadosEnd[n1][7]
            cName  := aDadosEnd[n1][8]

            //--- Verifica se existe na DAR, caso não existir executa o PostGeoLoc e grava a DAR
            DAR->(dbSetOrder(1))					   	
            If DAR->(DBSeek(xFilial("DAR") + cIdent)) 	.And. !Empty(DAR->DAR_LATITU) .And. !Empty(DAR->DAR_LONGIT)
                cLatitude := AllTrim(DAR->DAR_LATITU)
                cLongitude:= AllTrim(DAR->DAR_LONGIT)
                lRet:= .T.
            Else
                aRet:= T146CalGeo( cIdent, cPais , cEstado, cMunic, cCep, cEnd )
                If Len(aRet) > 0
                    cLatitude:= aRet[1]
                    cLatitude:= aRet[2]
                EndIf
            EndIf
            
            If lRet
                If n1 == 1  //Origem                    
                    oDadosTPR:SetOrigem( cIdent, cPais, cLatitude, cLongitude, cOperation, cName )
                Else //Destino
                    oDadosTPR:SetDestino( cIdent, cPais, cLatitude, cLongitude, cOperation, cName )
                EndIf   
            Else
                Exit
            EndIf

        EndIf
    Next n1

FwFreeArray(aRet)
Return lRet


/* {Protheus.doc} T146GrvRot
Grava Tabela de Integração TMS x TPR
@author		Katia
@since		25/08/2021
@version	12.1.35
@type function
*/
Function T146GrvRot(cIdRot , aDoctosTPR , cJson , cResult , cError)
Local oModel   := Nil
Local oMdFldDMR:= Nil
Local oMdGrdDMS:= Nil
Local lRet     := .F.
Local nCount   := 0
Local cItem    := StrZero(1,Len(DMS->DMS_ITEM))
Local aArea    := GetArea()

Default cIdRot      := ""
Default aDoctosTPR  := {}
Default cJson       := ""
Default cResult     := "" 
Default cError      := "" 

If Empty(cError)

    oModel := FWLoadModel( 'TMSAC19' )
    oModel:SetOperation( 3 )
    oModel:Activate()

    oMdFldDMR:= oModel:GetModel("MdFieldDMR")
    oMdGrdDMS:= oModel:GetModel("MdGridDMS")

    oMdFldDMR:LoadValue('DMR_FILROT', cFilAnt)
    If !Empty(cIdRot)
        oMdFldDMR:LoadValue('DMR_IDROT' , cIdRot)  
    EndIf
    For nCount:= 1 To Len(aDoctosTPR)
        If nCount <> 1
            oMdGrdDMS:AddLine()
        EndIf
        oMdGrdDMS:LoadValue('DMS_ENTIDA', aDoctosTPR[ nCount, 1 ] )
        oMdGrdDMS:LoadValue('DMS_CHVENT', aDoctosTPR[ nCount, 2 ] )
        oMdGrdDMS:LoadValue('DMS_INDENT', cValToChar(aDoctosTPR[ nCount, 3 ]) )    
        oMdGrdDMS:LoadValue('DMS_ITEM'  , cItem )
        cItem:= Soma1(cItem)

    Next nCount

    lRet:= oModel:VldData()
    If lRet 
        oModel:CommitData()
        cIdRot  := DMR->DMR_FILROT + DMR->DMR_IDROT 
    Else
        Help("", 1,"HELP", NIL, oModel:GetErrorMessage()[6] )
    EndIf

    If lRet 
        If !IsInCallStack("GerDARProc")
            oDadosTPR:InsertDLU( xFilial("DMR") , "DMR", cIdRot , "Routing" ,  , "TMSA146" , cResult, cJson , Iif( lRet , "1","2") ) 
        Else 
            oDadosGeo:InsertDLU( xFilial("DMR") , "DMR", cIdRot , "Geoloc" ,  , "TMSAO15" , cResult, cJson , Iif( lRet , "1","2") )
        EndIf 
    EndIf

    oModel:Destroy()
    oModel:= Nil	
EndIf

RestArea(aArea)
Return lRet

/*/{Protheus.doc} T146CalGeo()
CallBack Result da Geolocalização
@param      cIdent, cPais , cEstado, cMunic, cCep, cEnd
@author     Katia
@since      26/08/2021
@version    12.1.35
@return     aRet
/*/
Function  T146CalGeo(cIdent, cPais , cEstado, cMunic, cCep, cEnd)
Local lRet       := .F.
Local aGeoCode   := {}
Local nTamFil    := TamSx3("DAR_FILIAL")[1]
Local nTamEnt    := TamSx3("DAR_ENTIDA")[1]
Local cFilEnt    := ""
Local cEntida    := ""
Local cCodEnt    := ""
Local aRet       := {}

Default cIdent   := ""
Default cPais    := ""
Default cEstado  := ""
Default cMunic   := ""
Default cCep     := ""
Default cEnd     := ""

oDadosTPR:AddAddress( cIdent, cPais , cEstado, cMunic, cCep, cEnd )
lRet:= oDadosTPR:PostGeoLoc()		
If lRet
	aGeoCode:= oDadosTPR:GetGeoLoc()		
    If Len(aGeoCode) > 0                   
        cFilEnt:= SubStr(cIdent, 1        , nTamFil)
        cEntida:= SubStr(cIdent, nTamFil+1, nTamEnt)
        cCodEnt:= SubStr(cIdent, nTamFil+nTamEnt+1)

        lRet:= T146AddDAR(cFilEnt, cEntida, cCodEnt, aGeoCode[1], aGeoCode[2])  
        If lRet
            aAdd(aRet,aGeoCode[1])    //Latitude
            aAdd(aRet,aGeoCode[2])    //Longitude
        EndIf
    EndIf
EndIf

Return aRet

/*/{Protheus.doc} T146Ident()
Retorna o Identificador da Roteirização
@param      ?
@author     Katia
@since      30/08/2021
@version    12.1.35
@return     cChvEnt,cEntidade,nIndiceEnt,cIdent
/*/
Function T146Ident(cFilOri,cLotNfc,cCliRem,cLojRem,cCliDes,cLojDes,cServic,cCodPro,cNumNfc,;
                    cSerNfc,cFilDoc,cDoc,cSerie)

Local aRet       := {}
Local cDadosTab  := ""
Local cChvEnt    := ""
Local cEntidade  := ""
Local nIndiceEnt := ""
Local cIdentifier:= ""

If Empty(cFilDoc) .And. Empty(cDoc) .And. Empty(cSerie)
    cChvEnt:= xFilial("DTC") +;  
             Padr(cFilOri ,Len(DTC->DTC_FILORI)) +;
             Padr(cLotNfc ,Len(DTC->DTC_LOTNFC)) +;    
             Padr(cCliRem ,Len(DTC->DTC_CLIREM)) +;    
             Padr(cLojRem ,Len(DTC->DTC_LOJREM)) +;    
             Padr(cCliDes ,Len(DTC->DTC_CLIDES)) +;    
             Padr(cLojDes ,Len(DTC->DTC_LOJDES)) +; 
             Padr(cServic ,Len(DTC->DTC_SERVIC)) +;   
             Padr(cCodPro ,Len(DTC->DTC_CODPRO)) +;                          
             Padr(cNumNfc ,Len(DTC->DTC_NUMNFC)) +;    
             Padr(cSerNfc ,Len(DTC->DTC_SERNFC))      

            cIdentifier:= "NFC|DTC|" + cChvEnt
            cEntidade  := "DTC"                                                   
            nIndiceEnt := 1                

Else
    If cSerie == "COL"
        cDadosTab:= "COL|DT5|" 
        cChvEnt   :=  xFilial("DT5") 
        cEntidade := "DT5"
        nIndiceEnt:= 4   
    Else
        cDadosTab:= "CTE|DT6|" 
        cChvEnt   := xFilial("DT6")
        cEntidade:= "DT6"
        nIndiceEnt:= 1       
    EndIf

    cChvEnt+= Padr(cFilDoc ,Len(DT6->DT6_FILDOC)) +;    
              Padr(cDoc    ,Len(DT6->DT6_DOC))    +; 
              Padr(cSerie  ,Len(DT6->DT6_SERIE))    

    cIdentifier  := cDadosTab + cChvEnt
EndIf

aAdd(aRet,cChvEnt)      //DMS_CHVENT
aAdd(aRet,cEntidade)    //DMS_ENTIDA 
aAdd(aRet,nIndiceEnt)   //DMS_INDENT
aAdd(aRet,cIdentifier)  //Identifier enviado para TPR

Return aRet

/*/{Protheus.doc} T146DocTPR()
Valida se o Documento encontra-se em Roteirização - TPR
@param      cFilDoc,cDoc,cSerie
@author     Katia
@since      01/09/2021
@version    12.1.35
@return     lRet
/*/
Function T146DocTPR(cFilDoc,cDoc,cSerie, nRecnoDTC)
Local lRet     := .T.
Local aArea    := GetArea()
Local aRet     := {}
Local cRoteiri := ""

Default cFilDoc  := ""
Default cDoc     := ""
Default cSerie   := ""
Default nRecnoDTC:= 0

cRoteiri:= TMSROTEIRI() 
If cRoteiri == '2'   //1-Maplink, 2-TPR
    aRet:= T146IdDMS(Nil,cFilDoc,cDoc,cSerie,nRecnoDTC)
    If Len(aRet) > 0 
        lRet:= TMSAC19Doc(aRet[1],aRet[2])    //ChvEnt, Entidade
    EndIf
EndIf

RestArea(aArea)
FwFreeArray(aRet)
Return lRet

/*/{Protheus.doc} TMSA146Dat()
Retorna data Inicio e Fim (previsão) de entrega
@param      cFilDoc,cDoc,cSerie
@author     Katia
@since      01/09/2021
@version    12.1.35
@return     lRet
/*/
Function  TMSA146Dat(cEntidade, nIndiceEnt, cIdent)
Local aRet     := {}
Local dIniEnt  := ""
Local dFimEnt  := ""
Local cHrIni   := "00:00:00"
Local cHrFim   := "23:59:00"
Local aRetPrz  := {}
Local cHorPrv  := ""
   
If cEntidade == "DT5"
    DT5->(DbSetOrder(nIndiceEnt))   
    If DT5->(DbSeek(cIdent))       
        dIniEnt:= FwTimeStamp(5, DT5->DT5_DATSOL , TRANSFORM( DT5->DT5_HORSOL + "00", "@R 99:99:99") )
        cHorPrv:= DT5->DT5_HORPRV

        If DT5->DT5_DATSOL == DT5->DT5_DATPRV  .And. DT5->DT5_HORSOL == DT5->DT5_HORPRV 
            cHorPrv:= SomaHoras(cHorPrv, '0100')
        EndIf

        dFimEnt:= FwTimeStamp(5, DT5->DT5_DATPRV , TRANSFORM( cValToChar(cHorPrv) + "00", "@R 99:99:99") )
    EndIf

ElseIf cEntidade == "DT6"
    DT6->(DbSetOrder(nIndiceEnt))
    If DT6->(DbSeek(cIdent))           
        aRet:= T146DtaAgd(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
        If Len(aRet) > 0 
            dIniEnt:= aRet[1]
            dFimEnt:= aRet[2]
        Else
            dIniEnt:= FwTimeStamp(5, DT6->DT6_DATEMI , cHrIni )

            dFimEnt:= FwTimeStamp(5, DT6->DT6_PRZENT , cHrFim )            
        EndIf
    EndIf

ElseIf cEntidade == "DTC"  
    DTC->(DbSetOrder(nIndiceEnt))
    If DTC->(DbSeek(cIdent))    
        dIniEnt:= FwTimeStamp(5, DTC->DTC_EMINFC , cHrIni )

        cRet:= TmsPrzEnt(2,@aRetPrz,DTC->DTC_CLIREM,DTC->DTC_LOJREM,DTC->DTC_CLIDES,DTC->DTC_LOJDES,DTC->DTC_SQEDES,DTC->DTC_CDRDES,DTC->DTC_CDRORI,DTC->DTC_CLIDEV,;
        DTC->DTC_LOJDEV,DTC->DTC_TIPTRA,DTC->DTC_CDRCAL)

        If Len(aRetPrz) > 0 .And. !Empty(aRetPrz[1])
            dFimEnt:= FwTimeStamp(5, aRetPrz[1], Transform( aRetPrz[2] + "00", "@R 99:99:99") ) 
        Else    
            dFimEnt:= FwTimeStamp(5, DTC->DTC_PRVENT, cHrFim )  
        EndIf                

    EndIf
EndIf

If !Empty(dIniEnt)
    aAdd(aRet,dIniEnt)
    aAdd(aRet,dFimEnt)
EndIf

FwFreeArray(aRetPrz)
Return aRet

/*/{Protheus.doc} T146DtaAgd()
Retorna a Data de Agendamento do Documento
@param      cFilDoc,cDoc,cSerie
@author     Katia
@since      02/09/2021
@version    12.1.35
@return     dDataIni, dDataFim
/*/
Function T146DtaAgd( cFilDoc , cDoc , cSerie, dDataIni, dDataIni )
Local aArea         := GetArea()
Local cQuery        := ""
Local cAliasQry     := GetNextAlias()
Local dDataAgd      := cTod('')
Local aRet          := {}
Local dDtIni        := ""
Local dDtFim        := ""
Local cHorIni       := "00:00:00"
Local cHorFim       := "23:59:00"

Default cFilDoc     := ""
Default cDoc        := ""
Default cSerie      := ""

cQuery  := " SELECT DYD_DATAGD, DYD_INIAGD , DYD_FIMAGD "
cQuery  += " FROM " + RetSQLName("DT6") + " DT6 "
cQuery  += " INNER JOIN " + RetSQLName("DYD") + " DYD "
cQuery  += "    ON DYD_FILIAL       = '" + xFilial("DYD") + "' "
cQuery  += "    AND DYD_FILDOC      = DT6_FILDOC "
cQuery  += "    AND DYD_DOC         = DT6_DOC "
cQuery  += "    AND DYD_SERIE       = DT6_SERIE "
cQuery  += "    AND DYD_NUMAGD      = DT6_NUMAGD "
cQuery  += "    AND DYD_ITEAGD      = DT6_ITEAGD "
cQuery  += "    AND DYD_STATUS      IN ('1','4') "
cQuery  += "    AND DYD.D_E_L_E_T_  = '' "
cQuery  += " WHERE DT6_FILIAL       = '" + xFilial("DT6") + "' "
cQuery  += "    AND DT6_FILDOC      = '" + cFilDoc + "' "
cQuery  += "    AND DT6_DOC         = '" + cDoc + "' "
cQuery  += "    AND DT6_SERIE       = '" + cSerie + "' "
cQuery  += "    AND DT6.D_E_L_E_T_ = '' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

TcSetField(cAliasQry,"DYD_DATAGD","D",8,0)

While (cAliasQry)->( !Eof() )
    
    If !Empty((cAliasQry)->DYD_DATAGD)
        dDataAgd    := (cAliasQry)->DYD_DATAGD
    EndIf

    If !Empty((cAliasQry)->DYD_INIAGD)
         cHorIni     := TRANSFORM( (cAliasQry)->DYD_INIAGD  + "00", "@R 99:99:99")
    EndIf

    If !Empty((cAliasQry)->DYD_FIMAGD)
        cHorFim     := TRANSFORM( (cAliasQry)->DYD_FIMAGD  + "00", "@R 99:99:99")
    EndIf

    (cAliasQry)->( dbSkip() )
EndDo 

(cAliasQry)->( dbCloseArea() )

If !Empty(dDataAgd) .And. !Empty(cHorIni) .And. !Empty(cHorFim)
    dDtIni:= FwTimeStamp(5, dDataAgd , TRANSFORM( cHorIni + "00", "@R 99:99:99") )
    dDtFim:= FwTimeStamp(5, dDataAgd , TRANSFORM( cHorFim + "00", "@R 99:99:99") )

    aAdd(aRet, dDtIni)
    aAdd(aRet, dDtFim)
EndIf

RestArea( aArea )
Return aRet

/*/{Protheus.doc} T146VldExt()
Função para validar se existe Chave Externa gerada para a Roteirização
@param      cEntExt, cChvExt
@author     Katia
@since      20/09/2021
@version    12.1.35
@return     Nil
/*/
Function T146VldExt(cEntExt,cChvExt,cStatus)
Local cRet     := ""
Local cAliasQry:= GetNextAlias()
Local cQuery   := ""

Default cEntExt:= ""
Default cChvExt:= ""
Default cStatus:= ""

	cQuery := " SELECT DMS.DMS_FILROT , DMS.DMS_IDROT FROM "
	cQuery +=  RetSqlName("DMS") + " DMS "
	cQuery += " WHERE DMS.DMS_FILIAL = '" + xFilial("DMS") + "' "
    cQuery += " AND DMS.DMS_ENTEXT = '" + cEntExt + "' "
    cQuery += " AND DMS.DMS_CHVEXT = '" + cChvExt + "' "
    
    If !Empty(cStatus)
        cQuery += " AND DMS.DMS_STATUS = '" + cStatus + "' "
    EndIf

	cQuery += " AND DMS.D_E_L_E_T_ = ' ' "
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
    If (cAliasQry)->(!Eof())
       cRet:= (cAliasQry)->DMS_FILROT + (cAliasQry)->DMS_IDROT
    EndIf
    (cAliasQry)->(dbCloseArea())
    
Return cRet


/*/{Protheus.doc} T146ExcTPR()
Função para excluir os registros da Roteirização 
Obs: Utilizado ao excluir uma Programação de Carregamento
@param      cFilPrg,cNumPrg,cSeqPrg
@author     Katia
@since      20/09/2021
@version    12.1.35
@return     Nil
/*/
Function T146ExcTPR()
Local cChvExt  := ""
Local cSeek    := ""
Local cFilRot  := ""
Local cNumRot  := ""
Local aAreaDF8 := DF8->(GetArea())
Local cIdRot   := ""
Local lRet     := .F.

cChvExt:= xFilial("DF8") + DF8->DF8_FILORI + DF8->DF8_NUMPRG + DF8->DF8_SEQPRG

If !Empty(cChvExt)   
    cSeek:= xFilial('DMS')+ "DF8"  + Padr(cChvExt,Len(DMS->DMS_CHVEXT))

    DMS->(DbSetOrder(3))
    DMS->(DBSeek(cSeek))
    While DMS->(!Eof()) .And. DMS->(DMS_FILIAL+DMS_ENTEXT+DMS_CHVEXT) == cSeek
        cFilRot:= DMS->DMS_FILROT
        cNumRot:= DMS->DMS_IDROT

        RecLock('DMS',.F.)
        dbDelete()
        DMS->(MsUnLock())
        
        DMS->(dbSkip())
    EndDo

    If !Empty(cFilRot) .And. !Empty(cNumRot)        
        //--- Uma roteirização pode ter gerado mais de uma Programação de Carregamento  
        //--- Portanto, se não encontrar nenhum registro, exclui a Roteirização  
        DMS->(DbSetOrder(1))
        If !DMS->(DBSeek(xFilial('DMS')+cFilRot+cNumRot))
            DMR->(DbSetOrder(1))
            If DMR->(DbSeek( xFilial('DMR')  + cFilRot + cNumRot) )
            	
                cIdRot:= DMR->DMR_FILROT  + DMR->DMR_IDROT
			    lRet:= TMSAC19DLU(cIdRot)

                If lRet
                    RecLock('DMR',.F.)
                    dbDelete()
                    DMR->(MsUnLock())
                EndIf
            EndIf
        EndIf

    EndIf
EndIf

RestArea(aAreaDF8)
FwFreeArray(aAreaDF8)
Return Nil

/*/{Protheus.doc} T146VldTPR()
Função para validar dados da TPR
@param      
@author     Katia
@since      20/09/2021
@version    12.1.35
@return     Nil
/*/
Function T146VldTPR(cEntida,cFilOri,cNumPrg,cSeqPrg,cStatus)
Local cChvExt:= "" 
Local cRet := ""				

Default cEntida:= ""
Default cFilOri:= ""
Default cNumPrg:= ""
Default cSeqPrg:= ""
Default cStatus:= ""

cChvExt:= xFilial("DF8") + PadR( cFilOri, TamSx3("DF8_FILORI")[1] ) + PadR( cNumPrg, TamSx3("DF8_NUMPRG")[1] ) + PadR( cSeqPrg, TamSx3("DF8_SEQPRG")[1] )
cRet := T146VldExt(cEntida,Padr(cChvExt,TamSx3("DMS_CHVEXT")[1]),cStatus)

Return cRet

/*/{Protheus.doc} T146PrgTPR()
Função para verificar a Legenda do Status da Programaçao x TPR
@param      cFilOri,cNumPrg,cSeqPrg 
@author     Katia
@since      21/09/2021
@version    12.1.35
@return     xRet
/*/
Function T146LegTPR(cFilOri,cNumPrg,cSeqPrg)
Local xRet     := ""
Local cIdRot   := ""

Default cFilOri:= ""
Default cNumPrg:= ""
Default cSeqPrg:= ""

    //-- Busca o Nro da Roteirização da Programação
    cIdRot:= T146VldTPR('DF8',cFilOri,cNumPrg,cSeqPrg) 

    //-- Retorna o status (cor) da Roteirização
    xRet:= TMSAC19St(cIdRot)

Return xRet

/*/{Protheus.doc} T146VgeTPR()
Função para verificar se a Viagem está integrada com o TPR
@param      cFilOri,Viagem
@author     Katia
@since      21/09/2021
@version    12.1.35
@return     xRet
/*/
Function T146VgeTPR(cFilOri,cViagem)
Local xRet     := ""
Local cIdRot   := ""

Default cFilOri:= ""
Default cViagem:= ""

    DF8->(DbSetOrder(2))
	If DF8->(MsSeek(xFilial('DF8') + cFilOri + cViagem )) 
        //-- Busca o Nro da Roteirização da Programação
        cIdRot:= T146VldTPR('DF8',DF8->DF8_FILORI, DF8->DF8_NUMPRG, DF8->DF8_SEQPRG) 
    EndIf

    //-- Retorna o status (cor) da Roteirização
    xRet:= TMSAC19St(cIdRot)
    
Return xRet

/*/{Protheus.doc} TMSTPRDtIn
** Gera a data/hora de carregamento com base nos parâmetros
@author Equipe OMS
@since 09/09/2021
/*/
Static Function TMSTPRDtIn(cMVTmpCar,cMVPlanej)
	Local cJSData := ""
	Local dDtCarreg := ddatabase
	Local cTmpCar := IIF(Empty(cMVTmpCar) .Or. cMVTmpCar == "  :  " ,"00:00",cMVTmpCar)

	If cMVPlanej = 1
		cJSData :=  FWTimeStamp(5,dDtCarreg,cTmpCar)
	Else
		dDtCarreg := DaySum(dDtCarreg,1)
		cJSData :=  FWTimeStamp(5,dDtCarreg,cTmpCar)
	EndIf
Return cJSData


/*/{Protheus.doc} TMSTPRMili //OMSTPRMili
** Converte hora em milisegundos
@author Equipe OMS
@since 09/09/2021
/*/
Static Function TMSTPRMili(cHoraMinut)
	Local aHoraMinut := {}
	Local nMiliseg := 0

	aHoraMinut := StrTokArr( cHoraMinut, ":" )
	nMiliseg :=  IIF( Val(aHoraMinut[1]) > 0, Val(aHoraMinut[1]) * 3600000 ,0)
	nMiliseg +=  IIF( Val(aHoraMinut[2]) > 0, Val(aHoraMinut[2]) * 60000  ,0)

Return nMiliseg

