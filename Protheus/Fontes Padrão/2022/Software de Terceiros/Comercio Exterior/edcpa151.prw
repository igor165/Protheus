#INCLUDE "Average.ch"
#INCLUDE "EDCPA150.ch"
#Define PEDIDO_APH  "H_PDIsencao"
#Define ANEXO_APH   "H_ANIsencao"


Function EDCPA151(nPedido,mCarta)

Local nTimeOut  := 120
Local aHeadOut  := {}
Local cHeadRet  := ""
Local sPostRet  := ""
Local lRequest  := EasyGParam("MV_AVG0204",,.F.) // Parametro se faz o request ou utiliza o APH
Local aForms    := {}
Local nForm     := 0
Local cPostPar  := ""
Local cFile     := "" , cQuebra := "", cPagina := ""
Local aSecoes   := {}
Local cSecao    := "" , nPosSec := 0, nAnexo := 0
Local i, j
Local nPos      := 0  , nPosQuebra := 0, nPosEspec := 0 
Local lAnexoImp := .F., lAnexoExp := .F.
Local lRet      := .F.
Local aPaginas  := {}

Private mCartaPag := mCarta  // GFP - 19/10/2011 - Parte Superior da Carta
Private aAnexosImp      := {} , aAnexosExp := {} , aAnexosPerc:= {} , aTotImp := {} , aTotExp := {}, aFormularios := {}
Private cEspecificacao  := ""
Private bDescArray      := {|A,B,C| DescArray(A,B,C)}
Private nLinhasPorAnexo := 20
Private cVia1           := "Via1"
Private cVia2           := "Via2"
Private cVia3           := "Via3"
Private cVia4           := "Via4"
Private cExtensao       := ".htm"
//AOM - 26/06/2012
Private cCmposPic := "ED1_PESO/ED2_PESO/ED1_QTDNCM/ED2_QTDNCM/ED1_VL_MOE/ED2_VL_MOE"

ED0->(dbGoTo(nPedido))

If Select("ITENS_IMP") > 0
   ITENS_IMP->(dbCloseArea())
EndIf

BeginSql Alias "ITENS_IMP"

   SELECT ED2_NCM,ED2_UMNCM,ED2_ITEM,ED2_MOEDA,sum(ED2_PESO) AS ED2_PESO, sum(ED2_VL_MOE) AS ED2_VL_MOE,sum(ED2_QTDNCM) AS ED2_QTDNCM,sum(ED2_VALEMB) AS ED2_VALEMB
   FROM %table:ED2% ED2
   WHERE ED2.%NotDel% AND ED2.ED2_FILIAL = %xFilial:ED2% AND ED2.ED2_PD = %Exp:ED0->ED0_PD%
   GROUP BY ED2_PD,ED2_NCM,ED2_UMNCM,ED2_ITEM,ED2_MOEDA
   
EndSql

If Select("ITENS_EXP") > 0
   ITENS_IMP->(dbCloseArea())
EndIf

BeginSql Alias "ITENS_EXP"

   SELECT ED1_NCM,ED1_UMNCM,ED1_PROD,ED1_MOEDA,sum(ED1_PESO) AS ED1_PESO,sum(ED1_VL_MOE) AS ED1_VL_MOE,sum(ED1_QTDNCM) AS ED1_QTDNCM,sum(ED1_VAL_EM) AS ED1_VAL_EM
   FROM %table:ED1% ED1
   WHERE ED1.%NotDel% AND ED1.ED1_FILIAL = %xFilial:ED1% AND ED1.ED1_PD = %Exp:ED0->ED0_PD%
   GROUP BY ED1_PD,ED1_NCM,ED1_UMNCM,ED1_PROD,ED1_MOEDA
   
EndSql

If Select("ITENS_VLCOM") > 0
   ITENS_IMP->(dbCloseArea())
EndIf

//Utilizados os campos ED2_PERCPE e ED2_PERCAP como minimo e maximo do percentual de perda, só porque é necessário um campo do dicionário.
BeginSql Alias "ITENS_VLCOM"

   SELECT ED2_NCM,ED2_ITEM,min(ED2_PERCPE) AS ED2_PERCPE, max(ED2_PERCPE) AS ED2_PERCAP
   FROM %table:ED2% ED2
   WHERE ED2.%NotDel% AND ED2.ED2_FILIAL = %xFilial:ED2% AND ED2.ED2_PD = %Exp:ED0->ED0_PD% 
   GROUP BY ED2_PD,ED2_NCM,ED2_ITEM
   HAVING max(ED2.ED2_PERCPE) > 5
   
EndSql

aAnexosImp := ConsolidaAnexo(GetItemArray("ITENS_IMP","ED2_ITEM"),"ITENS_IMP","ED2_NCM","ED2_PESO","ED2_VALEMB","ED2_UMNCM","ED2_QTDNCM","ED2_MOEDA","ED2_VL_MOE")
aAnexosExp := ConsolidaAnexo(GetItemArray("ITENS_EXP","ED1_PROD"),"ITENS_EXP","ED1_NCM","ED1_PESO","ED1_VAL_EM","ED1_UMNCM","ED1_QTDNCM","ED1_MOEDA","ED1_VL_MOE")
aAnexosPerc:= ConsolidaAnexo(GetItemArray("ITENS_VLCOM","ED2_ITEM")    ,"ITENS_VLCOM","ED2_NCM","ED2_PERCPE","ED2_PERCAP","ED2_ITEM" ,""          ,""         ,"")

ITENS_EXP->(dbCloseArea())
ITENS_IMP->(dbCloseArea())
ITENS_VLCOM->(dbCloseArea())

aTotImp    := TotalAnexos(aAnexosImp)
aTotExp    := TotalAnexos(aAnexosExp)

SYT->(DbSeek(xFilial("SYT")+ED0->ED0_IMPORT))
SYF->(dbSetOrder(1),dbSeek(xFilial("SYF")+EasyGParam("MV_SIMB2",,"US$")))

aFormularios := {}
aAdd(aFormularios,{"form_pedido" ,'http://www.bb.com.br/portalbb/frm/fw0707179_2.jsp',{1,2,2,3,4}})
aAdd(aFormularios,{"form_anexo"  ,'http://www.bb.com.br/portalbb/frm/fw0707187_2.jsp',{1,2,2,2}}  )
aAdd(aFormularios,{"form_aditivo",'http://www.bb.com.br/portalbb/frm/fw0707192_2.jsp',{1,2,2,2,3}})

aForms := {}

//Armazena os dados do pedido
GetPedido(aAnexosExp,aAnexosImp,aAnexosPerc,aTotExp,aTotImp,@aForms)

//Armazena todos os anexos de produtos importados
If Len(aAnexosImp) > 0 .And. (lAnexoImp := GetField(aAnexosImp[1],"QTD_ITENS",.F.)[2] > 4)
   GetAnexo("ED2","aAnexosImp",0,'porImportar',"ED2_VALEMB",@aForms)
EndIf

//Armazena todos os anexos de produtos Exportados
If Len(aAnexosExp) > 0 .And. (lAnexoExp := GetField(aAnexosExp[1],"QTD_ITENS",.F.)[2] > 4)
   GetAnexo("ED1","aAnexosExp",Len(aAnexosImp),'Exportadas',"ED1_VAL_EM",@aForms)
EndIf

//Armazena todos os anexos de subprodutos
If Len(aAnexosPerc) > 0 .And. GetField(aAnexosPerc[1],"QTD_ITENS",.F.)[2] > 2
   If Len(aAnexosImp) < 1 .And. Len(aAnexosExp) < 1
      nAnexo := 0
   Else
      If lAnexoImp .And. lAnexoExp
         nAnexo := Len(aAnexosImp) + Len(aAnexosExp)
      ElseIf lAnexoExp
         nAnexo := Len(aAnexosExp)
      Else 
         nAnexo := Len(aAnexosImp)
      EndIf
   EndIf
   GetAnexo("ED2","aAnexosPerc",nAnexo,' ',"",@aForms)
EndIf

/*
aParamAdi := {}
aAdd(aParamAdi,{'atoDe',,'atoDe'})
aAdd(aParamAdi,{'atoNum',,'atoNum'})
aAdd(aParamAdi,{'beneficiaria',,'beneficiaria'})
aAdd(aParamAdi,{'cnpj',,'cnpj'})
aAdd(aParamAdi,{'de1',,'de1'})
aAdd(aParamAdi,{'de2',,'de2'})
aAdd(aParamAdi,{'de3',,'de3'})
aAdd(aParamAdi,{'de4',,'de4'})
aAdd(aParamAdi,{'de5',,'de5'})
aAdd(aParamAdi,{'de6',,'de6'})
aAdd(aParamAdi,{'endereco',,'endereco'})
aAdd(aParamAdi,{'local',,'local'})
aAdd(aParamAdi,{'localData',,'localData'})
aAdd(aParamAdi,{'nome',,'nome'})
aAdd(aParamAdi,{'nomeExtenso1',,'nomeExtenso1'})
aAdd(aParamAdi,{'nomeExtenso2',,'nomeExtenso2'})
aAdd(aParamAdi,{'para1',,'para1'})
aAdd(aParamAdi,{'para2',,'para2'})
aAdd(aParamAdi,{'para3',,'para3'})
aAdd(aParamAdi,{'para4',,'para4'})
aAdd(aParamAdi,{'para5',,'para5'})
aAdd(aParamAdi,{'para6',,'para6'})
aAdd(aParamAdi,{'requer1',,'requer1'})
aAdd(aParamAdi,{'requer2',,'requer2'})
aAdd(aParamAdi,{'requer3',,'requer3'})
aAdd(aParamAdi,{'requer4',,'requer4'})
aAdd(aParamAdi,{'requer5',,'requer5'})
aAdd(aParamAdi,{'requer6',,'requer6'})
aAdd(aParamAdi,{'requer7',,'requer7'})
aAdd(aParamAdi,{'textoRequerer',,'textoRequerer'})
*/
//aAdd(aForms,{"form_aditivo",aParamAdi})

