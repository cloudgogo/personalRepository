/*
Navicat MySQL Data Transfer

Source Server         : aliyun
Source Server Version : 50636
Source Host           : 59.110.139.63:3306
Source Database       : office_oa

Target Server Type    : MYSQL
Target Server Version : 50636
File Encoding         : 65001

Date: 2017-05-28 00:02:12
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(30) NOT NULL DEFAULT '' COMMENT '用户名',
  `employee_name` varchar(10) NOT NULL DEFAULT '' COMMENT '员工姓名',
  `phone_number` varchar(11) NOT NULL DEFAULT '' COMMENT '联系电话',
  `password` varchar(255) NOT NULL DEFAULT '' COMMENT '密码(MD5转码)',
  `add_time` varchar(50) NOT NULL DEFAULT '' COMMENT '账号添加时间',
  `author_user` varchar(50) NOT NULL DEFAULT '' COMMENT '账号添加人',
  `last_login_time` varchar(50) NOT NULL DEFAULT '' COMMENT '最后登录时间',
  `ip` varchar(50) NOT NULL DEFAULT '' COMMENT '用户登陆IP地址',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '用户状态 1为真 0为假',
  `administortar` tinyint(1) NOT NULL DEFAULT '0' COMMENT '超级管理员 1为真 0为假',
  PRIMARY KEY (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 COMMENT='用户表';

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO `admin` VALUES ('1', 'admin', '超级管理员', '15103415760', 'e10adc3949ba59abbe56e057f20f883e', '1486782340', '超级管理员', '1493977943', '116.243.185.221', '1', '1');
INSERT INTO `admin` VALUES ('2', '001', '贾磊', '15103415760', 'e10adc3949ba59abbe56e057f20f883e', '1486975398', '超级管理员', '1487746973', '192.168.1.35', '1', '1');
INSERT INTO `admin` VALUES ('8', '003', '程静昀', '12345677654', 'e10adc3949ba59abbe56e057f20f883e', '1486974553', '超级管理员', '1489021598', '192.168.1.45', '1', '0');
INSERT INTO `admin` VALUES ('9', '004', '武海珠', '18035199880', 'e10adc3949ba59abbe56e057f20f883e', '1486973277', '超级管理员', '1489052185', '192.168.1.45', '1', '0');
INSERT INTO `admin` VALUES ('10', '006', '贺淑婷', '18035190000', 'e10adc3949ba59abbe56e057f20f883e', '1486974784', '超级管理员', '1486975598', '192.168.1.30', '1', '0');
INSERT INTO `admin` VALUES ('17', '009', '刘雪燕', '123456789', 'e10adc3949ba59abbe56e057f20f883e', '1487744027', '超级管理员', '1487901372', '192.168.1.136', '1', '0');

-- ----------------------------
-- Table structure for bank_info
-- ----------------------------
DROP TABLE IF EXISTS `bank_info`;
CREATE TABLE `bank_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bank_gys_name` varchar(255) NOT NULL DEFAULT '' COMMENT '关联供应商名称',
  `bank_gys_bianhao` varchar(255) NOT NULL DEFAULT '' COMMENT '关联供应商编号',
  `bank_account` varchar(255) NOT NULL DEFAULT '' COMMENT '开户银行',
  `account_name` varchar(255) NOT NULL DEFAULT '' COMMENT '开户名称',
  `bank_code` varchar(255) NOT NULL DEFAULT '' COMMENT '银行行号',
  `bank_card` varchar(255) NOT NULL DEFAULT '' COMMENT '银行卡号',
  `duty_paragraph` varchar(255) NOT NULL DEFAULT '' COMMENT '税号',
  `bank_address` varchar(255) NOT NULL DEFAULT '' COMMENT '地址',
  `account_tel` varchar(255) NOT NULL DEFAULT '' COMMENT '电话',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='银行信息';

-- ----------------------------
-- Records of bank_info
-- ----------------------------
INSERT INTO `bank_info` VALUES ('1', '测试修改代码是', 'GYS_170225163102', '测试修改；代码', '测试修改；代码', '测试修改；代码', '测试修改；代码', '测试修改；代码', '测试修改；代码', '测试修改；代码');
INSERT INTO `bank_info` VALUES ('2', '麻辣拌', 'GYS_170221103947', '测试重庆麻辣拌', '测试重庆麻辣拌', '测试重庆麻辣拌', '测试重庆麻辣拌', '测试重庆麻辣拌', '测试重庆麻辣拌', '测试重庆麻辣拌');
INSERT INTO `bank_info` VALUES ('3', '大盘鸡', 'GYS_170218142812', '', '', '', '', '', '', '');

-- ----------------------------
-- Table structure for card_info
-- ----------------------------
DROP TABLE IF EXISTS `card_info`;
CREATE TABLE `card_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_number` varchar(255) NOT NULL DEFAULT '' COMMENT '客户编号',
  `card_name` varchar(40) NOT NULL DEFAULT '' COMMENT '姓名',
  `card_number` varchar(20) NOT NULL DEFAULT '' COMMENT '身份证号',
  `images` varchar(255) NOT NULL DEFAULT '' COMMENT '正面',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='身份证信息';

-- ----------------------------
-- Records of card_info
-- ----------------------------
INSERT INTO `card_info` VALUES ('1', 'KH_170223170911', '马薇薇', '101505041651089401', '/office/Uploads/2017-03-06/KH_170223170911_1178782657.JPG');
INSERT INTO `card_info` VALUES ('2', 'KH_170308151124', '阿速达', '的撒', '/office/Uploads/2017-03-08/KH_170308151124_841641706.png');

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `catid` int(11) NOT NULL AUTO_INCREMENT,
  `pid` int(10) NOT NULL DEFAULT '0',
  `catname` varchar(20) NOT NULL DEFAULT '' COMMENT '列表名',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '1为正常0为不正常',
  `url` varchar(100) NOT NULL DEFAULT '' COMMENT 'a链接地址',
  `time` int(10) NOT NULL DEFAULT '0' COMMENT '添加时间',
  `icon_name` varchar(255) NOT NULL DEFAULT '' COMMENT '图标名称',
  `grade` varchar(10) NOT NULL DEFAULT '' COMMENT '菜单等级',
  PRIMARY KEY (`catid`)
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='栏目表';

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES ('1', '0', '一级菜单', '1', '一级菜单', '0', '一级菜单', '');
INSERT INTO `category` VALUES ('2', '0', '二级菜单', '1', '二级菜单', '0', '二级菜单', '');
INSERT INTO `category` VALUES ('3', '2', '二级菜单', '1', '二级菜单', '0', '二级菜单', '');
INSERT INTO `category` VALUES ('4', '0', '三级菜单', '1', '三级菜单', '0', '三级菜单', '');
INSERT INTO `category` VALUES ('5', '4', '三级菜单', '1', '三级菜单', '0', '三级菜单', '');
INSERT INTO `category` VALUES ('6', '5', '三级菜单', '1', '三级菜单', '0', '三级菜单', '');
INSERT INTO `category` VALUES ('7', '0', '四级菜单', '1', '四级菜单', '0', '四级菜单', '');
INSERT INTO `category` VALUES ('8', '7', '四级菜单', '1', '四级菜单', '0', '四级菜单', '');
INSERT INTO `category` VALUES ('9', '8', '四级菜单', '1', '四级菜单', '0', '四级菜单', '');
INSERT INTO `category` VALUES ('10', '9', '四级菜单', '1', '四级菜单', '0', '四级菜单', '');
INSERT INTO `category` VALUES ('11', '2', '二级平级', '1', '二级平级', '0', '二级平级', '');
INSERT INTO `category` VALUES ('12', '4', '三二平级', '1', '三二平级', '0', '三二平级', '');
INSERT INTO `category` VALUES ('13', '7', '4-1', '1', '', '0', '', '');
INSERT INTO `category` VALUES ('14', '8', '4-2', '1', '', '0', '', '');
INSERT INTO `category` VALUES ('15', '9', '4-3', '1', '', '0', '', '');

-- ----------------------------
-- Table structure for classification1
-- ----------------------------
DROP TABLE IF EXISTS `classification1`;
CREATE TABLE `classification1` (
  `cid` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL DEFAULT '' COMMENT '一级分类名称',
  `zz` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0不需要 1营业执照 2身份证明',
  PRIMARY KEY (`cid`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='分类一级';

-- ----------------------------
-- Records of classification1
-- ----------------------------
INSERT INTO `classification1` VALUES ('1', '二级分销', '1');
INSERT INTO `classification1` VALUES ('2', '三级分销商', '2');
INSERT INTO `classification1` VALUES ('3', '散户', '0');

-- ----------------------------
-- Table structure for classification2
-- ----------------------------
DROP TABLE IF EXISTS `classification2`;
CREATE TABLE `classification2` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` varchar(255) NOT NULL DEFAULT '' COMMENT '2级对应1级CID',
  `title` varchar(100) NOT NULL DEFAULT '' COMMENT '2级',
  `price` varchar(255) NOT NULL DEFAULT '' COMMENT '价格',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='分类2级';

-- ----------------------------
-- Records of classification2
-- ----------------------------
INSERT INTO `classification2` VALUES ('1', '1', '市级', '');
INSERT INTO `classification2` VALUES ('2', '1', '县级', '');
INSERT INTO `classification2` VALUES ('3', '1', '区级', '');
INSERT INTO `classification2` VALUES ('4', '3', '散户', '');
INSERT INTO `classification2` VALUES ('5', '2', '三级分销商', '');

-- ----------------------------
-- Table structure for customer
-- ----------------------------
DROP TABLE IF EXISTS `customer`;
CREATE TABLE `customer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_name` varchar(255) NOT NULL DEFAULT '' COMMENT '客户单位名称',
  `customer_pym` varchar(255) NOT NULL DEFAULT '' COMMENT '拼音码',
  `customer_number` varchar(255) NOT NULL DEFAULT '' COMMENT '客户编号',
  `customer_classification` varchar(10) NOT NULL DEFAULT '' COMMENT '客户分类',
  `follow_level` varchar(10) NOT NULL DEFAULT '' COMMENT '分类2级',
  `customer_rea` varchar(255) NOT NULL DEFAULT '' COMMENT '客户区域',
  `customer_sheng` varchar(15) NOT NULL DEFAULT '' COMMENT '省',
  `customer_shi` varchar(15) NOT NULL DEFAULT '' COMMENT '市',
  `customer_qu` varchar(15) NOT NULL DEFAULT '' COMMENT '区',
  `customer_industry` varchar(255) NOT NULL DEFAULT '' COMMENT '客户行业',
  `customer_from` varchar(255) NOT NULL DEFAULT '' COMMENT '客户来源',
  `credit_rating` varchar(255) NOT NULL DEFAULT '' COMMENT '信用等级',
  `customer_address` varchar(255) NOT NULL DEFAULT '' COMMENT '客户地址',
  `customer_username` varchar(255) NOT NULL DEFAULT '' COMMENT '客户联系人姓名',
  `customer_sex` tinyint(1) NOT NULL DEFAULT '0' COMMENT '客户性别',
  `customer_age` varchar(255) NOT NULL DEFAULT '0' COMMENT '客户年龄',
  `job` varchar(255) NOT NULL DEFAULT '' COMMENT '职务',
  `phone_number` varchar(50) NOT NULL DEFAULT '' COMMENT '手机号',
  `tel_number` varchar(50) NOT NULL DEFAULT '' COMMENT '办公电话',
  `email` varchar(100) NOT NULL DEFAULT '' COMMENT '邮箱',
  `qq` varchar(20) NOT NULL DEFAULT '' COMMENT 'QQ',
  `weichat` varchar(255) NOT NULL DEFAULT '' COMMENT '微信',
  `add_time` varchar(255) NOT NULL DEFAULT '' COMMENT '客户添加时间',
  `author_user` varchar(255) NOT NULL DEFAULT '' COMMENT '添加人',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0 为审核通过 1为审核中 2为审核未通过',
  `examine_author` varchar(30) NOT NULL DEFAULT '' COMMENT '审核人',
  `examine` text NOT NULL COMMENT '审核意见',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='客户表';

-- ----------------------------
-- Records of customer
-- ----------------------------
INSERT INTO `customer` VALUES ('3', '测试需要身份证', 'CeShiXuYaoShenFenZheng', 'KH_170223170911', '2', '5', '山西省太原市迎泽区', '山西省', '太原市', '迎泽区', '1', '1', '1', '啥的按时打', '马薇薇', '0', '29', '经理', '87180191019', '9109189', '01089', '1098', '1089', '1487840984', '超级管理员', '0', '超级管理员', '执照不清晰');
INSERT INTO `customer` VALUES ('4', '测试散户审核', 'CeShiSanHuShenHe', 'KH_170306103014', '3', '4', '山西省太原市迎泽区', '山西省', '太原市', '迎泽区', '1', '1', '3', '12', '13', '1', '123', '132', '132', '132', '123', '13', '123', '1488767434', '超级管理员', '0', '', '');
INSERT INTO `customer` VALUES ('5', '', '', 'KH_170308151124', '2', '5', '山西省太原市迎泽区', '山西省', '太原市', '迎泽区', '1', '1', '2', '', '', '1', '', '', '', '', '', '', '', '1488957107', '超级管理员', '1', '', '');

-- ----------------------------
-- Table structure for customer_credit_rating
-- ----------------------------
DROP TABLE IF EXISTS `customer_credit_rating`;
CREATE TABLE `customer_credit_rating` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `level` tinyint(1) NOT NULL DEFAULT '0' COMMENT '信用等级',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '额度',
  `add_time` varchar(100) NOT NULL DEFAULT '' COMMENT '添加时间',
  `author_user` varchar(20) NOT NULL DEFAULT '' COMMENT '添加人',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='客户->信用等级';

-- ----------------------------
-- Records of customer_credit_rating
-- ----------------------------
INSERT INTO `customer_credit_rating` VALUES ('1', '1', '1000', '1487066039', '超级管理员');
INSERT INTO `customer_credit_rating` VALUES ('2', '2', '2000', '1487066076', '超级管理员');
INSERT INTO `customer_credit_rating` VALUES ('3', '3', '5000', '1487066315', '超级管理员');
INSERT INTO `customer_credit_rating` VALUES ('4', '10', '10000', '1487123086', '超级管理员');

-- ----------------------------
-- Table structure for customer_from
-- ----------------------------
DROP TABLE IF EXISTS `customer_from`;
CREATE TABLE `customer_from` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '来源名称',
  `add_time` varchar(100) NOT NULL DEFAULT '' COMMENT '添加时间',
  `author_user` varchar(20) NOT NULL DEFAULT '' COMMENT '添加人',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='客户来源设置';

-- ----------------------------
-- Records of customer_from
-- ----------------------------
INSERT INTO `customer_from` VALUES ('1', '陌生开发', '1487059186', '超级管理员');
INSERT INTO `customer_from` VALUES ('2', '网站注册', '1487059197', '超级管理员');
INSERT INTO `customer_from` VALUES ('3', '朋友介绍', '1487059202', '超级管理员');
INSERT INTO `customer_from` VALUES ('4', '广告宣传', '1487059214', '超级管理员');
INSERT INTO `customer_from` VALUES ('5', '营销活动', '1487059221', '超级管理员');

-- ----------------------------
-- Table structure for customer_industry
-- ----------------------------
DROP TABLE IF EXISTS `customer_industry`;
CREATE TABLE `customer_industry` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '行业名称',
  `add_time` varchar(100) NOT NULL DEFAULT '' COMMENT '添加时间',
  `author_user` varchar(20) NOT NULL DEFAULT '' COMMENT '添加人',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COMMENT='客户行业';

-- ----------------------------
-- Records of customer_industry
-- ----------------------------
INSERT INTO `customer_industry` VALUES ('1', '零售', '1487053008', '超级管理员');
INSERT INTO `customer_industry` VALUES ('2', '电子类产品', '1487053022', '超级管理员');
INSERT INTO `customer_industry` VALUES ('4', '学校类客户', '1487123144', '超级管理员');
INSERT INTO `customer_industry` VALUES ('5', '电子类&gt;监控类', '1487123206', '超级管理员');
INSERT INTO `customer_industry` VALUES ('6', '电子类&gt;耗材类', '1487123214', '超级管理员');

-- ----------------------------
-- Table structure for customer_service
-- ----------------------------
DROP TABLE IF EXISTS `customer_service`;
CREATE TABLE `customer_service` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `service_number` varchar(255) NOT NULL DEFAULT '' COMMENT '售后编号',
  `customer_name` varchar(255) NOT NULL DEFAULT '' COMMENT '客户名称',
  `ywy` varchar(255) NOT NULL DEFAULT '' COMMENT '业务员',
  `pro_number` varchar(255) NOT NULL DEFAULT '' COMMENT '产品型号',
  `serial_number` varchar(255) NOT NULL DEFAULT '' COMMENT '序列号',
  `problem` text NOT NULL COMMENT '问题概述',
  `opinion` varchar(255) NOT NULL DEFAULT '' COMMENT '初检意见',
  `maintenance_costs` bigint(10) NOT NULL DEFAULT '0' COMMENT '维修费用',
  `add_time` varchar(100) NOT NULL DEFAULT '' COMMENT '添加时间',
  `add_author` varchar(20) NOT NULL DEFAULT '' COMMENT '添加人',
  `status` smallint(1) DEFAULT '0' COMMENT '维修状态 0为维修中 1为维修完成 2为审核中',
  `result` text NOT NULL COMMENT '维修结果',
  `consignee` varchar(20) NOT NULL DEFAULT '' COMMENT '提货人',
  `c_time` varchar(100) NOT NULL DEFAULT '' COMMENT '提货时间',
  `other` text NOT NULL COMMENT '备注',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COMMENT='售后服务';

-- ----------------------------
-- Records of customer_service
-- ----------------------------
INSERT INTO `customer_service` VALUES ('7', 'SH_1703091', '测试客户名称', '程静昀', 'DH-NVR-2014HS-V4', '3651-65056-05610-A0565', '无法开机', '主板损坏', '420', '1489050884', '超级管理员', '1', '送大华售后', '超级管理员', '1489051180', '无');

-- ----------------------------
-- Table structure for department
-- ----------------------------
DROP TABLE IF EXISTS `department`;
CREATE TABLE `department` (
  `catid` int(11) NOT NULL AUTO_INCREMENT,
  `pid` int(11) NOT NULL DEFAULT '0' COMMENT '父类id',
  `catname` varchar(20) NOT NULL DEFAULT '',
  `add_time` int(10) NOT NULL DEFAULT '0',
  `add_name` varchar(255) NOT NULL DEFAULT '' COMMENT '添加人',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '1正常 0非正常',
  PRIMARY KEY (`catid`)
) ENGINE=MyISAM AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COMMENT='部门表';

-- ----------------------------
-- Records of department
-- ----------------------------
INSERT INTO `department` VALUES ('1', '0', '总经办', '1486967978', '超级管理员', '1');
INSERT INTO `department` VALUES ('2', '1', '财务', '1486967994', '超级管理员', '1');
INSERT INTO `department` VALUES ('3', '1', '1-2部门', '1486968008', '超级管理员', '1');
INSERT INTO `department` VALUES ('4', '0', '销售部', '1486968024', '超级管理员', '1');
INSERT INTO `department` VALUES ('5', '4', '顶级销售小组', '1486968035', '超级管理员', '1');
INSERT INTO `department` VALUES ('8', '0', '3级部门', '1486969285', '超级管理员', '1');
INSERT INTO `department` VALUES ('9', '8', '3--1', '1486969296', '超级管理员', '1');
INSERT INTO `department` VALUES ('11', '4', '2--2', '1486969318', '超级管理员', '1');
INSERT INTO `department` VALUES ('15', '0', '部门', '1486975769', '贾磊', '1');
INSERT INTO `department` VALUES ('18', '15', '测试删除弹窗', '1487209426', '超级管理员', '1');
INSERT INTO `department` VALUES ('20', '15', '测试弹窗', '1487209459', '超级管理员', '1');
INSERT INTO `department` VALUES ('21', '15', '5555', '1487743257', '超级管理员', '1');

-- ----------------------------
-- Table structure for express
-- ----------------------------
DROP TABLE IF EXISTS `express`;
CREATE TABLE `express` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `express_name` varchar(100) NOT NULL DEFAULT '' COMMENT '物流公司名称',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态 1开启 0关闭',
  `add_time` varchar(100) NOT NULL DEFAULT '' COMMENT '添加时间',
  `author_user` varchar(20) NOT NULL DEFAULT '' COMMENT '添加人',
  `other` varchar(255) NOT NULL DEFAULT '无' COMMENT '备注',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='物流';

-- ----------------------------
-- Records of express
-- ----------------------------
INSERT INTO `express` VALUES ('1', '德邦物流', '1', '1486793862', '超级管理员', '');
INSERT INTO `express` VALUES ('2', '老鸿运物流', '1', '1486793899', '超级管理员', '');

-- ----------------------------
-- Table structure for gys
-- ----------------------------
DROP TABLE IF EXISTS `gys`;
CREATE TABLE `gys` (
  `gys_id` int(11) NOT NULL AUTO_INCREMENT,
  `gys_bianhao` varchar(255) NOT NULL DEFAULT '' COMMENT '供应商编号',
  `gys_name` varchar(255) NOT NULL DEFAULT '' COMMENT '供应商名称',
  `gys_pinyinma` varchar(255) NOT NULL DEFAULT '' COMMENT '拼音码',
  `gys_fenlei` varchar(255) NOT NULL DEFAULT '' COMMENT '供应商类型',
  `gys_jibie` varchar(255) NOT NULL DEFAULT '' COMMENT '供应商级别',
  `gys_szhy` varchar(255) NOT NULL DEFAULT '' COMMENT '供应商所在行业',
  `gys_diqu` varchar(255) NOT NULL DEFAULT '' COMMENT '地　　区',
  `gys_zizh` tinyint(3) NOT NULL DEFAULT '0' COMMENT '是否需要资质',
  `gys_is_taxpayer` tinyint(3) NOT NULL DEFAULT '0' COMMENT '是否一般纳税人',
  `gys_address` varchar(255) NOT NULL DEFAULT '' COMMENT '供应商地址',
  `gys_youbian` varchar(255) NOT NULL DEFAULT '' COMMENT '邮编',
  `gys_faren` varchar(20) NOT NULL DEFAULT '' COMMENT '法人代表',
  `gys_zuceziben` varchar(255) NOT NULL DEFAULT '' COMMENT '注册资本',
  `gys_web` varchar(255) NOT NULL DEFAULT '' COMMENT '供应商网址',
  `gys_zsbh` varchar(255) NOT NULL DEFAULT '' COMMENT '证书编号',
  `gys_dengjsj` varchar(255) NOT NULL DEFAULT '' COMMENT '登记时间',
  `gys_dengjijg` varchar(255) NOT NULL DEFAULT '' COMMENT '登记机关',
  `gys_fz_time` varchar(255) NOT NULL DEFAULT '' COMMENT '发证时间',
  `gys_zsyx_time` varchar(255) NOT NULL DEFAULT '' COMMENT '证书有效期日期',
  `gys_tx_people` varchar(255) NOT NULL DEFAULT '' COMMENT '提醒人',
  `gys_lianxiren` varchar(255) NOT NULL DEFAULT '' COMMENT '联 系 人',
  `gys_sex` tinyint(3) NOT NULL DEFAULT '0' COMMENT '1男0女',
  `gys_age` varchar(255) NOT NULL DEFAULT '' COMMENT '年龄',
  `gys_zhiwu` varchar(255) NOT NULL DEFAULT '' COMMENT '职务',
  `gys_tel` varchar(255) NOT NULL DEFAULT '' COMMENT '联系人电话',
  `gys_mobil` varchar(255) NOT NULL DEFAULT '' COMMENT '办公电话',
  `gys_mail` varchar(255) NOT NULL DEFAULT '' COMMENT '邮箱',
  `gys_qq` varchar(255) NOT NULL DEFAULT '' COMMENT 'qq',
  `gys_weixin` varchar(255) NOT NULL DEFAULT '' COMMENT '微信',
  `gys_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1正常0否',
  `gys_time` int(11) NOT NULL DEFAULT '0' COMMENT '添加时间',
  PRIMARY KEY (`gys_id`)
) ENGINE=MyISAM AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COMMENT='供应商表';

-- ----------------------------
-- Records of gys
-- ----------------------------
INSERT INTO `gys` VALUES ('15', 'GYS_170218142812', '大盘鸡', 'DaPanJi', '', '一级代理', '电子-&gt;电脑', '山西省太原市迎泽区', '0', '0', '小店', '030000', '小虎子', '20000', 'www.dapanji.com', '123456789', '2017-02-20', '太原交警大队', '2017-02-24', '2017-02-23', '超级管理员', '小毛驴', '1', '15', '经理', '15832568564', '0300-555 999', 'www.xiaohubianli.com', '589565878', '123456789', '0', '1488162148');
INSERT INTO `gys` VALUES ('18', 'GYS_170221103947', '麻辣拌', 'MaLaBan', '', '一级代理', '电子-&gt;电脑', '山西省太原市迎泽区', '1', '1', '重庆麻辣拌', '056666', '小红', '20000', 'www.malaban.com', '0452485855', '2017-02-21', '56156', '2017-02-21', '2017-02-21', '超级管理员', '小江', '1', '25', '阿斯顿', '12123213213', '06555-565661', '65161651', '6516165156', '61616161161', '0', '1488159258');
INSERT INTO `gys` VALUES ('30', 'GYS_170225163102', '测试修改代码是', 'CeShiXiuGaiDaiMaShi', '', '一级代理', '电子-&gt;电脑', '山西省太原市迎泽区', '1', '1', '测试修改；代码', '测试修改；代码', '测试修改；代码', '测试修改；代码', '测试修改；代码', '测试修改；代码是', '2017-02-06', '测试修改；代码', '2017-02-15', '2017-02-15', '超级管理员', '测试修改；代码是', '1', '测试修改；代码是', '测试修改；代码', '测试修改；代码', '测试修改；代码', '测试修改；代码', '测试修改；代码', '测试修改；代码', '0', '1488013986');

-- ----------------------------
-- Table structure for gys_dj
-- ----------------------------
DROP TABLE IF EXISTS `gys_dj`;
CREATE TABLE `gys_dj` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '等级名称',
  `add_time` varchar(100) NOT NULL DEFAULT '' COMMENT '添加时间',
  `author_user` varchar(20) NOT NULL DEFAULT '' COMMENT '添加人',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='供应商等级';

-- ----------------------------
-- Records of gys_dj
-- ----------------------------
INSERT INTO `gys_dj` VALUES ('1', '一级代理', '1487655091', '超级管理员');
INSERT INTO `gys_dj` VALUES ('2', '二级代理', '1487655108', '超级管理员');
INSERT INTO `gys_dj` VALUES ('3', '三级供应商', '1487655141', '超级管理员');
INSERT INTO `gys_dj` VALUES ('4', '四级供应商', '1487655149', '超级管理员');
INSERT INTO `gys_dj` VALUES ('5', '五级供应商', '1488007176', '超级管理员');

-- ----------------------------
-- Table structure for gys_fl
-- ----------------------------
DROP TABLE IF EXISTS `gys_fl`;
CREATE TABLE `gys_fl` (
  `gys_fl_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '供应商分类',
  `gys_fl_name` varchar(50) NOT NULL DEFAULT '' COMMENT '分类名称',
  PRIMARY KEY (`gys_fl_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='供应商分类表';

-- ----------------------------
-- Records of gys_fl
-- ----------------------------

-- ----------------------------
-- Table structure for gys_hy
-- ----------------------------
DROP TABLE IF EXISTS `gys_hy`;
CREATE TABLE `gys_hy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '来源名称',
  `add_time` varchar(100) NOT NULL DEFAULT '' COMMENT '添加时间',
  `author_user` varchar(20) NOT NULL DEFAULT '' COMMENT '添加人',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COMMENT='供应商行业表';

-- ----------------------------
-- Records of gys_hy
-- ----------------------------
INSERT INTO `gys_hy` VALUES ('4', '电子-&gt;电脑', '1487653115', '超级管理员');
INSERT INTO `gys_hy` VALUES ('9', '电脑器材-&gt;计算机硬盘', '1487654221', '超级管理员');
INSERT INTO `gys_hy` VALUES ('10', '安防-&gt;监控', '1487655763', '超级管理员');

-- ----------------------------
-- Table structure for gys_jb
-- ----------------------------
DROP TABLE IF EXISTS `gys_jb`;
CREATE TABLE `gys_jb` (
  `gys_jb_id` int(11) NOT NULL AUTO_INCREMENT,
  `gys_jb_name` varchar(255) NOT NULL DEFAULT '' COMMENT '级别名',
  PRIMARY KEY (`gys_jb_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='供应商级别';

-- ----------------------------
-- Records of gys_jb
-- ----------------------------
INSERT INTO `gys_jb` VALUES ('1', '厂家');
INSERT INTO `gys_jb` VALUES ('2', '省级');
INSERT INTO `gys_jb` VALUES ('3', '县级');
INSERT INTO `gys_jb` VALUES ('4', '同行业');

-- ----------------------------
-- Table structure for gys_pro
-- ----------------------------
DROP TABLE IF EXISTS `gys_pro`;
CREATE TABLE `gys_pro` (
  `pro_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `pro_gys_id` varchar(255) NOT NULL DEFAULT '' COMMENT '关联供应商id',
  `pro_gys_number` varchar(255) NOT NULL DEFAULT '' COMMENT '关联供应商编号',
  `pro_gys_name` varchar(255) NOT NULL DEFAULT '' COMMENT '关联供应商名称',
  `pro_name` varchar(255) NOT NULL DEFAULT '' COMMENT '产品名称',
  `pro_pinyinma` varchar(255) NOT NULL DEFAULT '' COMMENT '产品拼音码',
  `pro_number` varchar(255) NOT NULL DEFAULT '' COMMENT '产品编号',
  `pro_fl` varchar(255) NOT NULL DEFAULT '' COMMENT '产品分类',
  `pro_type` varchar(255) NOT NULL DEFAULT '' COMMENT '产品型号',
  `pro_unit` varchar(10) NOT NULL DEFAULT '' COMMENT '产品单位',
  `pro_pack` varchar(50) NOT NULL DEFAULT '' COMMENT '产品包装方式',
  `pro_price` varchar(255) NOT NULL DEFAULT '' COMMENT '产品进价',
  `pro_jy_price` varchar(255) NOT NULL DEFAULT '0' COMMENT '产品建议售价',
  `pro_zd_price` varchar(255) NOT NULL DEFAULT '0' COMMENT '产品最低售价',
  `pro_jy_profit` varchar(255) NOT NULL DEFAULT '0' COMMENT '建议售价利润',
  `pro_zd_profit` varchar(255) NOT NULL DEFAULT '0' COMMENT '最低售价利润',
  `pro_tcbl` varchar(10) NOT NULL DEFAULT '' COMMENT '产品提成比例',
  `pro_sm` text NOT NULL COMMENT '产品说明',
  `pro_picture` varchar(255) NOT NULL DEFAULT '' COMMENT '产品图上传',
  `pro_add_name` varchar(255) NOT NULL DEFAULT '' COMMENT '产品添加人',
  `pro_time` varchar(255) NOT NULL DEFAULT '' COMMENT '添加时间',
  `pro_status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '1正常0否',
  `pro_beizhu` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`pro_id`)
) ENGINE=MyISAM AUTO_INCREMENT=37 DEFAULT CHARSET=utf8 COMMENT='供应商产品表';

-- ----------------------------
-- Records of gys_pro
-- ----------------------------
INSERT INTO `gys_pro` VALUES ('21', '15', 'GYS_170218142812', '大盘鸡', '测试修改名称', 'CeShiXiuGaiMingChen', 'Pro_170223172340', '3', '测试修改型号', '箱', '塑料瓶装', '100', '200', '300', '100', '200', '50', '																																																																																																																																																																																																																												测试修改产品说明																																																																																																																																																																																																																																															', '/office/Uploads/pro_picture/2017-03-02/Pro_170223172340_618042399.png', '超级管理员', '1488440004', '1', '																																																																																																																																																																																																																												测试修改备注																													');
INSERT INTO `gys_pro` VALUES ('29', '18', 'GYS_170221103947', '麻辣拌', '大华四路同轴录像机', 'DaHuaSiLuTongZhouLuXiangJi', 'Pro_170227112034', '5', 'DH-NVR-1104HS-W', '个', '真空包装', '100', '200', '150', '100', '50', '10', '																																																							测试添加产品说明																																																																	', '/office/Uploads/pro_picture/2017-03-02/Pro_170227112034_1185710715.png', '超级管理员', '1488427099', '1', '																																																							测试产品备注																																																																');
INSERT INTO `gys_pro` VALUES ('36', '15', 'GYS_170218142812', '大盘鸡', '按时', 'AnShi', 'Pro_170302103954', '1', '', '个', '纸箱包装', '0', '0', '0', '0', '0', '10', '											', '', '超级管理员', '1488422397', '1', '											');

-- ----------------------------
-- Table structure for gys_zz
-- ----------------------------
DROP TABLE IF EXISTS `gys_zz`;
CREATE TABLE `gys_zz` (
  `gys_zz_id` int(11) NOT NULL AUTO_INCREMENT,
  `zz_status` tinyint(3) NOT NULL DEFAULT '1' COMMENT '1要资质0否',
  PRIMARY KEY (`gys_zz_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='管理员资质';

-- ----------------------------
-- Records of gys_zz
-- ----------------------------
INSERT INTO `gys_zz` VALUES ('1', '1');

-- ----------------------------
-- Table structure for license
-- ----------------------------
DROP TABLE IF EXISTS `license`;
CREATE TABLE `license` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `certificate_number` varchar(100) NOT NULL DEFAULT '' COMMENT '证书编号',
  `start_date` varchar(100) NOT NULL DEFAULT '' COMMENT '发证日期',
  `end_date` varchar(100) NOT NULL DEFAULT '' COMMENT '有效日期',
  `legal_representative` varchar(15) NOT NULL DEFAULT '' COMMENT '法定代理人',
  `registered_capital` varchar(10) NOT NULL DEFAULT '' COMMENT '注册资本',
  `images` varchar(255) NOT NULL DEFAULT '' COMMENT '图片路径',
  `add_author` varchar(30) NOT NULL DEFAULT '' COMMENT '添加人',
  `customer_number` varchar(255) NOT NULL DEFAULT '' COMMENT '客户编号->customer',
  `general_taxpayer` varchar(255) NOT NULL DEFAULT '' COMMENT '一般纳税人',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='客户营业执照信息表';

-- ----------------------------
-- Records of license
-- ----------------------------
INSERT INTO `license` VALUES ('5', '01123123', '2017-02-23', '2017-02-14', '吴秀波', '300万', '/office/Uploads/2017-03-06/KH_170223170800_506586813.jpg', '超级管理员', 'KH_170223170800', '1');

-- ----------------------------
-- Table structure for negotiation_progress
-- ----------------------------
DROP TABLE IF EXISTS `negotiation_progress`;
CREATE TABLE `negotiation_progress` (
  `id_np` int(11) NOT NULL AUTO_INCREMENT,
  `customer_number_np` varchar(255) NOT NULL DEFAULT '' COMMENT '客户编号',
  `title` varchar(255) NOT NULL DEFAULT '' COMMENT '洽谈标题',
  `content` text NOT NULL COMMENT '内容',
  `author_user_np` varchar(50) NOT NULL DEFAULT '' COMMENT '添加人',
  `add_time_np` varchar(15) NOT NULL DEFAULT '' COMMENT '添加时间',
  PRIMARY KEY (`id_np`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='洽谈进展';

-- ----------------------------
-- Records of negotiation_progress
-- ----------------------------

-- ----------------------------
-- Table structure for nsr
-- ----------------------------
DROP TABLE IF EXISTS `nsr`;
CREATE TABLE `nsr` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_name` varchar(255) NOT NULL DEFAULT '' COMMENT '公司全称',
  `company_address` varchar(255) NOT NULL DEFAULT '' COMMENT '公司地址',
  `representative` varchar(255) NOT NULL DEFAULT '' COMMENT '法人代表',
  `company_phone` varchar(255) NOT NULL DEFAULT '' COMMENT '公司电话',
  `tax_identification_number` varchar(255) NOT NULL DEFAULT '' COMMENT '统一社会信用代码',
  `bank_account` varchar(255) NOT NULL DEFAULT '' COMMENT '开户银行',
  `bank_number` varchar(255) NOT NULL DEFAULT '' COMMENT '银行账号',
  `customer_number` varchar(255) NOT NULL DEFAULT '' COMMENT '客户编号',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='纳税人信息';

-- ----------------------------
-- Records of nsr
-- ----------------------------
INSERT INTO `nsr` VALUES ('4', '测试公司名', '胸襟晒摩地哦啊什么', '吴秀波', '0351-8783337', '01', '农业', '460418960150621', 'KH_170223170800');

-- ----------------------------
-- Table structure for order
-- ----------------------------
DROP TABLE IF EXISTS `order`;
CREATE TABLE `order` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '',
  `number` varchar(255) NOT NULL DEFAULT '',
  `date` varchar(50) NOT NULL DEFAULT '0',
  `city` varchar(50) NOT NULL DEFAULT '',
  `head` varchar(20) NOT NULL DEFAULT '' COMMENT '负责人',
  `currency` varchar(20) NOT NULL DEFAULT '' COMMENT '货币',
  `amount` varchar(20) NOT NULL DEFAULT '' COMMENT '项目总额',
  `preferential` int(10) NOT NULL DEFAULT '0' COMMENT '1   为优惠金额  0 折扣',
  `money` varchar(30) NOT NULL DEFAULT '' COMMENT '优惠后的总价',
  `class` varchar(255) NOT NULL DEFAULT '' COMMENT '项目分类',
  `process` varchar(255) NOT NULL DEFAULT '' COMMENT '项目流程',
  `phase` varchar(20) NOT NULL DEFAULT '' COMMENT '项目阶段',
  `source` varchar(20) NOT NULL DEFAULT '' COMMENT '来源',
  `status` int(11) NOT NULL DEFAULT '1' COMMENT '1 正常 0 异常       项目状态',
  `price` int(11) NOT NULL DEFAULT '0' COMMENT '预计金钱',
  `time` int(11) NOT NULL DEFAULT '0' COMMENT '预计日期',
  `parter` int(11) NOT NULL DEFAULT '0' COMMENT '0  有    1  无',
  `parter_name` varchar(20) NOT NULL DEFAULT '' COMMENT '合作名称',
  `jiafei` varchar(20) NOT NULL DEFAULT '' COMMENT '预计甲方费用',
  `contact_id` int(11) NOT NULL DEFAULT '0' COMMENT '关联客户联系人',
  `product_id` int(11) NOT NULL DEFAULT '0' COMMENT '产品明细',
  `content` varchar(255) NOT NULL DEFAULT '' COMMENT '项目摘要',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of order
-- ----------------------------

-- ----------------------------
-- Table structure for pro_fl
-- ----------------------------
DROP TABLE IF EXISTS `pro_fl`;
CREATE TABLE `pro_fl` (
  `catid` int(11) NOT NULL AUTO_INCREMENT,
  `pid` int(11) NOT NULL DEFAULT '0' COMMENT '父类id',
  `catname` varchar(20) NOT NULL DEFAULT '',
  `add_time` int(10) NOT NULL DEFAULT '0',
  `add_name` varchar(255) NOT NULL DEFAULT '' COMMENT '添加人',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '1正常 0非正常',
  PRIMARY KEY (`catid`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COMMENT='产品分类';

-- ----------------------------
-- Records of pro_fl
-- ----------------------------
INSERT INTO `pro_fl` VALUES ('1', '0', '大华', '1487742729', '超级管理员', '1');
INSERT INTO `pro_fl` VALUES ('2', '1', '乐橙系列', '1487742784', '超级管理员', '1');
INSERT INTO `pro_fl` VALUES ('3', '1', '乐橙小分队', '1487747084', '贾磊', '1');
INSERT INTO `pro_fl` VALUES ('4', '0', '主板', '1487747103', '贾磊', '1');
INSERT INTO `pro_fl` VALUES ('5', '4', 'htc9620系列', '1487747119', '贾磊', '1');
INSERT INTO `pro_fl` VALUES ('6', '4', 'HTC9800系列', '1487747141', '贾磊', '1');

-- ----------------------------
-- Table structure for pro_pack
-- ----------------------------
DROP TABLE IF EXISTS `pro_pack`;
CREATE TABLE `pro_pack` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '单位名称',
  `add_time` varchar(100) NOT NULL DEFAULT '' COMMENT '添加时间',
  `author_user` varchar(20) NOT NULL DEFAULT '' COMMENT '添加人',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='产品单位';

-- ----------------------------
-- Records of pro_pack
-- ----------------------------
INSERT INTO `pro_pack` VALUES ('1', '纸箱包装', '1488525390', '超级管理员', '1');
INSERT INTO `pro_pack` VALUES ('2', '塑料瓶装', '1488525432', '超级管理员', '1');
INSERT INTO `pro_pack` VALUES ('3', '真空包装', '1488525443', '超级管理员', '1');

-- ----------------------------
-- Table structure for pro_unit
-- ----------------------------
DROP TABLE IF EXISTS `pro_unit`;
CREATE TABLE `pro_unit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '单位名称',
  `add_time` varchar(100) NOT NULL DEFAULT '' COMMENT '添加时间',
  `author_user` varchar(20) NOT NULL DEFAULT '' COMMENT '添加人',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COMMENT='产品单位';

-- ----------------------------
-- Records of pro_unit
-- ----------------------------
INSERT INTO `pro_unit` VALUES ('1', '个', '1487733339', '超级管理员', '1');
INSERT INTO `pro_unit` VALUES ('2', '元', '1487732466', '超级管理员', '1');
INSERT INTO `pro_unit` VALUES ('3', '包', '1487733398', '超级管理员', '0');
INSERT INTO `pro_unit` VALUES ('4', '太', '1487733428', '超级管理员', '1');
INSERT INTO `pro_unit` VALUES ('5', '块', '1487733439', '超级管理员', '0');
INSERT INTO `pro_unit` VALUES ('6', '套', '1487733453', '超级管理员', '1');
INSERT INTO `pro_unit` VALUES ('7', '袋', '1487733462', '超级管理员', '1');
INSERT INTO `pro_unit` VALUES ('8', '米', '1487733466', '超级管理员', '0');
INSERT INTO `pro_unit` VALUES ('9', '箱', '1487733490', '超级管理员', '1');
INSERT INTO `pro_unit` VALUES ('10', '件', '1487733515', '超级管理员', '1');

-- ----------------------------
-- Table structure for stock
-- ----------------------------
DROP TABLE IF EXISTS `stock`;
CREATE TABLE `stock` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stock_pro_id` int(11) NOT NULL DEFAULT '0' COMMENT '关联入库产品id',
  `stock_buy_id` int(11) NOT NULL DEFAULT '0' COMMENT '关联采购id',
  `stock_number` varchar(255) NOT NULL DEFAULT '' COMMENT '库存数量',
  `stock_yd_number` varchar(255) NOT NULL DEFAULT '' COMMENT '预定数量',
  `stock_inway_number` varchar(255) NOT NULL DEFAULT '' COMMENT '在途数量',
  `stock_ky_number` varchar(255) NOT NULL DEFAULT '' COMMENT '可用数量',
  `stock_cost_total` varchar(255) NOT NULL DEFAULT '' COMMENT '成本总价',
  `stock_dj_number` varchar(255) NOT NULL DEFAULT '' COMMENT '冻结数量',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '0冻结1未冻结',
  `add_time` varchar(100) NOT NULL DEFAULT '' COMMENT '入库时间',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='库存表';

-- ----------------------------
-- Records of stock
-- ----------------------------

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '员工数据库ID',
  `username` varchar(60) NOT NULL DEFAULT '' COMMENT '员工用户名',
  `address` text NOT NULL COMMENT '员工地址',
  `card_id` bigint(18) NOT NULL DEFAULT '0' COMMENT '身份证号',
  `join_time` varchar(100) NOT NULL DEFAULT '' COMMENT '入职时间',
  `department` varchar(10) NOT NULL DEFAULT '' COMMENT '所属部门',
  `sex` smallint(1) NOT NULL DEFAULT '0' COMMENT '员工性别 默认女 0 男 1',
  `from` varchar(10) NOT NULL DEFAULT '' COMMENT '籍贯',
  `education` varchar(10) NOT NULL DEFAULT '' COMMENT '学历',
  `major` varchar(100) NOT NULL DEFAULT '' COMMENT '专业',
  `other` varchar(170) NOT NULL DEFAULT '无' COMMENT '备注',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 COMMENT='用户数据表';

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('1', 'admin', '山西省太原市财大北校', '140106199206101216', '2017-01-01', '1', '1', '山西太原', '大专', '弱电工程', '无');
INSERT INTO `user` VALUES ('2', '001', '山西省太原市迎泽公园', '140106199206101216', '2017-02-01', '2', '1', '山西太原', '大专', '家里蹲', '无');
INSERT INTO `user` VALUES ('8', '003', '11111111111', '111111111111111111', '2017-01-04', '5', '0', '123', '123', '123', '');
INSERT INTO `user` VALUES ('9', '004', '山西省太原市财大北校', '123456', '2017-02-10', '8', '0', '', '', '', '');
INSERT INTO `user` VALUES ('10', '006', '山西省太原市迎泽区', '0', '2017-02-13', '11', '0', '', '', '', '无');
INSERT INTO `user` VALUES ('17', '009', '123456789', '123456789', '2016-02-11', '2', '0', '山西省太原市', '大专', '会计', '');
