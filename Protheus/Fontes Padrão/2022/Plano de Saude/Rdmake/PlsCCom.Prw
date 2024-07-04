
User Function PlsCCom

// Localizo a primeira faixa do sub-contrato

BTN->(MsSeek(	xFilial("BTN") + ParamIXB[2] + ParamIXB[3] + ParamIXB[4] + ParamIXB[5]+;
				ParamIXB[6] + ParamIXB[7]))
				

Return BTN->BTN_VALFAI