Begin Sequence

For i := 1 To Len(aForms)

   nForm := aScan(aFormularios,{|X| AllTrim(Upper(X[1])) == AllTrim(Upper(aForms[i][1])) })

   If lRequest 
      cPostPar := ""
      For j := 1 To Len(aForms[i][2])
         If ValType(aForms[i][2][j][3]) == "U"
            cPostPar += aForms[i][2][j][1] + "=#" + aForms[i][2][j][1] + "#&"
         Else
            cPostPar += aForms[i][2][j][1] + "=" + &(aForms[i][2][j][3]) + "&"
         EndIf
      Next j
      cPostPar := Left(cPostPar,Len(cPostPar)-1)
   
      sPostRet := EasyHttpSubmit("POST",aFormularios[nForm][2],cPostPar,nTimeOut)
   Else

      If Lower(aForms[i][1]) == "form_pedido"
         cFile := PEDIDO_APH
      ElseIf Lower(aForms[i][1]) == "form_anexo" 
         cFile := ANEXO_APH
     // ElseIf Lower(aForms[i][1]) == "form_aditivo"
     //    cFile := ADITIVO_APH
      EndIf

      nPosEspec := aScan(aForms[i][2],{|X| AllTrim(Upper(X[1])) == AllTrim(Upper("especificacao")) })
      If nPosEspec > 0 
         cEspecificacao := aforms[i][2][nPosEspec][3]
      EndIf
      sPostRet := &(cFile+"()")

   EndIf
      
   sPostRet := strTran(sPostRet,'src="','src="http://www.bb.com.br')
   sPostRet := strTran(sPostRet,'<head>',"<head><link rel='stylesheet' href='http://www.bb.com.br/docs/frm/inc/formIe.css' type='text/css'>")
   sPostRet := strTran(sPostRet,'onLoad="configuraX2copias_II()"',"")
   
   For j := 1 To Len(aForms[i][2])
      If !Empty(aForms[i][2][j][2])
         sPostRet := StrTran(sPostRet,"#"+aForms[i][2][j][1]+"#",&(aForms[i][2][j][2]))
      EndIf
   Next j
   
   cQuebra := '<br class="quebraPagina">'
   cFim    := '</body>'+CHR(13)+CHR(10)+'</html>'

   aSecoes := {}
   While (nPos := At(cQuebra,sPostRet)) > 0
      cSecao   := SubStr(sPostRet,1,nPos-1)
      sPostRet := SubStr( sPostRet , nPos+Len(cQuebra), Len(sPostRet))
      aAdd(aSecoes,cSecao)
   EndDo
   aAdd(aSecoes,sPostRet)

   cPagina := ""
   For j := 1 To Len(aFormularios[nForm][3])
      nPosSec := aFormularios[nForm][3][j]
      If nPosSec > 0 .AND. nPosSec <= Len(aSecoes)
         cPagina += aSecoes[nPosSec]
         cPagina += cQuebra
      EndIf
   Next j

   nPosQuebra := Rat(cQuebra,cPagina)
   nPosFim    := Rat(cFim,cPagina)
   If nPosFim < nPosQuebra
      cPagina := Substr(cPagina,1,nPosQuebra-1)
   EndIf
   aAdd(aPaginas,{nForm,cPagina})

Next i

// Criação das paginas e carregando as mesmas
If GetPaginas(aPaginas)
   lRet := EasyClientShell(cVia1 + cExtensao) .And. EasyClientShell(cVia2 + cExtensao) .And. EasyClientShell(cVia3 + cExtensao) .And. EasyClientShell(cVia4 + cExtensao)
EndIf

End Sequence

If !Empty(sPostRet)
   conout("Ok HttpPost")
   conout("WebPage", Len(sPostRet))
Endif
VarInfo("Header", cHeadRet)

Return lRet

Static Function GetPedido(aAnexosExp,aAnexosImp,aAnexosPerc,aTotExp,aTotImp,aForms)
Local aLayoutPed := {}
Local aMeses     := {"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"}
Local cMsgAnexos := ""
Local cLocalData := ""
Local cEndereco  := ""
Local lRet       := .T.
Local dDtEnvio
Local i
Local nAnexosImp  := 0
Local nAnexosExp  := 0
Local nAnexosPer  := 0

