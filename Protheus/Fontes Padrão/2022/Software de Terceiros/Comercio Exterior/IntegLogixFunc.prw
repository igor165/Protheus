#Include 'Protheus.ch'
#Include 'Average.ch'

/*
Funcao      : EasyConvCod()
Parametros  : xCodERP, cAlias
Retorno     : cRet
Objetivos   : Retornar o codigo equivalente para o Protheus
Autor       : Felipe Sales Martinez - FSM / Guilherme Fernandes Pilan - GFP
Data/Hora   : 01/12/11
Revisao     :
Obs.        :
*/
Function EasyConvCod( xCodERP, cAlias )
Local cRet := ""
Local aOrd 
Begin Sequence
  
   Do Case
   
      Case UPPER(cAlias) == "SAH" //Unidade de Medida
      		aOrd := SaveOrd("SAH")
            SAH->(DBSetOrder(2))
            If SAH->( DBSeek(xFilial("SAH")+ xCodERP ) )
               cRet := SAH->AH_UNIMED
               Break
            Endif
            
      Case UPPER(cAlias) == "SYF" //Moedas           
            aOrd := SaveOrd("SYF")
            If SYF->(DbSetOrder(4), DbSeek(xFilial("SYF")+AvKey(xCodERP,"YF_CODCERP")) ) .Or.;
               SYF->(DbSetOrder(5), DbSeek(xFilial("SYF")+AvKey(xCodERP,"YF_CODVERP")) ) .Or.;
               SYF->(DbSetOrder(6), DbSeek(xFilial("SYF")+AvKey(xCodERP,"YF_CODFERP")) )

               cRet := SYF->YF_MOEDA

            EndIf
            
      Case UPPER(cAlias) == "SY6" //Cond. Pagamento
			aOrd := SaveOrd("SY6")
            SY6->(DBSetOrder(2)) //Y6_FILIAL+Y6_CODERP
            If SY6->( DBSeek(xFilial("SY6")+ AvKey(xCodERP,"Y6_CODERP") ) )
               cRet := SY6->Y6_COD
               Break
            Endif
       
       Case Upper(cAlias) == "SYA"
          cRet := xCodERP
          aOrd := SaveOrd("SYA")
          SYA->(DbSetOrder(3))
          If SYA->(DbSeek(xFilial()+AvKey(xCodERP, "YA_CODERP")))
             cRet := SYA->YA_CODGI
             Break
		  ElseIf !Empty(xCodERP)
             cRet := xCodERP
             Break
          EndIf
          
            

   EndCase

End Sequence

If Valtype(aOrd) == "A"
	RestOrd(aord, .T.)
EndIf

Return cRet


/*
Funcao      : EasyConvInfo()
Parametros  : cCampo,cInfo
Retorno     : xRet
Objetivos   : Converte a informação para o modelo do campo
Autor       : Felipe Sales Martinez - FSM / Guilherme Fernandes Pilan - GFP
Data/Hora   : 01/12/11
Revisao     :
Obs.        :
*/
Function EasyConvInfo(cCampo,cInfo)
Local xRet 

//Formata a informação de TimeStamp "AAAA-MM-DDtHH:MM:SS-TimeZone" para Caracter Normal "DD/MM/AA"
If AvSx3(cCampo,AV_TIPO) == "D"
   cInfo := EasyTimeStamp(cInfo, .F. )
   cInfo := DTOC(cInfo)//AWF - 12/05/2014 - a Funcao abaixo (AvConvert()) esta esperando uma data caracter
EndIf

xRet := AvConvert("C",AvSx3(cCampo,AV_TIPO),AvSx3(cCampo,AV_TAMANHO),cInfo)

If ValType(xRet) == "C"
    xRet := AvKey(xRet,cCampo)
    If Len(xRet) > AvSx3(cCampo,AV_TAMANHO)
       xRet := Left(xRet,AvSx3(cCampo,AV_TAMANHO))
    EndIf
EndIf

Return xRet


