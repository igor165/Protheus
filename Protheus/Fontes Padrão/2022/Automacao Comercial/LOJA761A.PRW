#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA761A; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCValidMn       �Autor  �Vendas Clientes     � Data �  15/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em manipular um arquivo.                   	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCValidMn
	
	Data cProduto								
	Data cGrupo								    
	Data oResIdsMn	
	Data cTipoRet	

	Method New(cProduto, cGrupo)  	//Metodo construtor
	Method TemProdMbs()           	//Altera motivo 
	Method TemGrpMbs()				
	Method TemProdMek()
	Method TemGrpMek()
	Method GetRetorno()
	Method AddCabPad()	
	Method ValidaCabMbs()
 	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New		�Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Contrutor                                                   ���
�������������������������������������������������������������������������͹��
���Parametros�cExp1 - Codigo do Produto									  ���
���          �cExp2 - Codigo do Grp produto		  						  ��� 
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(cProduto, cGrupo)  Class LJCValidMn

Default cProduto  	:= ""
Default cGrupo   	:= ""

Self:cProduto 	:= cProduto
Self:cGrupo 	:= cGrupo
Self:oResIdsMn 	:= Nil
Self:oResIdsMn 	:= LJCResIdsMn():New() 

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetRetorno�Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata retorno da negociacao (Iten)                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetRetorno() Class LJCValidMn
Return Self:oResIdsMn

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TemProdMbs�Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata retorno da negociacao (Iten)                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TemProdMbs() Class LJCValidMn

DbSelectArea("MBS")
MBS->( DbSetOrder(2) )	//MBS_FILIAL + MBS_PRODUT
	
If !Empty(Self:cProduto) .AND. MBS->( DbSeek(xFilial("MBS") + Self:cProduto) )
	While !MBS->( Eof() ) .AND. MBS->MBS_FILIAL + AllTrim(MBS->MBS_PRODUT) == xFilial("MBS") + AllTrim(Self:cProduto)
		Self:cTipoRet 	:= "MBS"		
		Self:ValidaCabMbs()	
	 	MBS->( DbSkip() )
	End
EndIf

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TemGrpMbs �Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata retorno da negociacao (Iten)                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TemGrpMbs() Class LJCValidMn

DbSelectArea("MBS")
MBS->( DbSetOrder(3) )	//MBS_FILIAL + MBS_GRPROD

If !Empty(Self:cGrupo) .AND. MBS->( DbSeek(xFilial("MBS") + Self:cGrupo) )
	While !MBS->( Eof() ) .AND. MBS->MBS_FILIAL+ AllTrim(MBS->MBS_GRPROD)	== xFilial("MBS")+AllTrim(Self:cGrupo)
		Self:cTipoRet := "MBS"		
		Self:ValidaCabMbs()	
	 	MBS->( DbSkip() )
	 End
EndIf

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TemProdMEK�Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata retorno da negociacao (Iten)                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TemProdMEK() Class LJCValidMn

DbSelectArea("MEK")
MEK->( DbSetOrder(3) )	//MEK_FILIAL + MEK_PRODUT

If !Empty(Self:cProduto) .AND. MEK->( DbSeek(xFilial("MEK") + Self:cProduto) )
	While !Eof() .AND. MEK->MEK_FILIAL+ AllTrim(MEK->MEK_PRODUT)	== xFilial("MEK") + AllTrim(Self:cProduto)
		Self:cTipoRet 	:= "MEK"		
 		Self:ValidaCabMbs()	   	
    	DbSkip()
    End
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TemGrpMEK �Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata retorno da negociacao (Iten)                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TemGrpMEK() Class LJCValidMn

DbSelectArea("MEK")
MEK->( DbSetOrder(4) )

If !Empty(Self:cGrupo) .AND. MEK->( DbSeek(xFilial("MEK") + Self:cGrupo) )
	While MEK->( !Eof() ) .AND. MEK->MEK_FILIAL+ AllTrim(MEK->MEK_GRPROD) == xFilial("MEK")+ AllTrim(Self:cGrupo)
		Self:cTipoRet := "MEK"
		Self:ValidaCabMbs()
		MEK->( DbSkip() )
 	End
EndIf

Return()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ValidaCab �Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata retorno da negociacao (Iten)                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ValidaCabMbs() Class LJCValidMn

Local cEstCob	:= SM0->M0_ESTCOB	// Estado de cobran�a filial
Local oLjIdMn	:= Nil				// Dados da Multi Negocia��o	
Local lRet		:= .T.				// Valor de retorno
Local aBkMek	:= MEK->(GetArea())	// backup
Local lLJ7090	:= ExistBlock("LJ7090")	// Indica se existe o PE LJ7090

//posiciona no cabecalho da Multi Negociacao
If Self:cTipoRet == "MEK"
	DbSelectArea("MBS")
	MBS->( DbSetOrder(1) )	//MBS_FILIAL + MBS_CODIGO
	MBS->( DbSeek(xFilial("MBS") + MEK->MEK_CODIGO) )
EndIf

If lRet
	If !Empty(MBS->MBS_EST) .AND. MBS->MBS_EST <> cEstCob
		lRet := .F.
	EndIf
	
	If (!Empty(MBS->MBS_DATAIN).AND. dDataBase < MBS->MBS_DATAIN) .OR. (!Empty(MBS->MBS_DATAFI) .AND. dDataBase > MBS->MBS_DATAFI )
		lRet := .F.
	EndIf

	If MBS->MBS_ATIVAR == "2"
		lRet := .F.
	EndIf

	If !Empty(MBS->MBS_GRPFIL) //Tratamento para Grupos de Filiais
		SAU->(DbSetOrder(1))
		lRet := SAU->(DbSeek(xFilial("SAU")+MBS->MBS_GRPFIL+FWCodFil()))
	EndIf

	If lRet .And. lLJ7090
		lRet := ExecBlock("LJ7090",.F.,.F.,{MBS->MBS_CODIGO})
	EndIf
EndIf

If lRet .AND. !Self:oResIdsMn:Contains(MBS->MBS_CODIGO)
	oLjIdMn := LJCIdMn():New(MBS->MBS_CODIGO, MBS->MBS_DESCRI)
    Self:oResIdsMn:Add(MBS->MBS_CODIGO, oLjIdMn)
EndIf

RestArea(aBkMek)

Return()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ValidaCab �Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata retorno da negociacao (Iten)                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AddCabPad() Class LJCValidMn

If !Self:oResIdsMn:Contains(MBS->MBS_CODIGO)
	oLjIdMn := LJCIdMn():New(MBS->MBS_CODIGO, MBS->MBS_DESCRI)
    Self:oResIdsMn:Add(MBS->MBS_CODIGO, oLjIdMn)
EndIf

Return()