Begin Sequence

   dDtEnvio   := If(Empty(ED0->ED0_DT_ENV),dDataBase,ED0->ED0_DT_ENV)
   cLocalData := Upper(Left(AllTrim(SYT->YT_CIDADE),1))+Lower(SubStr(AllTrim(SYT->YT_CIDADE),2))+", "+;
                 StrZero(Day(dDtEnvio),2)+" de "+Lower(aMeses[Month(dDtEnvio)])+" de "+Str(Year(dDtEnvio),4)+"."

   cEndereco := AllTrim(SYT->YT_ENDE)+" - "+AllTrim(SYT->YT_CIDADE)+" - "+AllTrim(SYT->YT_ESTADO)

   //              {campo_formular,conteudo   ,conteudo_post}
   aAdd(aLayoutPed,{'beneficiario',"SYT->YT_NOME",           })// 4 
   aAdd(aLayoutPed,{'cgc'         ,"TransForm(SYT->YT_CGC,'"+AvSX3('YT_CGC',AV_PICTURE)+"')",           })// 5
   aAdd(aLayoutPed,{'endereco'    ,"'"+cEndereco+"'",           })// 6
   aAdd(aLayoutPed,{'requer'      ,           ,"'isencao'"})

   nAnexosImp := Len(aAnexosImp)
   nAnexosExp := Len(aAnexosExp)
   nAnexosPer := Len(aAnexosPerc)  
   If nAnexosImp == 1 .AND. GetField(aAnexosImp[1],"QTD_ITENS",.F.)[2] <= 4 //O Pedido de Drawback só tem espaco de 4 linhas para os itens, caso seja necessário mais espaço, utilizamos os anexos
      For i := 1 To 4
         aAdd(aLayoutPed,{'itemTarifa'+AllTrim(Str(i)),"GetFieldArray(aAnexosImp[1],'ITENS',"+Str(i)+",'ED2_NCM')[2]",})//7
         aAdd(aLayoutPed,{'peso'+AllTrim(Str(i))      ,"GetFieldArray(aAnexosImp[1],'ITENS',"+Str(i)+",'ED2_PESO')[2]",})//8
         aAdd(aLayoutPed,{'qtde'+AllTrim(Str(i))      ,"GetFieldArray(aAnexosImp[1],'ITENS',"+Str(i)+",'ED2_QTDNCM')[2]+' '+GetFieldArray(aAnexosImp[1],'ITENS',"+Str(i)+",'ED2_UMNCM')[2]",})//9
         aAdd(aLayoutPed,{'discrimina'+AllTrim(Str(i)),"GetFieldArray(aAnexosImp[1],'ITENS',"+Str(i)+",'DESCR')[2]",})//10
         aAdd(aLayoutPed,{'naMoeda'+AllTrim(Str(i))   ,"GetFieldArray(aAnexosImp[1],'ITENS',"+Str(i)+",'ED2_MOEDA')[2]+' '+GetFieldArray(aAnexosImp[1],'ITENS',"+Str(i)+",'ED2_VL_MOE')[2]",})//11
         aAdd(aLayoutPed,{'emDolar'+AllTrim(Str(i))   ,"GetFieldArray(aAnexosImp[1],'ITENS',"+Str(i)+",'ED2_VALEMB')[2]",})
      Next i
   Else
      If nAnexosImp > 1
         cMsgAnexos := "Anexos 001 á "+AllTrim(StrZero(nAnexosImp,3))
      Else
         cMsgAnexos := "Anexo 001"
      EndIf
   
      aAdd(aLayoutPed,{'itemTarifa1',"'"+cMsgAnexos+"'",})//7
      aAdd(aLayoutPed,{'peso1'      ,"'"+cMsgAnexos+"'",})//8
      aAdd(aLayoutPed,{'qtde1'      ,"'"+cMsgAnexos+"'",})//9
      aAdd(aLayoutPed,{'discrimina1',"'"+cMsgAnexos+"'",})//10
      aAdd(aLayoutPed,{'naMoeda1'   ,"'"+cMsgAnexos+"'",})//11
      aAdd(aLayoutPed,{'emDolar1'   ,"'"+cMsgAnexos+"'",})
   
      For i := 2 To 4
         aAdd(aLayoutPed,{'itemTarifa'+AllTrim(Str(i)),"''",})//7
         aAdd(aLayoutPed,{'peso'+AllTrim(Str(i))      ,"''",})//8
         aAdd(aLayoutPed,{'qtde'+AllTrim(Str(i))      ,"''",})//9
         aAdd(aLayoutPed,{'discrimina'+AllTrim(Str(i)),"''",})//10
         aAdd(aLayoutPed,{'naMoeda'+AllTrim(Str(i))   ,"''",})//11
         aAdd(aLayoutPed,{'emDolar'+AllTrim(Str(i))   ,"''",})
      Next i
   EndIf   
   
   cExtenso := "("+StrTran(AllTrim(EXTENSO(GetField(aTotImp,"ED2_VALEMB",.F.)[2],.F.)),"REAIS",If(GetField(aTotImp,"ED2_VALEMB",.F.)[2]<2,AllTrim(SYF->YF_DESC_SI),AllTrim(SYF->YF_DESC_PL)))+")"

   aAdd(aLayoutPed,{'liqTotal'  ,'GetField(aTotImp,"ED2_PESO")[2]',}) //12
   aAdd(aLayoutPed,{'bLiqTotal' ,"'KG'",})
   aAdd(aLayoutPed,{'qtdeTotal' ,'DescArray(GetField(aTotImp,"ED2_QTDNCM",.F.)[2],"'+FormatPict("ED2_QTDNCM",4)/*AVSX3("ED2_QTDNCM",AV_PICTURE)*/+'",.F.)',}) //13 - AOM 27/06/2012
   aAdd(aLayoutPed,{'bQtdeTotal',"''",})
   aAdd(aLayoutPed,{'valorEmb1' ,'DescArray(GetField(aTotImp,"ED2_VL_MOE",.F.)[2],"'+FormatPict("ED2_VL_MOE",4)/*AVSX3("ED2_VL_MOE",AV_PICTURE)*/+'",.T.)',}) //14 - AOM 27/06/2012
   aAdd(aLayoutPed,{'valorEmb2' ,'GetField(aTotImp,"ED2_VALEMB")[2]',})
   aAdd(aLayoutPed,{'valorEmbExtenso',"'"+cExtenso+"'",}) //15
   aAdd(aLayoutPed,{'produto18',,"'exportado'"})//16

   If nAnexosExp == 1 .AND. GetField(aAnexosExp[1],"QTD_ITENS",.F.)[2] <= 4 //O Pedido de Drawback só tem espaco de 4 linhas para os itens, caso seja necessário mais espaço, utilizamos os anexos
      For i := 1 To 4
         aAdd(aLayoutPed,{'itemTarifa'+AllTrim(Str(i))+'b',"GetFieldArray(aAnexosExp[1],'ITENS',"+Str(i)+",'ED1_NCM')[2]",})//17
         aAdd(aLayoutPed,{'peso'+AllTrim(Str(i))+'b'      ,"GetFieldArray(aAnexosExp[1],'ITENS',"+Str(i)+",'ED1_PESO')[2]",})//18
         aAdd(aLayoutPed,{'qtde'+AllTrim(Str(i))+'b'      ,"GetFieldArray(aAnexosExp[1],'ITENS',"+Str(i)+",'ED1_QTDNCM')[2]+' '+GetFieldArray(aAnexosExp[1],'ITENS',"+Str(i)+",'ED1_UMNCM')[2]",})//19
         aAdd(aLayoutPed,{'discrimina'+AllTrim(Str(i))+'b',"GetFieldArray(aAnexosExp[1],'ITENS',"+Str(i)+",'DESCR')[2]",})//20
         aAdd(aLayoutPed,{'naMoeda21'+AllTrim(Str(i))     ,"GetFieldArray(aAnexosExp[1],'ITENS',"+Str(i)+",'ED1_MOEDA')[2]+' '+GetFieldArray(aAnexosExp[1],'ITENS',"+Str(i)+",'ED1_VL_MOE')[2]",})//21
         aAdd(aLayoutPed,{'emDolar21'+AllTrim(Str(i))     ,"GetFieldArray(aAnexosExp[1],'ITENS',"+Str(i)+",'ED1_VAL_EM')[2]",})
      Next i
   Else
      If nAnexosExp > 1
         cMsgAnexos := "Anexos "+AllTrim(StrZero(nAnexosImp+1,3))+" á "+AllTrim(StrZero(nAnexosImp+nAnexosExp,3))
      Else
         cMsgAnexos := "Anexo "+AllTrim(StrZero(nAnexosImp+1,3))
      EndIf
    
      aAdd(aLayoutPed,{'itemTarifa1b',"'"+cMsgAnexos+"'",})//17
      aAdd(aLayoutPed,{'peso1b'      ,"'"+cMsgAnexos+"'",})//18
      aAdd(aLayoutPed,{'qtde1b'      ,"'"+cMsgAnexos+"'",})//19
      aAdd(aLayoutPed,{'discrimina1b',"'"+cMsgAnexos+"'",})//20
      aAdd(aLayoutPed,{'naMoeda211'  ,"'"+cMsgAnexos+"'",})//21
      aAdd(aLayoutPed,{'emDolar211'  ,"'"+cMsgAnexos+"'",})   
      For i := 2 To 4
         aAdd(aLayoutPed,{'itemTarifa'+AllTrim(Str(i))+'b',"''",})//17
         aAdd(aLayoutPed,{'peso'+AllTrim(Str(i))+'b'      ,"''",})//18
         aAdd(aLayoutPed,{'qtde'+AllTrim(Str(i))+'b'      ,"''",})//19
         aAdd(aLayoutPed,{'discrimina'+AllTrim(Str(i))+'b',"''",})//20
         aAdd(aLayoutPed,{'naMoeda21'+AllTrim(Str(i))     ,"''",})//21
         aAdd(aLayoutPed,{'emDolar21'+AllTrim(Str(i))     ,"''",})
      Next i
   EndIf

   cExtenso  := "("+StrTran(AllTrim(EXTENSO(GetField(aTotExp,"ED1_VAL_EM",.F.)[2],.F.)),"REAIS",If(GetField(aTotExp,"ED1_VAL_EM",.F.)[2]<2,AllTrim(SYF->YF_DESC_SI),AllTrim(SYF->YF_DESC_PL)))+")"//22

   aAdd(aLayoutPed,{'liqTotalb'  ,'GetField(aTotExp,"ED1_PESO")[2]',}) //12
   aAdd(aLayoutPed,{'bbLiqTotal' ,"'KG'",})
   aAdd(aLayoutPed,{'qtdeTotalb' ,'DescArray(GetField(aTotExp,"ED1_QTDNCM",.F.)[2],"'+FormatPict("ED1_QTDNCM",4)/*AVSX3("ED1_QTDNCM",AV_PICTURE)*/+'",.F.)',}) //13 - AOM 27/06/2012
   aAdd(aLayoutPed,{'bbQtdeTotalbb',"''",})
   aAdd(aLayoutPed,{'valorEmbb'  ,'GetField(aTotExp,"ED1_VAL_EM")[2]',})
   aAdd(aLayoutPed,{'valorEmbExtensob',"'"+cExtenso+"'",}) //15

   aAdd(aLayoutPed,{'param',,"''"}) //15
   aAdd(aLayoutPed,{'localData',"'"+cLocalData+"'",})
   aAdd(aLayoutPed,{'receitaFederal',"''",})
   aAdd(aLayoutPed,{'matriz',"''",})
   aAdd(aLayoutPed,{'nomeExtenso' ,'EasyGParam("MV_PEDATO1",,"")',})
   aAdd(aLayoutPed,{'nomeExtenso2','EasyGParam("MV_PEDATO2",,"")',})

   If nAnexosPer == 0
      aAdd(aLayoutPed,{'sub1',"''",})
      aAdd(aLayoutPed,{'aprop1',"''",})
      aAdd(aLayoutPed,{'venda1',"''",})
      aAdd(aLayoutPed,{'semValor1',"'X'",})
      aAdd(aLayoutPed,{'semIcm1',"''",})
      aAdd(aLayoutPed,{'sub2',"''",})
      aAdd(aLayoutPed,{'aprop2',"''",})
      aAdd(aLayoutPed,{'venda2',"''",})
      aAdd(aLayoutPed,{'semValor2',"'X'",})
      aAdd(aLayoutPed,{'semIcm2',"''",})
   ElseIf nAnexosPer == 1 .AND. GetField(aAnexosPerc[1],"QTD_ITENS",.F.)[2] <= 2 //O Pedido de Drawback só tem espaco de 2 linhas para os residuos, caso seja necessário mais espaço, utilizamos os anexos
      For i := 1 To 2
         aAdd(aLayoutPed,{'sub'+AllTrim(Str(i))     ,"GetFieldArray(aAnexosPerc[1],'ITENS',"+Str(i)+",'ED2_NCM')[2]+' - '+GetFieldArray(aAnexosPerc[1],'ITENS',"+Str(i)+",'ED2_ITEM')[2]",})
         aAdd(aLayoutPed,{'aprop'+AllTrim(Str(i))   ,"'Percentual de'",})//18
         aAdd(aLayoutPed,{'venda'+AllTrim(Str(i))   ,"'Perda '",})//19
         aAdd(aLayoutPed,{'semValor'+AllTrim(Str(i)),"GetPerca(aAnexosPerc[1],"+Str(i)+")",})
         aAdd(aLayoutPed,{'semIcm'+AllTrim(Str(i))  ,"''",})//21
      Next i
   Else

      If nAnexosImp < 1
         nAnexosImp := 0
      EndIf

      If nAnexosExp < 1 
         nAnexosExp := 0
      EndIf

      If nAnexosPer > 1
         cMsgAnexos := "Anexos "+AllTrim(StrZero(nAnexosImp+nAnexosExp+1,3))+" á "+AllTrim(StrZero(nAnexosImp+nAnexosExp+nAnexosPer,3))
      Else
         cMsgAnexos := "Anexo "+AllTrim(StrZero(nAnexosImp+nAnexosExp+1,3))
      EndIf

      aAdd(aLayoutPed,{'sub1',"'"+cMsgAnexos+"'",})
      aAdd(aLayoutPed,{'aprop1',"''",})
      aAdd(aLayoutPed,{'venda1',"''",})
      aAdd(aLayoutPed,{'semValor1',"''",})
      aAdd(aLayoutPed,{'semIcm1',"''",})
      aAdd(aLayoutPed,{'sub2',"'"+cMsgAnexos+"'",})
      aAdd(aLayoutPed,{'aprop2',"''",})
      aAdd(aLayoutPed,{'venda2',"''",})
      aAdd(aLayoutPed,{'semValor2',"''",})
      aAdd(aLayoutPed,{'semIcm2',"''",})
   EndIf

   aAdd(aForms,{"form_pedido" ,aLayoutPed})

