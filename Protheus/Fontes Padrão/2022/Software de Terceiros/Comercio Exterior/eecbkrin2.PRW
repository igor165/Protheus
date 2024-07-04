#INCLUDE "Protheus.ch"
#INCLUDE "EEC.ch"

Function EECBKRIN2()

 Local oXml 
 Local oNv1A,oNv2A,oNv3A,oNv4A,oNv5A
 Local oNv6A,oNv7A,oNv8A//,oNv9A,oNv10A 
 Local i,cRet,aPedidos
 
//RpcSetEnv("01","01",,,"EEC","",/*aTables*/,,,,)

//EEC->( DbSeek(  xFilial("EEC")+"020                 "))
//Frm104SolInt("015", "BK", EEC->EEC_PREEMB, 3)

 oNv1A      := ENode():New()
 //--------------------------------------------------(NV1)Message---------------------------------------------------------//
 oNv2A      := ENode():New()
 //--------------------------------------------------(NV2)Header---------------------------------------------------------// 
    oNV3A      := ENode():New()
    oNV3A:SetField('SenderId',cPartId)/*OK*/
    oNV3A:SetField('ReceiverId',"INTTRA")/*OK*/ 
    oNV3A:SetField('RequestDateTimeStamp',Left(FWTimeStamp( 3,Date(),Time()),19))
    oNV3A:SetField('RequestMessageVersion',"1.0")/*OK*/
    oNV3A:SetField('TransactionType',"Booking")/*OK*/
    oNV3A:SetField('TransactionVersion',"2.0")/*OK*/
    oNV3A:SetField('DocumentIdentifier',EEC->EEC_PREEMB)/*OK*/
 	oNV3A:SetField('TransactionStatus',cOpcao)/*OK*/   //Field->[Original,Change,Cancel]            //Field->[true,false]
 
 oNv2A:SetField('Header'           ,oNv3A)
 //--------------------------------------------------(NV2)Header---------------------------------------------------------//
 
 //--------------------------------------------------(NV2)MessageBody-------------------------------------------------------//  
 	   oNv3A      := ENode():New()
 
          oNV4A := ENode():New()
          oNV4A:SetField('ShipmentID',Alltrim(cID))/*OK*/
    
             oNV5A := ENode():New()
       		 oNV5A:SetField('Type',"InformationContact")        //Field->[InformationContact]
       	     oNV5A:SetField('Name',cContPartN)/*OK*/
                
                oNV6A := ENode():New()                
                If cContPartT == "Telephone"
                   oNV6A:SetField('Phone',cContPartV)
                ElseIf cContPartT == "Fax"
                   oNV6A:SetField('Fax'  ,cContPartV)
                ElseIf cContPartT == "Email"
                   oNV6A:SetField('Email',cContPartV)
                EndIf    
                
             oNV5A:SetField('CommunicationDetails',oNV6A)
             
          oNV4A:SetField('ContactInformation',oNv5A)
       
             oNV5A := ENode():New()                            //Att->[Date,DateTime]
             oNV5A:SetField(EAtt():New("Type","Date"))
             oNV5A:SetField(ETag():New("",Left(FWTimeStamp(3,/*sToD(cDtS8H4)*/dDataBase,Time()),19))) /*OK*/

          oNV4A:SetField('DateTime',oNV5A)
          
          //-------------MOVEMENT_TYPE----------------
          If EXL->EXL_TIPMOV == "1"
             oNV4A:SetField('MovementType',"PortToPort")          //Field->[DoorToDoor,DoorToPort,PortToDoor,PortToPort]
          ElseIf EXL->EXL_TIPMOV == "2"
             oNV4A:SetField('MovementType',"DoorToPort")          //Field->[DoorToDoor,DoorToPort,PortToDoor,PortToPort]          
          ElseIf EXL->EXL_TIPMOV == "3"
             oNV4A:SetField('MovementType',"PortToDoor")          //Field->[DoorToDoor,DoorToPort,PortToDoor,PortToPort]          
          ElseIf EXL->EXL_TIPMOV == "4"
             oNV4A:SetField('MovementType',"DoorToDoor")          //Field->[DoorToDoor,DoorToPort,PortToDoor,PortToPort]          
          EndIf
          //-------------MOVEMENT_TYPE----------------
          
          /*//**OMITED
          oNv4A:SetField('PerContainerReleaseNbrReqst',"true")    //Field->[true]
  
             oNV5A := ENode():New()  
             oNV5A:SetField('Text',EXL->(MSMM(EXL_CBKCOM,AVSX3("EXL_BKCOM",3),,,3)))  
    
          oNv4A:SetField('GeneralInformation',oNv5A)
   
             oNV5A := ENode():New()  
             oNV5A:SetField('Text',"_Text_")  
    
          oNv4A:SetField('AmendmentJustification',oNv5A) 
   
             oNV5A := ENode():New()  
             oNV5A:SetField('Filer',"NotCarrier")               //Field->[NotCarrier]
             oNV5A:SetField('FilingProgram',"AMS")              //Field->[AMS]

                oNV6A := ENode():New()                          //Att->[SCAC]
                oNV6A:SetField(EAtt():New("Type","SCAC"))
                oNV6A:SetField(ETag():New("","ID"))              
       
             oNV5A:SetField('FilerID',oNV6A)
          
          oNv4A:SetField('CustomsClearanceInstructions',oNv5A)
          
             oNV5A := ENode():New() 
             oNV5A:SetField(EAtt():New("Type","CCN"))       //Att->[CCN,UCR]
             oNV5A:SetField(ETag():New("",""))    

       		 oNV5A:SetField('CustomsDeclarationInfoValue',"_CustomsDeclarationInfoValue_")  
     
          oNv4A:SetField('CustomsDeclarationInformation',oNv5A)
          oNv4A:SetField('NatureOfCargo',"EnvironmentalPollutant")                    //Field->[EnvironmentalPollutant,Hazardous,NonContainerized,TemperatureControlled]
          */
          oNv4A:lUniqueField := .F.            
          For i:= 1 To 2
             oNV5A := ENode():New()
             oNV5A:SetField('Type',If(i == 1,"PlaceOfDelivery","PlaceOfReceipt")   )  //Field->[*PlaceOfDelivery,*PlaceOfReceipt,BookingOffice,ProhibitedTransshipmentLocation,RequestedTransshipmentLocation]              
                                                                                      //Att->[UNLOC,PartnerAlias] 
                oNV6A := ENode():New()                                                     
                If i == 1
                      oNV6A:SetField(EAtt():New("Type","UNLOC"))
                      oNV6A:SetField(ETag():New("",cLcDesLC)) 
                   
                   oNV5A:SetField('Identifier',oNV6A)                   
                   oNV5A:SetField('Name',cLcDesNM)   
                   
                      If !Empty(cLcDesETA)
                         oNV6A := ENode():New()                                                //Att->[Date,DateTime]
                         oNV6A:SetField(EAtt():New("Type","Date"))
                         oNV6A:SetField(ETag():New("", ""))
                         oNV6A:SetField(EAtt():New("DateType","EstimatedArrival"))             //Att->[EstimatedArrival,EarliestDeparture]  
                    //oNV5A:SetField('City',"_City_")
                    //oNV5A:SetField('SubDivision',"ST")
                    //oNV5A:SetField('CountryName',"_CountryName_")
                    //oNV5A:SetField('CountryCode',"55")
                         oNV6A:SetField(ETag():New("",Left(FWTimeStamp(3,sToD(cLcDesETA),Time()),19)))
                      oNV5A:SetField('DateTime',oNV6A)                         
                      EndIf                     
                Else
                      oNV6A:SetField(EAtt():New("Type","UNLOC"))
                      oNV6A:SetField(ETag():New("",cLcOriLC))
                   
                   oNV5A:SetField('Identifier',oNV6A)                   
                   oNV5A:SetField('Name',cLcOriNM)
                    
                      If !Empty(cLcOriETD)                   
                         oNV6A := ENode():New()                                                //Att->[Date,DateTime]
                         oNV6A:SetField(EAtt():New("Type","Date"))
                         oNV6A:SetField(ETag():New("", ""))
                         oNV6A:SetField(EAtt():New("DateType","EarliestDeparture"))             //Att->[EstimatedArrival,EarliestDeparture]  
                    //oNV5A:SetField('City',"_City_")
                    //oNV5A:SetField('SubDivision',"ST")
                    //oNV5A:SetField('CountryName',"_CountryName_")
                    //oNV5A:SetField('CountryCode',"55")
                         oNV6A:SetField(ETag():New("",Left(FWTimeStamp(3,sToD(cLcOriETD),Time()),19))) 
                      oNV5A:SetField('DateTime',oNV6A)
                      EndIf                                              
                EndIf                        
              
          oNv4A:SetField('Location',oNv5A) 
          Next i
          
          //------------REFERENCE INFORMATION------------ 
          oNv4A:lUniqueField := .F.
          If !Empty(EEC->EEC_NRCONH)
             oNV5A := ENode():New()                                   //Att->[BillOfLadingNumber, BookingNumber, ConsigneeReferenceNumber,ContractLineItemNumber]
             oNV5A:SetField('Value',Left(EEC->EEC_NRCONH,35))         //[ContractNumber, ContractPartyReferenceNumber, FreightForwarderRefNumber, FreightTariffNumber ]
             oNV5A:SetField(EAtt():New("Type","BillOfLadingNumber"))  //[INTTRAReferenceNumber,OutboundBookingAgentRefNumber, PurchaseOrderNumber, ShipperReferenceNumber ] 
             oNV5A:SetField(ETag():New("",""))                        //[VehicleIdentificationNumber]
              
          oNv4A:SetField('ReferenceInformation',oNv5A)          
          EndIf 
          If !Empty(EEC->EEC_REFIMP)
             oNV5A := ENode():New()                                       //Att->[BillOfLadingNumber, BookingNumber, ConsigneeReferenceNumber,ContractLineItemNumber]
             oNV5A:SetField('Value',Left(EEC->EEC_REFIMP,35))             //[ContractNumber, ContractPartyReferenceNumber, FreightForwarderRefNumber, FreightTariffNumber ]
             oNV5A:SetField(EAtt():New("Type","ConsigneeReferenceNumber"))//[INTTRAReferenceNumber,OutboundBookingAgentRefNumber, PurchaseOrderNumber, ShipperReferenceNumber ] 
             oNV5A:SetField(ETag():New("",""))                            //[VehicleIdentificationNumber]
              
          oNv4A:SetField('ReferenceInformation',oNv5A)          
          EndIf      
          If Type(/*'cContArm'*/'cCrtFrete') == 'C' .And. !Empty(/*cContArm*/cCrtFrete)
             oNV5A := ENode():New()                                            //Att->[BillOfLadingNumber, BookingNumber, ConsigneeReferenceNumber,ContractLineItemNumber]
             oNV5A:SetField('Value',/*cContArm*/StrTran(cCrtFrete,ENTER,""))                     //[ContractNumber, ContractPartyReferenceNumber, FreightForwarderRefNumber, FreightTariffNumber ]
             oNV5A:SetField(EAtt():New("Type","ContractNumber"))               //[INTTRAReferenceNumber,OutboundBookingAgentRefNumber, PurchaseOrderNumber, ShipperReferenceNumber ] 
             oNV5A:SetField(ETag():New("",""))                                 //[VehicleIdentificationNumber]
              
          oNv4A:SetField('ReferenceInformation',oNv5A)          
          EndIf      
          If !Empty(EXL->EXL_REFADD)
             oNV5A := ENode():New()                                           //Att->[BillOfLadingNumber, BookingNumber, ConsigneeReferenceNumber,ContractLineItemNumber]
             oNV5A:SetField('Value',Left(EXL->EXL_REFADD,35))                 //[ContractNumber, ContractPartyReferenceNumber, FreightForwarderRefNumber, FreightTariffNumber ]
             oNV5A:SetField(EAtt():New("Type","ContractPartyReferenceNumber"))//[INTTRAReferenceNumber,OutboundBookingAgentRefNumber, PurchaseOrderNumber, ShipperReferenceNumber ] 
             oNV5A:SetField(ETag():New("",""))                                //[VehicleIdentificationNumber]
              
          oNv4A:SetField('ReferenceInformation',oNv5A)          
          EndIf     
          If Type('cContFF') == 'C' .And. !Empty(cContFF)
             oNV5A := ENode():New()                                        //Att->[BillOfLadingNumber, BookingNumber, ConsigneeReferenceNumber,ContractLineItemNumber]
             oNV5A:SetField('Value',cContFF)                               //[ContractNumber, ContractPartyReferenceNumber, FreightForwarderRefNumber, FreightTariffNumber ]
             oNV5A:SetField(EAtt():New("Type","FreightForwarderRefNumber"))//[INTTRAReferenceNumber,OutboundBookingAgentRefNumber, PurchaseOrderNumber, ShipperReferenceNumber ] 
             oNV5A:SetField(ETag():New("",""))                             //[VehicleIdentificationNumber]
              
          oNv4A:SetField('ReferenceInformation',oNv5A)          
          EndIf     
          If Type('cInttraRef') == 'C' .And. !Empty(cInttraRef)
             oNV5A := ENode():New()                                        //Att->[BillOfLadingNumber, BookingNumber, ConsigneeReferenceNumber,ContractLineItemNumber]
             oNV5A:SetField('Value',cInttraRef)                            //[ContractNumber, ContractPartyReferenceNumber, FreightForwarderRefNumber, FreightTariffNumber ]
             oNV5A:SetField(EAtt():New("Type","INTTRAReferenceNumber"))    //[INTTRAReferenceNumber,OutboundBookingAgentRefNumber, PurchaseOrderNumber, ShipperReferenceNumber ] 
             oNV5A:SetField(ETag():New("",""))                             //[VehicleIdentificationNumber]
              
          oNv4A:SetField('ReferenceInformation',oNv5A)          
          EndIf
          If Type('cBooking') == 'C' .And. !Empty(cBooking)
             oNV5A := ENode():New()                                        //Att->[BillOfLadingNumber, BookingNumber, ConsigneeReferenceNumber,ContractLineItemNumber]
             oNV5A:SetField('Value',cBooking)                              //[ContractNumber, ContractPartyReferenceNumber, FreightForwarderRefNumber, FreightTariffNumber ]
             oNV5A:SetField(EAtt():New("Type","BookingNumber"))            //[INTTRAReferenceNumber,OutboundBookingAgentRefNumber, PurchaseOrderNumber, ShipperReferenceNumber ] 
             oNV5A:SetField(ETag():New("",""))                             //[VehicleIdentificationNumber]
              
          oNv4A:SetField('ReferenceInformation',oNv5A)          
          EndIf
          
          aPedidos := DetPedidos(EEC->EEC_PREEMB)
          For i:= 1 To Len(aPedidos) 
             oNV5A := ENode():New()                                        //Att->[BillOfLadingNumber, BookingNumber, ConsigneeReferenceNumber,ContractLineItemNumber]
             oNV5A:SetField('Value',aPedidos[i])                           //[ContractNumber, ContractPartyReferenceNumber, FreightForwarderRefNumber, FreightTariffNumber ]
             oNV5A:SetField(EAtt():New("Type","PurchaseOrderNumber"))      //[INTTRAReferenceNumber,OutboundBookingAgentRefNumber, PurchaseOrderNumber, ShipperReferenceNumber ] 
             oNV5A:SetField(ETag():New("",""))                             //[VehicleIdentificationNumber]
              
          oNv4A:SetField('ReferenceInformation',oNv5A)             
          Next i
          
             oNV5A := ENode():New()                                        //Att->[BillOfLadingNumber, BookingNumber, ConsigneeReferenceNumber,ContractLineItemNumber]
             oNV5A:SetField('Value',AllTrim(cId))                          //[ContractNumber, ContractPartyReferenceNumber, FreightForwarderRefNumber, FreightTariffNumber ]
             oNV5A:SetField(EAtt():New("Type","ShipperReferenceNumber"))   //[INTTRAReferenceNumber,OutboundBookingAgentRefNumber, PurchaseOrderNumber, ShipperReferenceNumber ] 
             oNV5A:SetField(ETag():New("",""))                             //[VehicleIdentificationNumber]
              
          oNv4A:SetField('ReferenceInformation',oNv5A) 
          //------------REFERENCE INFORMATION------------ /OK/
          /* //**OMITED  
             oNV5A := ENode():New()  
             oNV5A:SetField('Value',"_Value_")
       
                oNV6A := ENode():New()                           //Att->[Date]
                oNV6A:SetField(EAtt():New("Type","Date"))
           	    oNV6A:SetField(ETag():New("",""))
                                                                 //Att->[ExpiryDate,IssueDate]
          		oNV6A:SetField(EAtt():New("DateType","ExpiryDate"))
          		oNV6A:SetField(ETag():New("",Left(FWTimeStamp(3,Date(),Time()),19)))       
        
             oNV5A:SetField('DateTime',oNV6A) 
        
          oNv4A:SetField('ExportLicense',oNv5A)
          */
    //--------------------------------------TransportationDetails----------------------------------------------------------     
             oNV5A := ENode():New()
        
                oNV6A := ENode():New()                              //Field->[Barge, ContainerShip, OceanVessel, Rail, Road, Ship]                   
                oNV6A:SetField('Type',"ContainerShip")                                                         
                
                If !Empty(cNvNome)
                   oNV7A := ENode():New()                           //Att->[LloydsCode,VesselName,VoyageNumber]
                   oNV7A:SetField(EAtt():New("Type","VesselName"))
                   oNV7A:SetField(ETag():New("",cNvNome))                    
                   oNV6A:SetField('Identifier',oNV7A)
                EndIf
                If !Empty(cNvViagem) 
                   oNV7A := ENode():New()                           //Att->[LloydsCode,VesselName,VoyageNumber]
                   oNV7A:SetField(EAtt():New("Type","VoyageNumber"))
                   oNV7A:SetField(ETag():New("",cNvViagem))                    
                   oNV6A:SetField('Identifier',oNV7A)
                EndIf
                /* //**OMITED
                oNV6A:SetField('RegistrationCountryCode',"55")
                */
                   oNV7A := ENode():New()                           //Att->[SCACCode]
                   oNV7A:SetField(EAtt():New("Type","SCACCode"))
                   oNV7A:SetField(ETag():New("",cArmID))                                               
                oNV6A:SetField('OperatorIdentifier',oNV7A)
          
             oNV5A:SetField('ConveyanceInformation',oNv6A)
             
             //---------LOCATION-------------//
             oNv5A:lUniqueField := .F.
             For i := 1 To 2   
                oNV6A := ENode():New()
                
                If i == 1
                   oNV6A:SetField('Type',"PortOfLoad")                                              //Field->[PortOfLoad, PortOfDischarge] 
                      oNV7A := ENode():New()                                                        //Att->[UNLOC, PartnerAlias]
                      oNV7A:SetField(EAtt():New("Type","UNLOC"))
                      oNV7A:SetField( ETag():New("",cPtOriLC) )
                   oNV6A:SetField('Identifier',oNV7A)
                   oNV6A:SetField('Name',cPtOriNM) 
                   /*//**OMITED
                   oNV6A:SetField('City','')
                   oNV6A:SetField('Subdivision','')
                   oNV6A:SetField('CountryName','')
                   oNV6A:SetField('CountryCode','')
                   */
                   If !Empty(cPtOriETD)  
                      oNV7A := ENode():New()                        
                      oNV7A:SetField(EAtt():New("Type","Date"))                                      //Att->[Date,DateTime]
                      oNV7A:SetField(ETag():New("","")) 
                                                                                     
                      oNV7A:SetField(EAtt():New("DateType","EarliestDeparture"))                     //Att->[EstimatedArrival, EarliestDeparture]
                      oNV7A:SetField(ETag():New("",""))                                             
                      oNV7A:SetField(ETag():New("",Left(FWTimeStamp(3,sToD(cPtOriETD),Time()),19))) 
                    oNV6A:SetField('DateTime',oNV7A)                                                                                                      
                   EndIf                                                           
                Else
                
                   oNV6A:SetField('Type',"PortOfDischarge")                                         //Field->[PortOfLoad, PortOfDischarge] 
                      oNV7A := ENode():New()                                                        //Att->[UNLOC, PartnerAlias]
                      oNV7A:SetField(EAtt():New("Type","UNLOC"))
                      oNV7A:SetField( ETag():New("",cPtDesLC) )
                   oNV6A:SetField('Identifier',oNV7A)
                   oNV6A:SetField('Name',cPtDesNM) 
                   /*//**OMITED
                   oNV6A:SetField('City','')
                   oNV6A:SetField('Subdivision','')
                   oNV6A:SetField('CountryName','')
                   oNV6A:SetField('CountryCode','')
                   */
                   If !Empty(cPtDesETA)  
                      oNV7A := ENode():New()                        
                      oNV7A:SetField(EAtt():New("Type","Date"))                                      //Att->[Date,DateTime]
                      oNV7A:SetField(ETag():New("","")) 
                                                                                     
                      oNV7A:SetField(EAtt():New("DateType","EstimatedArrival"))                     //Att->[EstimatedArrival, EarliestDeparture]
                      oNV7A:SetField(ETag():New("",""))                                             
                      oNV7A:SetField(ETag():New("",Left(FWTimeStamp(3,sToD(cPtDesETA),Time()),19)))                                                                               
                   oNV6A:SetField('DateTime',oNV7A)  
                   EndIf                                                                        
                EndIf
                    
             oNV5A:SetField('Location',oNv6A)         
             Next i
             //---------LOCATION-------------//
                                                                               //Att->[InlandWaterTransport, MaritimeTransport, Rail/RoadTransport, Rail/WaterTransport]
             oNV5A:SetField(EAtt():New("TransportMode","InlandWaterTransport")) //     [RailTransport, Road/WaterTransport, RoadTransport]
      		 oNV5A:SetField(ETag():New("",""))  
                                                                               //Att->[PreCarriage, Main, OnCarriage]
       		 oNV5A:SetField(EAtt():New("TransportStage","Main"))
             oNV5A:SetField(ETag():New("",""))  
                                                  
          oNv4A:SetField('TransportationDetails',oNv5A) 
    
    //--------------------------------------End TransportationDetails----------------------------------------------------------
          //---------PARTY-------------//
          For i:= 1 To 4                          //Party -> Min. Occurs = 2
          
             IF i # 4
                oNv5A := Enode():New()
                oNv5A:SetField("Role", If(i == 1,"Booker",If(i==2,"Carrier","Shipper")) )  //Field->[*Carrier, *Booker, *Shipper, ContractParty, FreightPayer, Forwarder]
                oNv5A:SetField("Name", If(i#2,cPartName1,cArmName1) )                                           //       [MessageRecipient, FirstAdditionalNotifyParty, SecondAdditionalNotifyParty]
                                                                                                             //       [MainNotifyParty]
                   oNV6A := ENode():New()                                                   //Att->[DUNSNumber, INTTRACompanyID, PartnerAlias, PassThroughCode]
                   //oNV6A:SetField(EAtt():New("Type",If(i#2,"INTTRACompanyID","PartnerAlias"))) 
                   oNV6A:SetField(EAtt():New("Type","PartnerAlias"))
                   oNV6A:SetField(ETag():New("", If(i#2,cPartID,cArmID) ))
                oNv5A:SetField("Identifier",oNv6A)                     
               /* //**OMITED
                   oNv6A := Enode():New()   
          		   oNv6A:SetField("StreetAddress","")       
          		   oNv6A:SetField("CityName","")       
          		   oNv6A:SetField("SubDivision","")
          		   oNv6A:SetField("PostalCode","")
          		   oNv6A:SetField("CountryCode","")
          		   oNv6A:SetField("CountryName","")                                       
                oNv5A:SetField("Address",oNv6A)
               */ 
                If i # 2
          		   oNv6A := Enode():New()

          		   oNv6A:SetField("Type","InformationContact")                      //Field->[NotificationContact,InformationContact]
          		   oNv6A:SetField("Name",cContPartN_)
        
                      oNv7A := Enode():NEw()                  
                      If cContPartT_ == "Telephone"
                         oNv7A:SetField('Phone',cContPartV_)
                      ElseIf cContPartT_ == "Fax"
                         oNv7A:SetField('Fax'  ,cContPartV_)
                      ElseIf cContPartT_ == "Email"
                         oNv7A:SetField('Email',cContPartV_)
                      EndIf    
              
                   oNv6A:SetField("CommunicationDetails",oNv7A) 
                
                oNv5A:SetField("Contacts",oNv6A)
                EndIf
                //(ChargeCategory)**OMITED**//
                /* 
                If (i==1 .And. cMdlFrete == "Prepaid") .Or. (i==3 .and. cMdlFrete == "Collect" )    //NCF - 27/05/2013 - Modl. Frete INTTRA Prepaid e Info. do Booker
                   oNv6A := Enode():New()                                                           //NCF - 27/05/2013 - Modl. Frete INTTRA Collect e Info. do Shipper
                                                                           //Att->[AdditionalCharges,OceanFreight,DestinationHaulageCharges]
                   oNV6A:SetField(EAtt():New("ChargeType","OceanFreight")) //     [DestinationTerminalHandling,OriginHaulageCharges,OriginTerminalHandling]
                   oNV6A:SetField(ETag():New("",""))                 
                      
                      oNv7A := Enode():NEw()                                         //Att->[Collect,PrePaid,ThirdParty]
                      If cMdlFrete == "Prepaid"
                         oNV7A:SetField(EAtt():New("PrepaidorCollectIndicator","PrePaid"))
                      Else
                         oNV7A:SetField(EAtt():New("PrepaidorCollectIndicator","Collect"))
                      EndIf
                         oNV7A:SetField(ETag():New("",cContPartV_))
                         
                   oNv6A:SetField("PrepaidCollector",oNv7A) 
             
                      oNv7A := Enode():NEw()                  
                      
                      oNv7A:SetField("Type","PrepaidChargeLocation")

                         oNV8A := ENode():New()                                       //Att->[UNLOC, PartnerAlias]
                         oNV8A:SetField(EAtt():New("Type","UNLOC"))
                         oNV8A:SetField(ETag():New("",If(cMdlFrete == "Prepaid",cPtOriLC,cPtDesLC)))
                      oNv7A:SetField("Identifier",oNv8A)
                      
                      //oNv7A:SetField("Name","_Phone_")
                	  //oNv7A:SetField("City","_Phone_") 
                	  //oNv7A:SetField("SubDivision","ST")
                	  //oNv7A:SetField("CountryName","_Phone_")
                      //oNv7A:SetField("CountryCode","55")            
             
                   oNv6A:SetField("ChargeLocation",oNv7A)                                                                   
                oNv5A:SetField("ChargeCategory",oNv6A)  
             
                EndIf              
                */
             ELSE  //4º Loop *******INICIO DA INCLUSAO da Tag <PARTY> referente ao Pagador do Frete conforme a modalidade na aba INTTRA********  
          
             //NCF - 27/05/2013 - Modl. Frete INTTRA Prepaid e Info. do Booker
             //NCF - 27/05/2013 - Modl. Frete INTTRA Collect e Info. do Shipper
             oNv5A := Enode():New()
             oNv5A:SetField("Role", "FreightPayer" )                                                         //Field->[*Carrier, *Booker, *Shipper, ContractParty, FreightPayer, Forwarder]

   			
             oNv5A:SetField("Name", AllTrim(EXL->EXL_FRPAYE)     )
             
             //oNv5A:SetField("Name", Left(AllTrim(EXL->EXL_CLAUFR), 35))
             

			/* 
                oNV6A := ENode():New()                                                   //Att->[DUNSNumber, INTTRACompanyID, PartnerAlias, PassThroughCode]
                //oNV6A:SetField(EAtt():New("Type",If(i#2,"INTTRACompanyID","PartnerAlias"))) 
                oNV6A:SetField(EAtt():New("Type","PartnerAlias"))
                oNV6A:SetField(ETag():New(""    ,   cPartID    ))
             oNv5A:SetField("Identifier",oNv6A)
			*/
			//***
			
            /* //**OMITED
                oNv6A := Enode():New()   
          		oNv6A:SetField("StreetAddress","")       
          		oNv6A:SetField("CityName","")       
          		oNv6A:SetField("SubDivision","")
          		oNv6A:SetField("PostalCode","")
          		oNv6A:SetField("CountryCode","")
          		oNv6A:SetField("CountryName","")                                       
             oNv5A:SetField("Address",oNv6A)
            */ 
          		//oNv6A := Enode():New()

          		//oNv6A:SetField("Type","InformationContact")                      //Field->[NotificationContact,InformationContact]
          		//oNv6A:SetField("Name",AllTrim(EXL->EXL_FRPAYE))
        
                //oNv7A := Enode():NEw()                  
              
                //oNv6A:SetField("CommunicationDetails",oNv7A) 
                
              //oNv5A:SetField("Contacts",oNv6A)

                oNv6A := Enode():New()                                                           
                                                                           //Att->[AdditionalCharges,OceanFreight,DestinationHaulageCharges]
                   oNV6A:SetField(EAtt():New("ChargeType",cChargeType)) //     [DestinationTerminalHandling,OriginHaulageCharges,OriginTerminalHandling]
                   oNV6A:SetField(ETag():New("",""))
                      
                   oNv7A := Enode():NEw()                                         //Att->[Collect,PrePaid,ThirdParty]
                   oNV7A:SetField(EAtt():New("PrepaidorCollectIndicator",cMdlFrete))


				   oNV7A:SetField(ETag():New("",cContPartV_))
                         
                   oNv6A:SetField("PrepaidCollector",oNv7A) 
             
                      oNv7A := Enode():NEw()                  
                      
                      oNv7A:SetField("Type","PrepaidChargeLocation")

                         oNV8A := ENode():New()                                       //Att->[UNLOC, PartnerAlias]
                         oNV8A:SetField(EAtt():New("Type","UNLOC"))
                         oNV8A:SetField(ETag():New("",cLcFreLC))
                      oNv7A:SetField("Identifier",oNv8A)
                      
                      oNv7A:SetField("Name",cLcFreNM)
                	  
                	  //oNv7A:SetField("City","_Phone_") 
                	  //oNv7A:SetField("SubDivision","ST")
                	  //oNv7A:SetField("CountryName","_Phone_")
                      //oNv7A:SetField("CountryCode","55")            
             
                oNv6A:SetField("ChargeLocation",oNv7A)                                                                   
             oNv5A:SetField("ChargeCategory",oNv6A)  
             //*******FIM DA INCLUSAO da Tag <PARTY> referente ao Pagador do Frete conforme a modalidade na aba INTTRA********             
             /**/
          ENDIF
          
          oNv4A:lUniqueField := .F.
          oNv4A:SetField('Party',oNv5A)
           
          Next i
                 
        //---------PARTY-------------//
        
       oNv3A:SetField('MessageProperties',oNv4A)  //(NV3)MessageProperties
 
 //---------------------------------------------------(NV2)MessageBody----------------------------------------------------------//
 
 //---------------------------------------------------(NV2)MessageDetails-------------------------------------------------------//
         //--------GOODS_DETAILS----------//
         oNv4A      := ENode():New()         
         For i := 1 To Len(aEmbalagens)
 
            oNv5A := ENode():New()
            oNv5A:lUniqueField := .F.
            oNv5A:SetField('LineNumber',i)
    
               oNv6A := ENode():New()
       
                  oNv7A := ENode():New()
                  oNv7A:SetField('NumberOfPackages',AllTrim(Str(aEmbalagens[i][4])))
                  oNv7A:SetField('PackageTypeCode',"PC")
                  oNv7A:SetField('PackageTypeDescription',left(aEmbalagens[i][3],35)) //NCF - 26/07/2012 - Descrição da Embalagem continente
                  /* //**OMITED //LRS - 29/06/2016 - O inttra não permite descrições de embalagem com mais de 35 caracteres(ERROR 261756).
                     oNv8A := ENode():New()                     //Att->[FTQ,MTQ]
                     oNv8A:SetField(EAtt():New("UOM","FTQ"))
                     oNv8A:SetField(ETag():New("","0"))                  
                  
                  oNv7A:SetField('GoodGrossVolume',oNV8A)
                  */
                  If Empty(EEC->EEC_UNIDAD) .or.  AvVldUn(EEC->EEC_UNIDAD) // MPG - 06/02/2018
                     oNv8A := ENode():New()                     //Att->[KGM,LBS]
                     oNv8A:SetField(EAtt():New("UOM","KGM"))
                     oNv8A:SetField(ETag():New("",Transform(EEC->EEC_PESBRU,"99999999999999.999")))                                    
                  oNv7A:SetField('GoodGrossWeight',oNv8A)
                  
                  ElseIf !Empty(EEC->EEC_UNIDAD) .and. ! AvVldUn(EEC->EEC_UNIDAD) // MPG - 06/02/2018
                     oNv8A := ENode():New()                     //Att->[KGM,LBS]
                     oNv8A:SetField(EAtt():New("UOM","KGM"))
                     oNv8A:SetField(ETag():New("",Transform(AvTransUnid(EEC->EEC_UNIDAD,"KG",EE9->EE9_COD_I,EEC->EEC_PESBRU,.F.),"99999999999999.999")))                                    
                  oNv7A:SetField('GoodGrossWeight',oNv8A)            
                  
                  EndIf
                  /* //**OMITED
                     oNv8A := ENode():New()
                     oNv8A:SetField('NumberOfPackages',"1")
                     oNv8A:SetField('PackageTypeCode',"__")
                     oNv8A:SetField('PackageTypeDescription',"__")
             
                        oNv9A := ENode():New()                     //Att->[FTQ,MTQ]
                        oNv9A:SetField(EAtt():New("UOM","FTQ"))
                        oNv9A:SetField(ETag():New("","0"))                             
                           oNv8A:SetField('GoodGrossVolume',oNv9A)

                        oNv9A := ENode():New()                     //Att->[KGM,LBS]
                        oNv9A:SetField(EAtt():New("UOM","KGM"))
                        oNv9A:SetField(ETag():New("","0"))                                          
                     oNv8A:SetField('GoodGrossWeight',oNv9A)
             
                        oNv9A := ENode():New()
                        oNv9A:SetField('NumberOfPackages',"1")
                        oNv9A:SetField('PackageTypeCode',"__")
                		oNv9A:SetField('PackageTypeDescription',"__")
                
                           oNV10A := ENode():New()                           //Att->[FTQ,MTQ]
                           oNV10A:SetField(EAtt():New("UOM","FTQ"))
                           oNV10A:SetField(ETag():New("","0"))                
                
                        oNv9A:SetField('GoodGrossVolume',oNV10A)
                                
                           oNV10A := ENode():New()                           //Att->[FTQ,MTQ]
                           oNV10A:SetField(EAtt():New("UOM","KGM"))
                           oNV10A:SetField(ETag():New("","0"))                

                        oNv9A:SetField('GoodGrossWeight',oNV10A)                          
                     oNv8A:SetField('InnerInnerPack',oNv9A)                       
                  oNv7A:SetField('InnerPack',oNv8A)
                  */                 
               oNv6A:SetField('OuterPack',oNv7A) 
              
            oNv5A:SetField('PackageDetail',oNv6A)
            /*//**OMITED
               oNv6A := ENode():New()                           //Att->[USHTS,SchedB]
               oNv6A:SetField(EAtt():New("Type","USHTS"))
             //oNv6A:SetField(ETag():New("",""))                        
            oNv5A:SetField('CommodityClassification',oNv6A)
            */
            EE9->(DbSetORder(3))
            EE9->(DbSeek(xFilial("EE9")+EEC->EEC_PREEMB+aEmbalagens[i][1]))
            oNv5A:SetField('GoodDescription',Posicione("SB1",1,xFIlial("SB1")+EE9->EE9_COD_I,"B1_DESC"))
            /*//**OMITED
               oNv6A := ENode():New()
               oNv6A:SetField('CustomsDeclarationInfoValue',"__") 
                                                        //Att->[CCN,UCR]
               oNv6A:SetField(EAtt():New("Type","CCN"))
             //oNv6A:SetField(ETag():New("",""))                       
            oNv5A:SetField('CustomsDeclarationInformation',oNv6A)
    
               oNv6A := ENode():New()
                                                        //Att->[Feet,Meter]
               oNv6A:SetField(EAtt():New("UOM","Feet"))
             //oNv6A:SetField(ETag():New("","")) 
       
               oNv6A:SetField('Length',"0")
               oNv6A:SetField('Width',"0")
               oNv6A:SetField('Height',"0")       
                               
            oNv5A:SetField('OutOfGaugeDimensions',oNv6A) 

               oNv6A := ENode():New()
                                                        //Att->[StockKeepingUnit, VehicleIdentificationNumber, PurchaseOrderNumber]
               oNv6A:SetField(EAtt():New("Type","PurchaseOrderNumber"))
             //oNv6A:SetField(ETag():New("",""))        
               oNv6A:SetField('Value',"__")                       
            oNv5A:SetField('DetailsReferenceInformation',oNv6A)     
    
               oNv6A := ENode():New()
               oNv6A:SetField('Value',"__")
       
                  oNv7A := ENode():New()                             //Att->[Date]
                  oNv7A:SetField(EAtt():New("Type","Date"))
                  oNv7A:SetField(ETag():New("",""))
          
                //oNv7A := ENode():New()                           //Att->[ExpiryDate,IssueDate]
                  oNv7A:SetField(EAtt():New("DateType","ExpiryDate"))
                  oNv7A:SetField(ETag():New("",Left(FWTimeStamp(3,Date(),Time()),19)))              
       
               oNv6A:SetField('DateTime',oNv7A)                      
            oNv5A:SetField('ExportLicense',oNv6A) 
    
               oNv6A := ENode():New()
       		   oNv6A:SetField('EquipmentIdentifier',"__")
               oNv6A:SetField('NumberOfPackages',"0")
              
                  oNv7A := ENode():New()                     //Att->[FTQ,MTQ]
                  oNv7A:SetField(EAtt():New("UOM","FTQ"))
                  oNv7A:SetField(ETag():New("","0"))                             
               oNv6A:SetField('GrossVolume',oNv7A)

                  oNv7A := ENode():New()                     //Att->[KGM,LBS]
                  oNv7A:SetField(EAtt():New("UOM","KGM"))
                  oNv7A:SetField(ETag():New("","0"))                                          
               oNv6A:SetField('GrossWeight',oNv7A)
                                
            oNv5A:SetField('SplitGoodsDetails',oNv6A)
            */ 
               //-----HAZARDOUS_GOODS--------//
            EYJ->(DbSetOrder(1))
            EYJ->(DbSeek(xFilial("EYJ")+aEmbalagens[i][2])) 
               
            If EYJ->(!EOF()) .and. !Empty(EYJ->EYJ_GRAVID)               
               oNv6A := ENode():New()
               
                  If EYJ->EYJ_GRAVID == "1"
                     If !Empty(EYJ->EYJ_IMO)
                        oNv6A:SetField('IMOClassCode',Left(EYJ->EYJ_IMO,7))
                     EndIf
                     If !Empty(EYJ->EYJ_IMDG)
                        oNv6A:SetField('IMDGPageNumber',Left(EYJ->EYJ_IMDG,7))
                     EndIf
                     /*//**OMITED
                     oNv6A:SetField('HazardCodeVersionNumber',"__")
                     */                                                                                                        //Field->[GreatDanger, MediumDanger, MinorDanger]
                     oNv6A:SetField('PackingGroupCode',"MinorDanger")
       		         If !Empty(EYJ->EYJ_UNDG)
       		           oNv6A:SetField('UNDGNumber',Left(EYJ->EYJ_UNDG,4))
                     EndIf
                     If !Empty(EYJ->EYJ_TEMRIS) 
                        oNv7A := ENode():New()                     //Att->[CEL,FAH]
                        oNv7A:SetField(EAtt():New("UOM","CEL"))
                        oNv7A:SetField(ETag():New("",Strzero(EYJ->EYJ_TEMRIS,4,1)))                                          
                     oNv6A:SetField('FlashPointTemperature',oNv7A)
                     EndIf
                     /*//**OMITED
       		         oNv6A:SetField('EMSNumber',"__")
       		   		 oNv6A:SetField('TremCardNumber',"__")
       		   		 */
       		   		 oNv6A:SetField('ProperShippingName',EYJ->EYJ_NOMPER)
       		   		 /*//**OMITED
       		   		 oNv6A:SetField('TransportInLimitedQuantities',"true")
       		   		 oNv6A:SetField('TechnicalName',"__")
       		   		 oNv6A:SetField('EmptyUncleanedReceptacle',"true")
       		   		 oNv6A:SetField('MarinePollutantStatus',"MarinePollutant")  //Field->[MarinePollutant, NotMarinePollutant, SevereMarinePollutant]
       		   		 oNv6A:SetField('InhalantHazard',"true")
       		   		 oNv6A:SetField('AggregationState',"Liquid")                //Field->[Solid, Liquid, Gas]
                     */
                     If !Empty(EYJ->EYJ_CCOMPE)
                        oNv7A := ENode():New()
          		        oNv7A:SetField('Category',"GeneralHazmatComments")      //Field->[GeneralHazmatComments,RadioactiveGoodsAdditionalInstructions, RegulatoryInformation, HazmatPlacardInformation ]
          		        oNv7A:SetField('Text',EYJ->(MSMM(EYJ_CCOMPE,AVSX3("EYJ_COMPER",3),,,3)))                 
       		         oNv6A:SetField('HazardousGoodsComments',oNv7A)
       		         EndIf
                     /*//**OMITED
       		         oNv6A:SetField('IntermedBulkContainerCode',"__")
                     */
                     If !Empty(EYJ->EYJ_CTNAME) .and. !Empty(EYJ->EYJ_CTTEL)
                        oNv7A := ENode():New()
          		        oNv7A:SetField('Type',"HazardousMaterialsContact")      //Field->[HazardousMaterialsContact]
          		        oNv7A:SetField('Name',Left(EYJ->EYJ_CTNAME,35))
             		       oNv8A := ENode():New()
                           oNv8A:SetField('Phone',Left(EYJ->EYJ_CTTEL,35))                   
          		        oNv7A:SetField('CommunicationDetails',oNv8A)          		                              
       		         oNv6A:SetField('EmergencyResponseContact',oNv7A)              
                     EndIf
                  EndIf
                  If EYJ->EYJ_GRAVID == "2"
                     If !Empty(EYJ->EYJ_IMO)
                        oNv6A:SetField('IMOClassCode',Left(EYJ->EYJ_IMO,7))
                     EndIf
                     If !Empty(EYJ->EYJ_IMDG)
                        oNv6A:SetField('IMDGPageNumber',Left(EYJ->EYJ_IMDG,7))
                     EndIf
                     
                     oNv6A:SetField('HazardCodeVersionNumber',"1")
                     oNv6A:SetField('PackingGroupCode',"MediumDanger")  //Field->[GreatDanger, MediumDanger, MinorDanger]
       		         If !Empty(EYJ->EYJ_UNDG)
       		           oNv6A:SetField('UNDGNumber',Left(EYJ->EYJ_UNDG,4))
                     EndIf
                     If !Empty(EYJ->EYJ_TEMRIS) 
                        oNv7A := ENode():New()                     //Att->[CEL,FAH]
                        oNv7A:SetField(EAtt():New("UOM","CEL"))
                        oNv7A:SetField(ETag():New("",Strzero(EYJ->EYJ_TEMRIS,4,1)))                                          
                     oNv6A:SetField('FlashPointTemperature',oNv7A)
                     EndIf
                     /* //**OMITED
       		         oNv6A:SetField('EMSNumber',"__")
       		   		 oNv6A:SetField('TremCardNumber',"__")
       		   		 */
       		   		 oNv6A:SetField('ProperShippingName',EYJ->EYJ_NOMPER)
       		   		 /*
       		   		 oNv6A:SetField('TransportInLimitedQuantities',"true")
       		   		 oNv6A:SetField('TechnicalName',"__")
       		   		 oNv6A:SetField('EmptyUncleanedReceptacle',"true")
       		   		 oNv6A:SetField('MarinePollutantStatus',"MarinePollutant")  //Field->[MarinePollutant, NotMarinePollutant, SevereMarinePollutant]
       		   		 oNv6A:SetField('InhalantHazard',"true")
       		   		 oNv6A:SetField('AggregationState',"Liquid")                //Field->[Solid, Liquid, Gas]
                     */
                     If !Empty(EYJ->EYJ_CCOMPE)
                        oNv7A := ENode():New()
          		        oNv7A:SetField('Category',"GeneralHazmatComments")      //Field->[GeneralHazmatComments,RadioactiveGoodsAdditionalInstructions, RegulatoryInformation, HazmatPlacardInformation ]
          		        oNv7A:SetField('Text',EYJ->(MSMM(EYJ_CCOMPE,AVSX3("EYJ_COMPER",3),,,3)))                 
       		         oNv6A:SetField('HazardousGoodsComments',oNv7A)
       		         EndIf
                     /*//**OMITED
       		         oNv6A:SetField('IntermedBulkContainerCode',"__")
                     */
                     If !Empty(EYJ->EYJ_CTNAME) .and. !Empty(EYJ->EYJ_CTTEL)
                        oNv7A := ENode():New()
          		        oNv7A:SetField('Type',"HazardousMaterialsContact")      //Field->[HazardousMaterialsContact]
          		        oNv7A:SetField('Name',Left(EYJ->EYJ_CTNAME,35))
             		       oNv8A := ENode():New()
                           oNv8A:SetField('Phone',Left(EYJ->EYJ_CTTEL,35))                   
          		        oNv7A:SetField('CommunicationDetails',oNv8A)          		                              
       		         oNv6A:SetField('EmergencyResponseContact',oNv7A)              
                     EndIf
                  EndIf
                  If EYJ->EYJ_GRAVID == "3"
                     If !Empty(EYJ->EYJ_IMO)
                        oNv6A:SetField('IMOClassCode',Left(EYJ->EYJ_IMO,7))
                     EndIf
                     If !Empty(EYJ->EYJ_IMDG)
                        oNv6A:SetField('IMDGPageNumber',Left(EYJ->EYJ_IMDG,7))
                     EndIf
                     
                     oNv6A:SetField('HazardCodeVersionNumber',"1")
                     oNv6A:SetField('PackingGroupCode',"GreatDanger")  //Field->[GreatDanger, MediumDanger, MinorDanger]
       		         If !Empty(EYJ->EYJ_UNDG)
       		           oNv6A:SetField('UNDGNumber',Left(EYJ->EYJ_UNDG,4))
                     EndIf
                     If !Empty(EYJ->EYJ_TEMRIS) 
                        oNv7A := ENode():New()                     //Att->[CEL,FAH]
                        oNv7A:SetField(EAtt():New("UOM","CEL"))
                        oNv7A:SetField(ETag():New("",Strzero(EYJ->EYJ_TEMRIS,4,1)))                                          
                     oNv6A:SetField('FlashPointTemperature',oNv7A)
                     EndIf
                     /* //**OMITED
       		         oNv6A:SetField('EMSNumber',"__")
       		   		 oNv6A:SetField('TremCardNumber',"__")
       		   		 */
       		   		 oNv6A:SetField('ProperShippingName',EYJ->EYJ_NOMPER)
       		   		 /*
       		   		 oNv6A:SetField('TransportInLimitedQuantities',"true")
       		   		 oNv6A:SetField('TechnicalName',"__")
       		   		 oNv6A:SetField('EmptyUncleanedReceptacle',"true")
       		   		 oNv6A:SetField('MarinePollutantStatus',"MarinePollutant")  //Field->[MarinePollutant, NotMarinePollutant, SevereMarinePollutant]
       		   		 oNv6A:SetField('InhalantHazard',"true")
       		   		 oNv6A:SetField('AggregationState',"Liquid")                //Field->[Solid, Liquid, Gas]
                     */
                     If !Empty(EYJ->EYJ_CCOMPE)
                        oNv7A := ENode():New()
          		        oNv7A:SetField('Category',"GeneralHazmatComments")      //Field->[GeneralHazmatComments,RadioactiveGoodsAdditionalInstructions, RegulatoryInformation, HazmatPlacardInformation ]
          		        oNv7A:SetField('Text',EYJ->(MSMM(EYJ_CCOMPE,AVSX3("EYJ_COMPER",3),,,3)))                 
       		         oNv6A:SetField('HazardousGoodsComments',oNv7A)
       		         EndIf
                     /*//**OMITED
       		         oNv6A:SetField('IntermedBulkContainerCode',"__")
                     */
                     If !Empty(EYJ->EYJ_CTNAME) .and. !Empty(EYJ->EYJ_CTTEL)
                        oNv7A := ENode():New()
          		        oNv7A:SetField('Type',"HazardousMaterialsContact")      //Field->[HazardousMaterialsContact]
          		        oNv7A:SetField('Name',Left(EYJ->EYJ_CTNAME,35))
             		       oNv8A := ENode():New()
                           oNv8A:SetField('Phone',Left(EYJ->EYJ_CTTEL,35))                   
          		        oNv7A:SetField('CommunicationDetails',oNv8A)          		                              
       		         oNv6A:SetField('EmergencyResponseContact',oNv7A)              
                     EndIf
                  EndIf                
          	   /* //**OMITED
          		  oNv7A := ENode():New()                     //Att->[KGM,LBS]
          		  oNv7A:SetField(EAtt():New("UOM","KGM"))
        		  oNv7A:SetField(ETag():New("","0"))                                          
       		   oNv6A:SetField('HazardousGoodsWeight',oNv7A)

          		  oNv7A := ENode():New()                     //Att->[FTQ,MTQ,GAL,LTR]
          		  oNv7A:SetField(EAtt():New("UOM","FTQ"))
        		  oNv7A:SetField(ETag():New("","0"))       
       		   oNv6A:SetField('HazardousGoodsVolume',oNv7A) 

                  oNv7A := ENode():New()                     //Att->[MegaBecquerels]
                  oNv7A:SetField(EAtt():New("UOM","MegaBecquerels"))
                  oNv7A:SetField(ETag():New("","0"))       
               oNv6A:SetField('HazardousGoodsRadioactivity',oNv7A)

                  oNv7A := ENode():New()                     //Att->[PercentageOfAcidvsWater]
                  oNv7A:SetField(EAtt():New("UOM","PercantageOfAcidvsWater"))
                  oNv7A:SetField(ETag():New("","0"))         
               oNv6A:SetField('HazardousGoodsAcidConcentrtn',oNv7A)
       
                  oNv7A := ENode():New()
          		  oNv7A:SetField('EquipmentIdentifier',"__")
          		  oNv7A:SetField('NumberOfPackages',"0")
          
                     oNv8A := ENode():New()                     //Att->[FTQ,MTQ]
                     oNv8A:SetField(EAtt():New("UOM","FTQ"))
                     oNv8A:SetField(ETag():New("","0"))                             
                  oNv7A:SetField('GrossVolume',oNv8A)

                     oNv8A := ENode():New()                     //Att->[KGM,LBS]
                     oNv8A:SetField(EAtt():New("UOM","KGM"))
                     oNv8A:SetField(ETag():New("","0"))                                          
                  oNv7A:SetField('GrossWeight',oNv8A)
                                                      
               oNv6A:SetField('HazardousGoodsSplitDetails',oNv7A)
               */                               
            oNv5A:SetField('HazardousGoods',oNv6A)
             
            EndIf 
            
         oNv4A:SetField('GoodsDetails',oNv5A)
         Next i 
         
         //--------EQUIPMENT_DETAILS----------//
         For i:=1 To Len(aDetContainer)
            oNv5A := ENode():New()
            oNv5A:lUniqueField := .F. 
          /* //OMITED
               oNv6A := ENode():New()                     //Att->[ActualContainerNumber,LogicalContainerNumber]
               oNv6A:SetField(EAtt():New("EquipmentIdentifierType","ActualContainerNumber"))
               oNv6A:SetField(ETag():New("","00000"))
            oNv5A:SetField('EquipmentIdentifier',oNv6A)
          */
               oNv6A := ENode():New()
       		   oNv6A:SetField('EquipmentTypeCode',aDetContainer[i][1])
       		   //oNv6A:SetField('EquipmentDescription',"")                     
            oNv5A:SetField('EquipmentType',oNv6A)
      
    	    oNv5A:SetField('NumberOfEquipment',Alltrim(STR(/*Len(aDetContainer)*/aDetContainer[i][2]))) //NCF - 14/05/2013 - Quantidade prevista de Containeres por cada tipo de container
    
       		   oNv6A := ENode():New()
       		   oNv6A:SetField('CargoMovementType',"FCL/FCL")                                      //Field->[FCL/FCL, FCL/LCL]
       		   oNv6A:SetField('HaulageArrangements',cEnum_HlgArr)                                 //Field->[CarrierExportHaulageCarrierImportHaulage, CarrierExportHaulageMerchantImportHaulage]             
            oNv5A:SetField('ImportExportHaulage',oNv6A)                                           //       [MerchantExportHaulageCarrierImportHaulage, MerchantExportHaulageMerchantImportHaulage]
           /* //**OMITED
       		   oNv6A := ENode():New()                     //Att->[KGM,LBS]
               oNv6A:SetField(EAtt():New("UOM","KGM"))
               oNv6A:SetField(ETag():New("","0"))                                          
               oNv6A:SetField('EquipmentGrossWeight',oNv6A)
           
               oNv6A := ENode():New()                     //Att->[FTQ,MTQ]
               oNv6A:SetField(EAtt():New("UOM","MTQ"))
               oNv6A:SetField(ETag():New("","0"))                             
            oNv5A:SetField('EquipmentGrossVolume',oNv6A)

       		   oNv6A := ENode():New()                     //Att->[PercentOfMoistureInAir]
       		   oNv6A:SetField(EAtt():New("UOM","PercentOfMoistureInAir"))
     		   oNv6A:SetField(ETag():New("","0"))                 
            oNv5A:SetField('EquipmentHumidity',oNv6A)         
           */
            If !Empty(aDetContainer[i][4])
       		   oNv6A := ENode():New()                     //Att->[CBM,CBF]
       		   oNv6A:SetField(EAtt():New("UOM","CBM"))
     	       oNv6A:SetField(ETag():New("",aDetContainer[i][4]))                                 
   	 	    oNv5A:SetField('EquipmentAirFlow',oNv6A)                          
            EndIf    
            /*  //**OMITED
       		   oNv6A := ENode():New()                     //Att->[Percent]       
       		   oNv6A:SetField(EAtt():New("UOM","Percent"))
     		 //oNv6A:SetField(ETag():New("","")) 
                                                          //Att->[CarbonDioxide, Nitrogen, Oxygen]
       		   oNv6A:SetField(EAtt():New("Gas","Oxygen"))
     		   oNv6A:SetField(ETag():New("","0"))                                                                                                               
            oNv5A:SetField('EquipmentGasLevel',oNv6A)
    
       		   oNv6A := ENode():New()                     //Att->[Feet, Meter]       
       		   oNv6A:SetField(EAtt():New("UOM","Feet"))
     		 //oNv6A:SetField(ETag():New("",""))
     
       		   oNv6A:SetField('Length',"0")
       		   oNv6A:SetField('Width',"0")
       		   oNv6A:SetField('Height',"0")                              
    	    oNv5A:SetField('EquipmentDetailsDimensions',oNv6A) 
    
    	    oNv5A:SetField('NonActiveReefer',"true")
            */            
            
            If !Empty(aDetContainer[i][3])
       		   oNv6A := ENode():New()                     //Att->[CEL, FAH]       
       		   oNv6A:SetField(EAtt():New("UOM","CEL"))
     		   oNv6A:SetField(ETag():New("",aDetContainer[i][3]))
            oNv5A:SetField('EquipmentTemperature',oNv6A)
            EndIf
            /* //**OMITED
               oNv6A := ENode():New()
       	       oNv6A:SetField('EquipmentControlledAtmosphere',"true")
       		   oNv6A:SetField('SuperFreezerService',"true")
       		   oNv6A:SetField('GensetRequired',"true")
       		   oNv6A:SetField('Humidity',"true")
       		   oNv6A:SetField('InTransitColdSterilization',"true")
       		   oNv6A:SetField('NumberOfTemperatureProbes',"0")
       		   oNv6A:SetField('NumberOfUSDProbes',"0")
       		   oNv6A:SetField('TemperatureVariance',"0")
       		   oNv6A:SetField('VentSetting',"Closed")                //Field->[Open, Closed] 
            oNv5A:SetField('SpecialHandling',oNv6A)
    
       		   oNv6A := ENode():New()
       		   oNv6A:SetField('Category',"GeneralEquipmentComments")
       		   oNv6A:SetField('Text',"_text_")     //Field->[GeneralEquipmentComments, TemperatureControlInstructions]  
            oNv5A:SetField('EquipmentComments',oNv6A)
    
       		   oNv6A := ENode():New()                     //Att->[CCN, UCR]       
       		   oNv6A:SetField(EAtt():New("Type","CCN"))
     		 //oNv6A:SetField(ETag():New("",""))
     
       		   oNv6A:SetField('CustomsDeclarationInfoValue',"__")                           
    	    oNv5A:SetField('CustomsDeclarationInformation',oNv6A)
    
    	    oNv5A:SetField('StowageInstructions',"AboveDeck")                 //Field->[AboveDeck, BelowDeck]
            oNv5A:SetField('SpecialServiceRequest',"EquipmentCleanRequested") //Field->[EquipmentCleanRequested, FoodGradeEquipmentRequest, EquipmentSweepRequested, FumigationRequired]
                                                                             //       [GarmentOnHanger, HeavyWeightEquipment] 
       		   oNv6A := ENode():New()                                         //Att->[CustomerLoadPreference, PurchaseOrderNumber, VehicleIdentificationNumber]       
       		   oNv6A:SetField(EAtt():New("Type","PurchaseOrderNumber"))
     		 //oNv6A:SetField(ETag():New("",""))
     
       		   oNv6A:SetField('Value',"__")                           
    	    oNv5A:SetField('EquipmentReferenceInformation',oNv6A)
    
               oNv6A := ENode():New()
       		   oNv6A:SetField('Role',"ShipFromDoor")                           //Field->[ShipFromDoor, ShipToDoor, SubContractor, IntermediateStopOff, EmptyPickUp]
       		   oNv6A:SetField('Name',"__")
       
          		  oNv7A := ENode():New()                     //Att->[DUNSNumber, INTTRACompanyID, PartnerAlias, PassThroughCode]       
          		  oNv7A:SetField(EAtt():New("Type","DUNSNumber"))
                  oNv7A:SetField(ETag():New("","Ident"))       
       		   oNv6A:SetField('Identifier',oNv7A)

           	 	  oNv7A := Enode():New()   
          		  oNv7A:SetField("StreetAddress","_StreetAddress_")       
          		  oNv7A:SetField("CityName","__")       
          		  oNv7A:SetField("SubDivision","__")
          		  oNv7A:SetField("PostalCode","__")
          		  oNv7A:SetField("CountryCode","55")
          		  oNv7A:SetField("CountryName","__")                      
       		   oNv6A:SetField('Address',oNv7A)

                  oNv7A := ENode():New()                           //Att->[Date,DateTime]
          		  oNv7A:SetField(EAtt():New("Type","Date"))
          		  oNv7A:SetField(ETag():New("",""))
                                                                                 //Att->[ReqstDeliveryDateFullCont, ReqstPositionDateEmptyContAtDoor]
          		  oNv7A:SetField(EAtt():New("DateType","ReqstDeliveryDateFullCont"))     //     [ReqstPickUpDateAtStopOff, ReqstPickUpOfEmptyCont, ReqstPositionDateAtStopOff]
          		  oNv7A:SetField(ETag():New("",Left(FWTimeStamp(3,Date(),Time()),19)))
                       
        	   oNv6A:SetField('DateTime',oNv7A)

          		  oNv7A := Enode():New()   
          		  oNv7A:SetField("Type","InformationContact")                      //Field->[NotificationContact,InformationContact]
          		  oNv7A:SetField("Name","__") 
          
             		 oNv8A := Enode():New()   
                	 oNv8A:SetField("Phone","__")
                	 oNv8A:SetField("Fax","__")
               		 oNv8A:SetField("Email","abc@abc.com")
                          
          		  oNv7A:SetField('CommunicationDetails',oNv8A)       
       		   oNv6A:SetField('Contacts',oNv7A)                                  
            oNv5A:SetField('EquipmentParty',oNv6A)
            */                            
         oNv4A:SetField('EquipmentDetails',oNv5A)
         Next i
           
      oNv3A:SetField('MessageDetails',oNv4A) 
   oNv2A:SetField('MessageBody',oNv3A)

 //---------------------------------------------------(NV2)MessageDetails-------------------------------------------------------// 
 
  oNV2A:SetField(EAtt():New("xmlns:n1"            ,"http://xml.inttra.com/booking/services/01"))
  oNV2A:SetField(EAtt():New("xmlns:xsi"           ,"http://www.w3.org/2001/XMLSchema-instance"))
  oNV2A:SetField(EAtt():New("xmlns:schemaLocation","http://xml.inttra.com/booking/services/01 INTTRABooking2Request.xsd"))
  oNv1A:SetField("n1:Message",oNv2A)
 
  oXml      := EXml():New()
  oXml:AddRec(oNv1A)
 
  //cRet := '<?xml version="1.0" encoding="ISO-8859-1"?>'
  cRet :=  oXML:GetXML()    

Return cRet
