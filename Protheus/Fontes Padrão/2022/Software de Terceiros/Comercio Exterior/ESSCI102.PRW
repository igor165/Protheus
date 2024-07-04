#INCLUDE "PROTHEUS.CH"
#INCLUDE "AVERAGE.CH" 
#INCLUDE "APWIZARD.CH"  
#INCLUDE "TOPCONN.CH"  
#INCLUDE "FWBROWSE.CH"
#INCLUDE "shell.ch"

#DEFINE EXT_XML	".xml"
#DEFINE EXT_ZIP	".zip"

#Define INC_REG    "1" //1=Inclusão Registro
#Define RET_REG	   "2" //2=Retificação de Registro
#Define INC_ADI    "3" //3=Inclusão Aditivo
#Define RET_ADI    "4" //4=Retificação Aditivo
#Define INC_PAG    "5" //5=Inclusão Pagamento
#Define CAN_PAG    "6" //6=Cancel. Pagamento
#Define RET_PAG    "7" //7=Retificação Pagamento
*------------------------------------------*
Function ESSCI102(aItens,cTipoOpe,cNumLote,oError)
*------------------------------------------*
Local lRet := .T.
Local i := 1
Local cSeq , cName , cSeqXML, cChave, cProc := ""
Local oXmlServ, oZipXml
Local aOrd := SaveOrd({"EL3","EL4","EL5","EL6","EL8"})
      
For i := 1 To Len(aItens)
   //Limpando variaveis auxiliares.
   cSeq    := ""
   cName   := ""                                                                
   cSeqXML := ""
   cChave  := ""
   If cTipoOpe == INC_REG .Or. cTipoOpe == RET_REG
      
      EJY->(DbGoTo(aItens[i]))
      cChave := xFilial("EL3") + EJY->EJY_TPPROC + EJY->EJY_REGIST      
      EL3->(DbSetOrder(1)) //EL3_FILIAL + EL3_TPPROC + EL3_REGIST + EL3_SQEVCP
      EL3->(AvSeekLast(cChave)) //RRC - 05/02/2013 - Busca o registro que acabou de ser incluído para conseguir o número do lote atual
      cNumLote := EL3->EL3_IDLOTE
      EL3->(dbSetOrder(2)) //EL3_FILIAL + EL3_IDLOTE + EL3_TPPROC + EL3_REGIST
      EL3->(dbSeek(xFilial()+cNumLote+AvKey(EJY->EJY_TPPROC,"EL3_TPPROC")+AvKey(EJY->EJY_REGIST,"EL3_REGIST")))
      oXmlServ := SS102GerXML(cTipoOpe,EL3->EL3_TPPROC,EL3->EL3_REGIST,EL3->EL3_SQEVCP,,)
      
      If EJY->EJY_TPPROC == "V"
         cName += "RVS_"
      Else
         cName += "RAS_"
      EndIf
      
      If cTipoOpe == INC_REG
         cName += "INC_"
      Else
         cName += "RET_"
      EndIf

   
   ElseIf cTipoOpe == INC_ADI .Or. cTipoOpe == RET_ADI     
      
      EJZ->(DbGoTo(aItens[i]))
      cChave := xFilial("EL4") + EJZ->EJZ_TPPROC + EJZ->EJZ_REGIST  + EJZ->EJZ_SEQREG
      If Empty(cProc)
         cProc  := EJZ->EJZ_REGIST
      EndIf
      //RRC- 15/03/2013 - Guarda o conteúdo do primeiro RAS/RVS, para não deixar criar novamente um XML contendo todos os aditivos de um mesmo RAS/RVS
      If i==1 .Or. cProc <> EJZ->EJZ_REGIST  
         EL4->(DbSetOrder(1)) //EL4_FILIAL + EL4_TPPROC + EL4_REGIST + EL4_SEQREG + EL4_SQEVIT
         EL4->(AvSeekLast(cChave)) //RRC - 04/03/2013 - Busca o registro que acabou de ser incluído para conseguir o número do lote atual
         cNumLote := EL4->EL4_IDLOTE
         oXmlServ := SS102GerXML(cTipoOpe,EL4->EL4_TPPROC,EL4->EL4_REGIST,EL4->EL4_SQEVCP,EL4->EL4_SEQAD,,)
      
         If EJZ->EJZ_TPPROC == "V"
            cName += "RVS_ADT_"
         Else
            cName += "RAS_ADT_"
         EndIf
      
         If cTipoOpe == INC_ADI
            cName += "INC_"
         Else
            cName += "RET_"
         EndIf
      EndIf           
   ElseIf cTipoOpe == INC_PAG .Or. cTipoOpe == CAN_PAG .Or. cTipoOpe == RET_PAG
   
      EL1->(DbGoTo(aItens[i]))
      cSeq := SS101PrxNum("EL5",xFilial("EL5")+EL1->EL1_TPPROC+EL1->EL1_REGIST+EL1->EL1_SEQPAG,1,"EL5_SQEVPG") //FSM - EL1->EL1_FILIAL
      //cSeq := AllTrim(StrZero(Val(cSeq) - 1,2))
      cSeq := AllTrim(StrZero(Val(cSeq) - 1,AvSx3("EL5_SQEVPG", AV_TAMANHO))) 
      //AllTrim(AvSx3("EL5_SQEVPG",AV_TAMANHO))
      //AvSx3("EEQ_INTERN", AV_TIPO)
      EL5->(DbSetOrder(1)) //EL5_FILIAL+EL5_TPPROC+EL5_REGIST+EL5_SEQPAG+EL5_SQEVPG
      EL5->(dbSeek(xFilial("EL5")+EL1->EL1_TPPROC+EL1->EL1_REGIST+EL1->EL1_SEQPAG+cSeq))
      cNumLote := EL5->EL5_IDLOTE
      oXmlServ := SS102GerXML(cTipoOpe,EL5->EL5_TPPROC,EL5->EL5_REGIST,EL5->EL5_SQEVPG,,EL5->EL5_SEQPAG) 
      
      If EL1->EL1_TPPROC == "V"
         cName += "FAT_"
      Else
         cName += "PAG_"
      EndIf
      
      If cTipoOpe == INC_PAG
         cName += "INC_"
      ElseIf cTipoOpe == RET_PAG
         cName += "RET_"
      Else
         cName += "CAN_"
      EndIf
      
   EndIf
   
   //RRC- 15/03/2013 - Guarda o conteúdo do primeiro RAS/RVS, para não deixar criar novamente um XML contendo todos os aditivos de um mesmo RAS/RVS  
   If (cTipoOpe <> INC_ADI .And. cTipoOpe <> RET_ADI) .Or. i==1 .Or. cProc <> EJZ->EJZ_REGIST        
   //Verifica se o Objeto tem Erros caso nao gera XML
      If oXmlServ:HasErrors()
         oXmlServ:ShowErrors()
      Else 
         If lRet //Se .F., não criou o arquivo XML
            cSeqXML := StrZero(i,2)//Sequencia do Arquivo a ser criado no Temp
            lRet := SS102GerArq(oXmlServ:GetXML(),cName,cNumLote,cSeqXML,oError)
            If oError:HasErrors()
               oError:ShowErrors()
            EndIf
         EndIf
      EndIf
   EndIf   