End Sequence

Return lRet

Static Function GetAnexo(cAlias,cDados,nAnexo,cEspecificacao,cCampo,aForms)
Local aParamAne       := {}
Local aDados          := &(cDados)
Local aMeses          := {"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"}
Local cAnexo          := ""
Local cLocalData      := ""
Local cEndereco       := ""
Local cNomeExt        := EasyGParam("MV_PEDATO1",,"") + "  " + EasyGParam("MV_PEDATO2",,"") 
Local lRet            := .T.
Local lEspecificacao  := !Empty(cEspecificacao)//Upper(cEspecificacao) == "PORIMPORTAR" .Or. Upper(cEspecificacao) == "EXPORTADAS"
Local dDtEnvio
Local i,j

Begin Sequence

   dDtEnvio   := If(Empty(ED0->ED0_DT_ENV),dDataBase,ED0->ED0_DT_ENV)
   cLocalData := Upper(Left(AllTrim(SYT->YT_CIDADE),1))+Lower(SubStr(AllTrim(SYT->YT_CIDADE),2))+", "+;
                 StrZero(Day(dDtEnvio),2)+" de "+Lower(aMeses[Month(dDtEnvio)])+" de "+Str(Year(dDtEnvio),4)+"."
   cEndereco  := AllTrim(SYT->YT_ENDE)+" - "+AllTrim(SYT->YT_CIDADE)+" - "+AllTrim(SYT->YT_ESTADO)

   For i := 1 To Len(aDados)
      cAnexo := AllTrim(StrZero(nAnexo+i,3))
      aParamAne := {}
      aAdd(aParamAne,{'anexo'        ,"'"+cAnexo+"'"                                            ,                               })
      aAdd(aParamAne,{'beneficiario' ,"SYT->YT_NOME"                                            ,                               })// 1
      aAdd(aParamAne,{'cgc'          ,"TransForm(SYT->YT_CGC,'"+AvSX3('YT_CGC',AV_PICTURE)+"')" ,                               })// 2
      aAdd(aParamAne,{'endereco'     ,"'"+cEndereco+"'"                                         ,                               })


      If lEspecificacao // Anexo para os produtos importados ou exportados

         aAdd(aParamAne,{'especificacao',                                                          ,"'"+cEspecificacao+"'"})// 3

         For j := 1 To nLinhasPorAnexo
            aAdd(aParamAne,{'tarifa'+AllTrim(Str(j))    ,"GetFieldArray("+AllTrim(cDados)+"["+AllTrim(Str(i))+"],'ITENS',"+Str(j)+",'"+AllTrim(cAlias)+"_NCM')[2]"                                                                                                                 ,})//4
            aAdd(aParamAne,{'liquido'+AllTrim(Str(j))   ,"GetFieldArray("+AllTrim(cDados)+"["+AllTrim(Str(i))+"],'ITENS',"+Str(j)+",'"+AllTrim(cAlias)+"_PESO')[2]"                                                                                                                ,})//5
            aAdd(aParamAne,{'qtda'+AllTrim(Str(j))      ,"GetFieldArray("+AllTrim(cDados)+"["+AllTrim(Str(i))+"],'ITENS',"+Str(j)+",'"+AllTrim(cAlias)+"_QTDNCM')[2]+' '+GetFieldArray("+AllTrim(cDados)+"["+AllTrim(Str(i))+"],'ITENS',"+Str(j)+",'"+AllTrim(cAlias)+"_UMNCM')[2]",})//6
            aAdd(aParamAne,{'discrimina'+AllTrim(Str(j)),"GetFieldArray("+AllTrim(cDados)+"["+AllTrim(Str(i))+"],'ITENS',"+Str(j)+",'DESCR')[2]"                                                                                                                                   ,})//7
            aAdd(aParamAne,{'unitario'+AllTrim(Str(j))  ,"GetFieldArray("+AllTrim(cDados)+"["+AllTrim(Str(i))+"],'ITENS',"+Str(j)+",'"+AllTrim(cAlias)+"_MOEDA')[2]+' '+GetFieldArray("+AllTrim(cDados)+"["+AllTrim(Str(i))+"],'ITENS',"+Str(j)+",'"+AllTrim(cAlias)+"_VL_MOE')[2]",})//8
            aAdd(aParamAne,{'total'+AllTrim(Str(j))     ,"GetFieldArray("+AllTrim(cDados)+"["+AllTrim(Str(i))+"],'ITENS',"+Str(j)+",'"+AllTrim(cCampo)+"')[2]"                                                                                                                     ,})
         Next j

         aAdd(aParamAne,{'tt_liqui'      ,'GetField('+AllTrim(cDados)+'['+AllTrim(Str(i))+'],"'+AllTrim(cAlias)+'_PESO",.T.)[2]'                                                                                  ,    }) // 9
         aAdd(aParamAne,{'tt_liquiB'     ,"'KG'"                                                                                                                                                                  ,    })
         //aAdd(aParamAne,{'tt_quant'      ,'DescArray(GetField('+AllTrim(cDados)+'['+AllTrim(Str(i))+'],"'+AllTrim(cAlias)+'_QTDNCM",.F.)[2],AVSX3("'+AllTrim(cAlias)+'_QTDNCM",'+AllTrim(Str(AV_PICTURE))+'),.F.)',    }) //10   - NOPADO AOM - 27/06/2012
         aAdd(aParamAne,{'tt_quant'      ,'DescArray(GetField('+AllTrim(cDados)+'['+AllTrim(Str(i))+'],"'+AllTrim(cAlias)+'_QTDNCM",.F.)[2],"'+ FormatPict(AllTrim(cAlias)+"_QTDNCM",4) +'",.F.)',    }) //10 - AOM - 27/06/2012
         aAdd(aParamAne,{'tt_quantB'     ,"''"                                                                                                                                                                    ,    })
         //aAdd(aParamAne,{'embarqueMoeda' ,'DescArray(GetField('+AllTrim(cDados)+'['+AllTrim(Str(i))+'],"'+AllTrim(cAlias)+'_VL_MOE",.F.)[2],AVSX3("'+AllTrim(cAlias)+'_VL_MOE",'+AllTrim(Str(AV_PICTURE))+'),.T.)',    }) //11   - NOPADO AOM - 27/06/2012
         aAdd(aParamAne,{'embarqueMoeda' ,'DescArray(GetField('+AllTrim(cDados)+'['+AllTrim(Str(i))+'],"'+AllTrim(cAlias)+'_VL_MOE",.F.)[2],"'+ FormatPict(AllTrim(cAlias)+"_VL_MOE",4) +'",.T.)',    }) //11 - AOM - 27/06/2012
         aAdd(aParamAne,{'embarqueDolar' ,'GetField('+AllTrim(cDados)+'['+AllTrim(Str(i))+'],"'+AllTrim(cCampo)+'")[2]'                                                                                           ,    }) //12
      
      Else // Anexo para os subprodutos

         aAdd(aParamAne,{'especificacao',,"''"})// 3
         aAdd(aParamAne,{'tarifa1'    ,"''",})//4
         aAdd(aParamAne,{'liquido1'   ,"''",})//5
         aAdd(aParamAne,{'qtda1'      ,"''",})//6
         aAdd(aParamAne,{'discrimina1',"'Continuação do campo 30 do pedido do Drawback'",})//7
         aAdd(aParamAne,{'unitario1'  ,"''",})//8
         aAdd(aParamAne,{'total1'     ,"''",})
         aAdd(aParamAne,{'tarifa2'    ,"''",})//4
         aAdd(aParamAne,{'liquido2'   ,"''",})//5
         aAdd(aParamAne,{'qtda2'      ,"'Cod. Mercadoria'",})//6
         aAdd(aParamAne,{'discrimina2',"'Descricao'",})//7
         aAdd(aParamAne,{'unitario2'  ,"'% Perda'",})//8
         aAdd(aParamAne,{'total2'     ,"''",})            

         For j := 3 To nLinhasPorAnexo
            nPos := j - 2
            aAdd(aParamAne,{'tarifa'+AllTrim(Str(j))    ,"''",})//4
            aAdd(aParamAne,{'liquido'+AllTrim(Str(j))   ,"''",})//5
            aAdd(aParamAne,{'qtda'+AllTrim(Str(j))      ,"GetFieldArray("+AllTrim(cDados)+"["+AllTrim(Str(i))+"],'ITENS',"+Str(nPos)+",'"+AllTrim(cAlias)+"_NCM')[2]",})//6
            aAdd(aParamAne,{'discrimina'+AllTrim(Str(j)),"GetFieldArray("+AllTrim(cDados)+"["+AllTrim(Str(i))+"],'ITENS',"+Str(nPos)+",'DESCR')[2]",})//7
            aAdd(aParamAne,{'unitario'+AllTrim(Str(j))  ,"GetPerca("+AllTrim(cDados)+"["+AllTrim(Str(i))+"],"+Str(nPos)+")",})
            aAdd(aParamAne,{'total'+AllTrim(Str(j))     ,"''",})
         Next j

         aAdd(aParamAne,{'tt_liqui'      ,"''",    }) // 9
         aAdd(aParamAne,{'tt_liquiB'     ,"''",    })
         aAdd(aParamAne,{'tt_quant'      ,"''",    }) //10
         aAdd(aParamAne,{'tt_quantB'     ,"''",    })
         aAdd(aParamAne,{'embarqueMoeda' ,"''",    }) //11
         aAdd(aParamAne,{'embarqueDolar' ,"''",    }) //12      

      EndIf

      aAdd(aParamAne,{'param'         ,,"''"})
    
      //Campos para o anexo do produto importado
      aAdd(aParamAne,{'localdata'     ,"'"+cLocalData+"'",    }) //13
      aAdd(aParamAne,{'nomeExt'       ,"'"+cNomeExt+"'"  ,    }) //13

      aAdd(aForms,{"form_anexo"  ,aParamAne})
   Next i