/*
Funcao      : AddArrayXML()
Parametros  : aCab, cCampo, oXML, cTag
Retorno     : Nil
Objetivos   : Adiciona no array a informação corretamente.
Autor       : Felipe Sales Martinez - FSM / Guilherme Fernandes Pilan - GFP
Data/Hora   : 01/12/11
Revisao     :
Obs.        :
*/
Function AddArrayXML(oRec, cCampo, oXML, cTag, lObrigat)
Local xInfo 

xInfo := EasyGetXMLinfo(cCampo, oXML, cTag )

//If !Empty(xInfo) .Or. lObrigat 
   //aAdd(aCab, {cCampo, xInfo , Nil} )
   oRec:AddField(EInfo():New(cCampo,xInfo))
//EndIf

Return Nil

/*
Funcao      : EasyGetXMLinfo()
Parametros  : cCampo, oXML, cTag
Retorno     : xRet
Objetivos   : Retorna a informacao extraida do XML
Autor       : Felipe Sales Martinez - FSM
Data/Hora   : 07/12/11
Revisao     :
Obs.        :
*/
Function EasyGetXMLinfo(cCampo, oXML, cTag)
Local xRet := ""
Default cCampo := ""
Private oMessage := oXML

If IsCpoInXML(oXML, cTag )
   
   //Se o campo estiver preenchido, a informação ja é convertida para o tipo e tamanho do campo equivalente
   If !Empty(cCampo)
      xRet := EasyConvInfo(cCampo, &("oMessage:"+Upper(cTag)+":Text") )
   Else
   //Se nao for informado o campo, apenas retorna a informação do XML
      xRet := &("oMessage:"+Upper(cTag)+":Text")                           //NCF - 31/03/2016 - Na P12 precisa rodar a Macro inteira e não parcial.
   EndIf

ElseIf !Empty(cCampo)
   xRet := EasyConvInfo(cCampo, xRet )
EndIf

Return xRet


/*
Funcao      : IsCpoInXML()
Parametros  : oXML, cTag
Retorno     : .T./.F.
Objetivos   : Retorna se o campo esta presente no XML
Autor       : Felipe Sales Martinez - FSM
Data/Hora   : 06/12/11
Revisao     :
Obs.        :
*/
Function IsCpoInXML(oXML, cTag )
Private oMessage := oXML
Return ( ValType(oMessage) == "O" .And. ValType(XmlChildEx(oMessage, Upper(cTag))) <> "U" )


/*
Funcao      : EasyFromTo()
Parametros  : oXML, cTag, xTo
Retorno     : xRet
Objetivos   : Recebe um valor caracter de um XML e retorna o correto
              valor para o campo no Easy
Autor       : Felipe Sales Martinez - FSM / Guilherme Fernandes Pilan - GFP
Data/Hora   : 06/12/11
Revisao     :
Obs.        :
*/
Function EasyFromTo(xXML, cTag, xTo)
Local xInfo
Local xRet := ""
Private xMessage := xXML

Begin Sequence
   
    If ValType(xMessage) == "O"
      //xInfo := xMessage&(":" + Upper(cTag) + ":Text")
       xInfo := EasyGetXMLinfo( , xMessage, cTag )
    Else
       xInfo := xMessage
    EndIf
    
      
    Do Case
       
       //Converte a informação de True/False para S/N:
       Case Upper(xTo) $ "S/N"
       
            If Upper(xInfo) == "TRUE" .OR. Upper(xInfo) == "1"
               xRet := "S"
            Else
               xRet := "N"
            EndIf
       
       //Retira os pontos da palavra:
       Case Upper(xTo) == "SEM_CARACTER_ESPECIAL"
            xRet := StrTran(xInfo , "." , "" ) 
            xRet := StrTran(xRet  , "/" , "" ) 
            xRet := StrTran(xRet  , "-" , "" )
       
    EndCase

End Sequence

Return xRet


/*
Funcao      : EasyTimeStamp()
Parametros  : xInfo, lTipo
Retorno     : xRet
Objetivos   : 
Autor       : Felipe Sales Martinez
Data/Hora   : 27/12/11
Revisao     :
Obs.        :
*/
Function EasyTimeStamp(xInfo, lTipo, lOnlyDate)
Local xRet := ""
Local nType := 3
Local cTime := Time()
Default lTipo := .T.
Default xInfo := Date()
Default lOnlyDate := .F.