Next i

//RRC - 13/03/2013 - Compacta todos os arquivos XML gerados para os processos selecionados e grava o nome do arquivo.zip na EL8 (Lote Siscoserv)
If SS102ZipArq(cNumLote,oError)
   EL8->(DbSetOrder(2)) //EL8_FILIAL + EL8_IDLOTE
   EL8->(DbSeek(xFilial("EL8")+AvKey(cNumLote,"EL8_IDLOTE")))
   If RecLock("EL8",.F.)
      EL8->EL8_ARQENV := cNumLote+EXT_ZIP
      EL8->(MsUnLock())
   EndIf
   //RRC - 13/03/2013 - Grava o nome do arquivo.xml nas tabelas de histórico do Siscoserv (EL3, EL4 ou EL5) compactados pelo .zip que foi gravado no lote
   //SS101GrvArq(cTipoOpe,cNumLote,EXT_XML)                     
EndIf  
RestOrd(aOrd,.T.)
Return lRet

*----------------------------------------------------*
Function SS102GerArq(cXmlServ,cName,cNumLote,cSeqXML,oError) 
*----------------------------------------------------* 
Local lRet       := .T. 
Local nHandler   := 0
Local cDirXML    := GetTempPath(.T.)
Local cDirXMLSrv := "" //Diretorio temporario Servidor
Local cArqXML    := "" , cDateHr := ""