End Sequence

Return lRet 

Static Function GetPaginas(aPaginas)
Local nForm := 0, nForm1 := 0, nForm2 := 0, nForm3 := 0
Local i
Local cPagina := ""
Local aPag := {}, aRetQuebra := {}, aRet := {}
Local cPagina1 := "" // Pagina 1 - Via 1
Local cPagina2 := "" // Pagina 2 - Via 2 e Via 3
Local cPagina3 := "" // Pagina 3 - Via 2 e Via 3
Local cPagina4 := "" // Pagina 4 - Via 4
Local cPagAnexo2 := ""
Local nPosVia1 := 0 // Via 1
Local nPosVia2 := 0 // Via 2 e 3
Local nPosVia4 := 0 // Via 4
Local nPosVia5 := 0 // Protocolo
Local cDirStartPah := GetSrvProfString("STARTPATH","")
Local nHandle1 := 0
Local nHandle2 := 0
Local nHandle3 := 0
Local nHandle4 := 0
Local lRet := .F.

Begin Sequence

   For i := 1 To Len(aPaginas)
      nForm   := aPaginas[i][1]
      cPagina := aPaginas[i][2]
      If !Empty(cPagina) .And. !Empty(nForm) 
         aAdd(aRetQuebra,GetQuebra(cPagina,nForm))
      EndIf
   Next i

   If Empty(aRetQuebra)
      Break
   EndIf

   If !(ValType(cVia1) == "C" .Or. ValType(cVia2) == "C" .Or. ValType(cVia3) == "C" .Or. ValType(cVia4) == "C" .Or. Valtype(cExtensao) == "C")
      Break
   EndIf

   // Criação das paginas que serão apresentado as vias
   nHandle1 := EasyCreateFile(cDirStartPah + cVia1 + cExtensao)
   nHandle2 := EasyCreateFile(cDirStartPah + cVia2 + cExtensao)   
   nHandle3 := EasyCreateFile(cDirStartPah + cVia3 + cExtensao)
   nHandle4 := EasyCreateFile(cDirStartPah + cVia4 + cExtensao)
      
   If nHandle1 == -1 .Or. nHandle2 == -1 .Or. nHandle3 == -1 .Or. nHandle4 == -1 
      Break
   EndIf

   nForm1 := aScan(aRetQuebra,{|X| X[1] == 1}) // Formulario do pedido
   nForm2 := aScan(aRetQuebra,{|X| X[1] == 2}) // Formulario do anexo
   nForm3 := aScan(aRetQuebra,{|X| X[1] == 3}) // Formulario do aditivo

   If nForm1 == 1 // Pedido 

      nPosVia1 := aScan(aRetQuebra[nForm1][2],{|X| X[1] == 1 .And. !Empty(X[2]) }) // Via 1
      nPosVia2 := aScan(aRetQuebra[nForm1][2],{|X| X[1] == 2 .And. !Empty(X[2]) }) // Via 2 e 3
      nPosVia4 := aScan(aRetQuebra[nForm1][2],{|X| X[1] == 3 .And. !Empty(X[2]) }) // Via 4
      nPosVia5 := aScan(aRetQuebra[nForm1][2],{|X| X[1] == 4 .And. !Empty(X[2]) }) // Protocolo

      If nPosVia1 > 0 // Via 1
         FWrite(nHandle1, AcertaHeader(nForm1))
         FSeek(nHandle1, 0, 2) 
         FWrite(nHandle1, AcertaPagina(aRetQuebra[nForm1][2][nPosVia1][2]))
         FSeek(nHandle1, 0, 2) 
      EndIf

      If nPosVia2 > 0 // Via 2 e 3
         FWrite(nHandle2, AcertaHeader(nForm1))
         FSeek(nHandle2, 0, 2) 
         FWrite(nHandle2, AcertaPagina(aRetQuebra[nForm1][2][nPosVia2][2],Len(aRetQuebra)==1))
         FSeek(nHandle2, 0, 2) 

         FWrite(nHandle3, AcertaHeader(nForm1))
         FSeek(nHandle3, 0, 2) 
         FWrite(nHandle3, AcertaPagina(aRetQuebra[nForm1][2][nPosVia2][2],Len(aRetQuebra)==1))
         FSeek(nHandle3, 0, 2)
      EndIf
      
      If nPosVia4 > 0 // Via 1
         FWrite(nHandle4, AcertaHeader(nForm1))
         FSeek(nHandle4, 0, 2) 
         FWrite(nHandle4, AcertaPagina(aRetQuebra[nForm1][2][nPosVia4][2],Len(aRetQuebra)==1))
         FSeek(nHandle4, 0, 2) 
      EndIf

   EndIf

   If nForm2 == 2 // Anexos

      For i := nForm2 To (Len(aRetQuebra) - nForm3) 

         nPosVia1 := aScan(aRetQuebra[i][2],{|X| X[1] == 1 .And. !Empty(X[2]) }) // Via 1
         nPosVia2 := aScan(aRetQuebra[i][2],{|X| X[1] == 2 .And. !Empty(X[2]) }) // Via 2
   
         If nPosVia1 > 0 // Via 1
            FWrite(nHandle1, AcertaHeader(nForm2))
            FSeek(nHandle1, 0, 2) 
            FWrite(nHandle1, AcertaPagina(aRetQuebra[i][2][nPosVia1][2]))
            FSeek(nHandle1, 0, 2) 
         EndIf
       
         If nPosVia2 > 0 // Via 2 
            FWrite(nHandle2, AcertaHeader(nForm2))
            FSeek(nHandle2, 0, 2) 
            FWrite(nHandle2, AcertaPagina(aRetQuebra[i][2][nPosVia2][2], i == (Len(aRetQuebra) - nForm3)))

            FWrite(nHandle3, AcertaHeader(nForm2))
            FSeek(nHandle3, 0, 2) 
            FWrite(nHandle3, AcertaPagina(aRetQuebra[i][2][nPosVia2][2], i == (Len(aRetQuebra) - nForm3)))

            FWrite(nHandle4, AcertaHeader(nForm2))
            FSeek(nHandle4, 0, 2) 
            FWrite(nHandle4, AcertaPagina(aRetQuebra[i][2][nPosVia2][2], i == (Len(aRetQuebra) - nForm3)))
         EndIf

      Next i

   EndIf

   If nForm1 == 1 .And. nPosVia5 > 0 // Protocolo
      FWrite(nHandle1, AcertaHeader(nForm1,.T.))
      FSeek(nHandle1, 0, 2) 
      FWrite(nHandle1, AcertaPagina(aRetQuebra[nForm1][2][nPosVia5][2],If(Type("mCartaPag") == "C" .AND. !Empty(mCartaPag),.F.,.T.)))
   EndIf
   
   // GFP - 19/10/2011
   If Type("mCartaPag") == "C" .AND. !Empty(mCartaPag)  
         
      FWrite(nHandle1,AcertaHeader(4))
      FSeek(nHandle1, 0, 2) 
      FWrite(nHandle1, AcertaPagina(PA151Carta(),.T.))
   
   EndIf
      
   
   //If nForm3 == 3 // Aditivos
   //EndIf

   lRet := FClose(nHandle1) .And. FClose(nHandle2) .And. FClose(nHandle3) .And. FClose(nHandle4)

End Sequence

Return lRet

Static Function GetQuebra(cPagina,nForm)
Local cQuebraIni := '<table '
Local cQuebraFim := '<br class="quebraPagina">'
Local nVia       := 0 
Local cAux       := ""
Local cAux1      := ""
Local cAux2      := ""
Local aTables    := {}
Local nCont      := 0
Local nIni       := 0
Local nFim       := 0

Begin Sequence

   cAux := cPagina
   nIni := At(cQuebraIni,cAux)
   nFim := At(cQuebraFim,cAux)
   nCont := 1

   Do While nIni > 0 .And. nFim > 0 
      cTable := SubStr(cAux, nIni - 1, nFim  + Len(cQuebraFim) + 1 - nIni)
      cAux1  := SubStr(cAux, 1, nIni - 1)
      cAux2  := SubStr(cAux, nFim  + Len(cQuebraFim) + 1 , Len(cAux))
      cAux   := cAux1 + cAux2
      nIni   := At(cQuebraIni,cAux)
      nFim   := At(cQuebraFim,cAux)
      If nCont <= Len(aFormularios[nForm][3])
         nVia   := aFormularios[nForm][3][nCont]
         aAdd(aTables,{nVia,cTable})
      EndIf
      nCont++
   EndDo
   
   // Retirando o ultimo table
   nIni := At(cQuebraIni,cAux)
   nFim := Rat('</table>',cAux)
   If nIni > 0 .And. nFim > 0
      cTable := SubStr(cAux, nIni - 1, nFim + Len('</table>') + 1 - nIni)
      If nCont <= Len(aFormularios[nForm][3])
         nVia := aFormularios[nForm][3][nCont]
         aAdd(aTables,{nVia,cTable})
      EndIf
   EndIf

End Sequence

Return {nForm,aTables}              

Static Function AcertaHeader(nForm,lProtocolo)
Local cPag    := ""
Default lProtocolo := .F.

