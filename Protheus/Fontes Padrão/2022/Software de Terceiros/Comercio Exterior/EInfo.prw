/*
Classe      : Einfo
Parametros  : 
Retorno     : String XML
Objetivos   : Atualização de dicionários e helps
Autor       : Alessandro Alves Ferreira
Data/Hora   : Dezembro/2011
Revisao     : 02/10/2012 - Nilson César C. Filho
Obs.        : Alteração para permitir geração de 
              String estilo arquivo de inicialização ".INI"
*/

#include 'totvs.ch'
#include "average.ch"


Function EInfo()
Return Nil

Class EInfo FROM AvObject
 
   Data cField
   Data xContent

   METHOD New()
   METHOD GetEAutoArray()
   METHOD GetField()
   METHOD GetContent()
   METHOD GetContType()
   METHOD SetContent()
   METHOD GetINI()
      
End Class

METHOD New(cField,xContent) Class EInfo
   _Super:New()
   Self:SetClassName("EINFO")
   Self:cField   := cField
   Self:xContent := xContent
Return

METHOD SetContent(xContent) Class EInfo
   Self:xContent := xContent
Return Nil

METHOD GetEAutoArray() Class EInfo
Local aRet := {}
   If Self:GetContType() == "O" .AND. GetClassName(Self:GetContent()) $ "ETAB/EREC/EINFO"
      aRet := Self:GetContent():GetEAutoArray()      
   Else
      aRet := {Self:GetField(),Self:GetContent(),NIL}
   EndIf
Return aRet   
   
METHOD GetContType() Class EInfo
Return ValType(Self:GetContent())
   
METHOD GetField() Class EInfo
Return Self:cField

METHOD GetContent() Class EInfo
Return Self:xContent

METHOD GetINI() Class EInfo
Local cRet := ""
If ValType(Self:xContent) == "O" .AND. GetClassName(Self:xContent) $ "EREC"
   If !Empty(Self:cField)
      cRet := "["+Self:cField+"]"+CHR(13)+CHR(10)
   Else
      cRet := CHR(13)+CHR(10)
   EndIf
   cRet += Self:xContent:GetINI()   
ElseIf !Empty(Self:cField) .OR. !Empty(Self:xContent)
   cRet += AllTrim(Self:cField)+"="+AllTrim(cValToChar(Self:xContent))+CHR(13)+CHR(10)
Else
   cRet += CHR(13)+CHR(10)
EndIf
Return cRet

Class ERec FROM AvObject

   Data aFields
   Data lUniqueField
   
   METHOD New()
   METHOD AddField(oInfo, xValor)
   METHOD SetField(oInfo)
   METHOD GetField(nPos)
   METHOD GetFieldCont(nPos)
   METHOD GetValue(xInfo)
   METHOD FCount()
   METHOD GetEAutoArray()
   METHOD LoadRec(cAlias)
   METHOD GetINI()
   
End Class

METHOD New() Class ERec
   _Super:New()
   Self:SetClassName("EREC")
   Self:aFields      := {}
   Self:lUniqueField := .T.
Return
   
METHOD AddField(oInfo, xValor) Class ERec
Return Self:SetField(oInfo, xValor,.F.) 

METHOD SetField(oInfo, xValor,lUniqueField) Class ERec
Default lUniqueField := Self:lUniqueField
   If ValType(xValor) <> "U"
       Self:SetField(@EInfo():New(oInfo, xValor),,lUniqueField)                            //Para facilitar a chamada do SetField, instancia o Einfo automaticamente
   ElseIf ValType(oInfo) == "O"                                                                                   //Utilizado para os casos onde não é informado o segundo parâmetro "xvalor"
      If !lUniqueField
         aAdd(Self:aFields,oInfo)
      Else
         If ( nPos := aScan(Self:aFields,{|X| X:GetField() == oInfo:GetField()})  )   > 0
            Self:aFields[nPos]:SetContent(oInfo:GetContent())
         Else
            aAdd(Self:aFields,oInfo)                                                      //NCF - 28/12/2011
         EndIf
      EndIf
   EndIf
Return

METHOD GetField(xInfo) Class ERec
Local nPos, xRet

   If ValType(xInfo) == "N" .AND. Len(Self:aFields) >= xInfo
      xRet := Self:aFields[xInfo]
   ElseIf ValType(xInfo) == "C"
      If (nPos := aScan(Self:aFields,{|X| Upper(AllTrim(X:GetField())) == Upper(AllTrim(xInfo))})) > 0
         xRet := Self:aFields[nPos]
      EndIf
   EndIf
   
Return xRet

METHOD GetFieldCont(xInfo) Class ERec
Local oInfo := Self:GetField(xInfo)
Return If(ValType(oInfo) == "O",oInfo:GetContent(),NIL)

Method GetValue(xInfo) Class ERec
Return Self:GetFieldCont(xInfo)

METHOD FCount(oInfo) Class ERec
Return Len(Self:aFields)