Begin Sequence
  
   cDirXML    += "SISCOSERV\"
   cDirXMLSrv += cDirXml + cNumLote + "\"  
   
   If !lIsDir(cDirXML) .And. !(MakeDir(cDirXML) == 0)
      oError:Error( StrTran("Erro ao criar o diretório '###'.", "###", cDirXML),.F.)
      lRet := .F.
      Break
   EndIf   

   If !lIsDir(cDirXMLSrv) .And. !(MakeDir(cDirXMLSrv) == 0)
      oError:Error( StrTran("Erro ao criar o diretório '###'.", "###", cDirXMLSrv),.F.)
      lRet := .F.
      Break                          
   EndIf
                          
   cDateHr := SS102FormatDate()
   
   cArqXML := cName + cDateHr + "_" + cSeqXML + EXT_XML
   
   If (nHandler := EasyCreateFile(cDirXMLSrv + cArqXML)) == -1
      oError:Error( StrTran("O arquivo ### não pode ser criado: " + AllTrim(Str(FERROR())), "###",cArqXML),.F.)
   Else
      FWrite(nHandler,cXmlServ)
      FClose(nHandler)
   EndIf
      
End Sequence

Return lRet

*-------------------------*
Static Function SS102FormatDate()
*-------------------------*
Local cDateHora := ""
Local cAno := "",  cMes := "", cDia := "", cHora := "" , cMin := ""

cAno := YEAR(Date())
cMes := MONTH(Date())
cDia := DAY(Date())
cHora:= SUBSTR(Time(),1,2)
cMin := SUBSTR(Time(),4,2)

//cDateHora := cAno + StrZero( cMes,2 ) + cDia + cHora + cMin
cDateHora := AllTrim(Str(cAno)) + StrZero( cMes,2 ) +StrZero(cDia,2) + cHora + cMin
Return cDateHora 


/*
Funcao      : SS102GerXML().
Objetivos   : Criação do arquivo XML.
Sintaxe     : SS102GerXML()
Parametros  : cServico,cTipo,cProcesso,cSeqEnv,cSeqAdi,cSeqPag
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 30/08/12 - 10:00.

cServico : 1,2,3,4,5,6
cTipo    : A = Aquisição, V = Venda
cProcesso: Nº do processo
cSeqEnv  : Nº da sequencia de envio capa. Usado no cServico 2,4
cSeqAdi  : Nº da sequencia do aditivo. Usado no cServico 3,4
cSeqPag  : Nº da sequencia do pagamento. Usado no cServico 5,6
*/
Function SS102GerXML(cServico,cTipo,cProcesso,cSeqEnv,cSeqAdi,cSeqPag)
Local oXml
Local oRec
Local oTag
Local cChave
Default cSeqEnv  := ""
Default cSeqAdi  := ""
Default cSeqPag  := ""

cTipo := Upper(cTipo)
EL3->(dbSetOrder(1))
EL4->(dbSetOrder(1))
EL5->(dbSetOrder(1))
Do Case//Case para setar seek e a chave usada no seek da função.

   Case cServico == INC_REG
      EL3->(dbSeek(xFilial("EL3")+cTipo+cProcesso+cSeqEnv)) //EL3_FILIAL+EL3_TPPROC+EL3_REGIST+EL3_SQEVCP
      cChave := xFilial("EL4")+cTipo+cProcesso+cSeqEnv
      //cChaveAnt := cChave 
      
   Case cServico == RET_REG
      EL3->(dbSeek(xFilial("EL3")+cTipo+cProcesso+cSeqEnv))
      cChave  := xFilial("EL4")+cTipo+cProcesso+cSeqEnv
                     
   Case cServico == INC_ADI      
      cChave  := xFilial("EL4")+cTipo+cProcesso+cSeqAdi+cSeqEnv

   Case cServico == RET_ADI
      cChave := xFilial("EL4")+cTipo+cProcesso+cSeqAdi+cSeqEnv
           
   Case cServico == INC_PAG .Or. cServico == CAN_PAG .Or. cTipoOpe == RET_PAG
      //EL5->(dbSeek(xFilial("EL5")+cTipo+cProcesso+cSeqPag+cSeqEnv))//EL5_FILIAL+EL5_TPPROC+EL5_REGIST+EL5_SEQPAG+EL5_SQEVPG
      cChave := xFilial("EL5")+cTipo+cProcesso+cSeqPag+cSeqEnv

End Case


oTag := ENode():New()
oTag:SetField(EAtt():New("xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance"))