Begin Sequence

   Do Case
      Case nForm == 1 // Caso seja Pedido

         If !lProtocolo
            cPag := "<html>" + CHR(13)+CHR(10)
         EndIf

         cPag += "<head><link rel='stylesheet' href='http://www.bb.com.br/docs/frm/inc/formIe.css' type='text/css'>" + CHR(13)+CHR(10)+;
                 "<title>Pedido de Ato Concessório de Drawback Integrado Isenção</title>" + CHR(13)+CHR(10)+;
                 "<script language=" + Chr(34) + "javascript" + Chr(34) + " src=" + Chr(34) + "http://www.bb.com.br/docs/frm/inc/scripts.js" + Chr(34) + "></script>" + CHR(13)+CHR(10)+;
                 "<script>" + CHR(13)+CHR(10)+;
                 "	function timeOut(){" + CHR(13)+CHR(10)+;
                 "		setTimeout('',1000 );" + CHR(13)+CHR(10)+;
                 "	}" + CHR(13)+CHR(10)+;
                 "</script>" + CHR(13)+CHR(10)+;
                 "</head>" + CHR(13)+CHR(10)+;
                 "<body bgcolor=" + Chr(34) + "#ffffff" + Chr(34) + " topmargin=" + Chr(34) + "0" + Chr(34) + " leftmargin=" + Chr(34) + "0" + Chr(34) + " marginwidth=" + Chr(34) + "0" + Chr(34) + " marginheight=" + Chr(34) + "0" + Chr(34) + " >" + CHR(13)+CHR(10)

      Case nForm == 2 // Caso seja Anexo
         cPag := "<head><link rel='stylesheet' href='http://www.bb.com.br/docs/frm/inc/formIe.css' type='text/css'>" + CHR(13)+CHR(10)+;
                 "	<title>Anexo ao Ato Concessório ou Aditivo de " + Chr(34) + "Drawback" + Chr(34) + " Isenção Integrado</title>" + CHR(13)+CHR(10)+;
                 "	<script>" + CHR(13)+CHR(10)+;
                 "		function timeOut(){" + CHR(13)+CHR(10)+;
                 "			setTimeout('',1000 );" + CHR(13)+CHR(10)+;
                 "		}" + CHR(13)+CHR(10)+;
                 "	</script>" + CHR(13)+CHR(10)+;
                 "	<script language=" + Chr(34) + "javascript" + Chr(34) + " src=" + Chr(34) + "http://www.bb.com.br/docs/frm/inc/scripts.js" + Chr(34) + "></script>" + CHR(13)+CHR(10)+;
                 "</head>" + CHR(13)+CHR(10)+;
                 "<body bgcolor=" + Chr(34) + "#FFFFFF" + Chr(34) + " leftmargin=" + Chr(34) + "0" + Chr(34) + " topmargin=" + Chr(34) + "0" + Chr(34) + " marginwidth=" + Chr(34) + "0" + Chr(34) + " marginheight=" + Chr(34) + "0" + Chr(34) + " onLoad=" + Chr(34) + "" + Chr(34) + ", timeOut();>" + CHR(13)+CHR(10)

//      Case nForm == 3 // Caso seja Aditivo
//         cPag := ""

       Case nForm == 4 // Carta - GFP - 19/10/2011
          cPag := "<head>"+CHR(13)+CHR(10)+;
                   "</head>"+CHR(13)+CHR(10)+;
                   "   <body>"+CHR(13)+CHR(10)+;
                   "       <b>"+CHR(13)+CHR(10)+;
                   "      <font face= 'Arial' size= '5'>"
                   
       OtherWise
         cPag := ""

   End Case

End Sequence

Return cPag

Static Function AcertaPagina(cPagina,lFim)
Local cPag       := ""
Local cQuebra    := '<br class="quebraPagina">'
Local nPosQuebra := 0
Local nPosFim    := 0
Local nPosFimBody := 0
Local cFim       := '</html>'
Local cBody      := '</body>'
Default lFim     := .F.

Begin Sequence

   nPosQuebra  := Rat(cQuebra,cPagina)
   nPosFim     := Rat(cFim,cPagina)
   nPosFimBody := Rat(cBody,cPagina)

   If nPosQuebra > 0 
      cPag := SubStr(cPagina, 1, nPosQuebra - 1)
   EndIf

   If nPosFim > 0
      cPag := SubStr(cPagina, 1, nPosFim - 1)      
   EndIf

   If nPosFimBody > 0
      cPag := SubStr(cPagina, 1, nPosFimBody - 1)      
   EndIf
   
   If nPosQuebra == 0 .And. nPosFim == 0 .And. nPosFimBody == 0
     cPag := cPagina
   EndIf
 
   If !lFim
      cPag += '</body>'+CHR(13)+CHR(10)+cQuebra+CHR(13)+CHR(10)
   Else
      cPag += '</body>'+CHR(13)+CHR(10)+cFim
   EndIf

End Sequence

Return cPag

Static Function GetPerca(aDados,nPos)
Local cRet := ""

If !Empty(GetFieldArray(aDados,'ITENS',nPos,"ED2_NCM")[2])
   If GetFieldArray(aDados,'ITENS',nPos,"ED2_PERCPE")[2] == GetFieldArray(aDados,'ITENS',nPos,"ED2_PERCAP")[2]
      cRet := GetFieldArray(aDados,'ITENS',nPos,"ED2_PERCPE")[2]
   Else
      cRet := "Entre "+AllTrim(GetFieldArray(aDados,'ITENS',nPos,"ED2_PERCPE")[2])+"% á "+AllTrim(GetFieldArray(aDados,'ITENS',nPos,"ED2_PERCAP")[2])+"%"
   EndIf
EndIf

Return cRet

Static Function GetDescr(cItem,nTam,cOriDesc)
Local cDescricao := ""
Local aRet       := {}
Local i
Local nLinhas

Default nTam := 0
SB1->(dbSetOrder(1))

   If SB1->(dbSeek(xFilial("SB1")+AvKey(cItem,"B1_COD")))//AOM - 14/06/2012 - AvKey o correto é pelo B1_COD
      
      If ED2->(FieldPos("ED2_DI_ORI")) > 0 .And. EasyGParam("MV_EDC0010",,.F.) //RRC - 13/12/2012 - Parâmetro Lógico, se .T. irá concatenar código e descrição do produto, caso contrário, utilizará somente a descrição
         cDescricao := Alltrim(cItem)+" - "      
      EndIf 
      
      //AOM - 14/06/2012
      If cOriDesc == "ITENS_EXP"
         cDescricao += AvDescProdEE2(SB1->B1_COD,,, "PORT. -PORTUGUES")
      Else
         cDescricao += Alltrim(MSMM(SB1->B1_DESC_GI,AvSX3("B1_VM_GI",AV_TAMANHO))) + " (Nome Comercial - "
         cDescricao += Alltrim(MSMM(SB1->B1_DESC_I,AvSX3("B1_VM_I",AV_TAMANHO)))+ ")"//AOM - 14/06/2012
      EndIf
      
      
      cDescricao := StrTran( cDescricao, CRLF , " " )
      cDescricao := StrTran( cDescricao, Chr(13), " " )
      Do While At("  ",cDescricao) > 0
         cDescricao := StrTran( cDescricao, "  " , " " )
      EndDo
   EndIf
   
   If nTam > 0
      nLinhas := Min(MLCount(cDescricao,nTam),nLinhasPorAnexo)
      If nLinhas == 0 //RRC - 13/12/2012 - No caso da descrição estar em branco
         aAdd(aRet,MemoLine(cDescricao,nTam,i))        
      Else      
         For i := 1 To nLinhas
            aAdd(aRet,MemoLine(cDescricao,nTam,i))
         Next i      
      EndIf
   Else
      aRet := {cDescricao}
   EndIf
   
Return aRet

Static Function DescArray(aArray,cPicture,lMoeda)
Local cRet := ""
Local i

   For i := 1 To Len(aArray)
      cRet += If(lMoeda,aArray[i][1]+" ","")+Transform(aArray[i][2],cPicture)+If(!lMoeda," "+aArray[i][1],"")+";"
   Next i
   
Return cRet

Static Function SomaArray(aArray,cChave,nValor)
Local nPos

If !Empty(cChave)
   If (nPos := aScan(aArray,{|X| AllTrim(X[1]) == AllTrim(cChave)})) == 0
      aAdd(aArray,{cChave,0})
      nPos := Len(aArray)
   EndIf
   If ValType(nValor) == "N"
      aArray[nPos][2] += nValor
   EndIf
EndIf

Return aArray

Static Function GetRegArray()
Local aRet := {}
Local i

If !Empty(Alias())
   aRet := Array(Len(dbStruct()))
   For i := 1 To Len(aRet)
      aRet[i] := {FieldName(i),FieldGet(i)}
   Next i
EndIF

Return aRet

Static Function GetFieldArray(aArray,cCampo,nPosArray,cCampo2,lTransform)
Local nPosField, nPosField2
Default lTransform := .T.

If (nPosField := aScan(aArray,{|X| AllTrim(X[1]) == AllTrim(cCampo)})) > 0 .AND. ValType(aArray[nPosField][2]) == "A"
   If (nPosField2 := aScan(aArray[nPosField][2][nPosArray],{|X| ValType(X) == "A" .And. AllTrim(X[1]) == AllTrim(cCampo2)})) > 0
      If lTransform .AND. SX3->(dbSetOrder(2),dbSeek(cCampo2))
         If cCampo $ cCmposPic //AOM - 26/06/2012
            cRet := "<span style='font-size:9px'>"+Transform(aArray[nPosField][2][nPosArray][nPosField2][2],FormatPict(cCampo,4))+"</span>" 
         ElseIf (cCampo == "ITENS" .And. aArray[nPosField][2][nPosArray][nPosField2][1] $ cCmposPic) //AOM - 26/06/2012
            cRet := "<span style='font-size:9px'>"+Transform(aArray[nPosField][2][nPosArray][nPosField2][2],FormatPict(aArray[nPosField][2][nPosArray][nPosField2][1],4))+"</span>" 
         Else 
            cRet := "<span style='font-size:9px'>"+Transform(aArray[nPosField][2][nPosArray][nPosField2][2],AvSX3(cCampo2,AV_PICTURE))+"</span>"
         EndIf                 
      Else
         cRet := "<span style='font-size:7px'>"+aArray[nPosField][2][nPosArray][nPosField2][2]+"</span>"   // GFP - 27/03/2012 - Ajuste no tamanho do fonte.
      EndIf
   Else
      cRet := ""
   EndIf