METHOD GetEAutoArray() Class ERec
Local aReg := {}
Local i
For i := 1 To Len(Self:aFields)
    aAdd(aReg,Self:aFields[i]:GetEAutoArray())
Next i

Return aClone(aReg)

Method LoadRec(cAlias) Class ERec
Local nCpos, i

nCpos := (cAlias)->(FCount())
For i := 1 To nCpos
   (cAlias)->(Self:SetField(FieldName(i),FieldGet(i)))
Next i

Return Nil 

METHOD GetINI() Class ERec
Local cRet := ""
Local i 
For i:=1 to Self:FCount() 
   cRet += Self:GetField(i):GetINI()
Next i

Return cRet 


Class ETab FROM AvObject
  
   Data aRec
   
   METHOD New()
   METHOD AddRec(oRec)
   METHOD GetRec(nPos)
   METHOD RecCount()
   METHOD GetEAutoArray()
End Class

METHOD New() Class ETab
   _Super:New()
   Self:SetClassName("ETAB")
   Self:aRec := {}
Return
   
METHOD AddRec(oRec) Class ETab
   aAdd(Self:aRec,oRec)
Return

METHOD GetRec(xInfo) Class ETab
Local nPos, xRet

   If ValType(xInfo) == "N" .AND. Len(Self:aRec) >= xInfo
      xRet := Self:aRec[xInfo]
   ElseIf ValType(xInfo) == "B"
      If (nPos := aScan(Self:aRec,xInfo)) > 0
         xRet := Self:aRec[nPos]
      EndIf
   EndIf
   
Return xRet

METHOD RecCount() Class ETab
Return Len(Self:aRec)

METHOD GetEAutoArray() Class ETab
Local aTab := {}
Local i
For i := 1 To Len(Self:aRec)
    aAdd(aTab,Self:aRec[i]:GetEAutoArray())
Next i

Return aClone(aTab)

Class EExecAuto FROM ERec
   METHOD New()
End Class

METHOD New() Class EExecAuto
Return _Super:New()

Class EBatch From ETab
   METHOD New()
End Class

METHOD New() Class EBatch
Return _Super:New()

Class ETag FROM EInfo
   METHOD New()
   METHOD GetXML()
End Class

METHOD New(cField,xContent) Class ETag
Return _Super:New(cField,xContent)

METHOD GetXML() Class ETag
Local cRet := ""

If ValType(Self:xContent) == "O" .AND. GetClassName(Self:xContent) $ "EXML/ENODE/EATT/ETAG"
   If GetClassName(Self:xContent) == "ENODE"
      cRet := "<"+AllTrim(Self:cField)+Self:xContent:GetXML(.T.)+">"+Self:xContent:GetXML(.F.)+"</"+AllTrim(Self:cField)+">"
   ElseIf GetClassName(Self:xContent) $ "ETAG/EXML"
      cRet := "<"+AllTrim(Self:cField)+">"+Self:xContent:GetXML()+"</"+AllTrim(Self:cField)+">"
   ElseIf GetClassName(Self:xContent) == "EATT"
      cRet := "<"+AllTrim(Self:cField)+Self:xContent:GetXML()+">"+"</"+AllTrim(Self:cField)+">"
   EndIf
Else
   If !AllTrim(Self:cField) == ""
      cRet := "<"+AllTrim(Self:cField)+">"+ _NoTags( AllTrim(cValToChar(Self:xContent)) ) +"</"+AllTrim(Self:cField)+">"
   Else
      cRet := _NoTags( AllTrim(cValToChar(Self:xContent)) )
   EndIf
EndIf

Return cRet

Class EAtt FROM EInfo
    METHOD New()
    METHOD GetXML()
End Class

METHOD New(cField,xContent) Class EAtt
Return _Super:New(cField,xContent)

METHOD GetXML() Class EAtt
Return cRet := " "+AllTrim(Self:cField)+'="'+AllTrim(cValToChar(Self:xContent))+'"'

Class ENode FROM ERec
   METHOD New()
   METHOD SetField()
   METHOD GetXML()
End Class

METHOD New() Class ENode
_Super:New()
Self:lUniqueField := .F.
Return Self

METHOD SetField(oInfo, xValor,lUniqueField) Class ENode
   _Super:SetField(if(ValType(xValor)=="U",oInfo,ETag():New(oInfo, xValor)),,lUniqueField)
Return

METHOD GetXML(lAttrib) Class ENode
Local cRet    := ""
Local i 
Default lAttrib := .F.

For i:= 1 To Self:FCount()
   If lAttrib .AND. GetClassName(Self:GetField(i)) == "EATT" .OR. !lAttrib .AND. !GetClassName(Self:GetField(i)) == "EATT"
      cRet += Self:GetField(i):GetXML()
   EndIf
Next i

Return cRet

Class EXml FROM ETab
   METHOD New()
   METHOD GetXML()
End Class

METHOD New() Class EXml
Return _Super:New()

METHOD GetXML() Class EXML
Local cRet    := ""
Local i

For i:= 1 To Self:RecCount()
   cRet += Self:GetRec(i):GetXML(.F.)
Next i

Return cRet