If cTipo == "A"//Setando nome da tag para o tipo do serviço.
   Do Case
      Case cServico == INC_REG
         oTag:SetField(EAtt():New("xsi:noNamespaceSchemaLocation","incluir_RAS"       +".xsd"))
      Case cServico == RET_REG
         oTag:SetField(EAtt():New("xsi:noNamespaceSchemaLocation","retificar_RAS"     +".xsd"))
      Case cServico == INC_ADI
         oTag:SetField(EAtt():New("xsi:noNamespaceSchemaLocation","incluir_aditivo"   +".xsd"))
      Case cServico == RET_ADI
         oTag:SetField(EAtt():New("xsi:noNamespaceSchemaLocation","retificar_aditivo" +".xsd"))
      Case cServico == INC_PAG
         oTag:SetField(EAtt():New("xsi:noNamespaceSchemaLocation","inclusao_pagamento"+".xsd"))
      Case cServico == CAN_PAG
         oTag:SetField(EAtt():New("xsi:noNamespaceSchemaLocation","cancelar_pagamento"+".xsd"))
      Case cServico == RET_PAG
         oTag:SetField(EAtt():New("xsi:noNamespaceSchemaLocation","retificar_pagamento"+".xsd"))
   End Case
      
ElseIf cTipo == "V"
      
   Do Case
      Case cServico == INC_REG
            oTag:SetField(EAtt():New("xsi:noNamespaceSchemaLocation","incluir_registro"    +".xsd"))
      Case cServico == RET_REG                                                              
            oTag:SetField(EAtt():New("xsi:noNamespaceSchemaLocation","retificar_registro"  +".xsd"))
      Case cServico == INC_ADI                                        
            oTag:SetField(EAtt():New("xsi:noNamespaceSchemaLocation","incluir_aditivo"     +".xsd"))
      Case cServico == RET_ADI
            oTag:SetField(EAtt():New("xsi:noNamespaceSchemaLocation","retificar_aditivo"   +".xsd"))
      Case cServico == INC_PAG
            oTag:SetField(EAtt():New("xsi:noNamespaceSchemaLocation","incluir_faturamento" +".xsd"))
      Case cServico == CAN_PAG
            oTag:SetField(EAtt():New("xsi:noNamespaceSchemaLocation","cancelar_faturamento"+".xsd"))
      Case cServico == RET_PAG
         oTag:SetField(EAtt():New("xsi:noNamespaceSchemaLocation","retificar_faturamento"+".xsd"))
   End Case
   
End If
      
oRec := ENode():New()
oRec:SetField('','<?xml version="1.0" encoding="UTF-8"?>')
   
If cTipo == "A"
   
   Do Case//Setando nome da tag e chamando função pelo tipo do serviço.
      Case cServico == INC_REG
         oRec:SetField("IncluirRAS"       ,GetPrinc(cServico,oTag,cTipo,cChave))
      Case cServico == RET_REG
         oRec:SetField("RetificarRAS"     ,GetPrinc(cServico,oTag,cTipo,cChave))
      Case cServico == INC_ADI
         oRec:SetField("IncluirAditivo"   ,GetPrinc(cServico,oTag,cTipo,cChave))
      Case cServico == RET_ADI
         oRec:SetField("RetificarAditivo" ,GetPrinc(cServico,oTag,cTipo,cChave))
      Case cServico == INC_PAG
         oRec:SetField("InclusaoPagamento",GetPayment(cServico,oTag,cTipo,cChave))
      Case cServico == CAN_PAG
         oRec:SetField("CancelarPagamento",GetPayment(cServico,oTag,cTipo,cChave))
      Case cServico == RET_PAG
         oRec:SetField("RetificarPagamento",GetPayment(cServico,oTag,cTipo,cChave))
   End Case
      
ElseIf cTipo == "V"
      
   Do Case
      Case cServico == INC_REG
         oRec:SetField("IncluirRVS"      ,GetPrinc(cServico,oTag,cTipo,cChave))
      Case cServico == RET_REG
         oRec:SetField("RetificarRVS"    ,GetPrinc(cServico,oTag,cTipo,cChave))
      Case cServico == INC_ADI
         oRec:SetField("IncluirAditivo"  ,GetPrinc(cServico,oTag,cTipo,cChave))
      Case cServico == RET_ADI
         oRec:SetField("RetificarAditivo",GetPrinc(cServico,oTag,cTipo,cChave))
      Case cServico == INC_PAG
         oRec:SetField("InclusaoFatura"  ,GetPayment(cServico,oTag,cTipo,cChave))
      Case cServico == CAN_PAG
         oRec:SetField("CancelarFatura"  ,GetPayment(cServico,oTag,cTipo,cChave))
      Case cServico == RET_PAG
         oRec:SetField("RetificarFatura",GetPayment(cServico,oTag,cTipo,cChave))
   End Case