//Tipo = .T. -> Funcionalidade normal do TimeStampo. Retorno no formato "AAAA-MM-DDt00:00:00-03:00"
If !Empty(xInfo)
	If lTipo
	   
	   If ValType(xInfo) == "C"
	       xInfo := cToD(xInfo)
	   EndIf
	
	   xRet := FWTimeStamp( nType, xInfo, cTime )
	   
	   If lOnlyDate // Tratamento para retornar somente "AAAA-MM-DD"
	      xRet := SubStr(xRet , 1, At("T", xRet)-1 )
	   EndIf
	
	//Tipo = .F. -> Inverte o formato de TimeStamp para data Normal. Retorna uma data   
	Else
	   
	   //Pegando a data:
	   If At("T", xInfo) > 0
	      xInfo := SubStr(xInfo , 1, At("T", xInfo)-1 ) //"2011-12-20T00:00:00-03:00" -> "2011-12-20"
	   EndIf
	   
	   //Retirando os '-':
	   xInfo := StrTransf(xInfo,"-","") //"2011-12-20" -> "20111220"
	   
	   //Formatando a data
	   xRet := SToD(xInfo) //"20111220" -> "20/12/2011"
	   
	EndIf
EndIf

Return xRet


/*
Funcao      : EasyGetBArray()
Parametros  : aData, cChave
Retorno     : xRet
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 09/12/11
Revisao     :
Obs.        :
*/
/*
Function EasyGetBArray(aData, cChave)
Local xRet := {}
Local nPos

	If (nPos := aScan(aData, {|x| x[1] == cChave })) > 0
		xRet := aData[nPos][2]
	EndIf
	
Return xRet
*/

/*
Funcao      : EasyGetCommonsValue()
Parametros  : oXML, cValue
Retorno     : xRet
Objetivos   : 
Autor       : Felipe Sales Martinez - FSM 
Data/Hora   : 06/12/11
Revisao     :
Obs.        :
*/
Function EasyGetCommonValue(oBusinessCont, cValue)
Local xInfo := ""
Local aArray := {}
Local nCont := 0

cValue := Upper(cValue)

Begin Sequence

   Do Case

       Case cValue == "CNPJ"
		    
		    If IsCpoInXML(oBusinessCont, "_GovernmentalInformation") //Verificando se os nós encontram-se no XML 
			   
			   If ValType(oBusinessCont:_GovernmentalInformation:_Id) == "A"
			      aArray := oBusinessCont:_GovernmentalInformation:_Id
			   Else
			      aArray := {oBusinessCont:_GovernmentalInformation:_Id}
			   EndIf
			    
			   For nCont := 1 To Len(aArray)
			           
				   If Upper(AllTrim(aArray[nCont]:_Name:TEXT)) == UPPER("CNPJ")
				       xInfo := Right( AllTrim( EasyFromTo(AllTrim(aArray[nCont]:TEXT), , "SEM_CARACTER_ESPECIAL") ) , 14)
				       Exit
				   EndIf

			   Next nCont
			    
		    EndIf
	
       Case cValue == "NIF"
		    
		    If IsCpoInXML(oBusinessCont, "_GovernmentalInformation") //Verificando se os nós encontram-se no XML 
			   
			   If ValType(oBusinessCont:_GovernmentalInformation:_Id) == "A"
			      aArray := oBusinessCont:_GovernmentalInformation:_Id
			   Else
			      aArray := {oBusinessCont:_GovernmentalInformation:_Id}
			   EndIf
			    
			   For nCont := 1 To Len(aArray)
			           
				   If Upper(AllTrim(aArray[nCont]:_Name:TEXT)) == UPPER("NIF")
				       xInfo := AllTrim( EasyFromTo(AllTrim(aArray[nCont]:TEXT), , "SEM_CARACTER_ESPECIAL") )
				       Exit
				   EndIf

			   Next nCont
			    
		    EndIf
	EndCase

End Sequence

Return xInfo
