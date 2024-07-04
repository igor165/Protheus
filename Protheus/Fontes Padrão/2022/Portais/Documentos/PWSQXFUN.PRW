#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQUsrCfg   บAutor  ณTelso Carneiro      บ Data ณ  22/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca usuario do Sistema atraves do User do Portal     	  บฑฑ
ฑฑบ          ณ Amarracao no Cadastro de user do Portal.               	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Portal QDO                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QUsrCfg( cUsrWS )

Local aArUsr	:= GetArea()
Local aInfo		:= {}
Local cQUsuario := ""
Local cUsrPrt	:= ""
Local aArray 	:= {.F.,"","","","",""}
Local cEmail	:= ""

Default cUsrWS	:= ""

dbSelectArea("AI3")
dbSetOrder(1)
If DBSeek(xFilial("AI3")+cUsrWS)
	If !Empty(AI3->AI3_USRSIS)
		cUsrPrt:=AI3->AI3_USRSIS
		PswOrder(1)
		If PswSeek( cUsrPrt )
			aInfo := PswRet()
			cQUsuario := aInfo[1][2]  //LOGIN
			If !Empty(aInfo[1][14])
				cEmail := AllTrim(aInfo[1][14]) //Email
			Else
				cEmail := "SIGAQDO"
			EndIf
		EndIf
	EndIf	
EndIf

DbSelectArea("QAA")
DbSetOrder(6)

If QAA->(DbSeek(AllTRIM(UPPER(cQUsuario))))
	aArray[1]:= .T.
	aArray[2]:= QAA->QAA_FILIAL
	aArray[3]:= QAA->QAA_MAT
	aArray[4]:= QAA->QAA_CC
	If !Empty(AllTrim(QAA->QAA_EMAIL))
		aArray[5]:= QAA->QAA_EMAIL
	Else
		aArray[5]:= cEmail
	Endif
	aArray[6]:= QAA->QAA_NOME
EndIf

RestArea( aArUsr )
Return (aArray)
                                     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQDOXWS    บAutor  ณTelso Carneiro      บ Data ณ  03/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao da tabela em html dos documentos                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function GenTabBro(aHeader,aCols)
Local cBroHtml	
Local nI		:= 0
Local lCrtlCor	:= .T. 
Local lQhdComp	:= Empty(aCols[1,1])

cBroHtml:='<table align="center"  width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#E5E5E5"    >'

cBroHtml+='<tr>'
cBroHtml+='<td bgcolor="#C7C7C7" bordercolor="#000000" >&nbsp;</td>'       		

For nI:=1 to Len(aHeader)
	If AllTrim(aHeader[nI,2])=="QDH_RV"
		cBroHtml:=Subs(cBroHtml,1,Len(cBroHtml)-5)+" - "+AllTrim(aHeader[nI,1])+'</td>' 
	Else
		cBroHtml+='<td bgcolor="#C7C7C7" bordercolor="#000000"  >&nbsp;'+AllTrim(aHeader[nI,1])+'</td>'       		
	Endif
Next            
cBroHtml+='</tr>'

For nI:=1 to Len(aCols)
	cBroHtml+='<tr>'
    IF aCols[nI,6]=="B" //Baixado
    	cBroHtml+='<td '+IF(lCrtlCor,'bgcolor="#EAFFEA"','')+' > <img src="./images/bt_verde.gif" border="0" > </td>'
    Else                //Pendente
		cBroHtml+='<td '+IF(lCrtlCor,'bgcolor="#EAFFEA"','')+' > <img src="./images/bt_vermelho.gif" border="0"> </td>'		
	Endif
	
	IF !lQhdComp
 		cBroHtml+='<td '+IF(lCrtlCor,'bgcolor="#EAFFEA"','')+' >'+aCols[nI,1]+'</td>'
	Endif 
	cBroHtml+='<td '+IF(lCrtlCor,'bgcolor="#EAFFEA"','')+' >'+AllTrim(aCols[nI,2])+'</td>'
	cBroHtml+='<td '+IF(lCrtlCor,'bgcolor="#EAFFEA"','')+' ><a href="javascript:VisBaixa('+"'"+AllTrim(aCols[nI,6])+"','"+aCols[nI,1]+aCols[nI,3]+aCols[nI,4]+"','"+Alltrim(aCols[nI,8])+"'"+');" >'+AllTrim(aCols[nI,3])+" - "+AllTrim(aCols[nI,4])+'</a></td>'
	cBroHtml+='<td '+IF(lCrtlCor,'bgcolor="#EAFFEA"','')+' >'+AllTrim(aCols[nI,5])+'</td>'
	cBroHtml+='</tr>'
	lCrtlCor:=IF(lCrtlCor,.F.,.T.)
Next    		
cBroHtml+='</table>'

Return(cBroHtml)


Function Teste()
ConOut("tentrei no teste")
Return