End If
oXml := EXml():New()
oXml:AddRec(oRec)
   
//EECVIEW(oXml:GetXML())//para exibir na tela a string

Return oXml

/*
Funcao      : GetPrinc().
Objetivos   : Montar tag principal dos serviços cServico = 1,2,3,4.
Sintaxe     : GetPrinc()
Parametros  : cServico,oTag,cTipo,cChave
Retorno     : oTag
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 30/08/12 - 10:00.
*/
Static Function GetPrinc(cServico,oTag,cTipo,cChave)

If cTipo == "A"
   
   If cServico == INC_REG .Or. cServico == RET_REG
      oTag:SetField("NumeroRASEmpresa",EL3->EL3_REGIST)
   ElseIf cServico == INC_ADI .Or. cServico == RET_ADI
      oTag:SetField("NumeroRASEmpresa",EL4->EL4_REGIST)
   EndIf

   If cServico == INC_REG .Or. cServico == RET_REG 
      oTag:SetField("NomeVendedor"      ,EL3->EL3_NOME)
      oTag:SetField("EnderecoVendedor"  ,EL3->EL3_END)
      oTag:SetField("CodigoPaisVendedor",EL3->EL3_PAIS)
      If !Empty(EL3->EL3_NIF) //RRC - 20/02/2013 - Campo não obrigatório
         oTag:SetField("Nif"            ,EL3->EL3_NIF)
      EndIf
   EndIf
    
ElseIf cTipo == "V"

   If cServico == INC_REG .Or. cServico == RET_REG
      oTag:SetField("NumeroRVSEmpresa",EL3->EL3_REGIST)
   ElseIf cServico == INC_ADI .Or. cServico == RET_ADI
      oTag:SetField("NumeroRVSEmpresa",EL4->EL4_REGIST)
   EndIf   
   
   If cServico == INC_REG .Or. cServico == RET_REG
      oTag:SetField("NomeAdquirente"      ,EL3->EL3_NOME)
      oTag:SetField("EnderecoAdquirente"  ,EL3->EL3_END)
      oTag:SetField("CodigoPaisAdquirente",EL3->EL3_PAIS) 
      If !Empty(EL3->EL3_NIF) //RRC - 20/02/2013 - Campo não obrigatório
         oTag:SetField("Nif"              ,EL3->EL3_NIF)
      EndIf
   End If
   
End If  

If cServico == INC_REG .Or. cServico == RET_REG
   EL4->(dbSetOrder(3))//EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SQEVCP+EL4_SEQAD
   cLote := EL3->EL3_IDLOTE
ElseIf cServico == INC_ADI .Or. cServico == RET_ADI 
   EL4->(dbSetOrder(4))//EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQAD+EL4_SQEVCP
   cLote := EL4->EL4_IDLOTE
End If
   EL4->(dbSeek(cChave))
   Do While EL4->( !Eof() .AND. cChave == Left(&(IndexKey()),Len(cChave)) )  
      If EL4->EL4_IDLOTE == cLote
         oTag:SetField("Operacao",GetOperacao(cTipo))
      EndIf
      EL4->(DbSkip())
   EndDo
      
   If cServico == INC_REG .Or. cServico == RET_REG 
      EL7->(dbSetOrder(3))//EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SQEVCP
      EL7->(dbSeek(cChave))
      
      Do While EL7->( !Eof() .AND. cChave == Left(&(IndexKey()),Len(cChave)))      
         If Empty(EL7->EL7_SEQREG) .And. Empty(EL7->EL7_SEQPAG) //Não deve considerar os documentos dos pagamentos
            If cTipo == "A"
               oTag:SetField("VincImportacaoBens",GetVincula(cTipo))
            ElseIf cTipo == "V"
               oTag:SetField("VincExportacaoBens",GetVincula(cTipo))
            EndIf      
         EndIf
         EL7->(dbSkip())
      EndDo
      
      If !Empty(EL3->EL3_COMPL)
         oTag:SetField("InfoComplementar",EL3->EL3_COMPL)
      End If 
      oTag:SetField("CodigoMoeda",EL3->EL3_MOEDA)
   EndIf

Return oTag