Else
   cRet := ""
EndIf

Return {cCampo2,cRet}

Static Function GetField(aArray,cCampo,lTransform)
Default lTransform := .T.

If (nPosField := aScan(aArray,{|X| AllTrim(X[1]) == AllTrim(cCampo)})) > 0
   If lTransform  .AND. SX3->(dbSetOrder(2),dbSeek(cCampo))
      If cCampo $ cCmposPic //AOM - 26/06/2012
         cRet := Transform(aArray[nPosField][2],FormatPict(cCampo,4))
      Else
         cRet := Transform(aArray[nPosField][2],AvSX3(cCampo,AV_PICTURE))
      EndIf
   Else
      cRet := aArray[nPosField][2]
   EndIf
Else
   cRet := ""
EndIf

Return {cCampo,cRet}

Static Function ConsolidaAnexo(aItens,cAlias,cCpoNcm,cCpoPeso,cCpoVlUss,cCpoUmNcm,cCpoQtdNcm,cCpoMoeda,cCpoVlMoe)
Local aAnexos    := {}
Local aItemAnexo := {}
Local nLinha  := 1
Local nPosIni := 1
Local nPesoLin := 0
Local nUssLin := 0
Local nQtdNcm := 0
Local nVlMoe := 0
Local i,j

Begin Sequence

If Len(aItens) == 0
   Break
EndIf

For i := 1 To Len(aItens)+1
   
   If i == Len(aItens) + 1 .Or. nLinha + Len(aItens[i][1]) > nLinhasPorAnexo + 1
  
      For j := nLinha To nLinhasPorAnexo
         aAdd(aItemAnexo,{})
      Next j
      
      nUssTot := 0
      nLiqTot := 0
      aQtdTot := {}
      aMoeTot := {}
      If !Empty(cCpoPeso) .AND. !Empty(cCpoVlUss) .AND. !Empty(cCpoQtdNcm) .AND. !Empty(cCpoVlMoe)
         For j := 1 To Len(aItemAnexo)
            If !Empty(nPesoLin := GetField(aItemAnexo[j],cCpoPeso,.F.)[2])
               nLiqTot += nPesoLin
            EndIf
            
            If !Empty(nUssLin := GetField(aItemAnexo[j],cCpoVlUss,.F.)[2])
               nUssTot += nUssLin
            EndIf

            If !Empty(nQtdNcm := GetField(aItemAnexo[j],cCpoQtdNcm,.F.)[2])
               SomaArray(aQtdTot,GetField(aItemAnexo[j],cCpoUmNcm)[2],nQtdNcm)
            EndIf

            If !Empty(nVlMoe := GetField(aItemAnexo[j],cCpoVlMoe,.F.)[2])
               SomaArray(aMoeTot,GetField(aItemAnexo[j],cCpoMoeda)[2],nVlMoe)
            EndIf
         Next j
      EndIf
      
      aAdd(aAnexos,{{cCpoQtdNcm ,aQtdTot},;
                    {cCpoVlMoe  ,aMoeTot},;
                    {cCpoPeso   ,nLiqTot},;
                    {cCpoVlUss  ,nUssTot},;
                    {"ITENS"    ,aClone(aItemAnexo)},;
                    {"QTD_ITENS",nLinha-1}})

      aItemAnexo := {}

      nLinha  := 1
      nPosIni := i
      If i > Len(aItens)
         EXIT
      EndIf
   EndIf
   
   (cAlias)->(aAdd(aItemAnexo,{GetField(aItens[i][2],cCpoNcm,.F.)  ,GetField(aItens[i][2],cCpoPeso,.F.),GetField(aItens[i][2],cCpoQtdNcm,.F.),;
                               GetField(aItens[i][2],cCpoUmNcm,.F.),{"DESCR",aItens[i][1][1]},;
                               GetField(aItens[i][2],cCpoVlMoe,.F.),GetField(aItens[i][2],cCpoMoeda,.F.),;
                               GetField(aItens[i][2],cCpoVlUss,.F.)}))

   nLinha++
   For j := 2 To Len(aItens[i][1])
      aAdd(aItemAnexo,{{"DESCR",aItens[i][1][j]}})
      nLinha++
   Next j

Next i

End Sequence

Return aAnexos

Static Function TotalAnexos(aAnexos)
Local i, j, k, nPos, nPos2
Local aRet := {}

For i := 1 To Len(aAnexos)
   For j := 1 To Len(aAnexos[i])
      If aAnexos[i][j][1] <> "ITENS"
      
         nPos := aScan(aRet,{|X| X[1] == aAnexos[i][j][1]})
         
         If ValType(aAnexos[i][j][2]) <> "A"
            If nPos == 0
               aAdd(aRet,{aAnexos[i][j][1],0})
               nPos := Len(aRet)
            EndIf
            aRet[nPos][2] += aAnexos[i][j][2]
         Else
            If nPos == 0
               aAdd(aRet,{aAnexos[i][j][1],{}})
               nPos := Len(aRet)
            EndIf
            For k := 1 To Len(aAnexos[i][j][2])
               If (nPos2 := aScan(aRet[nPos][2],{|X| X[1] == aAnexos[i][j][2][k][1]})) == 0
                  aAdd(aRet[nPos][2],{aAnexos[i][j][2][k][1],0})
                  nPos2 := Len(aRet[nPos][2])
               EndIf
               aRet[nPos][2][nPos2][2] += aAnexos[i][j][2][k][2]
            Next k
         EndIf
      EndIf
   Next j
Next i

Return aRet

Static Function GetItemArray(cAlias,cCpoItem)
Local aItens := {}

Do While !(cAlias)->(EoF())
   If !Empty(cCpoItem)
      aAdd(aItens,{GetDescr((cAlias)->(FieldGet(FieldPos(cCpoItem))),/*35*/60,cAlias/*AOM - 14/06/2012*/),(cAlias)->(GetRegArray())})  // GFP - 27/03/2012 - Quantidade de caracteres por linha
   Else
      aAdd(aItens,{{""},(cAlias)->(GetRegArray())})   
   EndIf
   (cAlias)->(dbSkip())
EndDo

Return aItens

Static Function EasyHttpSubmit(cMethod,cUrl,cParams,nTimeOut,aHeaderParams)
Local cRespRet
Local cHeadRet
Local cDescStatu := ''
Begin Sequence
   
   If cMethod == "GET"

      MsAguarde({|| cRespRet := HttpGet(cUrl,cParams,nTimeOut,aHeaderParams,@cHeadRet)},"Aguarde...")

   ElseIf cMethod == "POST"

      MsAguarde({|| cRespRet := HttpPost(cUrl,"",cParams,nTimeOut,aHeaderParams,@cHeadRet)},"Aguarde...")

   Else
      BREAK
   EndIf
   
   If HTTPGetStatus() <> 200//200 = OK
      //SetProxy("srv-web",8080,"usuario","senha") - Cuidado com a configuração de proxy do Protheus.
      MsgStop("Erro na Requesição HTTP: "+Alltrim(Str(HTTPGetStatus(@cDescStatu)))+" - "+cDescStatu )
      BREAK
   EndIf

End Sequence

Return cRespRet

Static Function EasyClientShell(cSrvFile,cDirClient)
Local lRet := .F.
Local nMilisegundos := 2000
Default cDirClient := GetTempPath()

Begin Sequence

   If !File(cSrvFile)
      BREAK
   EndIf
     
   If File(cDirClient+cSrvFile)
      If FErase(cDirClient+cSrvFile) == -1 
         MsgInfo(StrTran("Erro ao excluir o arquivo '###' do diretório temporário. Não será possível prosseguir.", "###", cSrvFile), "Atenção")
         Break
      EndIf
   EndIf

   //Copia do Servidor para o diretório temporário
   If !CpyS2T(cSrvFile, cDirClient, .T.) .AND. !CpyS2T(GetSrvProfString("STARTPATH","")+cSrvFile, cDirClient, .T.)
      MsgInfo(StrTran("Erro ao copiar o arquivo '###' para o diretório temporário. Não será possível prosseguir.", "###", cSrvFile), "Atenção")
      Break
   EndIf 
   
   Sleep(nMilisegundos)
   //Executa o browser para visualizar o XML
   If ShellExecute("open", cDirClient + RetFileName(cSrvFile) + SubStr(cSrvFile,Rat(".",cSrvfile)), "", "", 1 ) <= 32
      MsgInfo("Erro na abertura do arquivo.", "Aviso")
   Else
      lRet := .T.
   EndIf
   
End Sequence

Return lRet                                              

Function RetEspecificacao()
Local cTag := ""