/*
Funcao      : GetOperacao().
Objetivos   : Tela para central de integração com o SiscoServ.
Sintaxe     : GetOperacao()
Parametros  : cTipo
Retorno     : oOperacao - tag Operação em formato xml montada.
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 30/08/12 - 10:00.
*/
Static Function GetOperacao(cTipo)
Local oOperacao := ENode():New()
Local oEnquadramento
Local i, cEnq, cRc, cExcl
If cTipo == "A"
   //RRC - 26/02/2013
   //oOperacao:SetField("NumeroOpAdqEmpresa" ,EL4->EL4_SEQREG)
   oOperacao:SetField("NumeroServAdqEmpresa" ,EL4->EL4_SEQREG)  
ElseIf cTipo == "V"
   oOperacao:SetField("NumeroOperacaoEmpresa",EL4->EL4_SEQREG)
EndIf
   oOperacao:SetField("CodigoNbs"            ,EL4->EL4_NBS)
   oOperacao:SetField("CodigoPaisDestino"    ,EL4->EL4_PAIS)
   oOperacao:SetField("ModoPrestacao"        ,EL4->EL4_MODO)
   //RRC - 05/02/2013 - Os campos de data devem ser informados independentemente de estarem vazios pois são obrigatórios
   oOperacao:SetField("DataInicio"   , If(!Empty(EL4->EL4_DTINI),TransPicture(EL4->EL4_DTINI,"date"),""))
   oOperacao:SetField("DataConclusao", If(!Empty(EL4->EL4_DTFIM),TransPicture(EL4->EL4_DTFIM,"date"),""))   
   oOperacao:SetField("Valor",If(!Empty(EL4->EL4_VALOR),TransPicture(EL4->EL4_VALOR,"VALOR"),""))
   
   For i := 1 To 3
      cEnq := EL4->(&("EL4_ENQ0"+AllTrim(Str(i))))
         
      If !Empty(cEnq)
         cRc   := EL4->(&("EL4_RC0" +AllTrim(Str(i))))
         cExcl := EL4->(&("EL4_EXCL"+AllTrim(Str(i))))
         oEnquadramento := ENode():New()
         oEnquadramento:SetField("CodigoEnquadramento",cEnq)
         
         If !Empty(cRc)
            oEnquadramento:SetField("NumeroRc",TransPicture(cRc,"rc"))
         EndIf
         
         If cExcl == "2" //RRC - 05/02/2013 - Para exclusão de um enquadramento deve gravar "true"          
            oEnquadramento:SetField("exclusao","true")
         EndIf
            
         oOperacao:SetField("Enquadramento",oEnquadramento)
      EndIf
   
   Next i

Return oOperacao

/*
Funcao      : GetVincula().
Objetivos   : Monta a tag Vincular aquisição - VincImportacaoBens/ venda - VincExportacaoBens.
Sintaxe     : GetVincula()
Parametros  : cTipo - Aquisição/venda
Retorno     : oTag - tag Vinculação em formato xml montada.
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 30/08/12 - 10:00.
*/
Static Function GetVincula(cTipo)//VincImportacaoBens,VincExportacaoBens 
Local oVincula := ENode():New()
/*NOPADO por RRC - 09/03/2013 - No caso dos documentos vinculados a pagamentos, é possível haver RE ou DI independentemente do tipo de processo
Foi passado também um terceiro parâmetro para o caso de possuir tanto RE quanto DI e retornar um de cada vez */
   //If cTipo == "A"   
      If !Empty(EL7->EL7_DI)
         oVincula:SetField("NumeroDI",TransPicture(EL7->EL7_DI,"DI"))
      EndIf
   //ElseIf cTipo == "V"   
      If !Empty(EL7->EL7_RE)
         oVincula:SetField("NumeroRE",TransPicture(EL7->EL7_RE,"RE"))
      EndIf   
   //End If   
   If EL7->EL7_EXCL == "2" //RRC - 13/02/2013 - Para exclusão de uma vinculação de bens deve gravar "true"
      oVincula:SetField("exclusao","true")
   EndIf   
Return oVincula
/*
Funcao      : GetPayment().
Objetivos   : Montar tag para os serviços de Inclução pagamento/fatura, cancelamento pagamento/fatura.
Sintaxe     : GetPayment()
Parametros  : cServico,oTag, cTipo,cChave
Retorno     : oTag
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 30/08/12 - 10:00.
*/
Static Function GetPayment(cServico,oTag, cTipo,cChave)
Local cLote := ""
EL5->(dbSetOrder(1))
EL5->(dbSeek(cChave))//EL5_FILIAL+EL5_TPPROC+EL5_REGIST+EL5_SEQPAG+EL5_SQEVPG
cLote := EL5->EL5_IDLOTE
If cServico == CAN_PAG//Serviço de cancelamento
   If cTipo == "A"
      oTag:SetField("IdPagamentoEmpresa",EL5->EL5_PAGID)
   ElseIf cTipo == "V"
      oTag:SetField("IdFaturaEmpresa"   ,EL5->EL5_PAGID)
   EndIf 
   Return oTag
End If

If cTipo == "A"
   
   oTag:SetField("NumeroRASEmpresa"  ,EL5->EL5_REGIST)
   oTag:SetField("IdPagamentoEmpresa",EL5->EL5_PAGID)
   oTag:SetField("NumeroPagamento"   ,EL5->EL5_DOC)
   oTag:SetField("DataPagamento"     ,TransPicture(EL5->EL5_DTPAG,"DATE"))

ElseIf cTipo == "V"

   oTag:SetField("NumeroRVSEmpresa"  ,EL5->EL5_REGIST)
   oTag:SetField("IdFaturaEmpresa"   ,EL5->EL5_PAGID)
   oTag:SetField("NumeroFatura"      ,EL5->EL5_DOC)
   oTag:SetField("DataFatura"        ,TransPicture(EL5->EL5_DTPAG,"DATE"))

End If   
   
   EL6->(dbSetOrder(1))//EL6_FILIAL+EL6_TPPROC+EL6_REGIST+EL6_SEQPAG+EL6_SQEVPG+EL6_SEQREG
   EL6->(dbSeek(cChave))
   Do While EL6->( !Eof() .AND. cChave == Left(&(IndexKey()),Len(cChave)) )  
      If cTipo == "A"
         oTag:SetField("ItemPagamento",ItemPagame("A"))
      ElseIf cTipo == "V"
         oTag:SetField("ItemFatura"   ,ItemPagame("V"))
      EndIf 
      EL6->(dbSkip())
   EndDo                            
   
   EL7->(DbSetOrder(2)) //EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SQEVPG
   EL7->(DbSeek(cChave))
   Do While EL7->(!Eof()) .And. EL7->(&(IndexKey())) == Left(cChave,Len(EL7->(&(IndexKey())))) // cChave == Left(EL7->(&(IndexKey())),Len(cChave))
      If cLote == EL7->EL7_IDLOTE .And. !Empty(EL7->EL7_RE)
         oTag:SetField("VinculacaoNumRE",TransPicture(EL7->EL7_RE,"RE"))
      EndIf
      EL7->(DbSkip())
   EndDo

   EL7->(DbSeek(cChave))
   Do While EL7->(!Eof()) .And.  EL7->(&(IndexKey())) == Left(cChave,Len(EL7->(&(IndexKey())))) // cChave == Left(EL7->(&(IndexKey())),Len(cChave))
      If cLote == EL7->EL7_IDLOTE .And. !Empty(EL7->EL7_DI)
         oTag:SetField("VinculacaoNumDI",TransPicture(EL7->EL7_DI,"DI"))
      EndIf
      EL7->(DbSkip())
   EndDo
   
Return oTag

/*
Funcao      : ItemPagame().
Objetivos   : Criação da tag TcItemPagamento.
Sintaxe     : ItemPagame()
Parametros  : cTipo
Retorno     : oOperacao
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 30/08/12 - 10:00.
*/
Static Function ItemPagame(cTipo)
Local oOperacao := ENode():New()

If cTipo == "A"

   oOperacao:SetField("NumOpAdqEmpresa"      ,EL6->EL6_SEQREG)
   oOperacao:SetField("ValorPago"            ,TransPicture(EL6->EL6_VLCAMB,"VALOR"),"")
   If !Empty(EL6->EL6_VLEXT)
      oOperacao:SetField("ValorPagoRecMantidoExt",TransPicture(EL6->EL6_VLEXT,"VALOR"),"")
   End If

ElseIf cTipo == "V"
   
   oOperacao:SetField("NumeroOperacaoEmpresa",EL6->EL6_SEQREG)
   oOperacao:SetField("ValorFaturado"        ,TransPicture(EL6->EL6_VLCAMB,"VALOR"),"")
   If !Empty(EL6->EL6_VLEXT)
      oOperacao:SetField("ValorMantidoExterior",TransPicture(EL6->EL6_VLEXT,"VALOR"),"")
   End If
   