Begin Sequence

   If ValType("cEspecificacao") == Nil
      Break
   EndIf

   Do Case
      Case AllTrim(Upper(cEspecificacao)) == AllTrim("'PORIMPORTAR'")
         cTag :="						<td width=" + Chr(34) + "26" + Chr(34) + " class=" + Chr(34) + "resultadoInput" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + ">"+CHR(13)+CHR(10)+; 
                "									<img src=" + Chr(34) + "/docs/frm/img/boxPreenchido.gif" + Chr(34) + " width=" + Chr(34) + "18" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + "></td>"+CHR(13)+CHR(10)+; 
                "				      			<td class=" + Chr(34) + "itemMiddle" + Chr(34) + ">Por importar e/ou por adquirir no mercado interno</td>"+CHR(13)+CHR(10)+; 
                "				         		<td width=" + Chr(34) + "26" + Chr(34) + " valign=" + Chr(34) + "bottom" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + ">"+CHR(13)+CHR(10)+; 
                "								"+CHR(13)+CHR(10)+; 
                "				         			<img src=" + Chr(34) + "/docs/frm/img/boxPreencheSolido.gif" + Chr(34) + " width=" + Chr(34) + "18" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + "></td>"+CHR(13)+CHR(10)+; 
                "				         	 	<td class=" + Chr(34) + "itemMiddle" + Chr(34) + ">Exportadas</td>"+CHR(13)+CHR(10)+; 
                "				         		<td width=" + Chr(34) + "26" + Chr(34) + " valign=" + Chr(34) + "bottom" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + ">"+CHR(13)+CHR(10)+; 
                "								"+CHR(13)+CHR(10)+; 
                "				         			<img src=" + Chr(34) + "/docs/frm/img/boxPreencheSolido.gif" + Chr(34) + " width=" + Chr(34) + "18" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + "></td>"+CHR(13)+CHR(10)+; 
                "				         	 	<td class=" + Chr(34) + "itemMiddle" + Chr(34) + ">Fornecidas</td>"+CHR(13)+CHR(10)
      Case AllTrim(Upper(cEspecificacao)) == AllTrim("'EXPORTADAS'")
         cTag :="						<td width=" + Chr(34) + "26" + Chr(34) + " class=" + Chr(34) + "resultadoInput" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + ">"+CHR(13)+CHR(10) +; 
                "									<img src=" + Chr(34) +"/docs/frm/img/boxPreencheSolido.gif" + Chr(34) + " width=" + Chr(34) + "18" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + "></td>"+CHR(13)+CHR(10)+; 
                "				      			<td class=" + Chr(34) + "itemMiddle" + Chr(34) + ">Por importar e/ou por adquirir no mercado interno</td>"+CHR(13)+CHR(10)+; 
                "				         		<td width=" + Chr(34) + "26" + Chr(34) + " valign=" + Chr(34) + "bottom" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + ">"+CHR(13)+CHR(10) +; 
                "								"+CHR(13)+CHR(10)+; 
                "				         			<img src=" + Chr(34) + "/docs/frm/img/boxPreenchido.gif" + Chr(34) + " width=" + Chr(34) + "18" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + "></td>"+CHR(13)+CHR(10)+; 
                "				         	 	<td class=" + Chr(34) + "itemMiddle" + Chr(34) + ">Exportadas</td>"+CHR(13)+CHR(10)+; 
                "				         		<td width=" + Chr(34) + "26" + Chr(34) + " valign=" + Chr(34) + "bottom" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + ">"+CHR(13)+CHR(10) +; 
                "								"+CHR(13)+CHR(10)+; 
                "				         			<img src=" + Chr(34) + "/docs/frm/img/boxPreencheSolido.gif" + Chr(34) + " width=" + Chr(34) + "18" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + "></td>"+CHR(13)+CHR(10)+; 
                "				         	 	<td class=" + Chr(34) + "itemMiddle" + Chr(34) + ">Fornecidas</td>"+CHR(13)+CHR(10) 

    OtherWise
         cTag :="						<td width=" + Chr(34) + "26" + Chr(34) + " class=" + Chr(34) + "resultadoInput" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + ">"+CHR(13)+CHR(10) +; 
                "									<img src=" + Chr(34) + "/docs/frm/img/boxPreencheSolido.gif" + Chr(34) + " width=" + Chr(34) + "18" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + "></td>"+CHR(13)+CHR(10)+; 
                "				      			<td class=" + Chr(34) + "itemMiddle" + Chr(34) + ">Por importar e/ou por adquirir no mercado interno</td>"+CHR(13)+CHR(10)+; 
                "				         		<td width=" + Chr(34) + "26" + Chr(34) + " valign=" + Chr(34) + "bottom" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + ">"+CHR(13)+CHR(10) +; 
                "								"+CHR(13)+CHR(10)+; 
                "				         			<img src=" + Chr(34) + "/docs/frm/img/boxPreencheSolido.gif" + Chr(34) + " width=" + Chr(34) + "18" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + "></td>"+CHR(13)+CHR(10)+; 
                "				         	 	<td class=" + Chr(34) + "itemMiddle" + Chr(34) + ">Exportadas</td>"+CHR(13)+CHR(10)+; 
                "				         		<td width=" + Chr(34) + "26" + Chr(34) + " valign=" + Chr(34) + "bottom" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + ">"+CHR(13)+CHR(10) +; 
                "								"+CHR(13)+CHR(10)+; 
                "				         			<img src=" + Chr(34) + "/docs/frm/img/boxPreencheSolido.gif" + Chr(34) + " width=" + Chr(34) + "18" + Chr(34) + " height=" + Chr(34) + "18" + Chr(34) + "></td>"+CHR(13)+CHR(10)+; 
                "				         	 	<td class=" + Chr(34) + "itemMiddle" + Chr(34) + ">Fornecidas</td>"+CHR(13)+CHR(10)
     
   End Case				         	 	

End Sequence

Return cTag

/*======================================================================================
Função    : PA151Carta()
Objetivo  : Ajustar dados para visualização/impressão da Carta ao Banco do Brasil.
Autor     : Guilherme Fernandes Pilan - GFP
Data/Hora : 19/10/2011
Obs       : - 
======================================================================================*/
Static Function PA151Carta()

Local mCartaSup := "", mCartaInf := ""
Local cPagina := ""

// Montagem da Parte Inferior da Carta
mCartaInf += CHR(13)+CHR(10)
mCartaInf += STR0094 + "                              de " + CHR(13)+CHR(10) //STR0094 - "Vinculado ao Ato Concessório No. "
mCartaInf += STR0095 + CHR(13)+CHR(10) //STR0095 - "Praça de Emissão: "
mCartaInf += STR0096 + CHR(13)+CHR(10)+CHR(13)+CHR(10)+CHR(13)+CHR(10)+CHR(13)+CHR(10)+CHR(13)+CHR(10) //STR0096 - "Data: "
mCartaInf += "                                                                                                    "
mCartaInf += STR0097 //STR0097 - "Assinatura e Carimbo"
mCartaInf += CHR(13)+CHR(10)


mCartaSup := StrTran(mCartaPag , CHR(13)+CHR(10) , '<br>'  )   // Substituição de ENTER por <br> para visualização em HTML.
mCartaSup := StrTran(mCartaSup , " "               , '&nbsp;')  // Substituição de ESPAÇOS por '&nbsp; ' para visualização em HTML.

mCartaInf := StrTran(mCartaInf , CHR(13)+CHR(10) , '<br>'  )   // Substituição de ENTER por <br> para visualização em HTML.
mCartaInf := StrTran(mCartaInf , " "               , '&nbsp;')  // Substituição de ESPAÇOS por '&nbsp; ' para visualização em HTML.

cPagina += "<table width= '666' cellpadding='2' cellspacing='0' border=2 bordercolor=#000000 align='center'>"
cPagina += "   <tr>"
cPagina += "      <td>"
cPagina +=            mCartaSup
cPagina += "      </td>"
cPagina += "   </tr>"
cPagina += "</table>"

cPagina += "<br>"

cPagina += "<table width= '666' cellpadding='2' cellspacing='0' border=2 bordercolor=#000000 align='center'>"
cPagina += "   <tr>"
cPagina += "      <td>"
cPagina +=            STR0098 //STR0098 - "Para preenchimento pela Dependência do Banco do Brasil S.A."
cPagina += "      </td>"
cPagina += "   </tr>"
cPagina += "</table>"

cPagina += "<br>"

cPagina += "<table width= '666' cellpadding='2' cellspacing='0' border=2 bordercolor=#000000 align='center'>"
cPagina += "   <tr>"
cPagina += "      <td>"
cPagina +=            mCartaInf
cPagina += "      </td>"
cPagina += "   </tr>"
cPagina += "</table>"

Return cPagina
/*
Funcao      : FormatPict
Parametros  : cCampo   : Campo do Dicionario em qual a picture sera espelhada
Retorno     : nDecimal : indica a quantidade de decimais na picture
Objetivos   : Montar uma picture com os decimais informado.
Autor       : Allan Oliveira Monteiro
Data/Hora   : 27/06/2012 
*/
Function FormatPict(cCampo,nDecimal) 
Local cPicture := "" , cFormPic := ""
Local i, nVirg := 0

SX3->(DbSetOrder(2))//X3_CAMPO

Begin Sequence

    If Empty(cCampo) .Or. Empty(nDecimal) .Or. !SX3->(DbSeek(cCampo))
       Break
    EndIf
    
    If  "@" $ AVSX3(cCampo,6)//Picture 
       cFormPic += "@E"    
    EndIf
    
    For i := 1 to AVSX3(cCampo,3) //Tamanho
       If i == nDecimal + 1
          cPicture :=  "." + cPicture
          Loop
       Elseif nVirg == 3 
          cPicture :=  "," + cPicture
          nVirg := 0 
       EndIf
       cPicture := "9" + cPicture
       If At(".",cPicture ) > 0       
          nVirg++
       EndIf    
    Next i
    
    cPicture := cFormPic + " " + cPicture

End Sequence

Return cPicture