EndIf 
Return oOperacao

/*
Funcao      : TransPicture().                                                                        
Objetivos   : Aplicar picture numa string.
Parametros  : cString: String a ser aplicada a picture/ cTipo: tipo de picture a ser aplicada.
Retorno     : cRet: String com a picture.
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 30/08/12 - 10:00.
*/
Static Function TransPicture(cString,cTipo)
Local cRet := ""
cTipo := If(!Empty(cTipo),Upper(cTipo),"") //RRC - 09/03/2013
If !Empty(cString) .And. !Empty(cTipo)

   Do Case
      Case cTipo == "DATE" .Or. cTipo == "DATA"
         cRet := Transform(cString,"@D")

      Case cTipo == "DI"
         cRet := Transform(cString      ,"@R 99/9999999-9")
               
      Case cTipo == "RC"
         cRet := Transform(cString      ,"@R 99/999999")
            
      Case cTipo == "RE"
         cRet := Transform(cString      ,"@R 99/9999999999")
               
      Case cTipo == "VALOR" //RRC - 13/02/2013 - O ponto é o separador dos centavos
         cRet := Transform(cString           ,"99999999999999.99")

   End Case
   
EndIf

Return cRet

/*
Programa   : SS102ZipArq()
Objetivo   : No momento da geração do lote, cria o arquivo VBScript para zipar os arquivos XML para o diretório "/comex/siscoserv/naoenviados/" (ESSCI100:cDirGerados)
Parametros :
Retorno    : lRet
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 13/03/2012 11:55 
Revisao    : 
*/

Function SS102ZipArq(cNumLote,oError)
Local cDirXMLSrv := GetTempPath(.T.) + "SISCOSERV\" + cNumLote + "\"  
Local cTexto     := ""
Local cArqVbs    := "LoteZip.vbs"
Local cDirVbs    := GetTempPath(.T.) + "SISCOSERV\" + cArqVbs
Local cDirClient := GetClientDir()+cNumLote
Local lRet       := .T.
Local nHandler   := 0
Local nFound     

Begin Sequence
   If !lIsDir(cDirXMLSrv)
      oError:Error( StrTran("Erro ao criar o diretório '###'", "###", cDirXMLSrv),.F.)
      lRet := .F.
      Break                          
   EndIf
   
   If FindFunction("H_EASYZIP")
      cTexto := H_EASYZIP()
      cTexto := StrTran(cTexto,"#DIRORIGEM#" ,'"'+cDirXMLSrv+'"')
      cTexto := StrTran(cTexto,"#DIRDESTINO#",'"'+cDirClient+'"')
   Else
      oError:Error("Este ambiente não está preparado para compactar os arquivos XML. Favor entrar em contato com o suporte Trade-Easy.",.F.)
      lRet := .F.
      Break
   EndIf
 
   //Exclui o arquivo VbScript caso já exista
   If File(cDirVbs)
      FErase(cDirVbs)
   EndIf

   //Cria um novo arquivo VbScript para compactar os arquivos XML
   If (nHandler := EasyCreateFile(cDirVbs)) == -1
      oError:Error("Erro ao criar o arquivo '###' para compactar os arquivos XML.", "###", cArqVbs,.F.)
      lRet := .F.
      Break
   Else   
      FWrite(nHandler, cTexto)
      FClose(nHandler)
      If (nFound := WaitRun('wscript.exe "'+cDirVbs+'"',SW_MINIMIZE)) == 0
         //RRC - 13/03/2013 - A função CpyT2S() copia o arquivo que está no client para o servidor. O diretório de origem neste caso é "/comex/siscoserv/naoenviados/"
         If !CpyT2S( cDirClient+EXT_ZIP, ESSCI100:cDirGerados , .F. ) 
            oError:Error( "Não foi possível copiar a pasta compactada dos arquivos XML para o diretório do seu ambiente: "+ESSCI100:cDirGerados,.F.)
            lRet := .F.
            Break
         EndIf
      Else
         oError:Error("Erro de execução de aplicativo para gerar a pasta compactada dos arquivos XML.",.F.)
         lRet := .F.
         Break 
      EndIf      
   EndIf
End Sequence

If File(cDirClient+EXT_ZIP)
   FErase(cDirClient+EXT_ZIP)
EndIf

Return lRet